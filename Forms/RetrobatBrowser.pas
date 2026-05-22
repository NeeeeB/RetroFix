unit RetrobatBrowser;

interface

uses
   System.SysUtils, System.Classes,
   System.Generics.Collections, System.Math,
   System.JSON, System.Types, System.UITypes,
   Vcl.Forms, Vcl.Controls, Vcl.ExtCtrls, Vcl.StdCtrls,
   Vcl.Skia, Vcl.Graphics,
   System.Skia,
   ESApi, Constantes, Types;

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
      viewBoxMinX  : Single;
      viewBoxMinY  : Single;
      viewBoxWidth : Single;
      viewBoxHeight: Single;
      destructor Destroy; override;
   end;

   TfrmRetrobatBrowser = class( TForm )
      SkPaintBox   : TSkPaintBox;
      pnlTop       : TPanel;
      lblBreadcrumb: TLabel;
      btnBack      : TButton;
      procedure FormCreate( Sender: TObject );
      procedure FormDestroy( Sender: TObject );
      procedure FormResize( Sender: TObject );
      procedure FormShow( Sender: TObject );
      procedure FormMouseWheel( Sender: TObject; Shift: TShiftState;
                           WheelDelta: Integer; MousePos: TPoint;
                           var Handled: Boolean );
      procedure SkPaintBoxDraw( Sender: TObject; const ACanvas: ISkCanvas;
                                 const ARect: TRectF; const AOpacity: Single );
      procedure SkPaintBoxMouseDown( Sender: TObject; Button: TMouseButton;
                                      Shift: TShiftState; X, Y: Integer );
      procedure btnBackClick( Sender: TObject );
   private
      FSettings     : TSettings;
      FItems        : TJSONArray;
      FCurrentSystem: string;
      FImageCache   : TObjectDictionary<string, TCachedImage>;
      FCols         : Integer;
      FScrollY      : Single;
      procedure initLayout;
      procedure clearAll;
      procedure loadSystems;
      procedure loadGames( const aSystem: string );
      procedure loadImage( const aKey, aSystem, aGameId: string;
                            aIsSystem: Boolean );
      function getItemKey( aIndex: Integer ): string;
      function getVisibleStartRow: Integer;
      function getVisibleEndRow: Integer;
      procedure drawTile( const ACanvas: ISkCanvas;
                           const aTileRect, aImgRect, aLblRect: TRectF;
                           const aName, aKey: string );
   public
      procedure init( aSettings: TSettings );
      procedure mouseWheel( aUp: Boolean );
   end;

implementation

uses
   System.StrUtils;

{$R *.dfm}

destructor TCachedImage.Destroy;
begin
   svg.Free;
   inherited;
end;

procedure TfrmRetrobatBrowser.FormCreate( Sender: TObject );
begin
   FImageCache:= TObjectDictionary<string, TCachedImage>.Create( [doOwnsValues] );
   FCols      := 1;
   FScrollY   := 0;
end;

procedure TfrmRetrobatBrowser.FormDestroy( Sender: TObject );
begin
   FreeAndNil( FItems );
   FImageCache.Free;
end;

procedure TfrmRetrobatBrowser.FormResize( Sender: TObject );
begin
   initLayout;
end;

procedure TfrmRetrobatBrowser.FormShow( Sender: TObject );
begin
   loadSystems;
end;

procedure TfrmRetrobatBrowser.FormMouseWheel( Sender: TObject;
                                               Shift: TShiftState;
                                               WheelDelta: Integer;
                                               MousePos: TPoint;
                                               var Handled: Boolean );
begin
   FScrollY:= Max( 0, FScrollY - WheelDelta );
   SkPaintBox.Invalidate;
   Handled:= True;
end;

procedure TfrmRetrobatBrowser.init( aSettings: TSettings );
begin
   FSettings:= aSettings;
end;

