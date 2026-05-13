unit BiosExport;

interface

uses
   Types,
   Constantes;

procedure exportBiosToCSV( const aResults: TArray<TBiosResult>;
                           const aFilePath: string );

implementation

uses
   System.SysUtils,
   System.IOUtils,
   System.Classes;

procedure exportBiosToCSV( const aResults: TArray<TBiosResult>;
                           const aFilePath: string );
var
   _lines: TStringList;
begin
   _lines:= TStringList.Create;
   try
      // Header
      _lines.Add( 'System Key;System Name;File;Status;Expected MD5;Actual MD5;Full Path' );

      for var _r in aResults do
         _lines.Add( Format( '%s;%s;%s;%s;%s;%s;%s',
                             [_r.SystemKey,
                              _r.SystemName,
                              _r.FileName,
                              cstBiosStatusStrings[_r.Status],
                              _r.ExpectedMD5,
                              _r.ActualMD5,
                              _r.FullPath] ) );

      _lines.SaveToFile( aFilePath, TEncoding.UTF8 );
   finally
      _lines.Free;
   end;
end;

end.
