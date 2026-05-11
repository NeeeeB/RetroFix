unit RomUtils;

interface

uses
   Types;

function detectRomLangAndRegion( const aRomPath: string;
                                 const aSystemName: string ): TLangInfo;

function shouldExtractHashFromArchive( const aSystemName: string ): Boolean;

implementation

uses
   System.SysUtils,
   System.StrUtils,
   System.IOUtils,
   Constantes;

function detectRomLangAndRegion( const aRomPath: string;
                                 const aSystemName: string ): TLangInfo;

   function matchLangData( const aToken: string;
                           out aLang, aRegion: string ): Boolean;
   begin
      Result:= False;
      aLang:= '';
      aRegion:= '';
      for var _e in cstEntries do
         for var _t in _e.tokens.Split( [','] ) do
            if ( _t = aToken ) then begin
               aLang:= _e.lang;
               aRegion:= _e.region;
               Exit( True );
            end;
   end;

   function isHardRegion( const aToken: string ): Boolean;
   begin
      Result:= ( aToken = 'usa' ) or ( aToken = 'us' ) or
               ( aToken = 'europe' ) or ( aToken = 'eu' ) or
               ( aToken = 'brazil' ) or ( aToken = 'br' ) or
               ( aToken = 'japan' ) or ( aToken = 'jp' ) or
               ( aToken = 'kr' ) or ( aToken = 'korea' );
   end;

   procedure extractBracketTokens( const aContent: string;
                                   const aOpen, aClose: Char;
                                   var aList: TArray<string> );
   begin
      var _pos:= 0;
      while _pos < Length( aContent ) do begin
         var _start:= aContent.IndexOf( aOpen, _pos );
         if ( _start < 0 ) then Break;
         var _end:= aContent.IndexOf( aClose, Succ( _start ) );
         if ( _end < 0 ) then Break;
         aList:= aList + [aContent.Substring( Succ( _start ), _end - _start - 1 )];
         _pos:= Succ( _end );
      end;
   end;

begin
   Result.language:= '';
   Result.region:= '';

   var _fileName:= TPath.GetFileName( aRomPath ).ToLower;
   var _sysName:= aSystemName.ToLower;

   // Arcade special case
   var _isArcade:= ( _sysName = 'mame' ) or ( _sysName = 'fbneo' ) or
                   ( _sysName = 'arcade' ) or ( _sysName = 'neogeo' );

   if ( _isArcade ) and
      ( _fileName.EndsWith( 'j.zip' ) ) then begin
      Result.language:= 'jp';
      Result.region:= 'jp';
      Exit;
   end;

   // Extract tokens from () and []
   var _bracketTokens: TArray<string>;
   extractBracketTokens( _fileName, '(', ')', _bracketTokens );
   extractBracketTokens( _fileName, '[', ']', _bracketTokens );

   var _languages: TArray<string>;
   var _mHardRegion:= False;

   for var _bracket in _bracketTokens do begin
      for var _part in _bracket.Split( ['_', ' ', ','] ) do begin
         var _s:= _part.Trim;
         if ( _s.IsEmpty ) then Continue;

         var _clearLang:= _s.StartsWith( 't-' );
         _s:= _s.Replace( 't+', '' ).Replace( 't-', '' );

         var _lang, _region: string;
         if ( not matchLangData( _s, _lang, _region ) ) then Continue;

         if ( not _lang.IsEmpty ) then begin
            if ( _clearLang ) then
               _languages:= [];
            var _alreadyThere:= False;
            for var _l in _languages do
               if ( _l = _lang ) then begin
                  _alreadyThere:= True;
                  Break;
               end;
            if ( not _alreadyThere ) then
               _languages:= _languages+[_lang];
         end;

         if ( not _region.IsEmpty ) then begin
            var _newHard:= isHardRegion( _s );
            if ( not _mHardRegion ) then begin
               Result.region:= _region;
               _mHardRegion:= _newHard;
            end else if ( _newHard ) then
               Result.region:= _region;
         end;
      end;
   end;

   // Region fallbacks
   if ( Result.region.IsEmpty ) then begin
      if ( cstJapanDefaults.Contains( _sysName ) ) then
         Result.region:= 'jp'
      else if ( _isArcade ) then
         Result.region:= 'us'
      else if ( _sysName = 'thomson' ) then
         Result.region:= 'eu';
   end;

   // Language fallbacks
   if ( Length( _languages ) = 0 ) then begin
      if ( cstJapanDefaults.Contains( _sysName ) ) then
         _languages:= TArray<string>.Create( 'jp' )
      else if ( _sysName = 'thomson' ) then
         _languages:= TArray<string>.Create( 'fr' )
      else
         _languages:= TArray<string>.Create( 'en' );
   end;

   if ( Length( _languages ) > 0 ) then
      Result.language:= _languages[0];
end;

function shouldExtractHashFromArchive( const aSystemName: string ): Boolean;
begin
   Result:= ( IndexStr( LowerCase( aSystemName ), cNoExtractSystems ) < 0 );
end;

end.
