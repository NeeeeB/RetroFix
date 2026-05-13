unit BiosDetails;

interface

uses
   Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
   Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ComCtrls,
   Vcl.ExtCtrls,
   Types,
   Constantes,
   Vcl.Menus, VirtualTrees.BaseAncestorVCL, VirtualTrees.BaseTree,
  VirtualTrees.AncestorVCL, VirtualTrees, VirtualTrees.Types;

type
   PBiosNodeData = ^TBiosNodeData;
   TBiosNodeData = record
      result   : TBiosResult;
      isAltPath: Boolean;
      isGroup   : Boolean;
      groupText : string;
   end;

   TfrmBiosDetails = class( TForm )
      pnlTop: TPanel;
      rgpGroupMode: TRadioGroup;
      lvBios: TListView;
      popupMenu: TPopupMenu;
      mniCopyMD5: TMenuItem;
      gbxFilters: TGroupBox;
      chkFilterOK: TCheckBox;
      chkFilterNoHash: TCheckBox;
      chkFilterMismatch: TCheckBox;
      chkFilterMissing: TCheckBox;
      mniOpenFolder: TMenuItem;
      gbxActions: TGroupBox;
      btnRescan: TButton;
      chkRescanForceExtract: TCheckBox;
      chkRescanStrictMode: TCheckBox;
      btnExportCSV: TButton;
      chkPartial: TCheckBox;
      vstBios: TVirtualStringTree;
      procedure FormCreate( Sender: TObject );
      procedure rgpGroupModeClick( Sender: TObject );
      procedure lvBiosCustomDrawItem( Sender: TCustomListView; Item: TListItem;
                                      State: TCustomDrawState; var DefaultDraw: Boolean );
      procedure mniCopyMD5Click(Sender: TObject);
      procedure popupMenuPopup(Sender: TObject);
      procedure chkFilterClick(Sender: TObject);
      procedure mniOpenFolderClick(Sender: TObject);
      procedure btnRescanClick(Sender: TObject);
      procedure btnExportCSVClick(Sender: TObject);
      procedure vstBiosGetText( Sender: TBaseVirtualTree;
                                Node: PVirtualNode;
                                Column: TColumnIndex;
                                TextType: TVSTTextType;
                                var CellText: string );
      procedure vstBiosFreeNode( Sender: TBaseVirtualTree;
                                 Node: PVirtualNode );
    procedure vstBiosPaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType);

   private
      FResults: TArray<TBiosResult>;
      FGroupMode: TGroupMode;
      FOnRescan: TRescanEvent;
      procedure populateListView;
      procedure populateVST;
      function addGroup( const aCaption: string ): TListGroup;
      function statusSortOrder( const aStatus: TBiosStatus ): Integer;
      function isStatusVisible( const aStatus: TBiosStatus ): Boolean;

   public
      property OnRescan: TRescanEvent read FOnRescan write FOnRescan;
      procedure setResults( const aResults: TArray<TBiosResult> );
   end;

implementation

uses
   System.Generics.Defaults,
   System.Generics.Collections,
   System.IOUtils,
   system.StrUtils,
   System.Math,
   Vcl.Clipbrd,
   Vcl.Dialogs,
   Winapi.ShellAPI,
   BiosExport;

{$R *.dfm}

procedure TfrmBiosDetails.btnExportCSVClick( Sender: TObject );
begin
   var _dlg:= TSaveDialog.Create( Self );
   try
      _dlg.Title:= 'Export BIOS report';
      _dlg.DefaultExt:= 'csv';
      _dlg.Filter:= 'CSV files (*.csv)|*.csv';
      _dlg.FileName:= 'bios_report';
      if _dlg.Execute then begin
         Screen.Cursor:= crHourGlass;
         try
            exportBiosToCSV( FResults, _dlg.FileName );
         finally
            Screen.Cursor:= crDefault;
         end;
      end;
   finally
      _dlg.Free;
   end;
end;

