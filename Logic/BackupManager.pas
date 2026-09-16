unit BackupManager;

interface

type
   TBackupChoice = ( bcCancel, bcNoBackup, bcBackup );

function askBackup( aFileCount: Integer; const aRomsDir: string;
                    var aFolder: string ): TBackupChoice;
function newBackupSession: string;
function backupMove( const aRootPath, aFilePath, aBackupRoot, aSession: string;
                     out aError: string ): Boolean;
function backupCopy( const aRootPath, aFilePath, aBackupRoot, aSession: string;
                     out aError: string ): Boolean;

implementation

uses
   System.SysUtils,
   System.IOUtils,
   System.UITypes,
   Vcl.Dialogs,
   Constantes;

function newBackupSession: string;
begin
   Result:= 'Backup_RetroFix_'+FormatDateTime( 'yyyy-mm-dd_hhnnss', Now );
end;

function buildDestPath( const aRootPath, aFilePath, aBackupRoot, aSession: string ): string;
begin
   var _rel:= ExtractRelativePath( IncludeTrailingPathDelimiter( aRootPath ), aFilePath );
   if ( TPath.IsPathRooted( _rel ) ) then
      _rel:= TPath.GetFileName( aFilePath );
   Result:= TPath.Combine( TPath.Combine( aBackupRoot, aSession ), _rel );
end;

function askBackup( aFileCount: Integer; const aRomsDir: string;
                    var aFolder: string ): TBackupChoice;
begin
   case MessageDlg( Format( rstBackupQuestion, [aFileCount] ),
                    mtConfirmation, [mbYes, mbNo, mbCancel], 0 ) of
      mrNo: Exit( bcNoBackup );
      mrYes: ;
   else
      Exit( bcCancel );
   end;

   Result:= bcCancel;
   var _dlg:= TFileOpenDialog.Create( nil );
   try
      _dlg.Options:= [fdoPickFolders, fdoPathMustExist, fdoForceFileSystem];
      _dlg.Title:= rstBackupSelectFolder;
      if ( not aFolder.IsEmpty ) and ( TDirectory.Exists( aFolder ) ) then
         _dlg.DefaultFolder:= aFolder;
      while ( _dlg.Execute ) do begin
         var _sel: string:= _dlg.FileName;
         if ( _sel.StartsWith( IncludeTrailingPathDelimiter( aRomsDir ), True ) ) then begin
            MessageDlg( rstBackupInRoms, mtWarning, [mbOK], 0 );
            Continue;
         end;
         aFolder:= _sel;
         Exit( bcBackup );
      end;
   finally
      _dlg.Free;
   end;
end;

function backupMove( const aRootPath, aFilePath, aBackupRoot, aSession: string;
                     out aError: string ): Boolean;
begin
   Result:= False;
   aError:= '';
   try
      var _dest:= buildDestPath( aRootPath, aFilePath, aBackupRoot, aSession );
      TDirectory.CreateDirectory( TPath.GetDirectoryName( _dest ) );
      TFile.Move( aFilePath, _dest );
      Result:= True;
   except
      on E: Exception do
         aError:= E.Message;
   end;
end;

function backupCopy( const aRootPath, aFilePath, aBackupRoot, aSession: string;
                     out aError: string ): Boolean;
begin
   Result:= False;
   aError:= '';
   try
      var _dest:= buildDestPath( aRootPath, aFilePath, aBackupRoot, aSession );
      TDirectory.CreateDirectory( TPath.GetDirectoryName( _dest ) );
      TFile.Copy( aFilePath, _dest, True );
      Result:= True;
   except
      on E: Exception do
         aError:= E.Message;
   end;
end;

end.
