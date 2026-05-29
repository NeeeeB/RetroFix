unit RetrobatBrowser;

interface

uses
   System.SysUtils, System.Classes, System.Generics.Collections, System.Math,
   System.JSON, System.Types, System.UITypes, System.Threading,
   Vcl.Forms, Vcl.Controls, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ControlList,
   Vcl.Graphics, Vcl.Skia, System.Skia,
   ESApi, Constantes, Types;

const
   NB_COLS = 4; // Notre hack multi-colonnes cible 4 éléments par ligne

type
   TfrmRetrobatBrowser = class( TForm )
      pnlTop: TPanel;
      lblBreadcrumb: TLabel;
      btnBack: TButton;
      ControlList1: TControlList;
      imgCol0: TImage;
      lblCol0: TLabel;
      imgCol1: TImage;
      lblCol1: TLabel;
      imgCol2: TImage;
      lblCol2: TLabel;
      imgCol3: TImage;
      lblCol3: TLabel;
      procedure FormCreate( Sender: TObject );
      procedure FormDestroy( Sender: TObject );
      procedure FormShow( Sender: TObject );
      procedure ControlList1BeforeDrawItem( AIndex: Integer; ACanvas: TCanvas;
                                            ARect: TRect; AState: TOwnerDrawState );
      procedure OnGameClick( Sender: TObject );
      procedure btnBackClick( Sender: TObject );
    procedure ControlList1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ControlList1MouseLeave(Sender: TObject);
   private
      FSettings: TSettings;
      FItems: TJSONArray;
      FCurrentSystem: string;

      // Liste des images en cours de téléchargement pour éviter les doublons de requêtes
      FDownloadingKeys: THashSet<string>;

      // Cache VCL local compatible avec TImage standard
      FImageCache: TObjectDictionary<string, TBitmap>;

      // Tableaux pratiques pour mapper nos composants du ControlList
      FImages: array[0..NB_COLS-1] of TImage;
      FLabels: array[0..NB_COLS-1] of TLabel;

      procedure clearAll;
      procedure loadSystems;
      procedure loadGames( const aSystem: string );
      procedure loadImageAsync( const aKey, aSystem, aGameId: string; aIsSystem: Boolean; aRowIndex: Integer );
      function getItemKey( aIndex: Integer ): string;
      procedure UpdateControlListCount;
   public
      procedure init( aSettings: TSettings );
   end;

implementation

uses
   Vcl.Dialogs,
   System.StrUtils;

{$R *.dfm}

procedure TfrmRetrobatBrowser.FormCreate( Sender: TObject );
begin
   FImageCache     := TObjectDictionary<string, TBitmap>.Create( [doOwnsValues] );
   FDownloadingKeys:= THashSet<string>.Create;

   // On mappe nos composants pour pouvoir faire des boucles dessus
   FImages[0] := imgCol0; FImages[1] := imgCol1; FImages[2] := imgCol2; FImages[3] := imgCol3;
   FLabels[0] := lblCol0; FLabels[1] := lblCol1; FLabels[2] := lblCol2; FLabels[3] := lblCol3;
end;

procedure TfrmRetrobatBrowser.FormDestroy( Sender: TObject );
begin
   clearAll;
   FImageCache.Free;
   FDownloadingKeys.Free;
end;

procedure TfrmRetrobatBrowser.FormShow( Sender: TObject );
begin
   loadSystems;
end;

procedure TfrmRetrobatBrowser.init( aSettings: TSettings );
begin
   FSettings:= aSettings;
end;

procedure TfrmRetrobatBrowser.clearAll;
begin
   FreeAndNil( FItems );
   FImageCache.Clear;
   FDownloadingKeys.Clear;
   ControlList1.ItemCount := 0;
end;

function TfrmRetrobatBrowser.getItemKey( aIndex: Integer ): string;
begin
   Result:= '';
   if ( FItems = nil ) or ( aIndex >= FItems.Count ) then Exit;
   var _obj:= FItems.Items[aIndex] as TJSONObject;
   Result:= _obj.GetValue<string>( 'id', '' );
   if ( Result.IsEmpty ) then
      Result:= _obj.GetValue<string>( 'name', '' );
end;