procedure TfrmBiosDetails.btnRescanClick( Sender: TObject );
begin
   if not Assigned( FOnRescan ) then
      Exit;

   Screen.Cursor:= crHourGlass;
   try
      btnRescan.Enabled:= False;
      btnRescan.Caption:= rstScanning;
      try
         var _options: TScanOptions;
         _options.forceExtract:= chkRescanForceExtract.Checked;
         _options.strictMode:= chkRescanStrictMode.Checked;
         FOnRescan( Self, _options );
      finally
         btnRescan.Enabled:= True;
         btnRescan.Caption:= cstRescan;
      end;
   finally
      Screen.Cursor:= crDefault;
   end;
end;

procedure TfrmBiosDetails.chkFilterClick(Sender: TObject);
begin
//   populateListView;
   populateVST;
end;

procedure TfrmBiosDetails.FormCreate( Sender: TObject );
begin
   vstBios.NodeDataSize:= SizeOf( TBiosNodeData );
   FGroupMode:= gmSystem;
//   lvBios.Groups.Clear;
end;

procedure TfrmBiosDetails.setResults( const aResults: TArray<TBiosResult> );
begin
   FResults:= aResults;
//   populateListView;
   populateVST;
end;

procedure TfrmBiosDetails.rgpGroupModeClick( Sender: TObject );
begin
   case rgpGroupMode.ItemIndex of
      0: FGroupMode:= gmSystem;
      1: FGroupMode:= gmStatus;
   end;
//   populateListView;
   populateVST;
end;

function TfrmBiosDetails.addGroup( const aCaption: string ): TListGroup;
begin
   Result:= lvBios.Groups.Add;
   Result.Header:= aCaption;
   Result.State:= [lgsNormal];
end;

function TfrmBiosDetails.statusSortOrder( const aStatus: TBiosStatus ): Integer;
begin
   case aStatus of
      bsMissing: Result:= 0;
      bsMD5Mismatch: Result:= 1;
      bsPresentNoHash: Result:= 2;
      bsOK: Result:= 3;
      bsPartial: Result:= 4;
   else
      Result:= 5;
   end;
end;

function TfrmBiosDetails.isStatusVisible( const aStatus: TBiosStatus ): Boolean;
begin
   case aStatus of
      bsOK: Result:= chkFilterOK.Checked;
      bsPresentNoHash: Result:= chkFilterNoHash.Checked;
      bsMD5Mismatch: Result:= chkFilterMismatch.Checked;
      bsMissing: Result:= chkFilterMissing.Checked;
      bsPartial: Result:= chkPartial.Checked;
   else
      Result:= True;
   end;
end;

procedure TfrmBiosDetails.populateListView;

   function getOrCreateGroup( const aCaption: string ): Integer;
   begin
      for var ii:= 0 to Pred( lvBios.Groups.Count ) do begin
         if lvBios.Groups[ii].Header = aCaption then begin
            Result:= lvBios.Groups[ii].GroupID;
            Exit;
         end;
      end;
      var _g:= addGroup( aCaption );
      Result:= _g.GroupID;
   end;

