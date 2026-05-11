unit BiosChecker;

interface

uses
   Types;

type
   TProgressCallback = procedure( const aSystem, aFile: string;
                                  aCurrent, aTotal: Integer ) of object;

function checkBios( const aBiosDir: string;
                    const aEntries: TArray<TBiosSystemEntry>;
                    const aStrict: Boolean;
                    aOnProgress: TProgressCallback ): TArray<TBiosResult>;

implementation

uses
   System.SysUtils,
   System.IOUtils,
   HashUtils;

function checkBios( const aBiosDir: string;
                    const aEntries: TArray<TBiosSystemEntry>;
                    const aStrict: Boolean;
                    aOnProgress: TProgressCallback ): TArray<TBiosResult>;
begin
   var _results: TArray<TBiosResult>;
   SetLength( _results, 0 );

   // Count total files for progress callback
   var _total:= 0;
   for var _se in aEntries do
      Inc( _total, Length( _se.files ) );

   var _current:= 0;

   for var _se in aEntries do begin
      for var _bf in _se.files do begin
         Inc( _current );

         // Build full path
         var _fullPath: string;
         if ( not _bf.subPath.IsEmpty ) then
            _fullPath:= TPath.Combine( aBiosDir,
                                       TPath.Combine( _bf.subPath, _bf.fileName ) )
         else
            _fullPath:= TPath.Combine( aBiosDir, _bf.fileName );

         // Notify progress
         if ( Assigned( aOnProgress ) ) then
            aOnProgress( _se.SystemName, _bf.fileName, _current, _total );

         // Build result record
         var _res: TBiosResult;
         _res.SystemKey:= _se.SystemKey;
         _res.SystemName:= _se.SystemName;
         _res.FileName:= _bf.fileName;
         _res.FullPath:= _fullPath;
         _res.ExpectedMD5:= _bf.MD5;
         _res.ActualMD5:= '';

         if ( not FileExists( _fullPath ) ) then begin
            // File is missing — always an error regardless of strict mode
            _res.Status:= bsMissing;
         end else if ( _bf.MD5.IsEmpty ) then begin
            // File present but no hash to verify against
            _res.Status:= bsPresentNoHash;
         end else begin
            // File present and we have an expected MD5 — compute and compare
            _res.ActualMD5:= fileMD5( _fullPath );
            if ( _res.ActualMD5 = _bf.MD5 ) then
               _res.Status:= bsOK
            else if ( aStrict ) then
               _res.Status:= bsMissing  // In strict mode, MD5 mismatch is treated as missing
            else
               _res.Status:= bsMD5Mismatch;  // In normal mode, just a warning
         end;

         _results:= _results+[_res];
      end;
   end;

   Result:= _results;
end;

end.