procedure TfrmRetrobatBrowser.UpdateControlListCount;
begin
   if FItems = nil then
      ControlList1.ItemCount := 0
   else
      // Hack multi-colonne : s'il y a 11 jeux, 11/4 = 2.75 -> Il faut 3 lignes
      ControlList1.ItemCount := Ceil( FItems.Count / NB_COLS );
end;

// C'est ici que la magie virtuelle opère par ligne
procedure TfrmRetrobatBrowser.ControlList1BeforeDrawItem( AIndex: Integer;
  ACanvas: TCanvas; ARect: TRect; AState: TOwnerDrawState );
var
  iCol, iGlobalIndex: Integer;
  _item: TJSONObject;
  _name, _key: string;
  _bmp: TBitmap;
  _mousePos: TPoint;
  _localImgRect: TRect;
begin
   // Récupération de la position de la souris relative au ControlList
   // On récupère la position de la souris relative à l'ÉLÉMENT SURVOLÉ, et pas à la grille globale
//   _mousePos := ControlList1.ScreenToClient(Mouse.CursorPos);
//   if ControlList1.HotItemIndex >= 0 then
//      // On retire le décalage de défilement de la ligne pour tomber pile en face
//      _mousePos.Y := _mousePos.Y - (ControlList1.HotItemIndex * ControlList1.ItemHeight);

   // AIndex représente le numéro de la ligne courante du TControlList
   for iCol := 0 to NB_COLS - 1 do begin
      iGlobalIndex := ( AIndex * NB_COLS ) + iCol;

      if iGlobalIndex >= FItems.Count then begin
         FImages[iCol].Visible := False;
         FLabels[iCol].Visible := False;
         Continue;
      end;

      FImages[iCol].Visible := True;
      FLabels[iCol].Visible := True;

      _item := FItems.Items[iGlobalIndex] as TJSONObject;
      _name := _item.GetValue<string>( 'name', '' );
      _key  := getItemKey( iGlobalIndex );

      FLabels[iCol].Caption := _name;

      // Gestion de l'image via le cache
      if FImageCache.TryGetValue( _key, _bmp ) then begin
         FImages[iCol].Picture.Bitmap := _bmp;
      end else begin
         FImages[iCol].Picture := nil;

         if not FDownloadingKeys.Contains( _key ) then begin
            FDownloadingKeys.Add( _key );
            loadImageAsync( _key,
                           IfThen( FCurrentSystem.IsEmpty, _name, FCurrentSystem ),
                           _item.GetValue<string>( 'id', '' ),
                           FCurrentSystem.IsEmpty,
                           AIndex );
         end;
      end;

      // --- LE CADRE PARFAIT : GÉOMÉTRIE + VERROU DE LIGNE ---

      // Sécurité 1 : On interdit le dessin si la ligne en cours (AIndex) n'est pas la ligne survolée
      if AIndex = ControlList1.HotItemIndex then
      begin
         _mousePos := ControlList1.ScreenToClient(Mouse.CursorPos);

         // 2. Calcul du rectangle de l'image basé sur ARect (gère l'en-tête et le scroll)
         _localImgRect := TRect.Create(
            ARect.Left + FImages[iCol].Left,
            ARect.Top + FImages[iCol].Top,
            ARect.Left + FImages[iCol].Left + FImages[iCol].Width,
            ARect.Top + FImages[iCol].Top + FImages[iCol].Height
         );

         // Sécurité 2 : On vérifie si la souris est bien dans cette colonne précise
         if _localImgRect.Contains(_mousePos) then
         begin
            var _oldColor := ACanvas.Pen.Color;
            var _oldWidth := ACanvas.Pen.Width;
            var _oldStyle := ACanvas.Brush.Style;
            try
               ACanvas.Brush.Style := bsClear;
               ACanvas.Pen.Color   := clHighlight; // Ton bleu
               ACanvas.Pen.Width   := 3;

               ACanvas.Rectangle(_localImgRect);
            finally
               ACanvas.Pen.Color   := _oldColor;
               ACanvas.Pen.Width   := _oldWidth;
               ACanvas.Brush.Style := _oldStyle;
            end;
         end;
      end;
   end;
end;

