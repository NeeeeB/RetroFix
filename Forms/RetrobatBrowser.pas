unit RetrobatBrowser;

interface

uses
   System.SysUtils, System.Classes, System.Threading,
   System.Generics.Collections, System.Math,
   System.JSON, System.Types, System.UITypes,
   Winapi.Windows,
   Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls,
   Vcl.Graphics, Vcl.Grids, Vcl.Skia,
   System.Skia,
   Types, ESApi;

const
   cstTileWidth  = 150;
   cstTileHeight = 120;
   cstLabelHeight= 20;

type
   TCachedImage = class
   public
      svg          : TSkSvg;
      skImage      : ISkImage;
      isSvg        : Boolean;
      viewBoxWidth : Single;
      viewBoxHeight: Single;
      destructor Destroy; override;
   end;

   TfrmRetrobatBrowser = class( TForm )
      pnlTop       : TPanel;
      lblBreadcrumb: TLabel;
      btnBack      : TButton;
      drawGrid     : TDrawGrid;
      procedure btnBackClick( Sender: TObject );
      procedure FormCreate( Sender: TObject );
      procedure FormDestroy( Sender: TObject );
      procedure drawGridDrawCell( Sender: TObject; ACol, ARow: Longint;
                                   Rect: TRect; State: TGridDrawState );
      procedure drawGridSelectCell( Sender: TObject; ACol, ARow: Longint;
                                     var CanSelect: Boolean );
      procedure drawGridMouseWheelDown( Sender: TObject; Shift: TShiftState;
                                         MousePos: TPoint; var Handled: Boolean );
      procedure drawGridMouseWheelUp( Sender: TObject; Shift: TShiftState;
                                       MousePos: TPoint; var Handled: Boolean );
      procedure FormResize( Sender: TObject );
   private
      FSettings     : TSettings;
      FCurrentSystem: string;
      FItems        : TJSONArray;
      FImageCache   : TObjectDictionary<string, TCachedImage>;
      FLoadingKeys  : TDictionary<string, Boolean>;
      FBufferBitmap : TBitmap;
      procedure updateGrid;
      procedure loadSystems;
      procedure loadGames( const aSystemName: string );
      procedure clearAll;
      procedure loadImage( const aKey: string;
                            const aSystemName: string;
                            const aGameId: string;
                            aIsSystem: Boolean );
      function getItemIndex( aCol, aRow: Integer ): Integer;
      function getItemKey( aIndex: Integer ): string;
   public
      procedure init( aSettings: TSettings );
   end;

implementation

uses
   System.StrUtils,
   Constantes;

{$R *.dfm}

destructor TCachedImage.Destroy;
begin
   svg.Free;
   inherited;
end;

procedure TfrmRetrobatBrowser.FormCreate( Sender: TObject );
begin
   FImageCache  := TObjectDictionary<string, TCachedImage>.Create( [doOwnsValues] );
   FLoadingKeys := TDictionary<string, Boolean>.Create;
   FBufferBitmap:= TBitmap.Create;
   FBufferBitmap.PixelFormat:= pf32bit;

   drawGrid.DefaultColWidth := cstTileWidth;
   drawGrid.DefaultRowHeight:= cstTileHeight;
   drawGrid.FixedCols       := 0;
   drawGrid.FixedRows       := 0;
   drawGrid.Options         := [goDrawFocusSelected];
   drawGrid.ScrollBars      := ssVertical;
   drawGrid.Color           := $00302020;
end;

procedure TfrmRetrobatBrowser.FormDestroy( Sender: TObject );
begin
   FreeAndNil( FItems );
   FImageCache.Free;
   FLoadingKeys.Free;
   FBufferBitmap.Free;
end;

procedure TfrmRetrobatBrowser.FormResize( Sender: TObject );
begin
   updateGrid;
end;

procedure TfrmRetrobatBrowser.init( aSettings: TSettings );
begin
   FSettings:= aSettings;
   loadSystems;
