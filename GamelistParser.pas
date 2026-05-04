unit GamelistParser;

interface

uses
   System.Generics.Collections,
   Types;

function parseGamelist( const aRomDir: string;
                        const aSystemName: string ): TGamelistResult;

implementation

uses
   System.SysUtils,
   System.IOUtils,
   Constantes,
   Neslib.Xml;

function parseGamelist( const aRomDir: string;
                        const aSystemName: string ): TGamelistResult;

   function resolveRelativePath( const aBasePath, aRelativePath: string ): string;
   begin
      var _clean:= aRelativePath;
      if ( _clean.StartsWith( './' ) ) then
         _clean:= _clean.Substring( 2 );
      Result:= TPath.Combine( aBasePath, _clean.Replace( '/', '\' ) );
   end;

begin
   Result:= TGamelistResult.Create;
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

   var _doc:= TXmlDocument.Create;
   _doc.Load( _gamelistPath );
   var _root:= _doc.DocumentElement;
   if ( _root.IsEmpty ) then
      Exit;

   var _games:= TList<TGameEntry>.Create;
   try
      var _gameNode:= _root.FirstChild;
      while ( not _gameNode.IsEmpty ) do begin
         if ( _gameNode.NodeType = TXmlNodeType.Element ) and
            ( _gameNode.Value = cstXmlGame ) then begin

            var _entry:= Default( TGameEntry );

            // Extract id attribute
            var _idAttr:= _gameNode.AttributeByName( cstXmlId );
            if ( not _idAttr.Value.IsEmpty ) then
               _entry.id:= _idAttr.Value;

            // Parse child nodes
            var _child:= _gameNode.FirstChild;
            while ( not _child.IsEmpty ) do begin
               if ( _child.NodeType = TXmlNodeType.Element ) then begin
                  var _tag:= _child.Value;
                  var _text:= _child.Text;

                  if ( _tag = cstXmlName ) then
                     _entry.name:= _text
                  else if ( _tag = cstXmlPath ) then begin
                     if ( not _text.IsEmpty ) then
                        _entry.romPath:= resolveRelativePath( aRomDir, _text );
                  end else if ( _tag = cstXmlMD5 ) then
                     _entry.md5:= _text
                  else if ( _tag = cstXmlHash ) then _entry.crc32:= _text
                  else if ( _tag = cstXmlDesc ) then _entry.desc:= _text
                  else if ( _tag = cstXmlGenre ) then _entry.genre:= _text
                  else if ( _tag = cstXmlRating ) then _entry.rating:= _text
                  else if ( _tag = cstXmlReleaseDate ) then _entry.releaseDate:= _text
                  else if ( _tag = cstXmlDeveloper ) then _entry.developer:= _text
                  else if ( _tag = cstXmlPublisher ) then _entry.publisher:= _text
                  else if ( _tag = cstXmlFamily ) then _entry.family:= _text
                  else if ( _tag = cstXmlArcadeSystem ) then _entry.arcadeSystem:= _text
                  else if ( _tag = cstXmlPlayers ) then _entry.players:= _text
                  else if ( _tag = cstXmlLang ) then _entry.lang:= _text
                  else if ( _tag = cstXmlRegion ) then _entry.region:= _text
                  else begin
                     for var mt:= Low( TMediaType ) to High( TMediaType ) do begin
                        if ( _tag = cstMediaTypeTags[mt] ) and
                           ( not _text.IsEmpty ) then begin
                           var _media: TGameMedia;
                           _media.mediaType:= mt;
                           _media.path:= resolveRelativePath( aRomDir, _text );
                           _media.exists:= TFile.Exists( _media.path );
                           _entry.medias:= _entry.medias+[_media];
                           _entry.isScraped:= True;
                           Break;
                        end;
                     end;
                  end;
               end;
               _child:= _child.NextSibling;
            end;

            _games.Add( _entry );
         end;
         _gameNode:= _gameNode.NextSibling;
      end;

      Result.games:= _games.ToArray;
   finally
      _games.Free;
   end;
end;

end.
