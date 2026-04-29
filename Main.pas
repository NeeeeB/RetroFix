unit Main;

interface

uses
   System.Diagnostics,
   Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics,
   Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.StdCtrls,
   Vcl.ExtCtrls, Vcl.Skia,
   Constantes,
   Types, System.ImageList, Vcl.ImgList, Vcl.ComCtrls,
   BiosDetails, GameListDetails;

type
   TfrmMain = class( TForm )
      fileOpenDialog: TFileOpenDialog;
      pnlMain: TPanel;
      pnlTop: TPanel;
      lblRetrobatPath: TLabel;
      edtRetrobatPath: TEdit;
      btnSelectFolder: TButton;
      lblValidSelectedFolder: TLabel;
      gbxActions: TGroupBox;
      imageList: TImageList;
      btnSaveSettings: TButton;
      gbxBios: TGroupBox;
      btnScanBios: TButton;
      chkForceExtract: TCheckBox;
      chkStrictMode: TCheckBox;
      lblBiosScanResult: TLabel;
      btnBiosScanDetails: TButton;
      pnlBottom: TPanel;
      progressBar: TProgressBar;
      lblProgress: TLabel;
      gbxGamelists: TGroupBox;
      btnScanGamelists: TButton;
      btnGamelistScanDetails: TButton;
      lblGamelistScanResult: TLabel;
      procedure FormCreate(Sender: TObject);
      procedure FormDestroy(Sender: TObject);
      procedure btnSelectFolderClick(Sender: TObject);
      procedure btnSaveSettingsClick(Sender: TObject);
      procedure edtRetrobatPathChange(Sender: TObject);
      procedure btnScanBiosClick(Sender: TObject);
      procedure chkStrictModeClick(Sender: TObject);
      procedure btnBiosScanDetailsClick(Sender: TObject);
      procedure chkForceExtractClick(Sender: TObject);
      procedure onBiosRescan(Sender: TObject; const aOptions: TScanOptions);
      procedure onBiosDetailsClose( Sender: TObject; var Action: TCloseAction );
      procedure onGamelistDetailsClose( Sender: TObject; var Action: TCloseAction );
      procedure btnScanGamelistsClick(Sender: TObject);
      procedure FormShow(Sender: TObject);
      procedure btnGamelistScanDetailsClick(Sender: TObject);

   private
      FStopWatch: TStopwatch;
      FSettings: TSettings;
      FBiosResults: TArray<TBiosResult>;
      FLoading: Boolean;
      FBiosDetails: TfrmBiosDetails;
      FGamelistResults: TArray<TGamelistResult>;
      FGamelistDetails: TfrmGamelistDetails;
      function tryAndLoadSettings: Boolean;
      function retrobatFolderValidation( const aFolderPath: string ): TValidFolder;
      function getBaseFolder: string;
      function getBiosJsonPath: string;
      function getSettingsFilePath: string;
      procedure setLabelTextAndColor(aValidFolderValue: TValidFolder);
      function computeSummary( const aResults: TArray<TBiosResult> ): TBiosSummary;
      procedure displaySummary( const aSummary: TBiosSummary );
      procedure onBiosProgress( const aSystem, aFile: string; aCurrent, aTotal: Integer );
      function computeGamelistSummary( const aResults: TArray<TGamelistResult> ): TGamelistSummary;
      procedure displayGamelistSummary( const aSummary: TGamelistSummary );
      procedure onGamelistProgress( const aSystem: string; aCurrent, aTotal: Integer );

   end;

var
   frmMain: TfrmMain;

implementation

uses
   System.IOUtils,
   Rest.JSON,
   BiosExtractor,
   BiosParser,
   BiosChecker,
   GamelistChecker;

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
   lblValidSelectedFolder.Caption:= cstValidFolderStrings[vfUndefined];
   lblValidSelectedFolder.Font.Color:= cstValidFolderColors[vfUndefined];
   FSettings:= TSettings.Create;
   if ( tryAndLoadSettings ) then begin
      FLoading:= True;
      try
         edtRetrobatPath.Text:= FSettings.retrobatPath;
         var _valid:= retrobatFolderValidation( edtRetrobatPath.Text );
         gbxActions.Enabled:= ( _valid = vfValid );
         setLabelTextAndColor( _valid );
         chkStrictMode.Checked:= FSettings.strictMode;
         chkForceExtract.Checked:= FSettings.forceExtract;
      finally
         FLoading:= False;
      end;
   end;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
   btnSelectFolder.SetFocus;
