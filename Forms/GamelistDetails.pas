unit GamelistDetails;

interface

uses
   System.Generics.Collections,
   Winapi.Windows, System.SysUtils, System.Classes,
   Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
   Vcl.ComCtrls, Vcl.ExtCtrls,
   Types, Constantes, Vcl.Menus, VirtualTrees.BaseAncestorVCL,
   VirtualTrees.BaseTree, VirtualTrees.AncestorVCL, VirtualTrees,
   VirtualTrees.Types;

type
   TfrmGamelistDetails = class( TForm )
      pnlTop: TPanel;
      lblSystem: TLabel;
      cbxSystems: TComboBox;
      pgcMain: TPageControl;
      tbsMissingRoms: TTabSheet;
      tbsUnscraped: TTabSheet;
      tbsMissingMedias: TTabSheet;
      tbsOrphans: TTabSheet;
      lblStats: TLabel;
      tbsNoMedia: TTabSheet;
      btnVerifyHashes: TButton;
      tbsHashMismatch: TTabSheet;
      popActions: TPopupMenu;
      mniOpenFolder: TMenuItem;
      mniDeleteOrphan: TMenuItem;
      mniAddMissingMedia: TMenuItem;
      mniCopyExpectedHash: TMenuItem;
      mniScrapeGame: TMenuItem;
      pbScraping: TProgressBar;
      lblScraping: TLabel;
      mniScrapeMedias: TMenuItem;
      btnCancelScrape: TButton;
      mniDeleteMissingROM: TMenuItem;
      vstMissingRoms: TVirtualStringTree;
      vstUnscraped: TVirtualStringTree;
      vstNoMedia: TVirtualStringTree;
      vstMissingMedias: TVirtualStringTree;
      vstOrphans: TVirtualStringTree;
      vstHashMismatch: TVirtualStringTree;
      procedure FormCreate( Sender: TObject );
      procedure cbxSystemsChange( Sender: TObject );
      procedure pgcMainMouseMove( Sender: TObject; Shift: TShiftState; X, Y: Integer );
      procedure btnVerifyHashesClick(Sender: TObject);
      procedure FormClose(Sender: TObject; var Action: TCloseAction);
      procedure FormDestroy(Sender: TObject);
      procedure mniOpenFolderClick(Sender: TObject);
      procedure mniDeleteOrphanClick(Sender: TObject);
      procedure popActionsPopup(Sender: TObject);
      procedure mniAddMissingMediaClick(Sender: TObject);
      procedure mniCopyExpectedHashClick(Sender: TObject);
      procedure mniScrapeGameClick(Sender: TObject);
      procedure mniScrapeMediasClick(Sender: TObject);
      procedure btnCancelScrapeClick(Sender: TObject);
      procedure mniDeleteMissingROMClick(Sender: TObject);
      procedure vstMissingRomsGetText( Sender: TBaseVirtualTree;
                                       Node: PVirtualNode;
                                       Column: TColumnIndex;
                                       TextType: TVSTTextType;
                                       var CellText: string );
      procedure vstMissingRomsPaintText( Sender: TBaseVirtualTree;
                                         const TargetCanvas: TCanvas;
                                         Node: PVirtualNode;
                                         Column: TColumnIndex;
                                         TextType: TVSTTextType );
      procedure vstMissingRomsFreeNode( Sender: TBaseVirtualTree;
                                        Node: PVirtualNode );
      procedure vstUnscrapedFreeNode( Sender: TBaseVirtualTree;
                                      Node: PVirtualNode );
      procedure vstUnscrapedGetText( Sender: TBaseVirtualTree;
                                     Node: PVirtualNode;
                                     Column: TColumnIndex;
                                     TextType: TVSTTextType;
                                     var CellText: string );
      procedure vstUnscrapedPaintText( Sender: TBaseVirtualTree;
                                       const TargetCanvas: TCanvas;
                                       Node: PVirtualNode;
                                       Column: TColumnIndex;
                                       TextType: TVSTTextType );
      procedure vstNoMediaGetText( Sender: TBaseVirtualTree;
                                   Node: PVirtualNode;
                                   Column: TColumnIndex;
                                   TextType: TVSTTextType;
                                   var CellText: string );
      procedure vstNoMediaPaintText( Sender: TBaseVirtualTree;
                                     const TargetCanvas: TCanvas;
                                     Node: PVirtualNode;
                                     Column: TColumnIndex;
                                     TextType: TVSTTextType );
      procedure vstNoMediaFreeNode( Sender: TBaseVirtualTree;
                                    Node: PVirtualNode );
      procedure vstMissingMediasFreeNode( Sender: TBaseVirtualTree;
                                          Node: PVirtualNode );
      procedure vstMissingMediasPaintText( Sender: TBaseVirtualTree;
                                           const TargetCanvas: TCanvas;
                                           Node: PVirtualNode;
                                           Column: TColumnIndex;
                                           TextType: TVSTTextType );
      procedure vstMissingMediasGetText( Sender: TBaseVirtualTree;
                                         Node: PVirtualNode;
                                         Column: TColumnIndex;
                                         TextType: TVSTTextType;
                                         var CellText: string );
      procedure vstOrphansFreeNode( Sender: TBaseVirtualTree;
                                    Node: PVirtualNode );
      procedure vstOrphansGetText( Sender: TBaseVirtualTree;
                                   Node: PVirtualNode;
                                   Column: TColumnIndex;
                                   TextType: TVSTTextType;
                                   var CellText: string );
      procedure vstOrphansPaintText( Sender: TBaseVirtualTree;
                                     const TargetCanvas: TCanvas;
                                     Node: PVirtualNode;
                                     Column: TColumnIndex;
                                     TextType: TVSTTextType );
      procedure vstMouseMove( Sender: TObject; Shift: TShiftState; X, Y: Integer );


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
      FScrapingInProgress, FCancelScraping: Boolean;
      procedure populateComboBox;
      procedure populateTrees;
      procedure populateMissingRoms( const aResults: TArray<TGamelistResult> );
      procedure populateUnscraped( const aResults: TArray<TGamelistResult> );
      procedure populateMissingMedias( const aResults: TArray<TGamelistResult> );
      procedure populateOrphans( const aResults: TArray<TGamelistResult> );
      procedure populateNoMedia( const aResults: TArray<TGamelistResult> );
      procedure updateTabCaptions( const aResults: TArray<TGamelistResult> );
      function getFilteredResults: TArray<TGamelistResult>;
      function mediaTypeToStr( aMediaType: TMediaType ): string;
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
      procedure updateVerifyHashesVisibility;
      procedure scrapeRoms( const aRefs: TArray<TGameEntryRef> );
      procedure scrapeMedias(const aRefs: TArray<TGameEntryRef>);

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
   System.StrUtils,
   System.UITypes,
   System.IOUtils,
   System.Threading,
   Vcl.Dialogs,
   Vcl.Clipbrd,
   Winapi.CommCtrl,
   Winapi.ShellAPI,
   HashUtils,
   RomUtils,
   Rpcs3Utils,
   ScreenScraperApi,
   GamelistParser,
   GamelistChecker,
   ConfirmDelete;

{$R *.dfm}

