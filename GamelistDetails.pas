unit GamelistDetails;

interface

uses
   System.Generics.Collections,
   Winapi.Windows, System.SysUtils, System.Classes,
   Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
   Vcl.ComCtrls, Vcl.ExtCtrls,
   Types, Constantes, Vcl.Menus;

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
      popActions: TPopupMenu;
      mniOpenFolder: TMenuItem;
      mniDeleteOrphan: TMenuItem;
      mniAddMissingMedia: TMenuItem;
      mniCopyExpectedHash: TMenuItem;
      mniScrapeGame: TMenuItem;
      pbScraping: TProgressBar;
      lblScraping: TLabel;
      procedure FormCreate( Sender: TObject );
      procedure cbxSystemsChange( Sender: TObject );
      procedure pgcMainMouseMove( Sender: TObject; Shift: TShiftState; X, Y: Integer );
      procedure btnVerifyHashesClick(Sender: TObject);
      procedure FormClose(Sender: TObject; var Action: TCloseAction);
      procedure FormDestroy(Sender: TObject);
      procedure lvMouseMove( Sender: TObject; Shift: TShiftState; X, Y: Integer );
      procedure lvContextPopup( Sender: TObject; MousePos: TPoint; var Handled: Boolean );
      procedure mniOpenFolderClick(Sender: TObject);
      procedure mniDeleteOrphanClick(Sender: TObject);
      procedure popActionsPopup(Sender: TObject);
      procedure mniAddMissingMediaClick(Sender: TObject);
      procedure mniCopyExpectedHashClick(Sender: TObject);
      procedure mniScrapeGameClick(Sender: TObject);

   private
      FResults: TObjectList<TGamelistResult>;
      FCancelled, FFormDestroyed: Boolean;
      FComputing, FSSAvailable: Boolean;
      FPreviousSystemIndex: Integer;
      FGameEntryRefs: TObjectList<TGameEntryRef>;
      FOnSummaryUpdate: TNotifyevent;
      FSSSystemsMapping: TDictionary<string, Integer>;
      FSSUserInfo: TSSUserInfo;
      FSettings: TSettings;
      FScrapingInProgress: Boolean;
      procedure populateComboBox;
      procedure populateListViews;
      procedure populateMissingRoms( const aResults: TArray<TGamelistResult> );
      procedure populateUnscraped( const aResults: TArray<TGamelistResult> );
      procedure populateMissingMedias( const aResults: TArray<TGamelistResult> );
      procedure populateOrphans( const aResults: TArray<TGamelistResult> );
      procedure populateNoMedia( const aResults: TArray<TGamelistResult> );
      procedure updateTabCaptions( const aResults: TArray<TGamelistResult> );
      function getFilteredResults: TArray<TGamelistResult>;
      function mediaTypeToStr( aMediaType: TMediaType ): string;
      function getOrCreateGroup( aListView: TListView; const aCaption: string ): Integer;
      procedure updateStats( const aResults: TArray<TGamelistResult> );
      function downloadIfAvailable( const aRipSource: string;
                                    const aXmlTag: string;
                                    const aFileSuffix: string;
                                    const aDestFolder: string;
                                    aMediaType: TMediaType;
                                    const aRomPath: string;
                                    const aLanguage: string;
                                    const aRegion: string;
                                    const aMedias: TArray<TSSMediaInfo>;
                                    out aError: string ): TGameMedia;

   public
      property OnSummaryUpdate: TNotifyEvent read FOnSummaryUpdate write FOnSummaryUpdate;
      property SSAvailable: Boolean read FSSAvailable write FSSAvailable;
      procedure setResults( aResults: TObjectList<TGamelistResult> );
      procedure setSSData( aSystemsMapping: TDictionary<string, Integer>;
                           const aUserInfo: TSSUserInfo;
                           aSettings: TSettings;
                           aSSAvailable: Boolean );

   end;

implementation

uses
   System.Types,
   System.UITypes,
   System.IOUtils,
   System.Threading,
   Vcl.Dialogs,
   Vcl.Clipbrd,
   Winapi.CommCtrl,
   Winapi.ShellAPI,
   HashUtils,
   RomUtils,
   ScreenScraperApi,
   GamelistParser;