end;

function TfrmMain.getBaseFolder: string;
begin
   Result:= TPath.GetDirectoryName( Application.ExeName );
end;

function TfrmMain.getBiosJsonPath: string;
begin
   Result:= TPath.Combine( getBaseFolder, cstBiosFileName );
end;

function TfrmMain.getSettingsFilePath: string;
begin
   Result:= TPath.Combine( getBaseFolder, cstSettingsFileName );
end;

procedure TfrmMain.btnGamelistScanDetailsClick( Sender: TObject );
begin
   if FGamelistDetails = nil then begin
      FGamelistDetails:= TfrmGamelistDetails.Create( Self );
      FGamelistDetails.OnClose:= onGamelistDetailsClose;
   end;
   FGamelistDetails.setResults( FGamelistResults );
   FGamelistDetails.Show;
   FGamelistDetails.BringToFront;
end;

procedure TfrmMain.onGamelistDetailsClose( Sender: TObject; var Action: TCloseAction );
begin
   Action:= caFree;
   FGamelistDetails:= nil;
end;

procedure TfrmMain.btnSaveSettingsClick(Sender: TObject);
begin
   TFile.WriteAllText( getSettingsFilePath, TJson.ObjectToJsonString( FSettings ) );
end;

procedure TfrmMain.btnSelectFolderClick( Sender: TObject );
begin
   if fileOpenDialog.Execute then begin
      edtRetrobatPath.Text:= fileOpenDialog.FileName;
      FSettings.retrobatPath:= edtRetrobatPath.Text;
      var _valid:= retrobatFolderValidation( edtRetrobatPath.Text );
      gbxActions.Enabled:= ( _valid = vfValid );
      setLabelTextAndColor( _valid );
   end;
end;

procedure TfrmMain.chkForceExtractClick(Sender: TObject);
begin
   if FLoading then
      Exit;
   FSettings.forceExtract:= chkForceExtract.Checked;
end;

procedure TfrmMain.chkStrictModeClick(Sender: TObject);
begin
   if FLoading then
      Exit;
   FSettings.strictMode:= chkStrictMode.Checked;
end;

procedure TfrmMain.edtRetrobatPathChange( Sender: TObject );
begin
   if FLoading then
      Exit;
   FSettings.retrobatPath:= edtRetrobatPath.Text;
   var _valid:= retrobatFolderValidation( edtRetrobatPath.Text );
   gbxActions.Enabled:= ( _valid = vfValid );
   setLabelTextAndColor( _valid );
end;

procedure TfrmMain.setLabelTextAndColor( aValidFolderValue: TValidFolder );
begin
   lblValidSelectedFolder.Caption:= cstValidFolderStrings[aValidFolderValue];
   lblValidSelectedFolder.Font.Color:= cstValidFolderColors[aValidFolderValue];
end;

function TfrmMain.tryAndLoadSettings: Boolean;
begin
   Result:= False;
   var _settingsFilePath:= getSettingsFilePath;

   if TFile.Exists( _settingsFilePath ) then begin
      var _jsonStr:= TFile.ReadAllText( _settingsFilePath );
      var _loaded:= TJson.JsonToObject<TSettings>( _jsonStr );
      if ( _loaded <> nil ) then begin
         FSettings.Free;
         FSettings:= _loaded;
         Result:= True;
      end;
   end;
end;

function TfrmMain.retrobatFolderValidation( const aFolderPath: string ): TValidFolder;
begin
   if FileExists( TPath.Combine( aFolderPath, cstRetrobatExeFilename ) ) then
      Result:= vfValid
   else
      Result:= vfInvalid;
end;

procedure TfrmMain.btnBiosScanDetailsClick( Sender: TObject );
begin
   if FBiosDetails = nil then begin
      FBiosDetails:= TfrmBiosDetails.Create( Self );
      FBiosDetails.OnRescan:= onBiosRescan;
      FBiosDetails.OnClose:= onBiosDetailsClose;
      FBiosDetails.chkRescanForceExtract.Checked:= chkForceExtract.Checked;
      FBiosDetails.chkRescanStrictMode.Checked:= chkStrictMode.Checked;
   end;
   FBiosDetails.setResults( FBiosResults );
   FBiosDetails.Show;
   FBiosDetails.BringToFront;