end;

procedure TfrmRetrobatBrowser.clearAll;
begin
   FreeAndNil( FItems );
   if Assigned( FImageCache ) then FImageCache.Clear;
   if Assigned( FLoadingKeys ) then FLoadingKeys.Clear;
   drawGrid.RowCount:= 1;
   drawGrid.ColCount:= 1;
end;

procedure TfrmRetrobatBrowser.updateGrid;
begin
   if ( FItems = nil ) or ( FItems.Count = 0 ) then begin
      drawGrid.ColCount:= 1;
      drawGrid.RowCount:= 1;
      Exit;
   end;
   var _cols:= Max( 1, drawGrid.ClientWidth div ( cstTileWidth + 1 ) );
   var _rows:= ( FItems.Count + _cols - 1 ) div _cols;
   drawGrid.ColCount:= _cols;
   drawGrid.RowCount:= Max( 1, _rows );
   drawGrid.Invalidate;
end;

function TfrmRetrobatBrowser.getItemIndex( aCol, aRow: Integer ): Integer;
begin
   Result:= aRow * drawGrid.ColCount + aCol;
end;

function TfrmRetrobatBrowser.getItemKey( aIndex: Integer ): string;
begin
   if ( FItems = nil ) or ( aIndex >= FItems.Count ) then Exit( '' );
   var _item:= FItems.Items[aIndex] as TJSONObject;
   var _id  := _item.GetValue<string>( 'id', '' );
   var _name:= _item.GetValue<string>( 'name', '' );
   Result:= IfThen( not _id.IsEmpty, _id, _name );
end;

procedure TfrmRetrobatBrowser.drawGridDrawCell( Sender: TObject;
                                                 ACol, ARow: Longint;
                                                 Rect: TRect;
                                                 State: TGridDrawState );