procedure TfrmGamelistDetails.FormCreate( Sender: TObject );
begin
   cbxSystems.Items.Clear;
   FComputing:= False;
   FPreviousSystemIndex:= 0;
   FGameEntryRefs:= TObjectlist<TGameEntryRef>.Create( True );
   vstMissingRoms.NodeDataSize:= SizeOf( TGamelistNodeData );
   vstUnscraped.NodeDataSize:= SizeOf( TGamelistNodeData );
   vstMissingMedias.NodeDataSize:= SizeOf( TGamelistNodeData );
   vstNoMedia.NodeDataSize:= SizeOf( TGamelistNodeData );
   vstOrphans.NodeDataSize:= SizeOf( TGamelistNodeData );
   vstHashMismatch.NodeDataSize:= SizeOf( THashMismatchNodeData );
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
   populateTrees;
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
         if ( ii <= High( cstHints ) ) then begin
            if ( pgcMain.Hint <> cstHints[ii] ) then begin
               pgcMain.Hint:= '';
               Application.CancelHint;
               pgcMain.Hint:= cstHints[ii];
            end;
            Exit;
         end;
      end;
   end;
   pgcMain.Hint:= '';
end;

procedure TfrmGamelistDetails.popActionsPopup(Sender: TObject);
begin
   var _vst:= pgcMain.ActivePage.Controls[0] as TVirtualStringTree;

   mniOpenFolder.Enabled:= ( _vst.SelectedCount = 1 );

   mniDeleteOrphan.Visible:= ( pgcMain.ActivePage = tbsOrphans ) and
                             ( vstOrphans.SelectedCount > 0 );

   mniAddMissingMedia.Visible:= ( pgcMain.ActivePage = tbsMissingMedias ) and
                                ( vstMissingMedias.SelectedCount > 0 );

   mniCopyExpectedHash.Visible:= ( pgcMain.ActivePage = tbsHashMismatch ) and
                                 ( vstHashMismatch.SelectedCount > 0 );

   mniScrapeGame.Visible:= FSSAvailable and
                           ( ( ( pgcMain.ActivePage = tbsUnscraped ) and
                               ( vstUnscraped.SelectedCount > 0 ) ) or
                             ( ( pgcMain.ActivePage = tbsNoMedia ) and
                               ( vstNoMedia.SelectedCount > 0 ) ) );
   mniScrapeGame.Enabled:= mniScrapeGame.Visible and
                           ( not FScrapingInProgress );

   mniScrapeMedias.Visible:= ( FSSAvailable ) and
                             ( pgcMain.ActivePage = tbsMissingMedias ) and
                             ( vstMissingMedias.SelectedCount > 0 );
   mniScrapeMedias.Enabled:= mniScrapeMedias.Visible and
                             ( not FScrapingInProgress );

   mniDeleteMissingROM.Visible:= ( pgcMain.ActivePage = tbsMissingRoms ) and
                                 ( vstMissingroms.SelectedCount > 0 );
   mniDeleteMissingROM.Enabled:= mniDeleteMissingROM.Visible;
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

