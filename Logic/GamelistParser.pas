unit GamelistParser;

interface

uses
   System.Generics.Collections,
   Types;

function parseGamelist( const aRomDir: string;
                        const aSystemName: string ): TGamelistResult;

function addGameToGamelist( const aRomDir: string;
                            const aEntry: TGameEntry ): Boolean;

function removeGamesFromGamelist( const aRomDir: string;
                                  const aRomPaths: TArray<string> ): Boolean;

function getFullNameFromShortName( const aShortName: string ): string;

implementation

uses
   System.SysUtils,
   System.IOUtils,
   System.DateUtils,
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

function addGameToGamelist( const aRomDir: string;
                             const aEntry: TGameEntry ): Boolean;

   procedure addElement( aGameNode: TXmlNode;
                         const aTag, aValue: string );
   begin
      if ( not aValue.IsEmpty ) then
         aGameNode.AddElement( aTag ).AddText( aValue );
   end;

begin
   Result:= False;
   var _gamelistPath:= TPath.Combine( aRomDir, cstGamelistFile );

   var _doc:= TXmlDocument.Create;
   if ( TFile.Exists( _gamelistPath ) ) then
      _doc.Load( _gamelistPath )
   else
      _doc.Root.AddElement( cstXmlGameList );

   var _root:= _doc.DocumentElement;
   if ( _root.IsEmpty ) then
      Exit;

   var _relPath:= './'+TPath.GetFileName( aEntry.romPath );

   // Check if game already exists — use path, not id
   var _existing:= _root.FirstChild;
   while ( not _existing.IsEmpty ) do begin
      var _next:= _existing.NextSibling;
      if ( _existing.NodeType = TXmlNodeType.Element ) and
         ( _existing.Value = cstXmlGame ) then begin
         var _pathNode:= _existing.ElementByName( cstXmlPath );
         if ( not _pathNode.IsEmpty ) and
            ( _pathNode.Text = _relPath ) then begin
            _root.RemoveChild( _existing );
            Break;
         end;
      end;
      _existing:= _next;
   end;

   var _game:= _root.AddElement( cstXmlGame );
   if ( not aEntry.id.IsEmpty ) then
      _game.AddAttribute( cstXmlId, aEntry.id );

   addElement( _game, cstXmlPath, _relPath );
   addElement( _game, cstXmlName, aEntry.name );
   addElement( _game, cstXmlDesc, aEntry.desc );
   addElement( _game, cstXmlGenre, aEntry.genre );

   // Medias in Retrobat order
   for var _mt in [ mtImage, mtVideo, mtMarquee, mtThumbnail, mtFanart,
                    mtManual, mtBezel, mtBoxBack, mtMap, mtCartridge,
                    mtBoxArt, mtWheel, mtMix, mtTitleshot, mtMagazine ] do begin
      for var _media in aEntry.medias do begin
         if ( _media.mediaType = _mt ) then begin
            var _relMediaPath:= './'+ExtractRelativePath( aRomDir+'\', _media.path ).Replace( '\', '/' );
            addElement( _game, cstMediaTypeTags[_mt], _relMediaPath );
            Break;
         end;
      end;
   end;

   addElement( _game, cstXmlRating, aEntry.rating );
   addElement( _game, cstXmlReleaseDate, aEntry.releaseDate );
   addElement( _game, cstXmlDeveloper, aEntry.developer );
   addElement( _game, cstXmlPublisher, aEntry.publisher );
   addElement( _game, cstXmlFamily, aEntry.family );
   addElement( _game, cstXmlArcadeSystem, aEntry.arcadeSystem );
   addElement( _game, cstXmlPlayers, aEntry.players );
   addElement( _game, cstXmlMD5, aEntry.md5 );
   addElement( _game, cstXmlLang, aEntry.lang );
   addElement( _game, cstXmlRegion, aEntry.region );

   // Scrap tag
   var _scrapNode:= _game.AddElement( cstXmlScrap );
   _scrapNode.AddAttribute( cstSSScrapName, cstSSScrapSource );
   _scrapNode.AddAttribute( cstSSScrapDate,
                            FormatDateTime( cstSSScrapDateFormat, Now ) );

   _doc.Save( _gamelistPath );
   Result:= True;
end;

function removeGamesFromGamelist( const aRomDir: string;
                                  const aRomPaths: TArray<string> ): Boolean;
begin
   Result:= False;
   var _gamelistPath:= TPath.Combine( aRomDir, cstGamelistFile );
   if ( not TFile.Exists( _gamelistPath ) ) then Exit;

   // Build set of relative paths for O(1) lookup
   var _toRemove:= TDictionary<string, Boolean>.Create;
   try
      for var _p in aRomPaths do
         _toRemove.TryAdd( './'+TPath.GetFileName( _p ), True );

      var _doc:= TXmlDocument.Create;
      _doc.Load( _gamelistPath );
      var _root:= _doc.DocumentElement;
      if ( _root.IsEmpty ) then Exit;

      var _node:= _root.FirstChild;
      while ( not _node.IsEmpty ) do begin
         var _next:= _node.NextSibling;
         if ( _node.NodeType = TXmlNodeType.Element ) and
            ( _node.Value = cstXmlGame ) then begin
            var _pathNode:= _node.ElementByName( cstXmlPath );
            if ( not _pathNode.IsEmpty ) and
               ( _toRemove.ContainsKey( _pathNode.Text ) ) then begin
               _root.RemoveChild( _node );
               Result:= True;
            end;
         end;
         _node:= _next;
      end;

      if ( Result ) then
         _doc.Save( _gamelistPath );
   finally
      _toRemove.Free;
   end;
end;

function getFullNameFromShortName( const aShortName: string ): string;
begin
   Result:= aShortName.ToUpper;
   for var _rec in cstShortToFullSystemName do begin
      if ( _rec.shortName = aShortName ) then
         Exit( _rec.fullName );
   end;
end;

end.