{$R *.dfm}

procedure TfrmGamelistDetails.FormCreate( Sender: TObject );
begin
   cbxSystems.Items.Clear;
   FComputing:= False;
   FPreviousSystemIndex:= 0;
   FGameEntryRefs:= TObjectlist<TGameEntryRef>.Create( True );
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
   FGameEntryRefs.Free;
end;

procedure TfrmGamelistDetails.setResults( aResults: TObjectList<TGamelistResult> );
begin
   FResults:= aResults;
   populateComboBox;
   populateListViews;
end;

procedure TfrmGamelistDetails.setSSData( aSystemsMapping: TDictionary<string, Integer>;
                                          const aUserInfo: TSSUserInfo;
                                          aSettings: TSettings;
                                          aSSAvailable: Boolean );
begin
   FSSSystemsMapping:= aSystemsMapping;
   FSSUserInfo:= aUserInfo;
   FSettings:= aSettings;
   FSSAvailable:= aSSAvailable;
end;

procedure TfrmGamelistDetails.pgcMainMouseMove( Sender: TObject;
                                                Shift: TShiftState;
                                                X, Y: Integer );
begin
   // Only show hints when mouse is in the tab header area
   var _tabRect: TRect;
   Winapi.Windows.SendMessage( pgcMain.Handle, TCM_GETITEMRECT,
                               0, LPARAM( @_tabRect ) );
   if ( Y > _tabRect.Bottom ) then begin
      pgcMain.Hint:= '';
      Exit;
   end;

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

procedure TfrmGamelistDetails.lvMouseMove( Sender: TObject;
                                           Shift: TShiftState;
                                           X, Y: Integer );
begin
   pgcMain.Hint:= '';
end;

procedure TfrmGamelistDetails.lvContextPopup( Sender: TObject;
                                              MousePos: TPoint;
                                              var Handled: Boolean );
begin
   var _lv:= Sender as TListView;
   Handled:= ( _lv.Selected = nil );
end;

procedure TfrmGamelistDetails.popActionsPopup(Sender: TObject);
begin
   var _lv:= pgcMain.ActivePage.Controls[0] as TListView;

   if ( pgcMain.ActivePage = tbsOrphans ) then
      mniOpenFolder.Enabled:= ( _lv.Selected <> nil ) and
                              ( _lv.Selected.Data <> nil ) and
                              ( _lv.SelCount = 1 )
   else
      mniOpenFolder.Enabled:= ( _lv.Selected <> nil ) and
                              ( _lv.Selected.Data <> nil );

   mniDeleteOrphan.Visible:= ( pgcMain.ActivePage = tbsOrphans ) and
                             ( lvwOrphans.Selected <> nil );

   mniAddMissingMedia.Visible:= ( pgcMain.ActivePage = tbsMissingMedias ) and
                                ( lvwMissingMedias.Selected <> nil ) and
                                ( lvwMissingMedias.Selected.Data <> nil );

   mniCopyExpectedHash.Visible:= ( pgcMain.ActivePage = tbsHashMismatch ) and
                                 ( lvwHashMismatch.Selected <> nil );

   mniScrapeGame.Visible:= FSSAvailable and
                           ( pgcMain.ActivePage = tbsUnscraped ) and
                           ( lvwUnscraped.Selected <> nil ) and
                           ( lvwUnscraped.SelCount = 1 );

   mniScrapeGame.Enabled:= mniScrapeGame.Visible and
                           ( not FScrapingInProgress );
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
      Exit( FResults.ToArray );
   // Filter by selected system
   var _systemName:= cbxSystems.Items[cbxSystems.ItemIndex];
   SetLength( Result, 0 );
   for var _r in FResults do
      if ( _r.systemName = _systemName ) then
         Result:= Result+[_r];
end;

