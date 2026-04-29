unit GamelistDetails;

interface

uses
   Winapi.Windows, System.SysUtils, System.Classes,
   Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
   Vcl.ComCtrls, Vcl.ExtCtrls,
   Types, Constantes;

type
   TfrmGamelistDetails = class( TForm )
      pnlTop: TPanel;
      lblSystem: TLabel;
      cbxSystems: TComboBox;
      pgcMain: TPageControl;
      tbsMissingRoms: TTabSheet;
      lvwMissingRoms: TListView;
      tbsUnscraped: TTabSheet;
      lvwUnscraped: TListView;
      tbsMissingMedias: TTabSheet;
      lvwMissingMedias: TListView;
      tbsOrphans: TTabSheet;
      lvwOrphans: TListView;
      lblStats: TLabel;
      tbsNoMedia: TTabSheet;
      lvwNoMedia: TListView;
      btnVerifyHashes: TButton;
      tbsHashMismatch: TTabSheet;
      lvwHashMismatch: TListView;
      procedure FormCreate( Sender: TObject );
      procedure cbxSystemsChange( Sender: TObject );
      procedure pgcMainMouseMove( Sender: TObject; Shift: TShiftState; X, Y: Integer );
      procedure btnVerifyHashesClick(Sender: TObject);
      procedure FormClose(Sender: TObject; var Action: TCloseAction);
      procedure FormDestroy(Sender: TObject);

   private
      FResults: TArray<TGamelistResult>;
      FCancelled, FFormDestroyed: Boolean;
      FComputing: Boolean;
      FPreviousSystemIndex: Integer;
      procedure populateComboBox;
      procedure populateListViews;
      procedure populateMissingRoms( const aResults: TArray<TGamelistResult> );
      procedure populateUnscraped( const aResults: TArray<TGamelistResult> );
      procedure populateMissingMedias( const aResults: TArray<TGamelistResult> );
      procedure populateOrphans( const aResults: TArray<TGamelistResult> );
      procedure populateNoMedia( const aResults: TArray<TGamelistResult> );
      procedure updateTabCaptions( const aResults: TArray<TGamelistResult> );
      function getFilteredResults: TArray<TGamelistResult>;
      function mediaTypeToStr( const aMediaType: TMediaType ): string;
      function getOrCreateGroup( aListView: TListView; const aCaption: string ): Integer;
      procedure updateStats( const aResults: TArray<TGamelistResult> );

   public
      procedure setResults( const aResults: TArray<TGamelistResult> );

   end;

implementation

uses
   System.Types,
   System.UITypes,
   System.IOUtils,
   System.Threading,
   Vcl.Dialogs,
   Winapi.CommCtrl,
   HashUtils;

{$R *.dfm}

procedure TfrmGamelistDetails.FormCreate( Sender: TObject );
begin
   cbxSystems.Items.Clear;
   FComputing:= False;
   FPreviousSystemIndex:= 0;
end;

procedure TfrmGamelistDetails.FormClose( Sender: TObject; var Action: TCloseAction );
begin
   if ( FComputing ) then begin
      FCancelled:= True;
      while ( FComputing ) do
         Application.ProcessMessages;
   end;
end;

procedure TfrmGamelistDetails.FormDestroy(Sender: TObject);
begin
   FCancelled:= True;
   FFormDestroyed:= True;
end;

procedure TfrmGamelistDetails.setResults( const aResults: TArray<TGamelistResult> );
begin
   FResults:= aResults;
   populateComboBox;
   populateListViews;
end;

procedure TfrmGamelistDetails.pgcMainMouseMove( Sender: TObject;
                                                Shift: TShiftState;
                                                X, Y: Integer );
begin
   for var ii:= 0 to Pred( pgcMain.PageCount ) do begin
      var _rect: TRect;
      Winapi.Windows.SendMessage( pgcMain.Handle, TCM_GETITEMRECT,
                                  ii, LPARAM( @_rect ) );
      if ( _rect.Contains( Point( X, Y ) ) ) then begin
         if ( ii <= High( cstHints ) ) then
            pgcMain.Hint:= cstHints[ii]
         else
            pgcMain.Hint:= '';
         Exit;
      end;
   end;
   pgcMain.Hint:= '';
end;

procedure TfrmGamelistDetails.populateComboBox;
begin
   cbxSystems.Items.BeginUpdate;
   cbxSystems.Items.Clear;
   try
      cbxSystems.Items.Add( 'All systems' );
      for var _r in FResults do
         cbxSystems.Items.Add( _r.systemName );
   finally
      cbxSystems.Items.EndUpdate;
   end;
   cbxSystems.ItemIndex:= 0;
end;