end;

procedure TfrmMain.onBiosDetailsClose( Sender: TObject; var Action: TCloseAction );
begin
   Action:= caFree;
   FBiosDetails:= nil;
end;

procedure TfrmMain.btnScanBiosClick( Sender: TObject );
begin
   FStopWatch:= TStopwatch.StartNew;
   Screen.Cursor:= crHourGlass;
   try
      btnScanBios.Enabled:= False;
      btnBiosScanDetails.Enabled:= False;
      lblBiosScanResult.Caption:= rstScanning;
      lblBiosScanResult.Font.Color:= clGray;
      try
         // Step 1 : extract bios.json if needed
         var _jsonPath:= getBiosJsonPath;
         if ( not TFile.Exists( _jsonPath ) ) or
            ( chkForceExtract.Checked ) then begin
            var _json, _err: string;
            if ( not extractBiosJson( FSettings.retrobatPath, _json, _err ) ) then begin
               lblBiosScanResult.Caption:= rstExtractionFailed+_err;
               lblBiosScanResult.Font.Color:= clRed;
               Exit;
            end;
            TFile.WriteAllText( _jsonPath, _json, TEncoding.UTF8 );
         end;

         // Step 2 : parse bios.json
         var _json:= TFile.ReadAllText( _jsonPath, TEncoding.UTF8 );
         var _entries:= parseBiosJson( _json );

         // Step 3 : check bios folder
         var _biosDir:= TPath.Combine( FSettings.retrobatPath, cstBios );
         FBiosResults:= checkBios( _biosDir, _entries, chkStrictMode.Checked, onBiosProgress );

         // Step 4 : compute and display summary
         displaySummary( computeSummary( FBiosResults ) );
         btnBiosScanDetails.Enabled:= True;
      finally
         btnScanBios.Enabled:= True;
      end;
   finally
      Screen.Cursor:= crDefault;
      progressBar.Position:= 0;
      FStopWatch.Stop;
      lblProgress.Caption:= Format( rstStopWatchStr, [FStopWatch.Elapsed.TotalSeconds] );
   end;
end;

procedure TfrmMain.btnScanGamelistsClick( Sender: TObject );
begin
   FStopWatch:= TStopwatch.StartNew;
   Screen.Cursor:= crHourGlass;
   try
      btnScanGamelists.Enabled:= False;
      btnGamelistScanDetails.Enabled:= False;
      lblGamelistScanResult.Caption:= rstScanning;
      lblGamelistScanResult.Font.Color:= clGray;
      try
         var _romsDir:= TPath.Combine( FSettings.retrobatPath, cstRomsFolder );
         FGamelistResults:= checkGamelists( _romsDir, onGamelistProgress );
         displayGamelistSummary( computeGamelistSummary( FGamelistResults ) );
         btnGamelistScanDetails.Enabled:= True;
      finally
         btnScanGamelists.Enabled:= True;
      end;
   finally
      Screen.Cursor:= crDefault;
      progressBar.Position:= 0;
      FStopWatch.Stop;
      lblProgress.Caption:= Format( rstStopWatchStr, [FStopWatch.Elapsed.TotalSeconds] );
   end;
end;

procedure TfrmMain.onGamelistProgress( const aSystem: string;
                                       aCurrent, aTotal: Integer );
begin
   progressBar.Max:= aTotal;
   progressBar.Position:= aCurrent;
   lblProgress.Caption:= '['+aSystem+']';
   Application.ProcessMessages;
end;

function TfrmMain.computeGamelistSummary( const aResults: TArray<TGamelistResult> ): TGamelistSummary;
begin
   Result:= Default( TGamelistSummary );
   for var _r in aResults do begin
      Inc( Result.totalSystems );
      Inc( Result.totalGames, Length( _r.games ) );
      Inc( Result.totalMissingROMs, Length( _r.missingROMs ) );
      Inc( Result.totalUnscraped, Length( _r.unscrapedROMs ) );
      Inc( Result.totalMissingMedias, Length( _r.missingMedias ) );
      Inc( Result.totalOrphanMedias, Length( _r.orphanMedias ) );
      for var _g in _r.games do begin
         if ( _g.isScraped ) then
            Inc( Result.totalScraped )
         else
            Inc( Result.totalNoMedia );
      end;
   end;
