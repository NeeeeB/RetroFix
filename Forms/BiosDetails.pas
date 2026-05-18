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
   TfrmBiosDetails = class( TForm )
      pnlTop: TPanel;
      rgpGroupMode: TRadioGroup;
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
      procedure vstBiosPaintText( Sender: TBaseVirtualTree;
                                  const TargetCanvas: TCanvas;
                                  Node: PVirtualNode;
                                  Column: TColumnIndex;
                                  TextType: TVSTTextType );

   private
      FResults: TArray<TBiosResult>;
      FGroupMode: TGroupMode;
      FOnRescan: TRescanEvent;
      procedure populateVST;
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
   populateVST;
end;

procedure TfrmBiosDetails.FormCreate( Sender: TObject );
begin
   vstBios.NodeDataSize:= SizeOf( TBiosNodeData );
   FGroupMode:= gmSystem;
end;

procedure TfrmBiosDetails.setResults( const aResults: TArray<TBiosResult> );
begin
   FResults:= aResults;
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
               gmSystem: _groupCaption:= _r.SystemName;
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
end;

procedure TfrmBiosDetails.popupMenuPopup(Sender: TObject);
begin
   var _node:= vstBios.FocusedNode;
   if ( _node = nil ) then begin
      mniCopyMD5.Enabled:= False;
      mniOpenFolder.Enabled:= False;
      Exit;
   end;
   var _data:= PBiosNodeData( vstBios.GetNodeData( _node ) );
   mniCopyMD5.Enabled:= ( not _data.result.expectedMD5.IsEmpty );
   mniOpenFolder.Enabled:= ( not _data.result.fullPath.IsEmpty ) ;
end;

procedure TfrmBiosDetails.mniCopyMD5Click(Sender: TObject);
begin
   var _data:= PBiosNodeData( vstBios.GetNodeData( vstBios.FocusedNode ) );
   Clipboard.AsText:= _data.result.expectedMD5;
end;

procedure TfrmBiosDetails.mniOpenFolderClick(Sender: TObject);
begin
   var _data:= PBiosNodeData( vstBios.GetNodeData( vstBios.FocusedNode ) );
   var _folder:= TPath.GetDirectoryName( _data.result.fullPath );
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