function TfrmGamelistDetails.getFilteredResults: TArray<TGamelistResult>;
begin
   // Index 0 = All systems
   if ( cbxSystems.ItemIndex <= 0 ) then
      Exit( FResults );
   // Filter by selected system
   var _systemName:= cbxSystems.Items[cbxSystems.ItemIndex];
   SetLength( Result, 0 );
   for var _r in FResults do
      if ( _r.systemName = _systemName ) then
         Result:= Result+[_r];
end;

procedure TfrmGamelistDetails.btnVerifyHashesClick( Sender: TObject );
begin
   Screen.Cursor:= crHourGlass;
   btnVerifyHashes.Enabled:= False;
   btnVerifyHashes.Caption:= rstComputing;
   tbsHashMismatch.TabVisible:= False;
   lvwHashMismatch.Items.Clear;
   FComputing:= True;

   FCancelled:= False;
   var _filtered:= getFilteredResults;

   TTask.Run( procedure
   begin
      try
         for var _r in _filtered do begin
            if ( FCancelled ) then
               Exit;
            for var _g in _r.games do begin
               if ( FCancelled ) then
                  Exit;
               if ( not _g.romPath.IsEmpty and TFile.Exists( _g.romPath ) ) then begin
                  if ( not _g.md5.IsEmpty ) then begin
                     var _actualMD5:= fileMD5( _g.romPath );
                     if ( FCancelled ) then
                        Exit;
                     if ( _actualMD5 <> LowerCase( _g.md5 ) ) then
                        TThread.Synchronize( nil, procedure
                        begin
                           if ( FFormDestroyed ) then Exit;
                           var _item:= lvwHashMismatch.Items.Add;
                           _item.Caption:= _r.systemName;
                           _item.SubItems.Add( _g.name );
                           _item.SubItems.Add( TPath.GetFileName( _g.romPath ) );
                           _item.SubItems.Add( LowerCase( _g.md5 ) );
                           _item.SubItems.Add( _actualMD5 );
                           _item.SubItems.Add( 'MD5' );
                        end );
                  end;

                  if ( not _g.crc32.IsEmpty ) then begin
                     var _actualCRC32:= fileCRC32( _g.romPath );
                     if ( FCancelled ) then
                        Exit;
                     if ( _actualCRC32 <> LowerCase( _g.crc32 ) ) then
                        TThread.Synchronize( nil, procedure
                        begin
                           if ( FFormDestroyed ) then Exit;
                           var _item:= lvwHashMismatch.Items.Add;
                           _item.Caption:= _r.systemName;
                           _item.SubItems.Add( _g.name );
                           _item.SubItems.Add( TPath.GetFileName( _g.romPath ) );
                           _item.SubItems.Add( LowerCase( _g.crc32 ) );
                           _item.SubItems.Add( _actualCRC32 );
                           _item.SubItems.Add( 'CRC32' );
                        end );
                  end;

               end;
            end;
         end;
      finally
         TThread.Synchronize( nil, procedure
         begin
            if ( FFormDestroyed ) then Exit;
            FComputing:= False;
            for var ii:= 0 to Pred( lvwHashMismatch.Columns.Count ) do
               lvwHashMismatch.Columns[ii].Width:= -2;
            btnVerifyHashes.Enabled:= True;
            btnVerifyHashes.Caption:= rstVerifyHashes;
            tbsHashMismatch.TabVisible:= ( lvwHashMismatch.Items.Count > 0 );
            if ( tbsHashMismatch.TabVisible ) then
               pgcMain.ActivePage:= tbsHashMismatch
            else
               ShowMessage( rstNoHashMismatch );
            Screen.Cursor:= crDefault;
         end );
      end;
   end );
end;

procedure TfrmGamelistDetails.cbxSystemsChange( Sender: TObject );
begin
   if ( FComputing ) then begin
      if MessageDlg( rstCancelHashVerification,
                     mtConfirmation, [mbYes, mbNo], 0 ) = mrYes then
         FCancelled:= True
      else begin
         cbxSystems.OnChange:= nil;
         cbxSystems.ItemIndex:= FPreviousSystemIndex;
         cbxSystems.OnChange:= cbxSystemsChange;
         Exit;
      end;
   end;

   // Reset hash tab
   tbsHashMismatch.TabVisible:= False;
   lvwHashMismatch.Items.Clear;

   var _filtered:= getFilteredResults;
   var _hasHashes:= False;
   if cbxSystems.ItemIndex > 0 then begin
      for var _r in _filtered do
         for var _g in _r.games do
            if not _g.md5.IsEmpty or not _g.crc32.IsEmpty then begin
               _hasHashes:= True;
               Break;
            end;
   end;
   btnVerifyHashes.Visible:= _hasHashes;
   if btnVerifyHashes.Visible then
      lblStats.Left:= btnVerifyHashes.Left + btnVerifyHashes.Width + cstMargin
   else
      lblStats.Left:= btnVerifyHashes.Left;
   populateListViews;
