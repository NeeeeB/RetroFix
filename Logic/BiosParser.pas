unit BiosParser;

interface

uses
   Types;

function parseBiosJson( const aJson: string ): TArray<TBiosSystemEntry>;

implementation

uses
   System.Generics.Collections,
   System.IOUtils,
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

            var _biosFile: TBiosFileEntry;
            _biosFile.relativePath:= _fileObj.GetValue<string>( cstFile, '' ).Replace( '/', '\' );
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