procedure TfrmGamelistDetails.btnVerifyHashesClick( Sender: TObject );
begin
   if ( MessageDlg( rstConfirmHashVerification,
                    mtConfirmation, [mbYes, mbNo], 0 ) ) = mrNo then
      Exit;

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
                           var _ref:= TGameEntryRef.Create;
                           _ref.systemName:= _r.systemName;
                           _ref.gameName:= _g.name;
                           _ref.romPath:= _g.romPath;
                           _ref.gamelistResult:= _r;
                           FGameEntryRefs.Add( _ref );
                           _item.Data:= _ref;
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
                           var _ref:= TGameEntryRef.Create;
                           _ref.systemName:= _r.systemName;
                           _ref.gameName:= _g.name;
                           _ref.romPath:= _g.romPath;
                           _ref.gamelistResult:= _r;
                           FGameEntryRefs.Add( _ref );
                           _item.Data:= _ref;
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
   FGameEntryRefs.Clear;
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
            var _ref:= TGameEntryRef.Create;
            _ref.systemName:= _r.systemName;
            _ref.gameName:= _gameName;
            _ref.romPath:= _path;
            _ref.gamelistResult:= _r;
            FGameEntryRefs.Add( _ref );
            _item.Data:= _ref;
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
            var _ref:= TGameEntryRef.Create;
            _ref.systemName:= _r.systemName;
            _ref.romPath:= _path;
            _ref.gamelistResult:= _r;
            FGameEntryRefs.Add( _ref );
            _item.Data:= _ref;
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
                  var _ref:= TGameEntryRef.Create;
                  _ref.systemName:= _r.systemName;
                  _ref.gameName:= _g.name;
                  _ref.romPath:= _g.romPath;
                  _ref.mediaPath:= _m.path;
                  _ref.gamelistResult:= _r;
                  FGameEntryRefs.Add( _ref );
                  _item.Data:= _ref;
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
            var _ref:= TGameEntryRef.Create;
            _ref.systemName:= _r.systemName;
            _ref.mediaPath:= _path;
            _ref.gamelistResult:= _r;
            FGameEntryRefs.Add( _ref );
            _item.Data:= _ref;
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
               var _ref:= TGameEntryRef.Create;
               _ref.systemName:= _r.systemName;
               _ref.gameName:= _g.name;
               _ref.romPath:= _g.romPath;
               _ref.gamelistResult:= _r;
               FGameEntryRefs.Add( _ref );
               _item.Data:= _ref;
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

function TfrmGamelistDetails.mediaTypeToStr( aMediaType: TMediaType ): string;
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

procedure TfrmGamelistDetails.mniAddMissingMediaClick( Sender: TObject );
begin
   if ( lvwMissingMedias.Selected = nil ) or
      ( lvwMissingMedias.Selected.Data = nil ) then
      Exit;
   var _ref:= TGameEntryRef( lvwMissingMedias.Selected.Data );
   var _targetPath:= _ref.mediaPath;
   var _ext:= TPath.GetExtension( _targetPath );
   var _dlg:= TOpenDialog.Create( Self );
   try
      _dlg.Title:= rstOpenDlgCaption+' '+_ref.gameName+
                   ' '+rstWillBeSavedAs+' '+TPath.GetFileName( _targetPath )+')';
      _dlg.Filter:= 'Media files (*'+_ext+')|*'+_ext+'|All files (*.*)|*.*';
      _dlg.FileName:= '';
      if ( _dlg.Execute ) then begin
         Screen.Cursor:= crHourGlass;
         try
            var _targetDir:= TPath.GetDirectoryName( _targetPath );
            if ( not TDirectory.Exists( _targetDir ) ) then
               TDirectory.CreateDirectory( _targetDir );
            TFile.Copy( _dlg.FileName, _targetPath, False );
            // Update FResults directly via reference
            var _list:= TList<string>.Create;
            try
               for var s in _ref.gamelistResult.missingMedias do
                  if ( s <> _ref.mediaPath ) then
                     _list.Add( s );
               _ref.gamelistResult.missingMedias:= _list.ToArray;
            finally
               _list.Free;
            end;
            lvwMissingMedias.Selected.Free;
            tbsMissingMedias.Caption:= Format( rstMissingMediasNb, [lvwMissingMedias.Items.Count] );
            if Assigned( FOnSummaryUpdate ) then
               FOnSummaryUpdate( Self );
         finally
            Screen.Cursor:= crDefault;
         end;
      end;
   finally
      _dlg.Free;
   end;
