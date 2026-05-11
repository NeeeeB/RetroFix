unit BiosExtractor;

interface

uses
   Constantes;

function extractBiosJson( const aRetroBatPath: string;
                          out aJson: string;
                          out aError: string ): Boolean;

implementation

uses
   System.SysUtils, System.IOUtils, Winapi.Windows;

function decodePsResourceOutput( const aFile: string ): string;
begin
   Result:= '';
   var _bytes: TArray<Byte>;
   var _lines:= TFile.ReadAllLines( aFile, TEncoding.UTF8 );
   SetLength( _bytes, Length( _lines ) );
   var ii:= 0;
   for var _line in _lines do begin
      var _trimmed:= Trim( _line );
      if ( _trimmed.IsEmpty ) then
         Continue;
      var _val: Integer;
      if TryStrToInt( _trimmed, _val ) and ( _val >= 0 ) and ( _val <= 255 ) then begin
         _bytes[ii]:= Byte(_val);
         Inc( ii );
      end;
   end;
   SetLength( _bytes, ii );
   Result:= TEncoding.UTF8.GetString( _bytes );
end;

function extractBiosJson( const aRetroBatPath: string;
                          out aJson: string;
                          out aError: string ): Boolean;
begin
   Result:= False;
   aJson:= '';
   aError:= '';

   var _batoceraExeFilePath:= TPath.Combine( aRetroBatPath,
                                             TPath.Combine( cstEmulationStationFolder, cstBatoceraExeName ) );

   if ( not FileExists( _batoceraExeFilePath ) ) then begin
      aError:= 'Could not find '+cstBatoceraExeName+' : ' + _batoceraExeFilePath;
      Exit;
   end;

   var _tempScript:= TPath.Combine( TPath.GetTempPath, cstRetroFixExtractPs1 );
   var _tempOut:= TPath.Combine( TPath.GetTempPath, cstRetroFixBiosJson );

   // Nettoyer un éventuel fichier de sortie précédent
   if ( FileExists( _tempOut ) ) then
      TFile.Delete( _tempOut );

   var _script:= '$exe = "' + _batoceraExeFilePath + '";' + #13#10 +
                 '$asm = [System.Reflection.Assembly]::LoadFile($exe);' + #13#10 +
                 '$stream = $asm.GetManifestResourceStream(''batocera_systems.Properties.Resources.resources'');' + #13#10 +
                 '$reader = New-Object System.Resources.ResourceReader($stream);' + #13#10 +
                 '$e = $reader.GetEnumerator();' + #13#10 +
                 'while ($e.MoveNext()) {' + #13#10 +
                 '  $e.Value | Out-File -FilePath "' + _tempOut + '" -Encoding UTF8;' + #13#10 +
                 '  break;' + #13#10 +
                 '}' + #13#10 +
                 '$reader.Close();';

   TFile.WriteAllText( _tempScript, _script, TEncoding.UTF8 );

   var _si: TStartupInfo;
   var _pi: TProcessInformation;
   FillChar( _si, SizeOf( _si ), 0 );
   _si.cb:= SizeOf(_si);
   _si.dwFlags:= STARTF_USESHOWWINDOW;
   _si.wShowWindow:= SW_HIDE;

   var _cmdLine:= 'powershell.exe -NonInteractive -NoProfile -ExecutionPolicy Bypass ' +
                  '-File "' + _tempScript + '"';

   if ( not CreateProcess( nil, PChar( _cmdLine ), nil, nil, False,
                           CREATE_NO_WINDOW, nil, nil, _si, _pi ) ) then begin
      aError := 'Can not run PowerShell : ' + SysErrorMessage( GetLastError );
      TFile.Delete( _tempScript );
      Exit;
   end;

   WaitForSingleObject( _pi.hProcess, 15000 );
   var _exitCode: DWORD;
   GetExitCodeProcess( _pi.hProcess, _exitCode );
   CloseHandle( _pi.hProcess );
   CloseHandle( _pi.hThread );

   if ( FileExists( _tempScript ) ) then
      TFile.Delete( _tempScript );

   if ( not FileExists( _tempOut ) ) then begin
      aError:= 'PowerShell generated no exit file ( exit code : ' +
               IntToStr( _exitCode ) + ')';
      Exit;
   end;

   try
      aJson:= decodePsResourceOutput( _tempOut );
      if ( aJson.IsEmpty ) then
         aError:= 'JSON is empty or invalid.'
      else
         Result:= True;
   finally
      TFile.Delete( _tempOut );
   end;
end;

end.
