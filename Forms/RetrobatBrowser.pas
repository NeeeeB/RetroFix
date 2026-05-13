unit RetrobatBrowser;

interface

uses
   System.SysUtils, System.Classes, System.Threading,
   Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls,
   Vcl.Graphics, Vcl.Imaging.PngImage, Vcl.Imaging.Jpeg, Vcl.Skia,
   Types, ESApi;

type
   TfrmRetrobatBrowser = class( TForm )
      pnlTop: TPanel;
      lblBreadcrumb: TLabel;
      btnBack: TButton;
      scrBox: TScrollBox;
      flowPanel: TFlowPanel;
      procedure btnBackClick( Sender: TObject );
      procedure FormCreate( Sender: TObject );
   private
      FSettings: TSettings;
      FCurrentSystem: string;
      procedure loadSystems;
      procedure loadGames( const aSystemName: string );
      procedure clearFlow;
      procedure tileClick( Sender: TObject );
      function createTile( const aCaption: string;
                           const aSystemName: string;
                           const aGameId: string = '' ): TSystemTile;
      procedure loadSystemLogo( aTile: TSystemTile;
                                const aSystemName: string );
      procedure loadGameThumbnail( aTile: TSystemTile;
                                   const aSystemName: string;
                                   const aGameId: string );
   public
      procedure init( aSettings: TSettings );
   end;

implementation

uses
   System.JSON,
   System.Generics.Collections,
   Constantes;

{$R *.dfm}

procedure TfrmRetrobatBrowser.FormCreate( Sender: TObject );
begin
   // Nothing yet
end;

procedure TfrmRetrobatBrowser.init( aSettings: TSettings );
begin
   FSettings:= aSettings;
   loadSystems;
end;

procedure TfrmRetrobatBrowser.clearFlow;
begin
   flowPanel.DisableAlign;
   try
      while ( flowPanel.ControlCount > 0 ) do
         flowPanel.Controls[0].Free;
   finally
      flowPanel.EnableAlign;
   end;
end;

function TfrmRetrobatBrowser.createTile( const aCaption: string;
                                         const aSystemName: string;
                                         const aGameId: string ): TSystemTile;
begin
   Result:= TSystemTile.Create( flowPanel );
   Result.Parent:= flowPanel;
   Result.Width:= 150;
   Result.Height:= 120;
   Result.Margins.SetBounds( 10, 10, 10, 10 );
   Result.AlignWithMargins:= True;
   Result.BevelOuter:= bvNone;
   Result.Caption:= '';
   Result.systemName:= aSystemName;
   Result.gameId:= aGameId;
   Result.Cursor:= crHandPoint;
   Result.OnClick:= tileClick;

   var _svg:= TSkSvg.Create( Result );
   _svg.Parent:= Result;
   _svg.Align:= alClient;
   _svg.Visible:= False;
   _svg.OnClick:= tileClick;

   var _img:= TSkAnimatedImage.Create( Result );
   _img.Parent:= Result;
   _img.Align:= alClient;
   _img.Visible:= False;
   _img.OnClick:= tileClick;

   var _lbl:= TLabel.Create( Result );
   _lbl.Parent:= Result;
   _lbl.Align:= alBottom;
   _lbl.Alignment:= taCenter;
   _lbl.Caption:= aCaption;
   _lbl.Height:= 20;
   _lbl.WordWrap:= False;
   _lbl.OnClick:= tileClick;
   _lbl.EllipsisPosition:= epEndEllipsis;
   _lbl.AutoSize:= False;
   _lbl.Width:= Result.Width;
end;

procedure TfrmRetrobatBrowser.tileClick( Sender: TObject );
begin
   var _ctrl:= TControl( Sender );
   // Walk up to find the TSystemTile
   while ( _ctrl <> nil ) and ( not ( _ctrl is TSystemTile ) ) do
      _ctrl:= _ctrl.Parent;
   if ( _ctrl = nil ) then Exit;

   var _tile:= TSystemTile( _ctrl );
   if ( FCurrentSystem.IsEmpty ) then
      loadGames( _tile.systemName );
   // TODO: launch game when in system view
end;

procedure TfrmRetrobatBrowser.loadSystemLogo( aTile: TSystemTile;
                                               const aSystemName: string );
