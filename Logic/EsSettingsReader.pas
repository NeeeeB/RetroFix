unit EsSettingsReader;

interface

uses
   Types;

function readEsSettings( const aRetrobatPath: string;
                         aSettings: TSettings ): Boolean;

implementation

uses
   System.SysUtils, System.IOUtils,
   Neslib.Xml,
   Constantes;

function readEsSettings( const aRetrobatPath: string;
                         aSettings: TSettings ): Boolean;
begin
   Result:= False;

   var _path:= TPath.Combine( aRetrobatPath,
                              TPath.Combine( cstEmulationStationFolder,
                                             TPath.Combine( '.emulationstation', cstEsSettingsFile ) ) );

   if ( not TFile.Exists( _path ) ) then
      Exit;

   var _doc:= TXmlDocument.Create;
   _doc.Load( _path );
   var _root:= _doc.DocumentElement;
   if ( _root.IsEmpty ) then
      Exit;

   var _node:= _root.FirstChild;
   while not _node.IsEmpty do begin
      if ( _node.NodeType = TXmlNodeType.Element ) then begin
         var _name:= _node.AttributeByName( 'name' ).Value;
         var _value:= _node.AttributeByName( 'value' ).Value;
         if ( _name = cstSSUserKey ) then
            aSettings.ssUserId:= _value
         else if ( _name = cstSSPasswordKey ) then
            aSettings.ssPassword:= _value
         else if ( _name = cstEsLanguageKey ) then begin
            // Extract language code from "fr_FR" → "fr"
            var _parts:= _value.Split( ['_'] );
            if ( Length( _parts ) > 0 ) then
               aSettings.scrapeLanguage:= LowerCase( _parts[0] );
         end else if ( _name = cstEsScrapperImageKey ) then
            aSettings.scrapeImageSrc:= _value
         else if ( _name = cstEsScrapperLogoKey ) then
            aSettings.scrapeLogoSrc:= _value
         else if ( _name = cstEsScrapperThumbKey ) then
            aSettings.scrapeThumbSrc:= _value
         else if ( _name = cstEsScrapeBezelKey ) then
            aSettings.scrapeBezel:= ( _value = 'true' )
         else if ( _name = cstEsScrapeBoxBackKey ) then
            aSettings.scrapeBoxBack:= ( _value = 'true' )
         else if ( _name = cstEsScrapeFanartKey ) then
            aSettings.scrapeFanart:= ( _value = 'true' )
         else if ( _name = cstEsScrapeManualKey ) then
            aSettings.scrapeManual:= ( _value = 'true' )
         else if ( _name = cstEsScrapeMapKey ) then
            aSettings.scrapeMap:= ( _value = 'true' )
         else if ( _name = cstEsScrapeVideosKey ) then
            aSettings.scrapeVideos:= ( _value = 'true' )
         else if ( _name = cstEsScraperRegionKey ) then
            aSettings.favRegion:= _value
         else if ( _name = cstEsPublicApiKey ) then
            aSettings.apiEnabled:= ( _value = 'true' );
      end;
      _node:= _node.NextSibling;
   end;

   Result:= ( not aSettings.ssUserId.IsEmpty );
end;

end.