procedure TfrmRetrobatBrowser.mouseWheel( aUp: Boolean );
begin
   if aUp then
      FScrollY:= Max( 0, FScrollY - 120 )
   else
      FScrollY:= FScrollY + 120;
   SkPaintBox.Invalidate;
end;

procedure TfrmRetrobatBrowser.clearAll;
begin
   FreeAndNil( FItems );
   FImageCache.Clear;
   FScrollY:= 0;
end;

procedure TfrmRetrobatBrowser.initLayout;
begin
   FCols:= Max( 1, Trunc( SkPaintBox.Width / cstTileWidth ) );
   SkPaintBox.Invalidate;
end;

function TfrmRetrobatBrowser.getItemKey( aIndex: Integer ): string;
begin
   Result:= '';
   if ( FItems = nil ) or ( aIndex >= FItems.Count ) then Exit;
   var _obj:= FItems.Items[aIndex] as TJSONObject;
   Result:= _obj.GetValue<string>( 'id', '' );
   if Result.IsEmpty then
      Result:= _obj.GetValue<string>( 'name', '' );
end;

function TfrmRetrobatBrowser.getVisibleStartRow: Integer;
begin
   Result:= Max( 0, Trunc( FScrollY / cstTileHeight ) );
end;

function TfrmRetrobatBrowser.getVisibleEndRow: Integer;
begin
   Result:= getVisibleStartRow + Trunc( SkPaintBox.Height / cstTileHeight ) + 2;
end;

procedure TfrmRetrobatBrowser.loadImage( const aKey, aSystem, aGameId: string;
                                          aIsSystem: Boolean );
begin
   var _bytes: TBytes;
   var _err  : string;
   if aIsSystem then
      TESApi.getSystemLogo( FSettings, aSystem, _bytes, _err )
   else
      TESApi.getGameMedia( FSettings, aSystem, aGameId, 'thumbnail', _bytes, _err );
   if ( Length( _bytes ) = 0 ) then Exit;

   // Detect SVG from bytes
   var _startIdx:= 0;
   if ( Length( _bytes ) >= 3 ) and
      ( _bytes[0] = $EF ) and ( _bytes[1] = $BB ) and ( _bytes[2] = $BF ) then
      _startIdx:= 3;
   while ( _startIdx < Length( _bytes ) ) and
         ( _bytes[_startIdx] <= 32 ) do
      Inc( _startIdx );
   var _isSvg:= ( _startIdx < Length( _bytes ) ) and
                ( _bytes[_startIdx] = Ord( '<' ) );

   var _cached:= TCachedImage.Create;
   if _isSvg then begin
      var _txt:= TEncoding.UTF8.GetString( _bytes, _startIdx,
                                            Length( _bytes ) - _startIdx );
      _cached.isSvg:= True;
      _cached.svg  := TSkSvg.Create( nil );
      _cached.svg.Svg.Source:= _txt;

      var _vbRect: TRectF;
      var _hasVB := _cached.svg.Svg.DOM.Root.TryGetViewBox( _vbRect );
      var _size  := _cached.svg.Svg.DOM.Root.GetIntrinsicSize( TSizeF.Create( 0, 0 ) );

      _cached.viewBoxMinX  := 0;
      _cached.viewBoxMinY  := 0;
      _cached.viewBoxWidth := 0;
      _cached.viewBoxHeight:= 0;

      if _hasVB then begin
         _cached.viewBoxMinX  := _vbRect.Left;
         _cached.viewBoxMinY  := _vbRect.Top;
         _cached.viewBoxWidth := _vbRect.Width;
         _cached.viewBoxHeight:= _vbRect.Height;
      end;

      if _size.Width > 0 then
         _cached.viewBoxWidth := _size.Width;
      if _size.Height > 0 then
         _cached.viewBoxHeight:= _size.Height;
      if _cached.svg.Svg.DOM.Root.TryGetViewBox( _vbRect ) then begin
         _cached.viewBoxMinX := _vbRect.Left;
         _cached.viewBoxMinY := _vbRect.Top;
      end;
      if ( _cached.viewBoxWidth = 0 ) or ( _cached.viewBoxHeight = 0 ) then begin
         _cached.viewBoxWidth := _vbRect.Width;
         _cached.viewBoxHeight:= _vbRect.Height;
      end;
   end else begin
      _cached.isSvg  := False;
      _cached.skImage:= TSkImage.MakeFromEncoded( _bytes );
   end;
   FImageCache.AddOrSetValue( aKey, _cached );