begin
   Screen.Cursor:= crHourGlass;
   try
      var _data: TArray<TBiosResult>;
      // Sort by status order when in gmStatus mode, otherwise keep original order
      if FGroupMode = gmStatus then begin
         _data:= Copy( FResults, 0, Length( FResults ) );
         TArray.Sort<TBiosResult>( _data, TComparer<TBiosResult>.Construct(
                                   function( const aLeft, aRight: TBiosResult ): Integer
                                   begin
                                      Result:= statusSortOrder( aLeft.Status ) - statusSortOrder( aRight.Status );
                                   end ) );
      end else
         _data:= FResults;

      lvBios.GroupView:= False;
      lvBios.Items.BeginUpdate;
      lvBios.Groups.Clear;
      lvBios.Items.Clear;
      try
         var _item: TListItem;
         var _groupCaption:= '';
         for var _r in _data do begin
            // Skip filtered out statuses
            if ( not isStatusVisible( _r.Status ) ) then
               Continue;

            case FGroupMode of
               gmSystem: _groupCaption:= _r.SystemName+' ('+_r.SystemKey+')';
               gmStatus: _groupCaption:= cstBiosStatusStrings[_r.Status];
            end;

            _item:= lvBios.Items.Add;
            _item.Caption:= _r.SystemName;
            _item.SubItems.Add( _r.FileName );
            _item.SubItems.Add( cstBiosStatusStrings[_r.Status] );
            _item.SubItems.Add( _r.FullPath );
            _item.SubItems.Add( _r.ExpectedMD5 );
            _item.SubItems.Add( _r.ActualMD5 );
            _item.GroupID:= getOrCreateGroup( _groupCaption );
            _item.ImageIndex:= Ord( _r.Status );

            // For partial status, add second line for alternative path
            if ( _r.Status = bsPartial ) and ( not _r.altFullPath.IsEmpty ) then begin
               // Line 1 status indicator
               _item.ImageIndex:= IfThen( _r.primaryExists, Ord( bsPartial ), Ord( bsMissing ) );

               // Line 2 : alternative path
               var _altItem:= lvBios.Items.Add;
               _altItem.Caption:= '';
               _altItem.SubItems.Add( ExtractFileName( _r.altFullPath ) );
               _altItem.SubItems.Add( IfThen( _r.altExists,
                                              cstBiosStatusStrings[bsOk],
                                              cstBiosStatusStrings[bsMissing] ) );
               _altItem.SubItems.Add( _r.altFullPath );
               _altItem.SubItems.Add( '' );
               _altItem.SubItems.Add( '' );
               _altItem.GroupID:= getOrCreateGroup( _groupCaption );
               _altItem.ImageIndex:= IfThen( _r.altExists, Ord( bsPartial ), Ord( bsMissing ) );
            end;
         end;
      finally
         lvBios.Items.EndUpdate;
         lvBios.GroupView:= True;
      end;

      lvBios.LockDrawing;
      try
         // Auto-resize columns to fit content
         for var ii:= 0 to Pred( lvBios.Columns.Count ) do
            lvBios.Columns[ii].Width:= -2;  // -2 = fit content AND header
      finally
         lvBios.UnlockDrawing;
      end;
   finally
      Screen.Cursor:= crDefault;
   end;
end;

procedure TfrmBiosDetails.populateVST;
begin
   vstBios.BeginUpdate;
   try
      vstBios.Clear;

      // Build groups
      var _groups:= TDictionary<string, PVirtualNode>.Create;
      try
         for var _r in FResults do begin
            if ( not isStatusVisible( _r.Status ) ) then Continue;

            // Determine group caption
            var _groupCaption:= '';
            case FGroupMode of
               gmSystem: _groupCaption:= _r.SystemName + ' (' + _r.SystemKey + ')';
               gmStatus: _groupCaption:= cstBiosStatusStrings[_r.Status];
            end;

            // Get or create group node
            var _groupNode: PVirtualNode;
            if ( not _groups.TryGetValue( _groupCaption, _groupNode ) ) then begin
               _groupNode:= vstBios.AddChild( nil );
               var _groupData:= PBiosNodeData( vstBios.GetNodeData( _groupNode ) );
               _groupData.isGroup  := True;
               _groupData.isAltPath:= False;
               _groupData.groupText:= _groupCaption;
               vstBios.Expanded[_groupNode]:= True;
               _groups.Add( _groupCaption, _groupNode );
            end;

            // Add item under group
            var _node:= vstBios.AddChild( _groupNode );
            var _data:= PBiosNodeData( vstBios.GetNodeData( _node ) );
            _data.result:= _r;
            _data.isAltPath:= False;
            _data.isGroup:= False;

            // Add alt path as sibling, not child
            if ( _r.Status = bsPartial ) and ( not _r.altFullPath.IsEmpty ) then begin
               var _altNode:= vstBios.AddChild( _groupNode );
               var _altData:= PBiosNodeData( vstBios.GetNodeData( _altNode ) );
               _altData.result:= _r;
               _altData.isAltPath:= True;
               _altData.isGroup:= False;
            end;
         end;
      finally
         _groups.Free;
      end;
   finally
      vstBios.EndUpdate;
   end;
   vstbios.FullExpand;
   vstBios.Header.AutoFitColumns( False, smaAllColumns, -1, -1 );
end;