end;

procedure TfrmGamelistDetails.mniCopyExpectedHashClick( Sender: TObject );
begin
   if ( lvwHashMismatch.Selected = nil ) then
      Exit;
   var _hash:= lvwHashMismatch.Selected.SubItems[2];
   if ( not _hash.IsEmpty ) then
      Clipboard.AsText:= _hash;
end;

procedure TfrmGamelistDetails.mniDeleteOrphanClick( Sender: TObject );
begin
   if ( lvwOrphans.SelCount = 0 ) then
      Exit;

   if ( MessageDlg( Format( rstDeleteOrphans, [lvwOrphans.SelCount] ),
                    mtConfirmation, [mbYes, mbNo], 0 ) = mrNo ) then
      Exit;

   Screen.Cursor:= crHourGlass;
   try
      var _item:= lvwOrphans.Selected;
      while ( _item <> nil ) do begin
         var _next:= lvwOrphans.GetNextItem( _item, sdAll, [isSelected] );
         if ( _item.Data <> nil ) then begin
            var _ref:= TGameEntryRef( _item.Data );
            if ( TFile.Exists( _ref.mediaPath ) ) then begin
               TFile.Delete( _ref.mediaPath );
               var _list:= TList<string>.Create;
               try
                  for var s in _ref.gamelistResult.orphanMedias do
                     if ( s <> _ref.mediaPath ) then
                        _list.Add( s );
                  _ref.gamelistResult.orphanMedias:= _list.ToArray;
               finally
                  _list.Free;
               end;
               _item.Free;
            end;
         end;
         _item:= _next;
      end;
   finally
      Screen.Cursor:= crDefault;
   end;

   tbsOrphans.Caption:= Format( rstOrphansNb, [lvwOrphans.Items.Count] );
   if Assigned( FOnSummaryUpdate ) then
      FOnSummaryUpdate( Self );
end;

procedure TfrmGamelistDetails.mniOpenFolderClick( Sender: TObject );
begin
   var _lv:= pgcMain.ActivePage.Controls[0] as TListView;
   if ( _lv.Selected = nil ) or
      ( _lv.Selected.Data = nil ) then
      Exit;
   var _ref:= TGameEntryRef( _lv.Selected.Data );
   var _path:= _ref.romPath;
   if ( _path.IsEmpty ) then
      _path:= _ref.mediaPath;
   if ( _path.IsEmpty ) then
      Exit;
   var _folder:= TPath.GetDirectoryName( _path );
   if ( TDirectory.Exists( _folder ) ) then
      ShellExecute( Handle, 'open', PChar( _folder ), nil, nil, SW_SHOWNORMAL );
end;

