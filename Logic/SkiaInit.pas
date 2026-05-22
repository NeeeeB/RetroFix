unit SkiaInit;

interface

implementation

uses
   System.SysUtils, System.Classes, System.IOUtils,
   Winapi.Windows;

initialization
   var _dllPath:= TPath.Combine( ExtractFilePath( ParamStr( 0 ) ), 'sk4d.dll' );
   if ( not FileExists( _dllPath ) ) then begin
      var _rs:= TResourceStream.Create( HInstance, 'SK4D', RT_RCDATA );
      try
         _rs.SaveToFile( _dllPath );
      finally
         _rs.Free;
      end;
   end;

end.