procedure TfrmBiosDetails.popupMenuPopup(Sender: TObject);
begin
   mniCopyMD5.Enabled:= ( lvBios.Selected <> nil ) and
                          not lvBios.Selected.SubItems[2].IsEmpty;
   mniOpenFolder.Enabled:= ( lvBios.Selected <> nil ) and
                             not lvBios.Selected.SubItems[4].IsEmpty;
end;

procedure TfrmBiosDetails.lvBiosCustomDrawItem( Sender: TCustomListView;
                                                Item: TListItem;
                                                State: TCustomDrawState;
                                                var DefaultDraw: Boolean );
begin
   Sender.Canvas.Font.Color:= cstBiosStatusColors[TBiosStatus( Item.ImageIndex )];
   DefaultDraw:= True;
end;

procedure TfrmBiosDetails.mniCopyMD5Click(Sender: TObject);
begin
   if ( lvBios.Selected = nil ) then
      Exit;
   var _md5:= lvBios.Selected.SubItems[2];  // index 2 = Expected MD5
   if ( _md5.IsEmpty ) then
      Exit;
   Clipboard.AsText:= _md5;
end;

procedure TfrmBiosDetails.mniOpenFolderClick(Sender: TObject);
begin
   if ( lvBios.Selected = nil ) then
      Exit;
   var _path:= lvBios.Selected.SubItems[4];  // index 4 = Full path
   if ( _path.IsEmpty ) then
      Exit;
   var _folder:= TPath.GetDirectoryName( _path );
   if ( TDirectory.Exists( _folder ) ) then
      ShellExecute( Handle, 'open', PChar( _folder ), nil, nil, SW_SHOWNORMAL );
end;

procedure TfrmBiosDetails.vstBiosGetText( Sender: TBaseVirtualTree;
                                           Node: PVirtualNode;
                                           Column: TColumnIndex;
                                           TextType: TVSTTextType;
                                           var CellText: string );
begin
   var _data:= PBiosNodeData( Sender.GetNodeData( Node ) );
   if ( _data = nil ) then Exit;

   if ( _data.isGroup ) then begin
      case Column of
         0: CellText:= _data.groupText;
      else
         CellText:= '';
      end;
      Exit;
   end;

   if ( _data.isAltPath ) then begin
      case Column of
         0: CellText:= '';
         1: CellText:= ExtractFileName( _data.result.altFullPath );
         2: CellText:= IfThen( _data.result.altExists,
                               cstBiosStatusStrings[bsOK],
                               cstBiosStatusStrings[bsMissing] );
         3: CellText:= _data.result.altFullPath;
         4: CellText:= _data.result.ExpectedMD5;
         5: CellText:= '';
      end;
   end else begin
      case Column of
         0: CellText:= _data.result.SystemName;
         1: CellText:= _data.result.FileName;
         2: CellText:= cstBiosStatusStrings[_data.result.Status];
         3: CellText:= _data.result.FullPath;
         4: CellText:= _data.result.ExpectedMD5;
         5: CellText:= _data.result.ActualMD5;
      end;
   end;
end;

procedure TfrmBiosDetails.vstBiosFreeNode( Sender: TBaseVirtualTree;
                                            Node: PVirtualNode );
begin
   var _data:= PBiosNodeData( Sender.GetNodeData( Node ) );
   if ( _data <> nil ) then
      Finalize( _data^ );
end;

procedure TfrmBiosDetails.vstBiosPaintText( Sender: TBaseVirtualTree;
                                             const TargetCanvas: TCanvas;
                                             Node: PVirtualNode;
                                             Column: TColumnIndex;
                                             TextType: TVSTTextType );
begin
   var _data:= PBiosNodeData( Sender.GetNodeData( Node ) );
   if ( _data = nil ) then Exit;
   if ( _data.isGroup ) then begin
      TargetCanvas.Font.Style:= [fsBold, fsItalic];
      TargetCanvas.Font.Color:= clWebRoyalBlue;
   end else if ( _data.isAltPath ) then begin
      var _color:= cstBiosStatusColors[bsOK];
      if ( not _data.result.altExists ) then
         _color:= cstBiosStatusColors[bsMissing];
      TargetCanvas.Font.Color:= _color;
   end else
      TargetCanvas.Font.Color:= cstBiosStatusColors[_data.result.Status];
end;

end.
