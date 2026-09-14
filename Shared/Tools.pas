unit Tools;

interface

uses
   System.SysUtils;

procedure writeLog( const aLine: string );
procedure logInfo( const aSystemName, aMessage: string );
procedure logError( const aSystemName, aGamelistPath: string; aException: Exception );

implementation

uses
   System.IOUtils,
   System.DateUtils,
   Constantes;

procedure writeLog( const aLine: string );
begin
   try
      var _logPath:= TPath.Combine( TPath.GetDirectoryName( ParamStr( 0 ) ), cstLogFile );
      TFile.AppendAllText( _logPath,
                           Format( '[%s] %s', [FormatDateTime( 'yyyy-mm-dd hh:nn:ss', Now ), aLine] )+sLineBreak,
                           TEncoding.UTF8 );
   except
      // le log ne doit jamais faire échouer le scan
   end;
end;

procedure logInfo( const aSystemName, aMessage: string );
begin
   writeLog( Format( 'INFO  | %s | %s', [aSystemName, aMessage] ) );
end;

procedure logError( const aSystemName, aGamelistPath: string; aException: Exception );
begin
   writeLog( Format( 'ERROR | %s | %s: %s | %s', [aSystemName, aException.ClassName, aException.Message, aGamelistPath] ) );
end;

end.
