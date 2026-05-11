unit BiosParser;

interface

uses
   Types;

function parseBiosJson( const aJson: string ): TArray<TBiosSystemEntry>;

implementation

uses
   System.Generics.Collections,
   System.SysUtils,
   System.JSON,
   Constantes;

function parseBiosJson( const aJson: string ): TArray<TBiosSystemEntry>;
begin
   var _results: TArray<TBiosSystemEntry>;
   SetLength( _results, 0 );
   var _root:= TJSONObject.ParseJSONValue( aJson ) as TJSONObject;
   if ( _root = nil ) then
      Exit( _results );
   try
      for var _pair in _root do begin
         var _sysObj:= _pair.JsonValue as TJSONObject;

         var _entry: TBiosSystemEntry;
         _entry.SystemKey:= _pair.JsonString.Value;
         _entry.SystemName:= _sysObj.GetValue<string>( cstName, _entry.SystemKey );
         SetLength( _entry.files, 0 );

         var _filesArr:= _sysObj.GetValue( cstBiosfiles ) as TJSONArray;
         if ( _filesArr = nil ) then begin
            _results:= _results+[_entry];
            Continue;
         end;

         for var ii:= 0 to Pred( _filesArr.Count ) do begin
            var _fileObj:= _filesArr.Items[ii] as TJSONObject;

            // Splitter "bios/kronos/kronos.bin" → retirer le préfixe "bios/"
            // puis séparer sous-dossier et nom de fichier
            var _filePath:= _fileObj.GetValue<string>( cstFile, '' );

            // Retirer le préfixe "bios/"
            if _filePath.StartsWith( cstBios+'/' ) then
               _filePath:= _filePath.Substring( Succ( Length( cstBios ) ) );  // longueur de 'bios/'

            // Séparer en parts sur '/'
            var _parts:= _filePath.Split( ['/'] );

            var _biosFile: TBiosFileEntry;
            if ( Length( _parts ) = 1 ) then begin
               // Racine du dossier bios : "scph5501.bin"
               _biosFile.subPath:= '';
               _biosFile.fileName:= _parts[0];
            end else begin
               // Sous-dossier(s) : "kronos/kronos.bin" ou "mame/hash/adam_cart.xml"
               _biosFile.fileName:= _parts[High( _parts )];
               _biosFile.subPath := String.Join( '\',
                                                 Copy( _parts, 0, Length( _parts ) - 1 ) );
            end;

            _biosFile.MD5:= LowerCase( _fileObj.GetValue<string>( cstMD5, '' ) );

            _entry.files:= _entry.files+[_biosFile];
         end;

         _results:= _results+[_entry];
      end;
   finally
      _root.Free;
   end;

   Result:= _results;
end;

end.