end;

procedure TfrmRetrobatBrowser.drawTile( const ACanvas: ISkCanvas;
                                         const aTileRect, aImgRect, aLblRect: TRectF;
                                         const aName, aKey: string );
begin
   // Tile background
   var _tilePaint: ISkPaint:= TSkPaint.Create;
   _tilePaint.Color:= $FF404040;
   ACanvas.DrawRect( aTileRect, _tilePaint );

   // Image
   var _img: TCachedImage:= nil;
   FImageCache.TryGetValue( aKey, _img );

   if ( _img <> nil ) then begin
      if ( _img.isSvg ) and ( _img.svg <> nil ) then begin
         var _vbW  := _img.viewBoxWidth;
         var _vbH  := _img.viewBoxHeight;
         var _minX := _img.viewBoxMinX;
         var _minY := _img.viewBoxMinY;
         if ( _vbW > 0 ) and ( _vbH > 0 ) then begin
            var _scale:= Min( aImgRect.Width / _vbW, aImgRect.Height / _vbH );
            var _dx   := aImgRect.Left + ( aImgRect.Width - _vbW * _scale ) / 2;
            var _dy   := aImgRect.Top + ( aImgRect.Height - _vbH * _scale ) / 2;
            ACanvas.Save;
            ACanvas.Translate( _dx - _minX * _scale, _dy - _minY * _scale );
            ACanvas.Scale( _scale, _scale );
            _img.svg.Svg.DOM.Render( ACanvas );
            ACanvas.Restore;
         end else begin
            _img.svg.Svg.DOM.SetContainerSize(
               TSizeF.Create( aImgRect.Width, aImgRect.Height ) );
            ACanvas.Save;
            ACanvas.Translate( aImgRect.Left, aImgRect.Top );
            _img.svg.Svg.DOM.Render( ACanvas );
            ACanvas.Restore;
         end;
      end else if ( _img.skImage <> nil ) then begin
         var _iw   := Single( _img.skImage.Width );
         var _ih   := Single( _img.skImage.Height );
         var _scale:= Min( aImgRect.Width / _iw, aImgRect.Height / _ih );
         var _dw   := _iw * _scale;
         var _dh   := _ih * _scale;
         var _dx   := aImgRect.Left + ( aImgRect.Width - _dw ) / 2;
         var _dy   := aImgRect.Top + ( aImgRect.Height - _dh ) / 2;
         ACanvas.DrawImageRect( _img.skImage,
                                TRectF.Create( _dx, _dy, _dx + _dw, _dy + _dh ),
                                TSkSamplingOptions.Create( TSkFilterMode.Linear,
                                                            TSkMipmapMode.Linear ) );
      end;
   end;

   // Label background
   var _lblPaint: ISkPaint:= TSkPaint.Create;
   _lblPaint.Color:= $CC000000;
   ACanvas.DrawRect( aLblRect, _lblPaint );

   // Label text
   var _txtPaint: ISkPaint:= TSkPaint.Create;
   _txtPaint.Color:= TAlphaColors.White;
   var _font:= TSkFont.Create( TSkTypeface.MakeDefault, 10 );
   ACanvas.DrawSimpleText( aName, aLblRect.Left + 5,
                            aLblRect.Bottom - 6, _font, _txtPaint );
end;

