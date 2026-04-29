unit GamelistParser;

interface

uses
   System.Generics.Collections,
   Types;

function parseGamelistFast( const aRomDir: string;
                            const aSystemName: string ): TGamelistResult;

implementation

uses
   System.SysUtils, System.IOUtils,
   System.StrUtils,
   System.NetEncoding,
   Constantes;

function parseGamelistFast( const aRomDir: string;
                            const aSystemName: string ): TGamelistResult;

   function extractTag( const aContent: string;
                     const aTag: string;
                     const aFrom: Integer ): string;
   begin
      var _open:= '<'+aTag+'>';
      var _close:= '</'+aTag+'>';
      var _start:= PosEx( _open, aContent, aFrom );
      if ( _start = 0 ) then
         Exit( '' );
      Inc( _start, Length( _open ) );
      var _end:= PosEx( _close, aContent, _start );
      if ( _end = 0 ) then
         Exit( '' );
      var _extracted:= Copy( aContent, _start, _end - _start );
      if ( Pos( '&', _extracted ) > 0 ) then
         Result:= TNetEncoding.HTML.Decode( _extracted )
      else
         Result:= _extracted;
   end;

   function resolveRelativePath( const aBasePath, aRelativePath: string ): string;
   begin
      var _clean:= aRelativePath;
      if _clean.StartsWith( './' ) then
         _clean:= _clean.Substring( 2 );
      Result:= TPath.Combine( aBasePath, _clean.Replace( '/', '\' ) );
   end;

begin
   Result.systemName:= aSystemName;
   Result.romDir:= aRomDir;
   Result.totalRoms:= 0;
   SetLength( Result.games, 0 );
   SetLength( Result.missingROMs, 0 );
   SetLength( Result.unscrapedROMs, 0 );
   SetLength( Result.orphanMedias, 0 );
   SetLength( Result.missingMedias, 0 );

   var _gamelistPath:= TPath.Combine( aRomDir, cstGamelistFile );
   if ( not TFile.Exists( _gamelistPath ) ) then
      Exit;

   // Read entire file at once
   var _content:= TFile.ReadAllText( _gamelistPath, TEncoding.UTF8 );

   // Find each <game> block
   var _gameOpen:= cstXmlGameTagOpen;
   var _gameClose:= cstXmlGameTagClose;
   var _pos:= 1;

   var _games:= TList<TGameEntry>.Create;
   try
      repeat
         // Find start of game block
         var _gameStart:= PosEx( _gameOpen, _content, _pos );
         if ( _gameStart = 0 ) then
            Break;

         // Find end of opening tag (to skip attributes like id="...")
         var _tagEnd:= PosEx( '>', _content, _gameStart );
         if ( _tagEnd = 0 ) then
            Break;

         // Find end of game block
         var _gameEnd:= PosEx( _gameClose, _content, _tagEnd );
         if ( _gameEnd = 0 ) then
            Break;

         // Extract game block content
         var _gameContent:= Copy( _content, _tagEnd+1, _gameEnd - _tagEnd - 1 );

         // Extract id from opening tag
         var _entry:= Default( TGameEntry );
         var _openTag:= Copy( _content, _gameStart, _tagEnd - _gameStart + 1 );
         var _idPos:= PosEx( 'id="', _openTag, 1 );
         if ( _idPos > 0 ) then begin
            Inc( _idPos, 4 );
            var _idEnd:= PosEx( '"', _openTag, _idPos );
            if ( _idEnd > 0 ) then
               _entry.id:= Copy( _openTag, _idPos, _idEnd - _idPos );
         end;

         // Extract name and path
         _entry.name:= extractTag( _gameContent, cstXmlName, 1 );
         var _romRelPath:= extractTag( _gameContent, cstXmlPath, 1 );
         if ( not _romRelPath.IsEmpty ) then
            _entry.romPath:= resolveRelativePath( aRomDir, _romRelPath );
         _entry.md5:= extractTag( _gameContent, cstXmlMD5, 1 );
         _entry.crc32:= extractTag( _gameContent, cstXmlHash, 1 );

         // Extract medias
         for var mt:= Low( TMediaType ) to High( TMediaType ) do begin
            var _value:= extractTag( _gameContent, cstMediaTypeTags[mt], 1 );
            if ( not _value.IsEmpty ) then begin
               var _media: TGameMedia;
               _media.mediaType:= mt;
               _media.path:= resolveRelativePath( aRomDir, _value );
               _media.exists:= TFile.Exists( _media.path );
               _entry.medias:= _entry.medias+[_media];
               _entry.isScraped:= True;
            end;
         end;

         _games.Add( _entry );

         // Move past this game block
         _pos:= _gameEnd + Length( _gameClose );
      until ( _pos >= Length( _content ) );

      Result.games:= _games.ToArray;
   finally
      _games.Free;
   end;
end;

end.