procedure TfrmGamelistDetails.mniScrapeGameClick( Sender: TObject );
begin
   if ( lvwUnscraped.Selected = nil ) or
      ( lvwUnscraped.Selected.Data = nil ) then
      Exit;

   var _ref:= TGameEntryRef( lvwUnscraped.Selected.Data );

   // Find system ID in mapping
   if not FSSSystemsMapping.ContainsKey( LowerCase( _ref.systemName ) ) then begin
      ShowMessage( 'System "' + _ref.systemName + '" not found in ScreenScraper mapping.' );
      Exit;
   end;

   var _systemId:= FSSSystemsMapping[ LowerCase( _ref.systemName ) ];
   var _romPath:= _ref.romPath;
   var _romDir:= _ref.gamelistResult.romDir;
   var _systemName:= _ref.systemName;

   FScrapingInProgress:= True;
   lblScraping.Visible:= True;
   pbScraping.Visible:= True;
   lvwUnscraped.Items.BeginUpdate;

   TTask.Run( procedure
   begin
      try
         var _gameInfo: TSSGameInfo;
         var _err: string;

         // Region for media selection
         var _mediaRegion:= FSettings.favRegion;

         // Lang and region for gamelist tags
         var _langInfo:= detectRomLangAndRegion( _romPath, _ref.systemName );
         var _romRegion:= _langInfo.region;
         if _romRegion.IsEmpty then
            _romRegion:= FSettings.favRegion;

         var _result:= getGameInfo( FSettings.ssUserId, FSettings.ssPassword,
                                    _systemId, _romPath,
                                    FSettings.scrapeLanguage, _mediaRegion,
                                    _gameInfo, _err );

         TThread.Queue( nil, procedure
         begin
            if FFormDestroyed then Exit;

            case _result of
               ssrNotFound:
                  ShowMessage( 'Game not found on ScreenScraper : ' + TPath.GetFileName( _romPath ) );

               ssrQuotaExceeded:
                  ShowMessage( 'ScreenScraper quota exceeded. Try again later.' );

               ssrError:
                  ShowMessage( 'ScreenScraper error : ' + _err );

               ssrOK: begin
                  var _downloadedMedias:= TList<TGameMedia>.Create;
                  try
                     // Configurable sources
                     var _gm:= downloadIfAvailable( FSettings.scrapeImageSrc, cstXmlImage,
                                                    cstXmlImage, TPath.Combine( _romDir, cstImages ),
                                                    mtImage, _romPath, FSettings.scrapeLanguage,
                                                    _mediaRegion, _gameInfo.medias, _err );
                     if ( _gm.exists ) then _downloadedMedias.Add( _gm );

                     if ( FSettings.scrapeThumbSrc <> FSettings.scrapeImageSrc ) then begin
                        _gm:= downloadIfAvailable( FSettings.scrapeThumbSrc, cstXmlThumbnail,
                                                   cstThumbFileSuffix, TPath.Combine( _romDir, cstImages ),
                                                   mtThumbnail, _romPath, FSettings.scrapeLanguage,
                                                   _mediaRegion, _gameInfo.medias, _err );
                        if ( _gm.exists ) then _downloadedMedias.Add( _gm );
                     end;

                     _gm:= downloadIfAvailable( FSettings.scrapeLogoSrc, cstXmlMarquee,
                                                cstXmlMarquee, TPath.Combine( _romDir, cstImages ),
                                                mtMarquee, _romPath, FSettings.scrapeLanguage,
                                                _mediaRegion, _gameInfo.medias, _err );
                     if ( _gm.exists ) then _downloadedMedias.Add( _gm );

                     // Fixed media types
                     if ( FSettings.scrapeVideos ) then begin
                        _gm:= downloadIfAvailable( cstSSMediaVideo, cstXmlVideo,
                                                   cstXmlVideo, TPath.Combine( _romDir, cstVideos ),
                                                   mtVideo, _romPath, FSettings.scrapeLanguage,
                                                   _mediaRegion, _gameInfo.medias, _err );
                        if ( _gm.exists ) then _downloadedMedias.Add( _gm );
                     end;

                     if ( FSettings.scrapeFanart ) then begin
                        _gm:= downloadIfAvailable( cstSSMediaFanart, cstXmlFanart,
                                                   cstXmlFanart, TPath.Combine( _romDir, cstImages ),
                                                   mtFanart, _romPath, FSettings.scrapeLanguage,
                                                   _mediaRegion, _gameInfo.medias, _err );
                        if ( _gm.exists ) then _downloadedMedias.Add( _gm );
                     end;

                     if ( FSettings.scrapeBoxBack ) then begin
                        _gm:= downloadIfAvailable( cstSSMediaBoxBack, cstXmlBoxBack,
                                                   cstXmlBoxBack, TPath.Combine( _romDir, cstImages ),
                                                   mtBoxBack, _romPath, FSettings.scrapeLanguage,
                                                   _mediaRegion, _gameInfo.medias, _err );
                        if ( _gm.exists ) then _downloadedMedias.Add( _gm );
                     end;

                     if ( FSettings.scrapeManual ) then begin
                        _gm:= downloadIfAvailable( cstSSMediaManual, cstXmlManual,
                                                   cstXmlManual, TPath.Combine( _romDir, cstManuals ),
                                                   mtManual, _romPath, FSettings.scrapeLanguage,
                                                   _mediaRegion, _gameInfo.medias, _err );
                        if ( _gm.exists ) then _downloadedMedias.Add( _gm );
                     end;

                     if ( FSettings.scrapeMap ) then begin
                        _gm:= downloadIfAvailable( cstSSMediaMap, cstXmlMap,
                                                   cstXmlMap, TPath.Combine( _romDir, cstImages ),
                                                   mtMap, _romPath, FSettings.scrapeLanguage,
                                                   _mediaRegion, _gameInfo.medias, _err );
                        if ( _gm.exists ) then _downloadedMedias.Add( _gm );
                     end;

                     if ( FSettings.scrapeBezel ) then begin
                        _gm:= downloadIfAvailable( cstSSMediaBezel, cstXmlBezel,
                                                   cstXmlBezel, TPath.Combine( _romDir, cstImages ),
                                                   mtBezel, _romPath, FSettings.scrapeLanguage,
                                                   _mediaRegion, _gameInfo.medias, _err );
                        if ( _gm.exists ) then _downloadedMedias.Add( _gm );
                     end;

                     // Build game entry and write to gamelist
                     var _entry:= Default( TGameEntry );
                     _entry.id           := _gameInfo.id;
                     _entry.name         := _gameInfo.name;
                     _entry.desc         := _gameInfo.desc;
                     _entry.genre        := _gameInfo.genre;
                     _entry.family       := _gameInfo.family;
                     _entry.arcadeSystem := _gameInfo.arcadeSystem;
                     _entry.rating       := _gameInfo.rating;
                     _entry.releaseDate  := _gameInfo.releaseDate;
                     _entry.developer    := _gameInfo.developer;
                     _entry.publisher    := _gameInfo.publisher;
                     _entry.players      := _gameInfo.players;
                     _entry.lang         := _langInfo.language;
                     _entry.region       := _romRegion;
                     _entry.romPath      := _romPath;
                     _entry.md5          := fileMD5( _romPath );
                     _entry.crc32        := fileCRC32( _romPath );
                     _entry.medias       := _downloadedMedias.ToArray;
                     _entry.isScraped    := _downloadedMedias.Count > 0;

                     addGameToGamelist( _romDir, _entry );
                  finally
                     _downloadedMedias.Free;
                  end;
               end;
            end;

            lvwUnscraped.Items.EndUpdate;
            FScrapingInProgress:= False;
            lblScraping.Visible:= False;
            pbScraping.Visible:= False;
            if ( _result = ssrOK ) then
               ShowMessage( rstGameScrapedSuccessfully );
         end );
      except
         on E: Exception do
            TThread.Queue( nil, procedure
            begin
               if FFormDestroyed then Exit;
               ShowMessage( 'Unexpected error : ' + E.Message );
               lvwUnscraped.Items.EndUpdate;
               FScrapingInProgress:= False;
               lblScraping.Visible:= False;
               pbScraping.Visible:= False;
            end );
      end;
   end );
end;

function TfrmGamelistDetails.downloadIfAvailable( const aRipSource: string;
                                                  const aXmlTag: string;
                                                  const aFileSuffix: string;
                                                  const aDestFolder: string;
                                                  aMediaType: TMediaType;
                                                  const aRomPath: string;
                                                  const aLanguage: string;
                                                  const aRegion: string;
                                                  const aMedias: TArray<TSSMediaInfo>;
                                                  out aError: string ): TGameMedia;
begin
   Result:= Default( TGameMedia );
   aError:= '';

   var _ripList:= getRipList( aRipSource );
   if ( Length( _ripList ) = 0 ) then Exit;

   var _best:= findBestMedia( aMedias, _ripList, aLanguage, aRegion );
   if ( _best.url.IsEmpty ) then Exit;

   var _romName:= TPath.GetFileNameWithoutExtension( aRomPath );
   var _destPath:= TPath.Combine( aDestFolder,
                                  _romName+'-'+aFileSuffix+'.'+_best.format );

   if ( downloadMedia( _best.url, _destPath, aError ) ) then begin
      Result.mediaType:= aMediaType;
      Result.path:= _destPath;
      Result.exists:= True;
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