procedure TfrmRetrobatBrowser.ControlList1MouseLeave(Sender: TObject);
begin
   ControlList1.Repaint;
end;

procedure TfrmRetrobatBrowser.ControlList1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
   // Force la liste à se repeindre dès que la souris bouge pour mettre à jour le cadre
   ControlList1.Repaint;
end;

// TÉLÉCHARGEMENT ASYNCHRONE : Ne gèle plus l'UI
procedure TfrmRetrobatBrowser.loadImageAsync( const aKey, aSystem, aGameId: string;
  aIsSystem: Boolean; aRowIndex: Integer );
begin
   TTask.Run( procedure
   var
      _bytes: TBytes;
      _err  : string;
      _bmp: TBitmap;
      _startIdx: Integer;
      _isSvg: Boolean;
   begin
      if ( aIsSystem ) then
         TESApi.getSystemLogo( FSettings, aSystem, _bytes, _err )
      else
         TESApi.getGameMedia( FSettings, aSystem, aGameId, 'thumbnail', _bytes, _err );

      if ( Length( _bytes ) > 0 ) then begin
         try
            // --- DETECTION DU FORMAT SVG ---
            _startIdx := 0;
            if ( Length( _bytes ) >= 3 ) and
               ( _bytes[0] = $EF ) and ( _bytes[1] = $BB ) and ( _bytes[2] = $BF ) then
               _startIdx := 3;
            while ( _startIdx < Length( _bytes ) ) and ( _bytes[_startIdx] <= 32 ) do
               Inc( _startIdx );
            _isSvg := ( _startIdx < Length( _bytes ) ) and ( _bytes[_startIdx] = Ord( '<' ) );

            _bmp := TBitmap.Create;
            _bmp.PixelFormat := pf32bit;

            if _isSvg then begin
               // --- CAS TEXTE VECTORIEL (SVG) ---
               var _txt := TEncoding.UTF8.GetString( _bytes, _startIdx, Length( _bytes ) - _startIdx );
               var _skSvg := TSkSvg.Create(nil);
               try
                  _skSvg.Svg.Source := _txt;

                  var _vbRect: TRectF;
                  var _w := 200.0;
                  var _h := 200.0;

                  // 1. On fixe la taille du Bitmap de destination (ex: un carré de 200x200)
                  _bmp.SetSize(200, 200);

                  // 2. On calcule le ratio pour centrer le logo dans ce carré
                  if _skSvg.Svg.DOM.Root.TryGetViewBox(_vbRect) then begin
                     _w := _vbRect.Width;
                     _h := _vbRect.Height;
                  end;

                  _bmp.SkiaDraw(procedure(const ACanvas: ISkCanvas)
                  begin
                     if (_w > 0) and (_h > 0) then begin
                        // Calcul du facteur d'échelle en gardant les proportions (Min)
                        var _scale := System.Math.Min(200 / _w, 200 / _h);
                        // Calcul des décalages X et Y pour centrer le rendu dans le bitmap
                        var _dx := (200 - _w * _scale) / 2;
                        var _dy := (200 - _h * _scale) / 2;

                        ACanvas.Save;
                        ACanvas.Translate(_dx - _vbRect.Left * _scale, _dy - _vbRect.Top * _scale);
                        ACanvas.Scale(_scale, _scale);
                        _skSvg.Svg.DOM.Render(ACanvas);
                        ACanvas.Restore;
                     end else begin
                        _skSvg.Svg.DOM.Render(ACanvas);
                     end;
                  end);
               finally
                  _skSvg.Free;
               end;
            end else begin
               // --- CAS IMAGES TRADITIONNELLES (PNG, JPG, WebP) ---
               var _skImg := TSkImage.MakeFromEncoded(_bytes);
               if _skImg <> nil then begin

                  // 1. On récupère la taille cible du composant (ex: 150x200)
                  // On met des valeurs par défaut au cas où le composant n'est pas encore initialisé
                  var _targetW := 150;
                  var _targetH := 200;

                  // 2. On calcule le ratio pour que l'image garde ses proportions sans se déformer
                  var _scale := System.Math.Min(_targetW / _skImg.Width, _targetH / _skImg.Height);
                  var _finalW := System.Math.Ceil(_skImg.Width * _scale);
                  var _finalH := System.Math.Ceil(_skImg.Height * _scale);

                  // 3. On crée le bitmap à la taille EXACTE ajustée
                  _bmp.SetSize(_finalW, _finalH);

                  _bmp.SkiaDraw(procedure(const ACanvas: ISkCanvas)
                  begin
                     // Fond transparent pour éviter les bords noirs/blancs chelous
                     ACanvas.Clear($00000000);

                     // On dessine le PNG en lui appliquant un échantillonnage linéaire de haute qualité
                     var _destRect := TRectF.Create(0, 0, _finalW, _finalH);
                     ACanvas.DrawImageRect(_skImg, _destRect,
                        TSkSamplingOptions.Create(TSkFilterMode.Linear, TSkMipmapMode.Linear));
                  end);
               end else begin
                  _bmp.Free;
                  _bmp := nil;
               end;
            end;

            // --- TRANSMISSION DU BITMAP FINI À L'UI ---
            if (_bmp <> nil) and (_bmp.Width > 0) and (_bmp.Height > 0) then begin
               TThread.Queue( nil, procedure
               begin
                  FImageCache.AddOrSetValue( aKey, _bmp );
                  FDownloadingKeys.Remove( aKey );
                  ControlList1.Invalidate;
               end );
               Exit;
            end else if _bmp <> nil then
               _bmp.Free;

         except
            // Sécurité décodeur
         end;
      end;

      // Nettoyage si échec
      TThread.Queue( nil, procedure
      begin
         FDownloadingKeys.Remove( aKey );
      end );
   end );