begin
   var _idx:= getItemIndex( ACol, ARow );
   if ( FItems = nil ) or ( _idx < 0 ) or ( _idx >= FItems.Count ) then begin
      drawGrid.Canvas.Brush.Color:= drawGrid.Color;
      drawGrid.Canvas.FillRect( Rect );
      Exit;
   end;

   var _item:= FItems.Items[_idx] as TJSONObject;
   var _name:= _item.GetValue<string>( 'name', '' );
   var _id  := _item.GetValue<string>( 'id', '' );
   var _key := getItemKey( _idx );

   // Background
   drawGrid.Canvas.Brush.Color:= IfThen( gdSelected in State, $00504040, $00302020 );
   drawGrid.Canvas.FillRect( Rect );

   // Image zone
   var _imgH        := Rect.Height - cstLabelHeight;
   var _cachedImage : TCachedImage:= nil;
   FImageCache.TryGetValue( _key, _cachedImage );

   if ( _cachedImage <> nil ) then begin
      FBufferBitmap.SetSize( Rect.Width, _imgH );
      FBufferBitmap.SkiaDraw( procedure( const ACanvas: ISkCanvas )
      begin
         ACanvas.Clear( TAlphaColors.Null );
         var _destRect:= TRectF.Create( 5, 5, Rect.Width - 5, _imgH - 5 );

         if ( _cachedImage.isSvg ) and ( _cachedImage.svg <> nil ) then begin
            var _vbW:= _cachedImage.viewBoxWidth;
            var _vbH:= _cachedImage.viewBoxHeight;
            if ( _vbW > 0 ) and ( _vbH > 0 ) then begin
               var _scale:= Min( _destRect.Width / _vbW, _destRect.Height / _vbH );
               var _dx   := _destRect.Left + ( _destRect.Width - _vbW * _scale ) / 2;
               var _dy   := _destRect.Top + ( _destRect.Height - _vbH * _scale ) / 2;
               ACanvas.Save;
               ACanvas.Translate( _dx, _dy );
               ACanvas.Scale( _scale, _scale );
               _cachedImage.svg.Svg.DOM.Render( ACanvas );
               ACanvas.Restore;
            end else begin
               _cachedImage.svg.Svg.DOM.SetContainerSize(
                  TSizeF.Create( _destRect.Width, _destRect.Height ) );
               ACanvas.Save;
               ACanvas.Translate( _destRect.Left, _destRect.Top );
               _cachedImage.svg.Svg.DOM.Render( ACanvas );
               ACanvas.Restore;
            end;
         end else if ( _cachedImage.skImage <> nil ) then begin
            var _iw   := _cachedImage.skImage.Width;
            var _ih   := _cachedImage.skImage.Height;
            var _scale:= Min( _destRect.Width / _iw, _destRect.Height / _ih );
            var _dw   := _iw * _scale;
            var _dh   := _ih * _scale;
            var _dx   := _destRect.Left + ( _destRect.Width - _dw ) / 2;
            var _dy   := _destRect.Top + ( _destRect.Height - _dh ) / 2;
            ACanvas.DrawImageRect( _cachedImage.skImage,
                                   TRectF.Create( _dx, _dy, _dx + _dw, _dy + _dh ),
                                   TSkSamplingOptions.Create( TSkFilterMode.Linear,
                                                               TSkMipmapMode.Linear ) );
         end;
      end );

      var _rgn:= CreateRectRgn( Rect.Left, Rect.Top, Rect.Right, Rect.Bottom - cstLabelHeight );
      SelectClipRgn( drawGrid.Canvas.Handle, _rgn );
      drawGrid.Canvas.Draw( Rect.Left, Rect.Top, FBufferBitmap );
      SelectClipRgn( drawGrid.Canvas.Handle, 0 );
      DeleteObject( _rgn );
   end else begin
      if ( not FLoadingKeys.ContainsKey( _key ) ) then begin
         FLoadingKeys.Add( _key, True );
         var _sysName:= IfThen( FCurrentSystem.IsEmpty,
                                 _item.GetValue<string>( 'name', '' ),
                                 FCurrentSystem );
         loadImage( _key, _sysName, _id, FCurrentSystem.IsEmpty );
      end;
   end;

   // Label
   var _lblRect       := Rect;
   _lblRect.Top       := _lblRect.Bottom - cstLabelHeight;
   drawGrid.Canvas.Brush.Color:= clBlack;
   drawGrid.Canvas.FillRect( _lblRect );
   drawGrid.Canvas.Font.Color := clWhite;
   drawGrid.Canvas.Font.Size  := 8;
   DrawText( drawGrid.Canvas.Handle, PChar( _name ), -1, _lblRect,
             DT_CENTER or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS );
end;

procedure TfrmRetrobatBrowser.drawGridSelectCell( Sender: TObject;
                                                   ACol, ARow: Longint;
                                                   var CanSelect: Boolean );
begin
   var _idx:= getItemIndex( ACol, ARow );
   if ( FItems = nil ) or ( _idx >= FItems.Count ) then begin
      CanSelect:= False;
      Exit;
   end;
   CanSelect:= True;
   var _item:= FItems.Items[_idx] as TJSONObject;
   if ( FCurrentSystem.IsEmpty ) then begin
      var _name:= _item.GetValue<string>( 'name', '' );
      loadGames( _name );
   end;
   // TODO: launch game
end;

procedure TfrmRetrobatBrowser.drawGridMouseWheelDown( Sender: TObject;
                                                       Shift: TShiftState;
                                                       MousePos: TPoint;
                                                       var Handled: Boolean );
begin
   drawGrid.TopRow:= Min( drawGrid.RowCount - 1, drawGrid.TopRow + 3 );
   Handled:= True;
end;

procedure TfrmRetrobatBrowser.drawGridMouseWheelUp( Sender: TObject;
                                                     Shift: TShiftState;
                                                     MousePos: TPoint;
                                                     var Handled: Boolean );
