unit Tools;

interface

uses
   System.SysUtils;

procedure writeLog( const aLine: string );
procedure logInfo( const aSystemName, aMessage: string );
procedure logError( const aSystemName, aGamelistPath: string; aException: Exception );
function normalizePath( const aPath: string ): string;
function loadXmlBytes( const aPath: string ): TBytes;

implementation

uses
   System.IOUtils,
   System.DateUtils,
   Constantes;

function isValidUtf8( const aBytes: TBytes ): Boolean;
begin
   var ii:= 0;
   var _len:= Length( aBytes );
   while ( ii < _len ) do begin
      var _b:= aBytes[ii];
      var _extra: Integer;
      if ( _b <= $7F ) then
         _extra:= 0
      else if ( _b >= $C2 ) and ( _b <= $DF ) then
         _extra:= 1
      else if ( _b >= $E0 ) and ( _b <= $EF ) then
         _extra:= 2
      else if ( _b >= $F0 ) and ( _b <= $F4 ) then
         _extra:= 3
      else
         Exit( False );   // $80..$C1 et $F5..$FF ne peuvent pas ouvrir une séquence

      if ( ii + _extra >= _len ) then
         Exit( False );   // séquence tronquée en fin de fichier

      for var jj:= 1 to _extra do begin
         var _c:= aBytes[ii + jj];
         if ( _c < $80 ) or ( _c > $BF ) then
            Exit( False );   // octet de continuation attendu
      end;

      Inc( ii, Succ( _extra ) );
   end;
   Result:= True;
end;

function loadXmlBytes( const aPath: string ): TBytes;
begin
   Result:= TFile.ReadAllBytes( aPath );
   var _len:= Length( Result );
   if ( _len = 0 ) then Exit;

   // BOM présente : Neslib détecte l'encodage tout seul
   if ( _len >= 3 ) and ( Result[0] = $EF ) and ( Result[1] = $BB ) and ( Result[2] = $BF ) then Exit;
   if ( _len >= 2 ) and ( ( ( Result[0] = $FF ) and ( Result[1] = $FE ) ) or
                          ( ( Result[0] = $FE ) and ( Result[1] = $FF ) ) ) then Exit;

   if ( isValidUtf8( Result ) ) then Exit;

   // Sinon : ANSI / Windows-1252, on convertit en UTF-8
   var _ansi:= TEncoding.GetEncoding( 1252 );
   try
      Result:= TEncoding.UTF8.GetBytes( _ansi.GetString( Result ) );
      writeLog( Format( 'non-UTF-8 file converted from Windows-1252: %s', [aPath] ) );
   finally
      _ansi.Free;
   end;
end;

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

function normalizePath( const aPath: string ): string;
begin
   if ( aPath.IsEmpty ) then
      Exit( '' );
   try
      Result:= TPath.GetFullPath( aPath.Replace( '/', '\' ) );
   except
      // chemin syntaxiquement invalide : on renvoie l'entrée telle quelle
      Result:= aPath;
   end;
end;

end.