procedure TfrmRetrobatBrowser.SkPaintBoxDraw( Sender: TObject;
                                               const ACanvas: ISkCanvas;
                                               const ARect: TRectF;
                                               const AOpacity: Single );
begin
   ACanvas.DrawColor( $FF302020 );
   if ( FItems = nil ) then Exit;

   var _startRow:= getVisibleStartRow;
   var _endRow  := getVisibleEndRow;

   for var ii:= _startRow * FCols to ( _endRow * FCols ) - 1 do begin
      if ( ii >= FItems.Count ) then Break;
      var _item    := FItems.Items[ii] as TJSONObject;
      var _col     := ii mod FCols;
      var _row     := ii div FCols;
      var _x       := Single( _col * cstTileWidth );
      var _y       := Single( _row * cstTileHeight ) - FScrollY;
      var _key     := getItemKey( ii );
      var _name    := _item.GetValue<string>( 'name', '' );
      var _tileRect:= TRectF.Create( _x, _y, _x + cstTileWidth, _y + cstTileHeight );
      var _imgRect := TRectF.Create( _x, _y, _x + cstTileWidth,
                                      _y + cstTileHeight - cstLabelHeight );
      var _lblRect := TRectF.Create( _x, _y + cstTileHeight - cstLabelHeight,
                                      _x + cstTileWidth, _y + cstTileHeight );

      if ( not FImageCache.ContainsKey( _key ) ) then
         loadImage( _key,
                    IfThen( FCurrentSystem.IsEmpty, _name, FCurrentSystem ),
                    _item.GetValue<string>( 'id', '' ),
                    FCurrentSystem.IsEmpty );

      drawTile( ACanvas, _tileRect, _imgRect, _lblRect, _name, _key );
   end;
end;

procedure TfrmRetrobatBrowser.SkPaintBoxMouseDown( Sender: TObject;
                                                    Button: TMouseButton;
                                                    Shift: TShiftState;
                                                    X, Y: Integer );
begin
   if ( Button <> mbLeft ) then Exit;
   if ( FItems = nil ) then Exit;
   var _col:= Trunc( X / cstTileWidth );
   var _row:= Trunc( ( Y + FScrollY ) / cstTileHeight );
   var _idx:= _row * FCols + _col;
   if ( _idx < 0 ) or ( _idx >= FItems.Count ) then Exit;
   if ( FCurrentSystem.IsEmpty ) then begin
      var _item:= FItems.Items[_idx] as TJSONObject;
      loadGames( _item.GetValue<string>( 'name', '' ) );
   end;
   // TODO: launch game
end;

procedure TfrmRetrobatBrowser.btnBackClick( Sender: TObject );
begin
   clearAll;
   FCurrentSystem:= '';
   btnBack.Visible:= False;
   lblBreadcrumb.Caption:= 'Systems';
   loadSystems;
end;

procedure TfrmRetrobatBrowser.loadSystems;
begin
   clearAll;
   FCurrentSystem       := '';
   btnBack.Visible      := False;
   lblBreadcrumb.Caption:= 'Systems';

   var _response, _err: string;
   if ( not TESApi.getSystemList( FSettings, _response, _err ) ) then Exit;
   var _json:= TJSONObject.ParseJSONValue( _response ) as TJSONArray;
   if ( _json = nil ) then Exit;
   FItems:= _json;
   initLayout;
end;

procedure TfrmRetrobatBrowser.loadGames( const aSystem: string );
begin
   clearAll;
   FCurrentSystem       := aSystem;
   btnBack.Visible      := True;
   lblBreadcrumb.Caption:= 'Systems > ' + aSystem;

   var _response, _err: string;
   if ( not TESApi.getSystemGames( FSettings, aSystem, _response, _err ) ) then Exit;
   var _json:= TJSONObject.ParseJSONValue( _response ) as TJSONArray;
   if ( _json = nil ) then Exit;
   FItems:= _json;
   initLayout;
end;

end.
