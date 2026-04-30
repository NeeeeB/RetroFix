unit GamelistChecker;

interface

uses
   System.Generics.Collections,
   Types;

type
   TGamelistProgressCallback = procedure( const aSystem: string;
                                          aCurrent, aTotal: Integer ) of object;

function checkGamelists( const aRomsDir: string;
                         aOnProgress: TGamelistProgressCallback ): TObjectList<TGamelistResult>;

implementation

uses
   System.SysUtils, System.IOUtils,
   Constantes, GamelistParser;

function checkGamelists( const aRomsDir: string;
                         aOnProgress: TGamelistProgressCallback ): TObjectList<TGamelistResult>;

   function getRomFiles( const aDir: string ): TArray<string>;
   begin
      var _list:= TList<string>.Create;
      try
         for var _f in TDirectory.GetFiles( aDir ) do
            if ( LowerCase( TPath.GetExtension( _f ) ) <> cstXmlExtension ) then
               _list.Add( _f );
         Result:= _list.ToArray;
      finally
         _list.Free;
      end;
   end;

   function getMediaFiles( const aDir: string ): TArray<string>;
   var
      _list: TList<string>;
   begin
      _list:= TList<string>.Create;
      try
         for var _subDir in [cstImages, cstVideos, cstManuals] do begin
            var _path:= TPath.Combine( aDir, _subDir );
            if ( TDirectory.Exists( _path ) ) then
               for var _f in TDirectory.GetFiles( _path ) do
                  _list.Add( _f );
         end;
         Result:= _list.ToArray;
      finally
         _list.Free;
      end;
   end;

begin
   Result:= TObjectList<TGamelistResult>.Create( True );
   if ( not TDirectory.Exists( aRomsDir ) ) then
         Exit;

   var _systemDirs:= TDirectory.GetDirectories( aRomsDir );
   var _total:= Length( _systemDirs );

   for var ii:= 0 to Pred( _total ) do begin
      var _systemDir:= _systemDirs[ii];
      var _systemName:= TPath.GetFileName( _systemDir );

      if ( Assigned( aOnProgress ) ) then
         aOnProgress( _systemName, Succ( ii ), _total );

      var _gamelistPath:= TPath.Combine( _systemDir, cstGamelistFile );
      if ( not TFile.Exists( _gamelistPath ) ) then
         Continue;

      var _result:= parseGamelistFast( _systemDir, _systemName );

      // Build dictionary of referenced ROM paths for O(1) lookup
      var _referencedROMs:= TDictionary<string, Boolean>.Create;
      try
         for var _game in _result.games do
            if ( not _game.romPath.IsEmpty ) then
               _referencedROMs.TryAdd( LowerCase( _game.romPath ), True );

         // Check missing ROMs
         var _missingROMs:= TList<string>.Create;
         try
            for var _game in _result.games do
               if ( not _game.romPath.IsEmpty ) and
                  ( not TFile.Exists( _game.romPath ) ) then
                  _missingROMs.Add( _game.romPath );
            _result.missingROMs:= _missingROMs.ToArray;
         finally
            _missingROMs.Free;
         end;

         // Count total ROMs on disk
         var _romFiles:= getRomFiles( _systemDir );
         _result.totalRoms:= Length( _romFiles );

         // Check unscraped ROMs
         var _unscrapedROMs:= TList<string>.Create;
         try
            for var _romFile in _romFiles do begin
               if ( not _referencedROMs.ContainsKey( LowerCase( _romFile ) ) ) then
                  _unscrapedROMs.Add( _romFile );
            end;
            _result.unscrapedROMs:= _unscrapedROMs.ToArray;
         finally
            _unscrapedROMs.Free;
         end;
      finally
         _referencedROMs.Free;
      end;

      // Build dictionary of referenced media paths for O(1) lookup
      var _referencedMedias:= TDictionary<string, Boolean>.Create;
      try
         for var _game in _result.games do
            for var _media in _game.medias do
               _referencedMedias.TryAdd( LowerCase( _media.path ), True );

         // Check missing medias
         var _missingMedias:= TList<string>.Create;
         try
            for var _game in _result.games do
               for var _media in _game.medias do
                  if ( not _media.exists ) then
                     _missingMedias.Add( _media.path );
            _result.missingMedias:= _missingMedias.ToArray;
         finally
            _missingMedias.Free;
         end;

         // Check orphan medias
         var _orphanMedias:= TList<string>.Create;
         try
            var _mediaFiles:= getMediaFiles( _systemDir );
            for var _mediaFile in _mediaFiles do
               if ( not _referencedMedias.ContainsKey( LowerCase( _mediaFile ) ) ) then
                  _orphanMedias.Add( _mediaFile );
            _result.orphanMedias:= _orphanMedias.ToArray;
         finally
            _orphanMedias.Free;
         end;
      finally
         _referencedMedias.Free;
      end;

      Result.Add( _result );
   end;
end;

end.