procedure TfrmGamelistDetails.btnCancelScrapeClick( Sender: TObject );
begin
   FCancelScraping:= True;
   btnCancelScrape.Enabled:= False;
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
   vstHashMismatch.Clear;
   FComputing:= True;
   FCancelled:= False;

   var _filtered:= getFilteredResults;

   TTask.Run( procedure
   begin
      try
         for var _r in _filtered do begin
            if ( FCancelled ) then Exit;
            for var _g in _r.games do begin
               if ( FCancelled ) then Exit;
               if ( not _g.romPath.IsEmpty ) and TFile.Exists( _g.romPath ) then begin
                  if ( not _g.md5.IsEmpty ) then begin
                     var _actualMD5:= fileMD5( _g.romPath );
                     if ( FCancelled ) then Exit;
                     if ( _actualMD5 <> LowerCase( _g.md5 ) ) then begin
                        TThread.Synchronize( nil, procedure
                        begin
                           if ( FFormDestroyed ) then Exit;
                           var _ref:= TGameEntryRef.Create;
                           _ref.systemName:= _r.systemName;
                           _ref.gameName:= _g.name;
                           _ref.romPath:= _g.romPath;
                           _ref.gamelistResult:= _r;
                           FGameEntryRefs.Add( _ref );
                           var _node:= vstHashMismatch.AddChild( nil );
                           var _data:= PHashMismatchNodeData( vstHashMismatch.GetNodeData( _node ) );
                           _data.ref:= _ref;
                           _data.expectedHash:= LowerCase( _g.md5 );
                           _data.actualHash:= _actualMD5;
                           _data.hashType:= 'MD5';
                        end );
                     end;
                  end;

                  if ( not _g.crc32.IsEmpty ) then begin
                     var _actualCRC32:= fileCRC32( _g.romPath );
                     if ( FCancelled ) then Exit;
                     if ( _actualCRC32 <> LowerCase( _g.crc32 ) ) then begin
                        TThread.Synchronize( nil, procedure
                        begin
                           if ( FFormDestroyed ) then Exit;
                           var _ref:= TGameEntryRef.Create;
                           _ref.systemName:= _r.systemName;
                           _ref.gameName:= _g.name;
                           _ref.romPath:= _g.romPath;
                           _ref.gamelistResult:= _r;
                           FGameEntryRefs.Add( _ref );
                           var _node:= vstHashMismatch.AddChild( nil );
                           var _data:= PHashMismatchNodeData( vstHashMismatch.GetNodeData( _node ) );
                           _data.ref:= _ref;
                           _data.expectedHash:= LowerCase( _g.crc32 );
                           _data.actualHash:= _actualCRC32;
                           _data.hashType:= 'CRC32';
                        end );
                     end;
                  end;
               end;
            end;
         end;
      finally
         TThread.Synchronize( nil, procedure
         begin
            if ( FFormDestroyed ) then Exit;
            FComputing:= False;
            btnVerifyHashes.Enabled:= True;
            btnVerifyHashes.Caption:= rstVerifyHashes;
            tbsHashMismatch.TabVisible:= ( vstHashMismatch.RootNodeCount > 0 );
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
   vstHashMismatch.Clear;

   updateVerifyHashesVisibility;
   populateTrees;
end;

procedure TfrmGamelistDetails.populateTrees;
begin
   Screen.Cursor:= crHourGlass;
   try
      FGameEntryRefs.Clear;
      var _filtered:= getFilteredResults;
      populateMissingRoms( _filtered );
      populateUnscraped( _filtered );
      populateMissingMedias( _filtered );
      populateOrphans( _filtered );
      populateNoMedia( _filtered );
      updateTabCaptions( _filtered );
      updateStats( _filtered );
   finally
      Screen.Cursor:= crDefault;
   end;
end;

procedure TfrmGamelistDetails.populateMissingRoms( const aResults: TArray<TGamelistResult> );
begin
   vstMissingRoms.BeginUpdate;
   try
      vstMissingRoms.Clear;
      var _groups:= TDictionary<string, PVirtualNode>.Create;
      try
         for var _r in aResults do begin
            for var _path in _r.missingROMs do begin
               var _gameName:= '';
               for var _g in _r.games do begin
                  if ( _g.romPath = _path ) then begin
                     _gameName:= _g.name;
                     Break;
                  end;
               end;

               // Create ref
               var _ref:= TGameEntryRef.Create;
               _ref.systemName:= _r.systemName;
               _ref.gameName:= _gameName;
               _ref.romPath:= _path;
               _ref.gamelistResult:= _r;
               FGameEntryRefs.Add( _ref );

               // Group node if All systems
               var _groupNode: PVirtualNode:= nil;
               if ( cbxSystems.ItemIndex = 0 ) then begin
                  if ( not _groups.TryGetValue( _r.systemName, _groupNode ) ) then begin
                     _groupNode:= vstMissingRoms.AddChild( nil );
                     var _groupData:= PGamelistNodeData( vstMissingRoms.GetNodeData( _groupNode ) );
                     _groupData.isGroup:= True;
                     _groupData.groupText:= getFullNameFromShortName( _r.systemName );
                     _groupData.ref:= nil;
                     vstMissingRoms.Expanded[_groupNode]:= True;
                     _groups.Add( _r.systemName, _groupNode );
                  end;
               end;

               // Item node
               var _node:= vstMissingRoms.AddChild( _groupNode );
               var _data:= PGamelistNodeData( vstMissingRoms.GetNodeData( _node ) );
               _data.isGroup:= False;
               _data.groupText:= '';
               _data.ref:= _ref;
            end;
         end;
      finally
         _groups.Free;
      end;
   finally
      vstMissingRoms.EndUpdate;
   end;
   vstMissingRoms.FullExpand;
end;

procedure TfrmGamelistDetails.vstMissingRomsGetText( Sender: TBaseVirtualTree;
                                                      Node: PVirtualNode;
                                                      Column: TColumnIndex;
                                                      TextType: TVSTTextType;
                                                      var CellText: string );
begin
   var _data:= PGamelistNodeData( Sender.GetNodeData( Node ) );
   if ( _data = nil ) then Exit;
   if ( _data.isGroup ) then begin
      CellText:= IfThen( Column = 0, _data.groupText, '' );
      Exit;
   end;
   if ( _data.ref = nil ) then Exit;
   case Column of
      0: CellText:= _data.ref.systemName;
      1: CellText:= _data.ref.gameName;
      2: CellText:= _data.ref.romPath;
   end;
end;

procedure TfrmGamelistDetails.vstMouseMove( Sender: TObject; Shift: TShiftState; X, Y: Integer );
begin
   pgcMain.Hint:= '';
   Application.CancelHint;
end;

procedure TfrmGamelistDetails.vstMissingRomsPaintText( Sender: TBaseVirtualTree;
                                                        const TargetCanvas: TCanvas;
                                                        Node: PVirtualNode;
                                                        Column: TColumnIndex;
                                                        TextType: TVSTTextType );
begin
   var _data:= PGamelistNodeData( Sender.GetNodeData( Node ) );
   if ( _data = nil ) then Exit;
   if ( _data.isGroup ) then begin
      TargetCanvas.Font.Style:= [fsBold, fsItalic];
      TargetCanvas.Font.Color:= clWebRoyalBlue;
   end;
end;

procedure TfrmGamelistDetails.vstMissingRomsFreeNode( Sender: TBaseVirtualTree;
                                                       Node: PVirtualNode );
begin
   var _data:= PGamelistNodeData( Sender.GetNodeData( Node ) );
   if ( _data <> nil ) then
      Finalize( _data^ );
end;

procedure TfrmGamelistDetails.populateUnscraped( const aResults: TArray<TGamelistResult> );
begin
   vstUnscraped.BeginUpdate;
   try
      vstUnscraped.Clear;
      var _groups:= TDictionary<string, PVirtualNode>.Create;
      try
         for var _r in aResults do begin
            for var _path in _r.unscrapedROMs do begin
               var _ref:= TGameEntryRef.Create;
               _ref.systemName:= _r.systemName;
               _ref.romPath:= _path;
               _ref.gamelistResult:= _r;
               FGameEntryRefs.Add( _ref );

               var _groupNode: PVirtualNode:= nil;
               if ( cbxSystems.ItemIndex = 0 ) then begin
                  if ( not _groups.TryGetValue( _r.systemName, _groupNode ) ) then begin
                     _groupNode:= vstUnscraped.AddChild( nil );
                     var _groupData:= PGamelistNodeData( vstUnscraped.GetNodeData( _groupNode ) );
                     _groupData.isGroup:= True;
                     _groupData.groupText:= getFullNameFromShortName( _r.systemName );
                     _groupData.ref:= nil;
                     vstUnscraped.Expanded[_groupNode]:= True;
                     _groups.Add( _r.systemName, _groupNode );
                  end;
               end;

               var _node:= vstUnscraped.AddChild( _groupNode );
               var _data:= PGamelistNodeData( vstUnscraped.GetNodeData( _node ) );
               _data.isGroup:= False;
               _data.groupText:= '';
               _data.ref:= _ref;
            end;
         end;
      finally
         _groups.Free;
      end;
   finally
      vstUnscraped.EndUpdate;
   end;
   vstUnscraped.FullExpand;
end;

procedure TfrmGamelistDetails.vstUnscrapedGetText( Sender: TBaseVirtualTree;
                                                    Node: PVirtualNode;
                                                    Column: TColumnIndex;
                                                    TextType: TVSTTextType;
                                                    var CellText: string );
begin
   var _data:= PGamelistNodeData( Sender.GetNodeData( Node ) );
   if ( _data = nil ) then Exit;
   if ( _data.isGroup ) then begin
      CellText:= IfThen( Column = 0, _data.groupText, '' );
      Exit;
   end;
   if ( _data.ref = nil ) then Exit;
   case Column of
      0: CellText:= _data.ref.systemName;
      1: CellText:= _data.ref.romPath;
   end;
end;

procedure TfrmGamelistDetails.vstUnscrapedPaintText( Sender: TBaseVirtualTree;
                                                      const TargetCanvas: TCanvas;
                                                      Node: PVirtualNode;
                                                      Column: TColumnIndex;
                                                      TextType: TVSTTextType );
begin
   var _data:= PGamelistNodeData( Sender.GetNodeData( Node ) );
   if ( _data = nil ) then Exit;
   if ( _data.isGroup ) then begin
      TargetCanvas.Font.Style:= [fsBold, fsItalic];
      TargetCanvas.Font.Color:= clWebRoyalBlue;
   end;
end;

procedure TfrmGamelistDetails.vstUnscrapedFreeNode( Sender: TBaseVirtualTree;
                                                     Node: PVirtualNode );
begin
   var _data:= PGamelistNodeData( Sender.GetNodeData( Node ) );
   if ( _data <> nil ) then
      Finalize( _data^ );
end;

procedure TfrmGamelistDetails.populateMissingMedias( const aResults: TArray<TGamelistResult> );
begin
   vstMissingMedias.BeginUpdate;
   try
      vstMissingMedias.Clear;
      var _groups:= TDictionary<string, PVirtualNode>.Create;
      try
         for var _r in aResults do
            for var _g in _r.games do
               for var _m in _g.medias do
                  if ( not _m.exists ) then begin
                     var _ref:= TGameEntryRef.Create;
                     _ref.systemName:= _r.systemName;
                     _ref.gameName:= _g.name;
                     _ref.romPath:= _g.romPath;
                     _ref.mediaPath:= _m.path;
                     _ref.mediaType:= _m.mediaType;
                     _ref.gamelistResult:= _r;
                     FGameEntryRefs.Add( _ref );

                     var _groupNode: PVirtualNode:= nil;
                     if ( cbxSystems.ItemIndex = 0 ) then begin
                        if ( not _groups.TryGetValue( _r.systemName, _groupNode ) ) then begin
                           _groupNode:= vstMissingMedias.AddChild( nil );
                           var _groupData:= PGamelistNodeData( vstMissingMedias.GetNodeData( _groupNode ) );
                           _groupData.isGroup:= True;
                           _groupData.groupText:= getFullNameFromShortName( _r.systemName );
                           _groupData.ref:= nil;
                           vstMissingMedias.Expanded[_groupNode]:= True;
                           _groups.Add( _r.systemName, _groupNode );
                        end;
                     end;

                     var _node:= vstMissingMedias.AddChild( _groupNode );
                     var _data:= PGamelistNodeData( vstMissingMedias.GetNodeData( _node ) );
                     _data.isGroup:= False;
                     _data.groupText:= '';
                     _data.ref:= _ref;
                  end;
      finally
         _groups.Free;
      end;
   finally
      vstMissingMedias.EndUpdate;
   end;
   vstMissingMedias.FullExpand;
end;

procedure TfrmGamelistDetails.vstMissingMediasGetText( Sender: TBaseVirtualTree;
                                                        Node: PVirtualNode;
                                                        Column: TColumnIndex;
                                                        TextType: TVSTTextType;
                                                        var CellText: string );
begin
   var _data:= PGamelistNodeData( Sender.GetNodeData( Node ) );
   if ( _data = nil ) then Exit;
   if ( _data.isGroup ) then begin
      CellText:= IfThen( Column = 0, _data.groupText, '' );
      Exit;
   end;
   if ( _data.ref = nil ) then Exit;
   case Column of
      0: CellText:= _data.ref.systemName;
      1: CellText:= _data.ref.gameName;
      2: CellText:= mediaTypeToStr( _data.ref.mediaType );
      3: CellText:= _data.ref.mediaPath;
   end;
end;

procedure TfrmGamelistDetails.vstMissingMediasPaintText( Sender: TBaseVirtualTree;
                                                          const TargetCanvas: TCanvas;
                                                          Node: PVirtualNode;
                                                          Column: TColumnIndex;
                                                          TextType: TVSTTextType );
begin
   var _data:= PGamelistNodeData( Sender.GetNodeData( Node ) );
   if ( _data = nil ) then Exit;
   if ( _data.isGroup ) then begin
      TargetCanvas.Font.Style:= [fsBold, fsItalic];
      TargetCanvas.Font.Color:= clWebRoyalBlue;
   end;
end;

procedure TfrmGamelistDetails.vstMissingMediasFreeNode( Sender: TBaseVirtualTree;
                                                         Node: PVirtualNode );
begin
   var _data:= PGamelistNodeData( Sender.GetNodeData( Node ) );
   if ( _data <> nil ) then
      Finalize( _data^ );
end;

procedure TfrmGamelistDetails.populateOrphans( const aResults: TArray<TGamelistResult> );
begin
   vstOrphans.BeginUpdate;
   try
      vstOrphans.Clear;
      var _groups:= TDictionary<string, PVirtualNode>.Create;
      try
         for var _r in aResults do begin
            for var _path in _r.orphanMedias do begin
               var _ref:= TGameEntryRef.Create;
               _ref.systemName:= _r.systemName;
               _ref.mediaPath:= _path;
               _ref.gamelistResult:= _r;
               FGameEntryRefs.Add( _ref );

               var _groupNode: PVirtualNode:= nil;
               if ( cbxSystems.ItemIndex = 0 ) then begin
                  if ( not _groups.TryGetValue( _r.systemName, _groupNode ) ) then begin
                     _groupNode:= vstOrphans.AddChild( nil );
                     var _groupData:= PGamelistNodeData( vstOrphans.GetNodeData( _groupNode ) );
                     _groupData.isGroup:= True;
                     _groupData.groupText:= getFullNameFromShortName( _r.systemName );
                     _groupData.ref:= nil;
                     vstOrphans.Expanded[_groupNode]:= True;
                     _groups.Add( _r.systemName, _groupNode );
                  end;
               end;

               var _node:= vstOrphans.AddChild( _groupNode );
               var _data:= PGamelistNodeData( vstOrphans.GetNodeData( _node ) );
               _data.isGroup:= False;
               _data.groupText:= '';
               _data.ref:= _ref;
            end;
         end;
      finally
         _groups.Free;
      end;
   finally
      vstOrphans.EndUpdate;
   end;
   vstOrphans.FullExpand;
end;

procedure TfrmGamelistDetails.vstOrphansGetText( Sender: TBaseVirtualTree;
                                                 Node: PVirtualNode;
                                                 Column: TColumnIndex;
                                                 TextType: TVSTTextType;
                                                 var CellText: string );
begin
   var _data:= PGamelistNodeData( Sender.GetNodeData( Node ) );
   if ( _data = nil ) then Exit;
   if ( _data.isGroup ) then begin
      CellText:= IfThen( Column = 0, _data.groupText, '' );
      Exit;
   end;
   if ( _data.ref = nil ) then Exit;
   case Column of
      0: CellText:= _data.ref.systemName;
      1: CellText:= _data.ref.mediaPath;
   end;
end;

procedure TfrmGamelistDetails.vstOrphansPaintText( Sender: TBaseVirtualTree;
                                                   const TargetCanvas: TCanvas;
                                                   Node: PVirtualNode;
                                                   Column: TColumnIndex;
                                                   TextType: TVSTTextType );
begin
   var _data:= PGamelistNodeData( Sender.GetNodeData( Node ) );
   if ( _data = nil ) then Exit;
   if ( _data.isGroup ) then begin
      TargetCanvas.Font.Style:= [fsBold, fsItalic];
      TargetCanvas.Font.Color:= clWebRoyalBlue;
   end;
end;

procedure TfrmGamelistDetails.vstOrphansFreeNode( Sender: TBaseVirtualTree;
                                                  Node: PVirtualNode );
begin
   var _data:= PGamelistNodeData( Sender.GetNodeData( Node ) );
   if ( _data <> nil ) then
      Finalize( _data^ );
end;

procedure TfrmGamelistDetails.populateNoMedia( const aResults: TArray<TGamelistResult> );
begin
   vstNoMedia.BeginUpdate;
   try
      vstNoMedia.Clear;
      var _groups:= TDictionary<string, PVirtualNode>.Create;
      try
         for var _r in aResults do begin
            for var _g in _r.games do begin
               if ( not _g.isScraped ) then begin
                  var _ref:= TGameEntryRef.Create;
                  _ref.systemName:= _r.systemName;
                  _ref.gameName:= _g.name;
                  _ref.romPath:= _g.romPath;
                  _ref.gamelistResult:= _r;
                  FGameEntryRefs.Add( _ref );

                  var _groupNode: PVirtualNode:= nil;
                  if ( cbxSystems.ItemIndex = 0 ) then begin
                     if ( not _groups.TryGetValue( _r.systemName, _groupNode ) ) then begin
                        _groupNode:= vstNoMedia.AddChild( nil );
                        var _groupData:= PGamelistNodeData( vstNoMedia.GetNodeData( _groupNode ) );
                        _groupData.isGroup:= True;
                        _groupData.groupText:= getFullNameFromShortName( _r.systemName );
                        _groupData.ref:= nil;
                        vstNoMedia.Expanded[_groupNode]:= True;
                        _groups.Add( _r.systemName, _groupNode );
                     end;
                  end;

                  var _node:= vstNoMedia.AddChild( _groupNode );
                  var _data:= PGamelistNodeData( vstNoMedia.GetNodeData( _node ) );
                  _data.isGroup:= False;
                  _data.groupText:= '';
                  _data.ref:= _ref;
               end;
            end;
         end;
      finally
         _groups.Free;
      end;
   finally
      vstNoMedia.EndUpdate;
   end;
   vstNoMedia.FullExpand;
end;

procedure TfrmGamelistDetails.vstNoMediaGetText( Sender: TBaseVirtualTree;
                                                 Node: PVirtualNode;
                                                 Column: TColumnIndex;
                                                 TextType: TVSTTextType;
                                                 var CellText: string );
begin
   var _data:= PGamelistNodeData( Sender.GetNodeData( Node ) );
   if ( _data = nil ) then Exit;
   if ( _data.isGroup ) then begin
      CellText:= IfThen( Column = 0, _data.groupText, '' );
      Exit;
   end;
   if ( _data.ref = nil ) then Exit;
   case Column of
      0: CellText:= _data.ref.systemName;
      1: CellText:= _data.ref.gameName;
      2: CellText:= _data.ref.romPath;
   end;
end;

procedure TfrmGamelistDetails.vstNoMediaPaintText( Sender: TBaseVirtualTree;
                                                   const TargetCanvas: TCanvas;
                                                   Node: PVirtualNode;
                                                   Column: TColumnIndex;
                                                   TextType: TVSTTextType );
begin
   var _data:= PGamelistNodeData( Sender.GetNodeData( Node ) );
   if ( _data = nil ) then Exit;
   if ( _data.isGroup ) then begin
      TargetCanvas.Font.Style:= [fsBold, fsItalic];
      TargetCanvas.Font.Color:= clWebRoyalBlue;
   end;
end;

procedure TfrmGamelistDetails.vstNoMediaFreeNode( Sender: TBaseVirtualTree;
                                                  Node: PVirtualNode );
begin
   var _data:= PGamelistNodeData( Sender.GetNodeData( Node ) );
   if ( _data <> nil ) then
      Finalize( _data^ );
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
   if ( vstMissingMedias.SelectedCount = 0 ) then Exit;

   var _node:= vstMissingMedias.GetFirstSelected;
   var _data:= PGamelistNodeData( vstMissingMedias.GetNodeData( _node ) );
   if ( _data = nil ) or ( _data.isGroup ) or ( _data.ref = nil ) then Exit;

   var _ref:= _data.ref;
   var _targetPath:= _ref.mediaPath;
   var _ext:= TPath.GetExtension( _targetPath );
   var _dlg:= TOpenDialog.Create( Self );
   try
      _dlg.Title:= rstOpenDlgCaption + ' ' + _ref.gameName +
                   ' ' + rstWillBeSavedAs + ' ' + TPath.GetFileName( _targetPath ) + ')';
      _dlg.Filter:= 'Media files (*' + _ext + ')|*' + _ext + '|All files (*.*)|*.*';
      _dlg.FileName:= '';
      if ( _dlg.Execute ) then begin
         Screen.Cursor:= crHourGlass;
         try
            var _targetDir:= TPath.GetDirectoryName( _targetPath );
            if ( not TDirectory.Exists( _targetDir ) ) then
               TDirectory.CreateDirectory( _targetDir );
            TFile.Copy( _dlg.FileName, _targetPath, False );
            // Update FResults
            var _list:= TList<string>.Create;
            try
               for var s in _ref.gamelistResult.missingMedias do begin
                  if ( s <> _ref.mediaPath ) then
                     _list.Add( s );
               end;
               _ref.gamelistResult.missingMedias:= _list.ToArray;
            finally
               _list.Free;
            end;
            vstMissingMedias.DeleteNode( _node );
            var _count:= 0;
            var _n:= vstMissingMedias.GetFirst;
            while ( _n <> nil ) do begin
               var _d:= PGamelistNodeData( vstMissingMedias.GetNodeData( _n ) );
               if ( _d <> nil ) and ( not _d.isGroup ) then Inc( _count );
               _n:= vstMissingMedias.GetNext( _n );
            end;
            tbsMissingMedias.Caption:= Format( rstMissingMediasNb, [_count] );
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
   var _node:= vstHashMismatch.GetFirstSelected;
   if ( _node = nil ) then Exit;
   var _data:= PHashMismatchNodeData( vstHashMismatch.GetNodeData( _node ) );
   if ( _data = nil ) then Exit;
   if ( not _data.expectedHash.IsEmpty ) then
      Clipboard.AsText:= _data.expectedHash;
end;

procedure TfrmGamelistDetails.mniDeleteMissingROMClick( Sender: TObject );
begin
   // Detect PS3 games in selection
   var _hasPs3Games:= False;
   var _node:= vstMissingRoms.GetFirstSelected;
   while ( _node <> nil ) do begin
      var _data:= PGamelistNodeData( vstMissingRoms.GetNodeData( _node ) );
      if ( _data <> nil ) and ( not _data.isGroup ) and ( _data.ref <> nil ) then begin
         if ( _data.ref.gamelistResult.systemName = 'ps3' ) then begin
            _hasPs3Games:= True;
            Break;
         end;
      end;
      _node:= vstMissingRoms.GetNextSelected( _node );
   end;

   var _deleteOrphans: Boolean;
   var _deleteRpcs3Data: Boolean;
   if ( vstMissingRoms.SelectedCount = 0 ) or
      ( not TfrmConfirmDelete.Execute( Format( rstDeleteMissingROMs, [vstMissingRoms.SelectedCount] ),
                                       _hasPs3Games, _deleteOrphans, _deleteRpcs3Data ) ) then
      Exit;

   Screen.Cursor:= crHourGlass;

   var _rpcs3Map: TDictionary<string, string>:= nil;
   if ( _hasPs3Games ) and ( _deleteRpcs3Data ) then
      _rpcs3Map:= buildRpcs3TitleMap( FSettings.retrobatPath );

   var _refsByResult:= TDictionary<TGamelistResult, TList<TGameEntryRef>>.Create;
   var _affectedResults:= TList<TGamelistResult>.Create;
   try
      _node:= vstMissingRoms.GetFirstSelected;
      while ( _node <> nil ) do begin
         var _data:= PGamelistNodeData( vstMissingRoms.GetNodeData( _node ) );
         if ( _data <> nil ) and ( not _data.isGroup ) and ( _data.ref <> nil ) then begin
            var _ref:= _data.ref;
            if ( not _refsByResult.ContainsKey( _ref.gamelistResult ) ) then begin
               _refsByResult.Add( _ref.gamelistResult, TList<TGameEntryRef>.Create );
               _affectedResults.Add( _ref.gamelistResult );
            end;
            _refsByResult[_ref.gamelistResult].Add( _ref );
         end;
         _node:= vstMissingRoms.GetNextSelected( _node );
      end;

      for var _r in _affectedResults do begin
         var _refs:= _refsByResult[_r];
         var _romPaths: TArray<string>;
         for var _ref in _refs do
            _romPaths:= _romPaths + [_ref.romPath];
         removeGamesFromGamelist( _r.romDir, _romPaths );

         var _gamesList:= TList<TGameEntry>.Create;
         try
            for var _g in _r.games do begin
               var _found:= False;
               for var _p in _romPaths do begin
                  if ( _g.romPath = _p ) then begin
                     _found:= True;
                     Break;
                  end;
               end;
               if ( not _found ) then
                  _gamesList.Add( _g );
            end;
            _r.games:= _gamesList.ToArray;
         finally
            _gamesList.Free;
         end;

         var _missingList:= TList<string>.Create;
         try
            for var _s in _r.missingROMs do begin
               var _found:= False;
               for var _p in _romPaths do begin
                  if ( _s = _p ) then begin
                     _found:= True;
                     Break;
                  end;
               end;
               if ( not _found ) then
                  _missingList.Add( _s );
            end;
            _r.missingROMs:= _missingList.ToArray;
         finally
            _missingList.Free;
         end;

         if ( _deleteOrphans ) then begin
            for var _ref in _refs do begin
               var _romName:= TPath.GetFileNameWithoutExtension( _ref.romPath );
               for var _subDir in [cstImages, cstVideos, cstManuals] do begin
                  var _path:= TPath.Combine( _r.romDir, _subDir );
                  if ( TDirectory.Exists( _path ) ) then begin
                     for var _f in TDirectory.GetFiles( _path ) do begin
                        if ( TPath.GetFileName( _f ).StartsWith( _romName ) ) then
                           TFile.Delete( _f );
                     end;
                  end;
               end;
            end;
         end;

         if ( _deleteRpcs3Data ) and ( _r.systemName = 'ps3' ) and
            ( _rpcs3Map <> nil ) then begin
            for var _ref in _refs do begin
               var _serial: string;
               if ( findRpcs3Serial( _rpcs3Map, _ref.gameName, _serial ) ) then begin
                  var _rpcs3Path:= TPath.Combine( TPath.Combine( FSettings.retrobatPath,
                                                                 'saves\ps3\rpcs3\dev_hdd0\game' ),
                                                  _serial );
                  if ( TDirectory.Exists( _rpcs3Path ) ) then
                     TDirectory.Delete( _rpcs3Path, True );
               end;
            end;
         end;

         var _newResult:= parseGamelist( _r.romDir, _r.systemName );
         _r.games:= _newResult.games;
         _r.missingMedias:= _newResult.missingMedias;
         _r.orphanMedias:= checkOrphanMedias( _r.romDir, _r.games );
         _newResult.Free;
      end;
   finally
      _rpcs3Map.Free;
      for var _list in _refsByResult.Values do
         _list.Free;
      _refsByResult.Free;
      _affectedResults.Free;
      Screen.Cursor:= crDefault;
   end;

   populateTrees;
   updateStats( getFilteredResults );
   if ( Assigned( FOnSummaryUpdate ) ) then
      FOnSummaryUpdate( Self );
end;

procedure TfrmGamelistDetails.mniDeleteOrphanClick( Sender: TObject );
begin
   if ( vstOrphans.SelectedCount = 0 ) then Exit;
   if ( MessageDlg( Format( rstDeleteOrphans, [vstOrphans.SelectedCount] ),
                    mtConfirmation, [mbYes, mbNo], 0 ) = mrNo ) then
      Exit;

   Screen.Cursor:= crHourGlass;
   try
      var _node:= vstOrphans.GetFirstSelected;
      while ( _node <> nil ) do begin
         var _next:= vstOrphans.GetNextSelected( _node );
         var _data:= PGamelistNodeData( vstOrphans.GetNodeData( _node ) );
         if ( _data <> nil ) and ( not _data.isGroup ) and ( _data.ref <> nil ) then begin
            var _ref:= _data.ref;
            if ( TFile.Exists( _ref.mediaPath ) ) then begin
               TFile.Delete( _ref.mediaPath );
               var _list:= TList<string>.Create;
               try
                  for var s in _ref.gamelistResult.orphanMedias do begin
                     if ( s <> _ref.mediaPath ) then
                        _list.Add( s );
                  end;
                  _ref.gamelistResult.orphanMedias:= _list.ToArray;
               finally
                  _list.Free;
               end;
               vstOrphans.DeleteNode( _node );
            end;
         end;
         _node:= _next;
      end;
   finally
      Screen.Cursor:= crDefault;
   end;

   var _count:= 0;
   var _n:= vstOrphans.GetFirst;
   while _n <> nil do begin
      var _d:= PGamelistNodeData( vstOrphans.GetNodeData( _n ) );
      if ( _d <> nil ) and ( not _d.isGroup ) then Inc( _count );
      _n:= vstOrphans.GetNext( _n );
   end;
   tbsOrphans.Caption:= Format( rstOrphansNb, [_count] );
   if Assigned( FOnSummaryUpdate ) then
      FOnSummaryUpdate( Self );
end;

procedure TfrmGamelistDetails.mniOpenFolderClick( Sender: TObject );
begin
   var _vst:= ( pgcMain.ActivePage.Controls[0] as TVirtualStringTree );
   var _node:= _vst.GetFirstSelected;
   if ( _node = nil ) then Exit;

   var _ref: TGameEntryRef:= nil;
   // Handle both node data types
   if ( pgcMain.ActivePage = tbsHashMismatch ) then begin
      var _data:= PHashMismatchNodeData( _vst.GetNodeData( _node ) );
      if ( _data <> nil ) then _ref:= _data.ref;
   end else begin
      var _data:= PGamelistNodeData( _vst.GetNodeData( _node ) );
      if ( _data <> nil ) and ( not _data.isGroup ) then _ref:= _data.ref;
   end;

   if ( _ref = nil ) then Exit;
   var _path:= _ref.romPath;
   if ( _path.IsEmpty ) then
      _path:= _ref.mediaPath;
   if ( _path.IsEmpty ) then Exit;
   var _folder:= TPath.GetDirectoryName( _path );
   if ( TDirectory.Exists( _folder ) ) then
      ShellExecute( Handle, 'open', PChar( _folder ), nil, nil, SW_SHOWNORMAL );
end;

procedure TfrmGamelistDetails.mniScrapeGameClick( Sender: TObject );
begin
   var _vst:= pgcMain.ActivePage.Controls[0] as TVirtualStringTree;
   if ( _vst.SelectedCount = 0 ) then Exit;
   var _refs: TArray<TGameEntryRef>;
   var _node:= _vst.GetFirstSelected;
   while ( _node <> nil ) do begin
      var _data:= PGamelistNodeData( _vst.GetNodeData( _node ) );
      if ( _data <> nil ) and ( not _data.isGroup ) and ( _data.ref <> nil ) then begin
         var _ref:= _data.ref;
         if FSSSystemsMapping.ContainsKey( LowerCase( _ref.systemName ) ) then
            _refs:= _refs + [_ref]
         else
            ShowMessage( 'System "' + _ref.systemName + '" not found in ScreenScraper mapping.' );
      end;
      _node:= _vst.GetNextSelected( _node );
   end;
   if ( Length( _refs ) = 0 ) then Exit;
   scrapeRoms( _refs );
end;

procedure TfrmGamelistDetails.scrapeRoms( const aRefs: TArray<TGameEntryRef> );
begin
   var _total:= Length( aRefs );

   if ( _total > 1 ) then begin
      // shitty hack to refresh the progressBar
      pbScraping.Style:= pbstMarquee;
      pbScraping.Style:= pbstNormal;
      pbScraping.Max:= _total;
      pbScraping.Position:= 0;
   end else begin
      pbScraping.Style:= pbstNormal;
      pbScraping.Style:= pbstMarquee;
   end;

   FScrapingInProgress:= True;
   pbScraping.Visible:= True;
   lblScraping.Visible:= True;

   FCancelScraping:= False;
   btnCancelScrape.Visible:= True;
   btnCancelScrape.Enabled:= True;

   var _successCount:= 0;
   var _errors:= TStringList.Create;

   TTask.Run( procedure
   begin
      var _quotaExceeded:= False;

      try
         var _current:= 0;
         for var _ref in aRefs do begin
            Inc( _current );
            if ( FFormDestroyed ) or ( _quotaExceeded ) or ( FCancelScraping ) then
               Break;

            var _romPath:= _ref.romPath;
            var _romDir:= _ref.gamelistResult.romDir;
            var _savedTotalRoms:= _ref.gamelistResult.totalRoms;

            if ( not FSSSystemsMapping.ContainsKey( LowerCase( _ref.systemName ) ) ) then
               Continue;

            var _systemId:= FSSSystemsMapping[ LowerCase( _ref.systemName ) ];

            // Update label
            TThread.Queue( nil, procedure
            begin
               if ( FFormDestroyed ) then Exit;
                  lblScraping.Caption:= Format( '%d/%d ', [_current, _total] )+
                                        rstScraping + ' "' +
                                        TPath.GetFileNameWithoutExtension( _romPath ) + '"';
               if ( _total > 1 ) then
                  pbScraping.Position:= _current;
            end );

            var _mediaRegion:= FSettings.favRegion;
            var _langInfo:= detectRomLangAndRegion( _romPath, _ref.systemName );
            var _romRegion:= _langInfo.region;
            if _romRegion.IsEmpty then
               _romRegion:= FSettings.favRegion;

            var _gameInfo: TSSGameInfo;
            var _err: string;
            var _result:= getGameInfo( FSettings.ssUserId, FSettings.ssPassword,
                                       _systemId, _ref.systemName, _romPath,
                                       FSettings.scrapeLanguage, _mediaRegion,
                                       _gameInfo, _err );

            case _result of
               ssrQuotaExceeded: begin
                  _quotaExceeded:= True;
                  TThread.Queue( nil, procedure
                  begin
                     if ( FFormDestroyed ) then Exit;
                     ShowMessage( rstQuotaExceeded );
                  end );
               end;

               ssrNotFound:
                  TThread.Queue( nil, procedure
                  begin
                     if ( FFormDestroyed ) then Exit;
                     _errors.Add( Format( rstGameNotFound, [TPath.GetFileName( _romPath )] ) );
                  end );

               ssrError:
                  TThread.Queue( nil, procedure
                  begin
                     if ( FFormDestroyed ) then Exit;
                     _errors.Add( TPath.GetFileName( _romPath ) + ' : ' + _err );
                  end );

               ssrOK: begin
                  var _downloadedMedias:= TList<TGameMedia>.Create;
                  try
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

                     var _entry:= Default( TGameEntry );
                     _entry.id          := _gameInfo.id;
                     _entry.name        := _gameInfo.name;
                     _entry.desc        := _gameInfo.desc;
                     _entry.genre       := _gameInfo.genre;
                     _entry.family      := _gameInfo.family;
                     _entry.arcadeSystem:= _gameInfo.arcadeSystem;
                     _entry.rating      := _gameInfo.rating;
                     _entry.releaseDate := _gameInfo.releaseDate;
                     _entry.developer   := _gameInfo.developer;
                     _entry.publisher   := _gameInfo.publisher;
                     _entry.players     := _gameInfo.players;
                     _entry.lang        := _langInfo.language;
                     _entry.region      := _romRegion;
                     _entry.romPath     := _romPath;
                     _entry.md5         := fileMD5( _romPath );
                     _entry.crc32       := fileCRC32( _romPath );
                     _entry.medias      := _downloadedMedias.ToArray;
                     _entry.isScraped   := ( _downloadedMedias.Count > 0 );

                     addGameToGamelist( FSettings, _romDir, _entry );
                  finally
                     _downloadedMedias.Free;
                  end;

                  // Update FResults in main thread
                  TThread.Synchronize( nil, procedure
                  begin
                     if ( FFormDestroyed ) then Exit;

                     var _unscrapedList:= TList<string>.Create;
                     try
                        for var _s in _ref.gamelistResult.unscrapedROMs do begin
                           if ( _s <> _romPath ) then
                              _unscrapedList.Add( _s );
                        end;
                        _ref.gamelistResult.unscrapedROMs:= _unscrapedList.ToArray;
                     finally
                        _unscrapedList.Free;
                     end;

                     var _newResult:= parseGamelist( _romDir, _ref.gamelistResult.systemName );
                     _ref.gamelistResult.games:= _newResult.games;
                     _ref.gamelistResult.missingMedias:= _newResult.missingMedias;
                     _ref.gamelistResult.orphanMedias:= _newResult.orphanMedias;
                     _newResult.Free;
                     _ref.gamelistResult.totalRoms:= _savedTotalRoms;
                  end );

                  Inc( _successCount );
               end;
            end;
         end;
      except
         on E: Exception do
            TThread.Queue( nil, procedure
            begin
               if ( FFormDestroyed ) then Exit;
               ShowMessage( rstUnexpectedError + E.Message );
            end );
      end;

      // Single UI refresh at the end
      TThread.Queue( nil, procedure
      begin
         if ( FFormDestroyed ) then Exit;
         pbScraping.Style:= pbstMarquee;
         pbScraping.Position:= 0;
         FScrapingInProgress:= False;
         lblScraping.Visible:= False;
         pbScraping.Visible:= False;
         btnCancelScrape.Visible:= False;
         FCancelScraping:= False;
         populateTrees;
         updateVerifyHashesVisibility;
         updateStats( getFilteredResults );
         if Assigned( FOnSummaryUpdate ) then
            FOnSummaryUpdate( Self );

         var _msg:= Format( rstScrapeSummary, [_successCount, _total] );
         if ( _errors.Count > 0 ) then
            _msg:= _msg + sLineBreak + _errors.Text;
         ShowMessage( _msg );
         _errors.Free;
      end );
   end );
end;

procedure TfrmGamelistDetails.mniScrapeMediasClick( Sender: TObject );
begin
   if ( vstMissingMedias.SelectedCount = 0 ) then Exit;
   var _refs: TArray<TGameEntryRef>;
   var _node:= vstMissingMedias.GetFirstSelected;
   while ( _node <> nil ) do begin
      var _data:= PGamelistNodeData( vstMissingMedias.GetNodeData( _node ) );
      if ( _data <> nil ) and ( not _data.isGroup ) and ( _data.ref <> nil ) then
         _refs:= _refs + [_data.ref];
      _node:= vstMissingMedias.GetNextSelected( _node );
   end;
   if ( Length( _refs ) = 0 ) then Exit;
   scrapeMedias( _refs );
end;

procedure TfrmGamelistDetails.scrapeMedias( const aRefs: TArray<TGameEntryRef> );
begin
   FScrapingInProgress:= True;
   pbScraping.Visible:= True;
   lblScraping.Visible:= True;

   // Group refs by romPath to avoid multiple getGameInfo calls for the same game
   var _grouped:= TObjectDictionary<string, TList<TGameEntryRef>>.Create( [doOwnsValues] );
   for var _ref in aRefs do begin
      if not _grouped.ContainsKey( _ref.romPath ) then
         _grouped.Add( _ref.romPath, TList<TGameEntryRef>.Create );
      _grouped[_ref.romPath].Add( _ref );
   end;

   // Build ordered list of unique roms
   var _romPaths:= TList<string>.Create;
   for var _key in _grouped.Keys do
      _romPaths.Add( _key );

   var _total:= _romPaths.Count;

   if ( _total > 1 ) then begin
      pbScraping.Style:= pbstMarquee;
      pbScraping.Style:= pbstNormal;
      pbScraping.Max:= _total;
      pbScraping.Position:= 0;
   end else begin
      pbScraping.Style:= pbstNormal;
      pbScraping.Style:= pbstMarquee;
   end;

   var _mediasDownloaded:= 0;
   var _mediasTotal:= 0;
   var _errors:= TStringList.Create;

   FCancelScraping:= False;
   btnCancelScrape.Visible:= True;
   btnCancelScrape.Enabled:= True;

   TTask.Run( procedure
   begin
      var _current:= 0;
      var _quotaExceeded:= False;

      try
         for var _romPath in _romPaths do begin
            if ( FFormDestroyed ) or ( _quotaExceeded ) or ( FCancelScraping ) then
               Break;
            Inc( _current );

            var _refsForRom:= _grouped[_romPath];
            var _ref0:= _refsForRom[0]; // Use first ref for common data
            var _romDir:= _ref0.gamelistResult.romDir;

            Inc( _mediasTotal, _refsForRom.Count );

            if ( not FSSSystemsMapping.ContainsKey( LowerCase( _ref0.systemName ) ) ) then
               Continue;

            var _systemId:= FSSSystemsMapping[ LowerCase( _ref0.systemName ) ];

            TThread.Queue( nil, procedure
            begin
               if ( FFormDestroyed ) then Exit;
               lblScraping.Caption:= Format( '%d/%d ', [_current, _total] ) +
                                     rstScraping + ' "' +
                                     mediaTypeToStr( _ref0.mediaType ) + ' - ' +
                                     TPath.GetFileNameWithoutExtension( _romPath ) + '"';
               if ( _total > 1 ) then
                  pbScraping.Position:= _current;
            end );

            var _mediaRegion:= FSettings.favRegion;
            var _gameInfo: TSSGameInfo;
            var _err: string;
            var _result:= getGameInfo( FSettings.ssUserId, FSettings.ssPassword,
                                       _systemId, _ref0.systemName, _romPath,
                                       FSettings.scrapeLanguage, _mediaRegion,
                                       _gameInfo, _err );

            case _result of
               ssrQuotaExceeded: begin
                  _quotaExceeded:= True;
                  TThread.Queue( nil, procedure
                  begin
                     if ( FFormDestroyed ) then Exit;
                     ShowMessage( rstQuotaExceeded );
                  end );
               end;

               ssrNotFound:
                  TThread.Queue( nil, procedure
                  begin
                     if ( FFormDestroyed ) then Exit;
                     _errors.Add( Format( rstGameNotFound, [TPath.GetFileName( _romPath )] ) );
                  end );

               ssrError:
                  TThread.Queue( nil, procedure
                  begin
                     if ( FFormDestroyed ) then Exit;
                     _errors.Add( TPath.GetFileName( _romPath ) + ' : ' + _err );
                  end );

               ssrOK: begin
                  // Download each missing media for this game
                  for var _ref in _refsForRom do begin
                     var _ripSource:= '';
                     var _fileSuffix:= '';
                     var _destFolder:= '';

                     case _ref.mediaType of
                        mtImage: begin
                           _ripSource:= FSettings.scrapeImageSrc;
                           _fileSuffix:= cstXmlImage;
                           _destFolder:= TPath.Combine( _romDir, cstImages );
                        end;
                        mtThumbnail: begin
                           _ripSource:= FSettings.scrapeThumbSrc;
                           _fileSuffix:= cstThumbFileSuffix;
                           _destFolder:= TPath.Combine( _romDir, cstImages );
                        end;
                        mtMarquee: begin
                           _ripSource:= FSettings.scrapeLogoSrc;
                           _fileSuffix:= cstXmlMarquee;
                           _destFolder:= TPath.Combine( _romDir, cstImages );
                        end;
                        mtVideo: begin
                           _ripSource:= cstSSMediaVideo;
                           _fileSuffix:= cstXmlVideo;
                           _destFolder:= TPath.Combine( _romDir, cstVideos );
                        end;
                        mtFanart: begin
                           _ripSource:= cstSSMediaFanart;
                           _fileSuffix:= cstXmlFanart;
                           _destFolder:= TPath.Combine( _romDir, cstImages );
                        end;
                        mtBoxBack: begin
                           _ripSource:= cstSSMediaBoxBack;
                           _fileSuffix:= cstXmlBoxBack;
                           _destFolder:= TPath.Combine( _romDir, cstImages );
                        end;
                        mtManual: begin
                           _ripSource:= cstSSMediaManual;
                           _fileSuffix:= cstXmlManual;
                           _destFolder:= TPath.Combine( _romDir, cstManuals );
                        end;
                        mtMap: begin
                           _ripSource:= cstSSMediaMap;
                           _fileSuffix:= cstXmlMap;
                           _destFolder:= TPath.Combine( _romDir, cstImages );
                        end;
                        mtBezel: begin
                           _ripSource:= cstSSMediaBezel;
                           _fileSuffix:= cstXmlBezel;
                           _destFolder:= TPath.Combine( _romDir, cstImages );
                        end;
                     end;

                     if ( _ripSource.IsEmpty ) then Continue;

                     var _gm:= downloadIfAvailable( _ripSource, cstMediaTypeTags[_ref.mediaType],
                                                    _fileSuffix, _destFolder,
                                                    _ref.mediaType, _romPath,
                                                    FSettings.scrapeLanguage, _mediaRegion,
                                                    _gameInfo.medias, _err );

                     if ( _gm.exists ) then begin
                        Inc( _mediasDownloaded );
                        var _mediaPath:= _ref.mediaPath;
                        TThread.Synchronize( nil, procedure
                        begin
                           if ( FFormDestroyed ) then Exit;
                           var _missingList:= TList<string>.Create;
                           try
                              for var s in _ref.gamelistResult.missingMedias do
                                 if ( s <> _mediaPath ) then
                                    _missingList.Add( s );
                              _ref.gamelistResult.missingMedias:= _missingList.ToArray;
                           finally
                              _missingList.Free;
                           end;

                           var _newResult:= parseGamelist( _romDir, _ref.gamelistResult.systemName );
                           _ref.gamelistResult.games:= _newResult.games;
                           _ref.gamelistResult.missingROMs:= _newResult.missingROMs;
                           _ref.gamelistResult.orphanMedias:= _newResult.orphanMedias;
                           _newResult.Free;
                        end );
                     end;
                  end;
               end;
            end;
         end;
      except
         on E: Exception do
            TThread.Queue( nil, procedure
            begin
               if ( FFormDestroyed ) then Exit;
               ShowMessage( 'Unexpected error : ' + E.Message );
            end );
      end;

      // Cleanup
      TThread.Queue( nil, procedure
      begin
         if FFormDestroyed then Exit;
         FScrapingInProgress:= False;
         lblScraping.Visible:= False;
         pbScraping.Visible:= False;
         pbScraping.Style:= pbstMarquee;
         pbScraping.Position:= 0;
         btnCancelScrape.Visible:= False;
         FCancelScraping:= False;
         populateTrees;
         updateVerifyHashesVisibility;
         updateStats( getFilteredResults );
         if ( Assigned( FOnSummaryUpdate ) ) then
            FOnSummaryUpdate( Self );
         var _msg:= Format( rstScrapeMediaSummary, [_mediasDownloaded, _mediasTotal] );
         if ( _errors.Count > 0 ) then
            _msg:= _msg + sLinebreak + _errors.Text;
         ShowMessage( _msg );
         _errors.Free;

         // Free after UI update
         _grouped.Free;
         _romPaths.Free;
      end );
   end );
end;

procedure TfrmGamelistDetails.updateVerifyHashesVisibility;
begin
   var _hasHashes:= False;
   if ( cbxSystems.ItemIndex > 0 ) then begin
      var _filtered:= getFilteredResults;
      for var _r in _filtered do begin
         for var _g in _r.games do begin
            if ( not _g.md5.IsEmpty ) or ( not _g.crc32.IsEmpty ) then begin
               _hasHashes:= True;
               Break;
            end;
         end;
      end;
   end;
   btnVerifyHashes.Visible:= _hasHashes;
   if ( btnVerifyHashes.Visible ) then
      lblStats.Left:= btnVerifyHashes.Left + btnVerifyHashes.Width + cstMargin
   else
      lblStats.Left:= btnVerifyHashes.Left;
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
      for var _g in _r.games do begin
         if _g.isScraped then
            Inc( _scraped );
      end;
   end;
   lblStats.Caption:= Format( rstSystemStats,
                              [_games, _scraped, _romsOnDisk] );
end;

end.