end;

procedure TfrmGamelistDetails.populateListViews;
begin
   var _filtered:= getFilteredResults;
   populateMissingRoms( _filtered );
   populateUnscraped( _filtered );
   populateMissingMedias( _filtered );
   populateOrphans( _filtered );
   populateNoMedia( _filtered );
   updateTabCaptions( _filtered );
   // Auto-resize columns
   for var ii:= 0 to Pred( lvwMissingRoms.Columns.Count ) do
      lvwMissingRoms.Columns[ii].Width:= -2;
   for var ii:= 0 to Pred( lvwUnscraped.Columns.Count ) do
      lvwUnscraped.Columns[ii].Width:= -2;
   for var ii:= 0 to Pred( lvwMissingMedias.Columns.Count ) do
      lvwMissingMedias.Columns[ii].Width:= -2;
   for var ii:= 0 to Pred( lvwOrphans.Columns.Count ) do
      lvwOrphans.Columns[ii].Width:= -2;
   for var ii:= 0 to Pred( lvwNoMedia.Columns.Count ) do
      lvwNoMedia.Columns[ii].Width:= -2;
   updateStats( _filtered );
end;

function TfrmGamelistDetails.getOrCreateGroup( aListView: TListView;
                                               const aCaption: string ): Integer;
begin
   for var ii:= 0 to Pred( aListView.Groups.Count ) do
      if ( aListView.Groups[ii].Header = aCaption ) then begin
         Result:= aListView.Groups[ii].GroupID;
         Exit;
      end;
   var _g:= aListView.Groups.Add;
   _g.Header:= aCaption;
   _g.State:= [lgsNormal];
   Result:= _g.GroupID;
end;

procedure TfrmGamelistDetails.populateMissingRoms( const aResults: TArray<TGamelistResult> );
begin
   lvwMissingRoms.GroupView:= False;
   lvwMissingRoms.Items.BeginUpdate;
   lvwMissingRoms.Groups.Clear;
   lvwMissingRoms.Items.Clear;
   try
      for var _r in aResults do
         for var _path in _r.missingROMs do begin
            var _item:= lvwMissingRoms.Items.Add;
            _item.Caption:= _r.systemName;
            var _gameName:= '';
            for var _g in _r.games do
               if ( _g.romPath = _path ) then begin
                  _gameName:= _g.name;
                  Break;
               end;
            _item.SubItems.Add( _gameName );
            _item.SubItems.Add( _path );
            if ( cbxSystems.ItemIndex = 0 ) then
               _item.GroupID:= getOrCreateGroup( lvwMissingRoms, _r.systemName );
         end;
   finally
      lvwMissingRoms.Items.EndUpdate;
      lvwMissingRoms.GroupView:= ( cbxSystems.ItemIndex = 0 ) and
                                  ( lvwMissingRoms.Groups.Count > 0 );
   end;
end;

procedure TfrmGamelistDetails.populateUnscraped( const aResults: TArray<TGamelistResult> );
begin
   lvwUnscraped.GroupView:= False;
   lvwUnscraped.Items.BeginUpdate;
   lvwUnscraped.Groups.Clear;
   lvwUnscraped.Items.Clear;
   try
      for var _r in aResults do
         for var _path in _r.unscrapedROMs do begin
            var _item:= lvwUnscraped.Items.Add;
            _item.Caption:= _r.systemName;
            _item.SubItems.Add( _path );
            if ( cbxSystems.ItemIndex = 0 ) then
               _item.GroupID:= getOrCreateGroup( lvwUnscraped, _r.systemName );
         end;
   finally
      lvwUnscraped.Items.EndUpdate;
      lvwUnscraped.GroupView:= ( cbxSystems.ItemIndex = 0 ) and
                                ( lvwUnscraped.Groups.Count > 0 );
   end;
end;

procedure TfrmGamelistDetails.populateMissingMedias( const aResults: TArray<TGamelistResult> );
begin
   lvwMissingMedias.GroupView:= False;
   lvwMissingMedias.Items.BeginUpdate;
   lvwMissingMedias.Groups.Clear;
   lvwMissingMedias.Items.Clear;
   try
      for var _r in aResults do
         for var _g in _r.games do
            for var _m in _g.medias do
               if ( not _m.exists ) then begin
                  var _item:= lvwMissingMedias.Items.Add;
                  _item.Caption:= _r.systemName;
                  _item.SubItems.Add( _g.name );
                  _item.SubItems.Add( mediaTypeToStr( _m.mediaType ) );
                  _item.SubItems.Add( _m.path );
                  if ( cbxSystems.ItemIndex = 0 ) then
                     _item.GroupID:= getOrCreateGroup( lvwMissingMedias, _r.systemName );
               end;
   finally
      lvwMissingMedias.Items.EndUpdate;
      lvwMissingMedias.GroupView:= ( cbxSystems.ItemIndex = 0 ) and
                                    ( lvwMissingMedias.Groups.Count > 0 );
   end;