end;

procedure TfrmMain.displayGamelistSummary( const aSummary: TGamelistSummary );
begin
   lblGamelistScanResult.Caption:= Format( rstGamelistScanSummary,
                                           [aSummary.totalSystems,
                                            aSummary.totalGames,
                                            aSummary.totalScraped,
                                            aSummary.totalNoMedia,
                                            aSummary.totalMissingROMs,
                                            aSummary.totalUnscraped,
                                            aSummary.totalMissingMedias,
                                            aSummary.totalOrphanMedias] );

   if ( aSummary.totalMissingROMs > 0 ) then
      lblGamelistScanResult.Font.Color:= clRed
   else if ( aSummary.totalUnscraped > 0 ) or
           ( aSummary.totalNoMedia > 0 ) or
           ( aSummary.totalMissingMedias > 0 ) or
           ( aSummary.totalOrphanMedias > 0 ) then
      lblGamelistScanResult.Font.Color:= $004080FF  // orange
   else
      lblGamelistScanResult.Font.Color:= clGreen;
end;

procedure TfrmMain.onBiosProgress( const aSystem, aFile: string; aCurrent, aTotal: Integer );
begin
   progressBar.Max:= aTotal;
   progressBar.Position:= aCurrent;
   lblProgress.Caption:= '['+aSystem+'] '+aFile;
   Application.ProcessMessages;
end;

function TfrmMain.computeSummary( const aResults: TArray<TBiosResult> ): TBiosSummary;
begin
   Result:= Default( TBiosSummary );
   for var _r in aResults do begin
      Inc( Result.total );
      case _r.Status of
         bsOK            : Inc( Result.ok );
         bsPresentNoHash : Inc( Result.presentNoHash );
         bsMD5Mismatch   : Inc( Result.md5Mismatch );
         bsMissing       : Inc( Result.missing );
      end;
   end;
end;

procedure TfrmMain.displaySummary( const aSummary: TBiosSummary );
begin
   lblBiosScanResult.Caption:= Format( rstBiosScanSummary,
                                       [aSummary.total,
                                        aSummary.ok,
                                        aSummary.presentNoHash,
                                        aSummary.md5Mismatch,
                                        aSummary.missing] );

   // Color logic
   if ( aSummary.missing > 0 ) then
      lblBiosScanResult.Font.Color:= clRed
   else if ( aSummary.md5Mismatch > 0 ) then
      lblBiosScanResult.Font.Color:= $004080FF  // orange
   else
      lblBiosScanResult.Font.Color:= clGreen;
end;

procedure TfrmMain.onBiosRescan( Sender: TObject; const aOptions: TScanOptions );
begin
   FStopWatch:= TStopwatch.StartNew;
   // Use options from detail form for this scan, without modifying main form checkboxes
   var _biosDir:= TPath.Combine( FSettings.retrobatPath, cstBios );
   var _jsonPath:= getBiosJsonPath;

   if ( aOptions.forceExtract ) or
      ( not TFile.Exists( _jsonPath ) ) then begin
      var _json, _err: string;
      if ( not extractBiosJson( FSettings.retrobatPath, _json, _err ) ) then
         Exit;
      TFile.WriteAllText( _jsonPath, _json, TEncoding.UTF8 );
   end;

   var _json:= TFile.ReadAllText( _jsonPath, TEncoding.UTF8 );
   var _entries:= parseBiosJson( _json );
   FBiosResults:= checkBios( _biosDir, _entries, aOptions.strictMode, onBiosProgress );
   displaySummary( computeSummary( FBiosResults ) );
   FBiosDetails.setResults( FBiosResults );
   FStopWatch.Stop;
   progressBar.Position:= 0;
   lblProgress.Caption:= Format( rstStopWatchStr, [FStopWatch.Elapsed.TotalSeconds] );
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
   FSettings.Free;
end;

end.