end;

// GESTION DU CLIC SUR LA GRILLE
procedure TfrmRetrobatBrowser.OnGameClick( Sender: TObject );
var
  ClickedComponent: TComponent;
  iCol, iRow, iGlobalIndex: Integer;
  _item: TJSONObject;
begin
   if FItems = nil then Exit;

   ClickedComponent := Sender as TComponent;
   iCol := ClickedComponent.Tag;                // Reçu via la config DFM (0, 1, 2 ou 3)
   iRow := ControlList1.ItemIndex;              // Ligne sélectionnée

   if iRow < 0 then Exit;

   iGlobalIndex := ( iRow * NB_COLS ) + iCol;

   if ( iGlobalIndex >= 0 ) and ( iGlobalIndex < FItems.Count ) then begin
      _item := FItems.Items[iGlobalIndex] as TJSONObject;

      if ( FCurrentSystem.IsEmpty ) then begin
         // On clique sur un système -> charger la liste des jeux
         loadGames( _item.GetValue<string>( 'name', '' ) );
      end else begin
         // On clique sur un jeu !
         // Remplace la ligne 253 par ceci :
         ShowMessage('Lancement du jeu : ' + _item.GetValue<string>( 'name', '' ));
         // TODO: Insérer ici ton code d'exécution de jeu (ex: avec ShellExecute ou appel API)
      end;
   end;
end;

procedure TfrmRetrobatBrowser.btnBackClick( Sender: TObject );
begin
   loadSystems;
end;

procedure TfrmRetrobatBrowser.loadSystems;
begin
   clearAll;
   FCurrentSystem:= '';
   btnBack.Visible:= False;
   lblBreadcrumb.Caption:= 'Systems';

   var _response, _err: string;
   if ( not TESApi.getSystemList( FSettings, _response, _err ) ) then Exit;
   var _json:= TJSONObject.ParseJSONValue( _response ) as TJSONArray;
   if ( _json = nil ) then Exit;
   FItems:= _json;

   UpdateControlListCount;
end;

procedure TfrmRetrobatBrowser.loadGames( const aSystem: string );
begin
   clearAll;
   FCurrentSystem:= aSystem;
   btnBack.Visible:= True;
   lblBreadcrumb.Caption:= 'Systems > ' + aSystem;

   var _response, _err: string;
   if ( not TESApi.getSystemGames( FSettings, aSystem, _response, _err ) ) then Exit;
   var _json:= TJSONObject.ParseJSONValue( _response ) as TJSONArray;
   if ( _json = nil ) then Exit;
   FItems:= _json;

   UpdateControlListCount;
end;

end.