begin
   drawGrid.TopRow:= Max( 0, drawGrid.TopRow - 3 );
   Handled:= True;
end;

procedure TfrmRetrobatBrowser.loadImage( const aKey: string;
                                          const aSystemName: string;
                                          const aGameId: string;
                                          aIsSystem: Boolean );
begin
   var _key       := aKey;
   var _systemName:= aSystemName;
   var _gameId    := aGameId;

   TTask.Run( procedure
   begin
      var _bytes: TBytes;
      var _err  : string;

      if aIsSystem then
         TESApi.getSystemLogo( FSettings, _systemName, _bytes, _err )
      else
         TESApi.getGameMedia( FSettings, _systemName, _gameId,
                               'thumbnail', _bytes, _err );

      if ( Length( _bytes ) = 0 ) then Exit;

      var _cached:= TCachedImage.Create;
      if ( _bytes[0] = Ord( '<' ) ) then begin
         _cached.isSvg:= True;
         _cached.svg  := TSkSvg.Create( nil );
         _cached.svg.Svg.Source:= TEncoding.UTF8.GetString( _bytes );
         _cached.viewBoxWidth := _cached.svg.Svg.OriginalSize.Width;
         _cached.viewBoxHeight:= _cached.svg.Svg.OriginalSize.Height;
         if ( _cached.viewBoxWidth = 0 ) then begin
            var _src   := string( _cached.svg.Svg.Source );
            var _p     := Pos( 'viewBox=', _src );
            if ( _p > 0 ) then begin
               var _vb   := _src.Substring( _p + 8 ).TrimLeft( ['"', ' '] );
               var _parts:= _vb.Split( [' ', ','] );
               if ( Length( _parts ) >= 4 ) then begin
                  TryStrToFloat( _parts[2].Replace( '.', FormatSettings.DecimalSeparator ),
                                 _cached.viewBoxWidth );
                  TryStrToFloat( _parts[3].Replace( '.', FormatSettings.DecimalSeparator ),
                                 _cached.viewBoxHeight );
               end;
            end;
         end;
      end else begin
         _cached.isSvg  := False;
         _cached.skImage:= TSkImage.MakeFromEncoded( _bytes );
      end;

      TThread.Queue( nil, procedure
      begin
         if Assigned( FImageCache ) then begin
            FImageCache.AddOrSetValue( _key, _cached );
            drawGrid.Invalidate;
         end else
            _cached.Free;
      end );
   end );
end;

procedure TfrmRetrobatBrowser.loadSystems;
begin
   clearAll;
   btnBack.Visible      := False;
   lblBreadcrumb.Caption:= 'Systems';
   FCurrentSystem       := '';

   TTask.Run( procedure
   begin
      var _response, _err: string;
      if ( not TESApi.getSystemList( FSettings, _response, _err ) ) then Exit;
      var _json:= TJSONObject.ParseJSONValue( _response ) as TJSONArray;
      if ( _json = nil ) then Exit;
      TThread.Queue( nil, procedure
      begin
         FItems:= _json;
         updateGrid;
      end );
   end );
end;

procedure TfrmRetrobatBrowser.loadGames( const aSystemName: string );
begin
   clearAll;
   FCurrentSystem       := aSystemName;
   btnBack.Visible      := True;
   lblBreadcrumb.Caption:= 'Systems > ' + aSystemName;

   TTask.Run( procedure
   begin
      var _response, _err: string;
      if ( not TESApi.getSystemGames( FSettings, aSystemName,
                                      _response, _err ) ) then Exit;
      var _json:= TJSONObject.ParseJSONValue( _response ) as TJSONArray;
      if ( _json = nil ) then Exit;
      TThread.Queue( nil, procedure
      begin
         FItems:= _json;
         updateGrid;
      end );
   end );
end;

procedure TfrmRetrobatBrowser.btnBackClick( Sender: TObject );
begin
   loadSystems;
end;

end.