begin
   TTask.Run( procedure
   begin
      var _bytes: TBytes;
      var _err: string;
      if ( not TESApi.getSystemLogo( FSettings, aSystemName, _bytes, _err ) ) then
         Exit;
      TThread.Queue( nil, procedure
      begin
         if ( not Assigned( aTile ) ) or
            ( not Assigned( aTile.Parent ) ) then Exit;
         try
            if ( _bytes[0] = Ord( '<' ) ) then begin
               // SVG
               var _svg: TSkSvg:= nil;
               for var ii:= 0 to Pred( aTile.ControlCount ) do begin
                  if ( aTile.Controls[ii] is TSkSvg ) then begin
                     _svg:= ( aTile.Controls[ii] as TSkSvg );
                     Break;
                  end;
               end;
               if ( _svg <> nil ) then begin
                  _svg.Svg.Source:= TEncoding.UTF8.GetString( _bytes );
                  _svg.Visible:= True;
               end;
            end else begin
               // PNG/JPEG
               var _img: TSkAnimatedImage:= nil;
               for var ii:= 0 to Pred( aTile.ControlCount ) do begin
                  if ( aTile.Controls[ii] is TSkAnimatedImage ) then begin
                     _img:= ( aTile.Controls[ii] as TSkAnimatedImage );
                     Break;
                  end;
               end;
               if ( _img <> nil ) then begin
                  _img.Source.Data:= _bytes;
                  _img.Visible:= True;
               end;
            end;
         except
         end;
      end );
   end );
end;

procedure TfrmRetrobatBrowser.loadGameThumbnail( aTile: TSystemTile;
                                                  const aSystemName: string;
                                                  const aGameId: string );
begin
   TTask.Run( procedure
   begin
      var _bytes: TBytes;
      var _err: string;
      if ( not TESApi.getGameMedia( FSettings, aSystemName, aGameId,
                                    'thumbnail', _bytes, _err ) ) then
         Exit;
      if ( Length( _bytes ) = 0 ) then Exit;
      TThread.Queue( nil, procedure
      begin
         if ( not Assigned( aTile ) ) or
            ( not Assigned( aTile.Parent ) ) then Exit;
         try
            // PNG/JPEG only for game thumbnails, no SVG scrape
            var _img: TSkAnimatedImage:= nil;
            for var ii:= 0 to Pred( aTile.ControlCount ) do  begin
               if ( aTile.Controls[ii] is TSkAnimatedImage ) then begin
                  _img:= ( aTile.Controls[ii] as TSkAnimatedImage );
                  Break;
               end;
            end;
            if ( _img <> nil ) then begin
               _img.Source.Data:= _bytes;
               _img.Visible:= True;
            end;
         except
         end;
      end );
   end );
end;

procedure TfrmRetrobatBrowser.loadSystems;
begin
   clearFlow;
   lblBreadcrumb.Caption:= 'Systems';
   btnBack.Visible:= False;
   FCurrentSystem:= '';

   TTask.Run( procedure
   begin
      var _response, _err: string;
      if ( not TESApi.getSystemList( FSettings, _response, _err ) ) then Exit;

      var _json:= TJSONObject.ParseJSONValue( _response ) as TJSONArray;
      if ( _json = nil ) then Exit;
      TThread.Queue( nil, procedure
      begin
         try
            flowPanel.DisableAlign;
            try
               for var ii:= 0 to Pred( _json.Count ) do begin
                  var _sys:= _json.Items[ii] as TJSONObject;
                  var _name:= _sys.GetValue<string>( 'name', '' );
                  var _fullname:= _sys.GetValue<string>( 'fullname', _name );
                  if ( _name.IsEmpty ) then Continue;
                  var _tile:= createTile( _fullname, _name );
                  loadSystemLogo( _tile, _name );
               end;
            finally
               flowPanel.EnableAlign;
            end;
         finally
            _json.Free;
         end;
      end );
   end );
end;

procedure TfrmRetrobatBrowser.loadGames( const aSystemName: string );
begin
   clearFlow;
   FCurrentSystem:= aSystemName;
   lblBreadcrumb.Caption:= 'Systems > ' + aSystemName;
   btnBack.Visible:= True;

   TTask.Run( procedure
   begin
      var _response, _err: string;
      if ( not TESApi.getSystemGames( FSettings, aSystemName,
                                      _response, _err ) ) then Exit;

      var _json:= TJSONObject.ParseJSONValue( _response ) as TJSONArray;
      if ( _json = nil ) then Exit;
      TThread.Queue( nil, procedure
      begin
         try
            flowPanel.DisableAlign;
            try
               for var ii:= 0 to Pred( _json.Count ) do begin
                  var _game:= _json.Items[ii] as TJSONObject;
                  var _name:= _game.GetValue<string>( 'name', '' );
                  var _id:= _game.GetValue<string>( 'id', '' );
                  if ( _name.IsEmpty ) then Continue;
                  var _tile:= createTile( _name, aSystemName, _id );
                  loadGameThumbnail( _tile, aSystemName, _id );
               end;
            finally
               flowPanel.EnableAlign;
            end;
         finally
            _json.Free;
         end;
      end );
   end );
end;

procedure TfrmRetrobatBrowser.btnBackClick( Sender: TObject );
begin
   loadSystems;
end;

end.