end;

procedure TfrmGamelistDetails.populateOrphans( const aResults: TArray<TGamelistResult> );
begin
   lvwOrphans.GroupView:= False;
   lvwOrphans.Items.BeginUpdate;
   lvwOrphans.Groups.Clear;
   lvwOrphans.Items.Clear;
   try
      for var _r in aResults do
         for var _path in _r.orphanMedias do begin
            var _item:= lvwOrphans.Items.Add;
            _item.Caption:= _r.systemName;
            _item.SubItems.Add( _path );
            if ( cbxSystems.ItemIndex = 0 ) then
               _item.GroupID:= getOrCreateGroup( lvwOrphans, _r.systemName );
         end;
   finally
      lvwOrphans.Items.EndUpdate;
      lvwOrphans.GroupView:= ( cbxSystems.ItemIndex = 0 ) and
                              ( lvwOrphans.Groups.Count > 0 );
   end;
end;

procedure TfrmGamelistDetails.populateNoMedia( const aResults: TArray<TGamelistResult> );
begin
   lvwNoMedia.GroupView:= False;
   lvwNoMedia.Items.BeginUpdate;
   lvwNoMedia.Groups.Clear;
   lvwNoMedia.Items.Clear;
   try
      for var _r in aResults do
         for var _g in _r.games do
            if not _g.isScraped then begin
               var _item:= lvwNoMedia.Items.Add;
               _item.Caption:= _r.systemName;
               _item.SubItems.Add( _g.name );
               _item.SubItems.Add( _g.romPath );
               if ( cbxSystems.ItemIndex = 0 ) then
                  _item.GroupID:= getOrCreateGroup( lvwNoMedia, _r.systemName );
            end;
   finally
      lvwNoMedia.Items.EndUpdate;
      lvwNoMedia.GroupView:= ( cbxSystems.ItemIndex = 0 ) and
                              ( lvwNoMedia.Groups.Count > 0 );
   end;
end;

procedure TfrmGamelistDetails.updateTabCaptions( const aResults: TArray<TGamelistResult> );
begin
   var _missingRoms:= 0;
   var _unscraped:= 0;
   var _missingMedias:= 0;
   var _orphans:= 0;
   var _noMedia:= 0;
   for var _r in aResults do begin
      Inc( _missingRoms, Length( _r.missingROMs ) );
      Inc( _unscraped, Length( _r.unscrapedROMs ) );
      Inc( _orphans, Length( _r.orphanMedias ) );
      for var _g in _r.games do begin
         if ( not _g.isScraped ) then
            Inc( _noMedia );
         for var _m in _g.medias do
            if ( not _m.exists ) then
               Inc( _missingMedias );
      end;
   end;
   tbsMissingRoms.Caption:= Format( rstMissingRomsNb, [_missingRoms] );
   tbsUnscraped.Caption:= Format( rstUnscrapedNb, [_unscraped] );
   tbsMissingMedias.Caption:= Format( rstMissingMediasNb, [_missingMedias] );
   tbsOrphans.Caption:= Format( rstOrphansNb, [_orphans] );
   tbsNoMedia.Caption:= Format( rstNoMediaNb, [_noMedia] );
end;

function TfrmGamelistDetails.mediaTypeToStr( const aMediaType: TMediaType ): string;
begin
   case aMediaType of
      mtImage     : Result:= rstImage;
      mtVideo     : Result:= rstVideo;
      mtMarquee   : Result:= rstMarquee;
      mtThumbnail : Result:= rstThumbnail;
      mtFanart    : Result:= rstFanart;
      mtTitleshot : Result:= rstTitleshot;
      mtManual    : Result:= rstManual;
      mtMagazine  : Result:= rstMagazine;
      mtMap       : Result:= rstMap;
      mtBezel     : Result:= rstBezel;
      mtCartridge : Result:= rstCartridge;
      mtBoxArt    : Result:= rstBoxArt;
      mtBoxBack   : Result:= rstBoxBack;
      mtWheel     : Result:= rstWheel;
      mtMix       : Result:= rstMix;
   else
      Result:= '?';
   end;
end;

procedure TfrmGamelistDetails.updateStats( const aResults: TArray<TGamelistResult> );
begin
   var _games:= 0;
   var _scraped:= 0;
   var _romsOnDisk:= 0;
   for var _r in aResults do begin
      Inc( _games, Length( _r.games ) );
      Inc( _romsOnDisk, _r.totalRoms );
      for var _g in _r.games do
         if _g.isScraped then
            Inc( _scraped );
   end;
   lblStats.Caption:= Format( rstSystemStats,
                              [_games, _scraped, _romsOnDisk] );
end;

end.
