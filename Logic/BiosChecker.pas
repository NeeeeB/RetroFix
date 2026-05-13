unit BiosChecker;

interface

uses
   Types,
   constantes;

type
   TProgressCallback = procedure( const aSystem, aFile: string;
                                  aCurrent, aTotal: Integer ) of object;

function checkBios( const aRetrobatPath: string;
                    const aEntries: TArray<TBiosSystemEntry>;
                    const aStrict: Boolean;
                    aOnProgress: TProgressCallback ): TArray<TBiosResult>;

implementation

uses
   System.SysUtils,
   System.StrUtils,
   System.IOUtils,
   HashUtils;

function checkBios( const aRetrobatPath: string;
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

         var _filename:= ExtractfileName( _bf.relativePath );

         // Build full path
         var _fullPath:= TPath.Combine( aRetrobatPath, _bf.relativePath );

         // Check alternative paths
         var _altRelPath:= '';
         for var _alt in cstBiosAlternativePaths do begin
            if ( _alt.systemKey = _se.SystemKey ) and
               ( _alt.fileName = _filename ) then begin
               _altRelPath:= _alt.altRelPath;
               Break;
            end;
         end;

         // Notify progress
         if ( Assigned( aOnProgress ) ) then
            aOnProgress( _se.SystemName, _filename, _current, _total );

         // Build result record
         var _res: TBiosResult;
         _res.SystemKey:= _se.SystemKey;
         _res.SystemName:= _se.SystemName;
         _res.FileName:= _filename;
         _res.FullPath:= _fullPath;
         _res.altFullPath:= IfThen( ( not _altRelPath.IsEmpty ),
                                    TPath.Combine( aRetrobatPath, _altRelPath ), '' );
         _res.ExpectedMD5:= _bf.MD5;
         _res.ActualMD5:= '';
         _res.primaryExists:= TFile.Exists( _fullPath );
         _res.altExists:= ( not _altRelPath.IsEmpty ) and
                          TFile.Exists( _res.altFullPath );

         if ( _altRelPath.IsEmpty ) then begin
            // No alternative path — standard check
            if ( not _res.primaryExists ) then
               _res.Status:= bsMissing
            else if ( _bf.MD5.IsEmpty ) then
               _res.Status:= bsPresentNoHash
            else begin
               _res.ActualMD5:= fileMD5( _fullPath );
               if ( _res.ActualMD5 = _bf.MD5 ) then
                  _res.Status:= bsOK
               else if ( aStrict ) then
                  _res.Status:= bsMissing
               else
                  _res.Status:= bsMD5Mismatch;
            end;
         end else begin
            // Has alternative path
            if ( not _res.primaryExists ) and ( not _res.altExists ) then
               _res.Status:= bsMissing
            else if ( _res.primaryExists ) and ( _res.altExists ) then begin
               // Both present — check MD5 on primary
               if ( _bf.MD5.IsEmpty ) then
                  _res.Status:= bsPresentNoHash
               else begin
                  _res.ActualMD5:= fileMD5( _fullPath );
                  if ( _res.ActualMD5 = _bf.MD5 ) then
                     _res.Status:= bsOK
                  else if ( aStrict ) then
                     _res.Status:= bsMissing
                  else
                     _res.Status:= bsMD5Mismatch;
               end;
            end else begin
               // One present, one absent — partial
               _res.Status:= bsPartial;
               // Calculate MD5 if primary exists
               if ( _res.primaryExists ) and ( not _bf.MD5.IsEmpty ) then
                  _res.ActualMD5:= fileMD5( _fullPath );
            end;
         end;

         _results:= _results+[_res];
      end;
   end;

   Result:= _results;
end;

end.
