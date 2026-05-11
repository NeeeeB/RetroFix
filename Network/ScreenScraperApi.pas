unit ScreenScraperApi;

interface

uses
   System.Generics.Collections,
   Types;

function loadSystemsMapping( const aSSId, aSSPassword: string;
                              out aMapping: TDictionary<string, Integer>;
                              out aError: string ): Boolean;

function getGameInfo( const aSSId, aSSPassword: string;
                      aSystemId: Integer;
                      const aSystemName: string;
                      const aRomPath: string;
                      const aLanguage: string;
                      const aRegion: string;
                      out aGameInfo: TSSGameInfo;
                      out aError: string ): TSSResult;

function downloadMedia( const aUrl: string;
                        const aDestPath: string;
                        out aError: string ): Boolean;

function getUserInfo( const aSSId, aSSPassword: string;
                      out aUserInfo: TSSUserInfo;
                      out aError: string ): Boolean;

function getRipList( const aImageSource: string ): TArray<string>;

function findBestMedia( const aMedias: TArray<TSSMediaInfo>;
                        const aRipList: TArray<string>;
                        const aLanguage: string;
                        const aRegion: string ): TSSMediaInfo;

function getArcadeSystemName( aSystemId: Integer ): string;

implementation

uses
   System.SysUtils,
   System.StrUtils,
   System.IOUtils,
   System.DateUtils,
   System.Classes,
   System.Net.HttpClientComponent,
   System.NetEncoding,
   System.JSON,
   HashUtils,
   RomUtils,
   Constantes;

function buildBaseParams( const aSSId, aSSPassword: string ): string;
begin
   Result:= '?devid='+cstSSDevId+
            '&devpassword='+cstSSDevPassword+
            '&softname='+cstSSSoftName+
            '&output=json'+
            '&ssid='+aSSId+
            '&sspassword='+aSSPassword;
end;

function httpGet( const aUrl: string;
                  out aResponse: string;
                  out aError: string ): Boolean;
begin
   Result:= False;
   aResponse:= '';
   aError:= '';
   var _client:= TNetHTTPClient.Create( nil );
   try
      _client.ConnectionTimeout:= 10000;
      _client.ResponseTimeout:= 30000;
      try
         var _response:= _client.Get( aUrl );
         aResponse:= _response.ContentAsString( TEncoding.UTF8 );
         Result:= True;
      except
         on E: Exception do
            aError:= E.Message;
      end;
   finally
      _client.Free;
   end;
end;

function checkResponseSuccess( const aJson: TJSONObject;
                               out aError: string ): Boolean;
begin
   var _header:= aJson.GetValue<TJSONObject>( cstSSHeader, nil );
   if ( _header = nil ) then begin
      aError:= 'Invalid response format';
      Exit( False );
   end;
   var _success:= _header.GetValue<string>( cstSSSuccess, 'false' );
   aError:= _header.GetValue<string>( cstSSError, '' );
   Result:= ( _success = 'true' );
end;

function loadSystemsMapping( const aSSId, aSSPassword: string;
                              out aMapping: TDictionary<string, Integer>;
                              out aError: string ): Boolean;
begin
   Result:= False;
   aMapping:= TDictionary<string, Integer>.Create;
   aError:= '';

   var _url:= cstSSBaseUrl+cstSSApiSystemes+buildBaseParams( aSSId, aSSPassword );
   var _response: string;
   if ( not httpGet( _url, _response, aError ) ) then
      Exit;

   var _json:= TJSONObject.ParseJSONValue( _response ) as TJSONObject;
   if ( _json = nil ) then begin
      aError:= 'Invalid JSON response';
      Exit;
   end;
   try
      if ( not checkResponseSuccess( _json, aError ) ) then
         Exit;

      var _responseObj:= _json.GetValue<TJSONObject>( cstSSResponse, nil );
      if ( _responseObj = nil ) then begin
         aError:= 'Missing response object';
         Exit;
      end;

      var _systemes:= _responseObj.GetValue<TJSONArray>( cstSSSystemes, nil );
      if ( _systemes = nil ) then begin
         aError:= 'Missing systemes array';
         Exit;
      end;

      for var ii:= 0 to Pred( _systemes.Count ) do begin
         var _sys:= _systemes.Items[ii] as TJSONObject;
         var _id:= _sys.GetValue<Integer>( cstSSId, 0 );
         var _noms:= _sys.GetValue<TJSONObject>( cstSSNoms, nil );
         if ( _noms = nil ) or ( _id = 0 ) then
            Continue;

         // nom_recalbox may contain multiple names separated by commas
         var _nomRecalbox:= _noms.GetValue<string>( cstSSNomRecalbox, '' );
         if ( _nomRecalbox.IsEmpty ) then
            Continue;

         // Add each name — some have multiple like "genesis,megadrive"
         for var _nom in _nomRecalbox.Split( [','] ) do begin
            var _trimmed:= _nom.Trim;
            if ( not _trimmed.IsEmpty ) then
               aMapping.TryAdd( LowerCase( _trimmed ), _id );
         end;
      end;

      Result:= True;
   finally
      _json.Free;
   end;
end;

function getGameInfo( const aSSId, aSSPassword: string;
                      aSystemId: Integer;
                      const aSystemName: string;
                      const aRomPath: string;
                      const aLanguage: string;
                      const aRegion: string;
                      out aGameInfo: TSSGameInfo;
                      out aError: string ): TSSResult;
begin
   Result:= ssrError;
   aError:= '';
   aGameInfo:= Default( TSSGameInfo );

   if ( not TFile.Exists( aRomPath ) ) then begin
      aError:= 'ROM file not found';
      Exit;
   end;

   // Compute hashes and file size for ROM identification
   var _extract:= shouldExtractHashFromArchive( aSystemName );
   var _hashInfo:= getRomHashInfo( aRomPath, _extract );
   var _romName:= TPath.GetFileName( aRomPath );

   var _url:= cstSSBaseUrl+cstSSApiGameInfo+
              buildBaseParams( aSSId, aSSPassword )+
              cstSSSystemeId+IntToStr( aSystemId )+
              cstSSRomType+
              cstSSRomNom+TNetEncoding.URL.Encode( _romName )+
              cstSSRomTaille+IntToStr( _hashInfo.size )+
              cstSSMd5+_hashInfo.md5+
              cstSSCrc+_hashInfo.crc32+
              cstSSSha1+_hashInfo.sha1;

   var _response: string;
   if ( not httpGet( _url, _response, aError ) ) then
      Exit;

   var _json:= TJSONObject.ParseJSONValue( _response ) as TJSONObject;
   if ( _json = nil ) then begin
      if ( _response.Contains( 'introuvable' ) ) or
         ( _response.Contains( 'not found' ) ) or
         ( _response.Contains( 'non trouvée' ) ) then
         Result:= ssrNotFound
      else
         aError:= 'Invalid JSON response';
      Exit;
   end;
   try
      if ( not checkResponseSuccess( _json, aError ) ) then begin
         if ( aError.Contains( cstSSJeuIntrouvable ) ) or
            ( aError.Contains( cstSSNotFound ) ) then
            Result:= ssrNotFound
         else if ( aError.Contains( cstSSQuota ) ) then
            Result:= ssrQuotaExceeded;
         Exit;
      end;

      var _responseObj:= _json.GetValue<TJSONObject>( cstSSResponse, nil );
      if ( _responseObj = nil ) then begin
         aError:= 'Missing response object';
         Exit;
      end;

      var _jeu:= _responseObj.GetValue<TJSONObject>( cstSSJeu, nil );
      if ( _jeu = nil ) then begin
         Result:= ssrNotFound;
         Exit;
      end;

      var _systeme:= _jeu.GetValue<TJSONObject>( cstSSSysteme, nil );
      if ( _systeme <> nil ) then begin
         var _systemId:= StrToIntDef( _systeme.GetValue<string>( cstSSId, '0' ), 0 );
         aGameInfo.arcadeSystem:= getArcadeSystemName( _systemId );
      end;

      aGameInfo.id:= _jeu.GetValue<string>( cstSSId, '' );

      // Get matched ROM region
      var _romId:= _jeu.GetValue<string>( cstSSRomId, '' );
      var _roms:= _jeu.GetValue<TJSONArray>( cstSSRoms, nil );
      if ( _roms <> nil ) and ( not _romId.IsEmpty ) then begin
         for var ii:= 0 to Pred( _roms.Count ) do begin
            var _rom:= _roms.Items[ii] as TJSONObject;
            if ( _rom.GetValue<string>( cstSSId, '' ) = _romId ) then begin
               var _regions:= _rom.GetValue<TJSONObject>( cstSSRegions, nil );
               if ( _regions <> nil ) then begin
                  var _shortnames:= _regions.GetValue<TJSONArray>( cstSSRegionsShortname, nil );
                  if ( _shortnames <> nil ) and ( _shortnames.Count > 0 ) then
                     aGameInfo.region:= _shortnames.Items[0].Value;
               end;
               Break;
            end;
         end;
      end;

      var _noms:= _jeu.GetValue<TJSONArray>( cstSSNoms, nil );
      if ( _noms <> nil ) then begin
         var _bestName:= '';
         for var ii:= 0 to Pred( _noms.Count ) do begin
            var _nomObj:= _noms.Items[ii] as TJSONObject;
            var _region:= _nomObj.GetValue<string>( cstSSRegion, '' );
            var _nom:= _nomObj.GetValue<string>( cstSSText, '' );
            // Get best name — priority: aLanguage > aRegion > wor > us > eu > jp > ss > first
            if ( _region = aLanguage ) then begin
               _bestName:= _nom;
               Break;
            end else if ( _region = aRegion ) and
                        ( _bestName.IsEmpty ) then
               _bestName:= _nom
            else if ( _region = cstSSRegionWor ) and
                    ( _bestName.IsEmpty ) then
               _bestName:= _nom
            else if ( _bestName.IsEmpty ) then
               _bestName:= _nom;
         end;
         aGameInfo.name:= _bestName;
      end;

      var _synopsis:= _jeu.GetValue<TJSONArray>( cstSSSynopsis, nil );
      if ( _synopsis <> nil ) then begin
         var _bestDesc:= '';
         for var ii:= 0 to Pred( _synopsis.Count ) do begin
            var _synObj:= _synopsis.Items[ii] as TJSONObject;
            var _region:= _synObj.GetValue<string>( cstSSLangue, '' );
            var _text:= _synObj.GetValue<string>( cstSSText, '' );
            // Get best description — priority: aLanguage > aRegion > wor > us > eu > jp > ss > first
            if ( _region = aLanguage ) then begin
               _bestDesc:= _text;
               Break;
            end else if ( _region = aRegion ) and
                        ( _bestDesc.IsEmpty ) then
               _bestDesc:= _text
            else if ( _region = cstSSRegionWor ) and
                    ( _bestDesc.IsEmpty ) then
               _bestDesc:= _text
            else if ( _bestDesc.IsEmpty ) then
               _bestDesc:= _text;
         end;
         aGameInfo.desc:= _bestDesc;
      end;

      // Developer
      var _dev:= _jeu.GetValue<TJSONObject>( cstSSDeveloppeur, nil );
      if ( _dev <> nil ) then
         aGameInfo.developer:= _dev.GetValue<string>( cstSSText, '' );

      // Publisher
      var _pub:= _jeu.GetValue<TJSONObject>( cstSSEditeur, nil );
      if ( _pub <> nil ) then
         aGameInfo.publisher:= _pub.GetValue<string>( cstSSText, '' );

      // Genre — take first available
      var _genres:= _jeu.GetValue<TJSONArray>( cstSSGenres, nil );
      if ( _genres <> nil ) and
         ( _genres.Count > 0 ) then begin
         // Take genre marked as "principale" if available, otherwise first
         var _genreObj: TJSONObject := nil;
         for var ii:= 0 to Pred( _genres.Count ) do begin
            var _g:= _genres.Items[ii] as TJSONObject;
            if ( _g.GetValue<string>( 'principale', '0' ) = '1' ) then begin
               _genreObj:= _g;
               Break;
            end;
         end;
         if ( _genreObj = nil ) then
            _genreObj:= _genres.Items[0] as TJSONObject;

         var _genreNoms:= _genreObj.GetValue<TJSONArray>( cstSSNoms, nil );
         if ( _genreNoms <> nil ) then begin
            var _bestGenre:= '';
            for var ii:= 0 to Pred( _genreNoms.Count ) do begin
               var _gn:= _genreNoms.Items[ii] as TJSONObject;
               var _langue:= _gn.GetValue<string>( cstSSLangue, '' );
               var _text:= _gn.GetValue<string>( cstSSText, '' );
               if ( _langue = aLanguage ) then begin
                  _bestGenre:= _text;
                  Break;
               end else if ( _bestGenre.IsEmpty ) then
                  _bestGenre:= _text;
            end;
            aGameInfo.genre:= _bestGenre;
         end;
      end;

      // Family — take first available in preferred language
      var _familles:= _jeu.GetValue<TJSONArray>( cstSSFamilles, nil );
      if ( _familles <> nil ) and ( _familles.Count > 0 ) then begin
         var _familleObj:= _familles.Items[0] as TJSONObject;
         var _familleNoms:= _familleObj.GetValue<TJSONArray>( cstSSNoms, nil );
         if ( _familleNoms <> nil ) then begin
            var _bestFamily:= '';
            for var ii:= 0 to Pred( _familleNoms.Count ) do begin
               var _fn:= _familleNoms.Items[ii] as TJSONObject;
               var _langue:= _fn.GetValue<string>( cstSSLangue, '' );
               var _text:= _fn.GetValue<string>( cstSSText, '' );
               if ( _langue = aLanguage ) then begin
                  _bestFamily:= _text;
                  Break;
               end else if _bestFamily.IsEmpty then
                  _bestFamily:= _text;
            end;
            aGameInfo.family:= _bestFamily;
         end;
      end;

      // Players
      var _joueurs:= _jeu.GetValue<TJSONObject>( cstSSJoueurs, nil );
      if ( _joueurs <> nil ) then
         aGameInfo.players:= _joueurs.GetValue<string>( cstSSText, '' );

      // Rating conversion: "19" -> "0.95"
      var _note:= _jeu.GetValue<TJSONObject>( cstSSNote, nil );
      if ( _note <> nil ) then begin
         var _ratingVal:= StrToIntDef( _note.GetValue<string>( cstSSText, '0' ), 0 );
         aGameInfo.rating:= FormatFloat( '0.##', _ratingVal / 20.0 ).Replace( ',', '.' );
      end;

      // Release date — take first available
      var _dates:= _jeu.GetValue<TJSONArray>( cstSSDates, nil );
      if ( _dates <> nil ) then begin
         var _bestDate:= '';
         for var ii:= 0 to Pred( _dates.Count ) do begin
            var _dateObj:= _dates.Items[ii] as TJSONObject;
            var _region:= _dateObj.GetValue<string>( cstSSRegion, '' );
            var _text:= _dateObj.GetValue<string>( cstSSText, '' );
            if ( _region = aLanguage ) then begin
               _bestDate:= _text;
               Break;
            end else if ( _region = aRegion ) and ( _bestDate.IsEmpty ) then
               _bestDate:= _text
            else if ( _region = cstSSRegionWor ) and ( _bestDate.IsEmpty ) then
               _bestDate:= _text
            else if _bestDate.IsEmpty then
               _bestDate:= _text;
         end;
         // Date can be YYYY-MM-DD or just YYYY
         if not _bestDate.IsEmpty then begin
            if ( _bestDate.Length = 4 ) then
               _bestDate:= _bestDate+'-01-01';
            var _dt: TDateTime;
            if ( TryISO8601ToDate( _bestDate, _dt ) ) then
               aGameInfo.releaseDate:= FormatDateTime( cstSSScrapDateFormat, _dt );
         end;
      end;

      // Medias list
      var _medias:= _jeu.GetValue<TJSONArray>( cstSSMedias, nil );
      if ( _medias <> nil ) then begin
         SetLength( aGameInfo.medias, _medias.Count );
         var _mediaIndex:= 0;
         for var ii:= 0 to Pred( _medias.Count ) do begin
            var _mediaObj:= _medias.Items[ii] as TJSONObject;
            var _m: TSSMediaInfo;
            _m.mediaType:= _mediaObj.GetValue<string>( cstSSType, '' );
            _m.region:= _mediaObj.GetValue<string>( cstSSRegion, '' );
            _m.url:= _mediaObj.GetValue<string>( cstSSUrl, '' );
            _m.format:= _mediaObj.GetValue<string>( cstSSFormat, '' );
            aGameInfo.medias[_mediaIndex]:= _m;
            Inc( _mediaIndex );
         end;
         SetLength( aGameInfo.medias, _mediaIndex );
      end;

      Result:= ssrOK;
   finally
      _json.Free;
   end;
end;

function getUserInfo( const aSSId, aSSPassword: string;
                      out aUserInfo: TSSUserInfo;
                      out aError: string ): Boolean;
begin
   Result:= False;
   aUserInfo:= Default( TSSUserInfo );
   aError:= '';

   var _url:= cstSSBaseUrl+cstSSApiUserInfo+
              buildBaseParams( aSSId, aSSPassword );

   var _response: string;
   if ( not httpGet( _url, _response, aError ) ) then
      Exit;

   var _json:= TJSONObject.ParseJSONValue( _response ) as TJSONObject;
   if ( _json = nil ) then begin
      aError:= 'Invalid JSON response';
      Exit;
   end;
   try
      if ( not checkResponseSuccess( _json, aError ) ) then
         Exit;

      var _responseObj:= _json.GetValue<TJSONObject>( cstSSResponse, nil );
      if ( _responseObj = nil ) then begin
         aError:= 'Missing response object';
         Exit;
      end;

      var _ssuser:= _responseObj.GetValue<TJSONObject>( cstSSUser, nil );
      if ( _ssuser = nil ) then begin
         aError:= 'Missing ssuser object';
         Exit;
      end;

      aUserInfo.userId:= _ssuser.GetValue<string>( cstSSId, '' );
      aUserInfo.maxThreads:= StrToIntDef( _ssuser.GetValue<string>( cstSSMaxThreads, '1' ), 1 );
      aUserInfo.requestsToday:= StrToIntDef( _ssuser.GetValue<string>( cstSSRequestsToday, '0' ), 0 );
      aUserInfo.maxRequestsPerDay:= StrToIntDef( _ssuser.GetValue<string>( cstSSMaxRequests, '0' ), 0 );
      aUserInfo.maxDownloadSpeed:= StrToIntDef( _ssuser.GetValue<string>( cstSSMaxDownload, '0' ), 0 );

      Result:= True;
   finally
      _json.Free;
   end;
end;

function downloadMedia( const aUrl: string;
                        const aDestPath: string;
                        out aError: string ): Boolean;
begin
   Result:= False;
   aError:= '';

   var _client:= TNetHTTPClient.Create( nil );
   try
      _client.ConnectionTimeout:= 10000;
      _client.ResponseTimeout:= 60000;
      try
         // Create target directory if needed
         var _dir:= TPath.GetDirectoryName( aDestPath );
         if ( not TDirectory.Exists( _dir ) ) then
            TDirectory.CreateDirectory( _dir );

         var _stream:= TFileStream.Create( aDestPath, fmCreate );
         try
            _client.Get( aUrl, _stream );
            Result:= True;
         finally
            _stream.Free;
         end;
      except
         on E: Exception do begin
            aError:= E.Message;
            if TFile.Exists( aDestPath ) then
               TFile.Delete( aDestPath );
         end;
      end;
   finally
      _client.Free;
   end;
end;

function getRipList( const aImageSource: string ): TArray<string>;
begin
   case IndexStr( aImageSource, [cstSSMediaSs, cstSSMediaSsTitle, cstSSMediaMixV1, cstSSMediaMixV2, cstSSMediaBox2D, cstSSMediaBox3D,
                                 cstSSMediaWheelHD, cstSSMediaWheel, cstSSMediaLogo, cstSSMediaScreenMarquee, cstSSMediaVideo] ) of
      0: Exit( TArray<string>.Create( cstSSMediaSs, cstSSMediaSsTitle ) );
      1: Exit( TArray<string>.Create( cstSSMediaSsTitle, cstSSMediaSs ) );
      2: Exit( TArray<string>.Create( cstSSMediaMixV1, cstSSMediaMixV2 ) );
      3: Exit( TArray<string>.Create( cstSSMediaMixV2, cstSSMediaMixV1 ) );
      4: Exit( TArray<string>.Create( cstSSMediaBox2D, cstSSMediaBox3D ) );
      5: Exit( TArray<string>.Create( cstSSMediaBox3D, cstSSMediaBox2D ) );
      6: Exit( TArray<string>.Create( cstSSMediaWheelHD, cstSSMediaWheel, cstSSMediaWheelSteel,
                                      cstSSMediaWheelCarbon, cstSSMediaScreenMarqueeSm, cstSSMediaScreenMarquee ) );
      7: Exit( TArray<string>.Create( cstSSMediaWheel, cstSSMediaWheelHD, cstSSMediaWheelSteel, cstSSMediaWheelCarbon,
                                      cstSSMediaScreenMarqueeSm, cstSSMediaScreenMarquee ) );
      8: Exit( TArray<string>.Create( cstSSMediaScreenMarqueeSm, cstSSMediaScreenMarquee, cstSSMediaWheel,
                                      cstSSMediaWheelHD, cstSSMediaWheelSteel, cstSSMediaWheelCarbon ) );
      9: Exit( TArray<string>.Create( cstSSMediaScreenMarquee, cstSSMediaScreenMarqueeSm, cstSSMediaWheel, cstSSMediaWheelHD ) );
      10: Exit( TArray<string>.Create( cstSSMediaVideoNorm, cstSSMediaVideo ) );
   else
      if ( aImageSource = cstSSMediaNone ) then
         Exit( Default( TArray<string> ) );
      Result:= TArray<string>.Create( aImageSource );
   end;
end;

function findBestMedia( const aMedias: TArray<TSSMediaInfo>;
                        const aRipList: TArray<string>;
                        const aLanguage: string;
                        const aRegion: string ): TSSMediaInfo;
begin
   Result:= Default( TSSMediaInfo );
   // Build priority list : language > region > wor > us > eu > jp > ss > cus > any
   var _priorities:= TArray<string>.Create( aLanguage, aRegion, 'wor', 'us', 'eu', 'jp', 'ss', 'cus' );

   for var _ripType in aRipList do
      for var _priority in _priorities do
         for var _m in aMedias do
            if ( _m.mediaType = _ripType ) and
               ( _m.region = _priority ) then begin
               Result:= _m;
               Exit;
            end;

   // Last resort — take any matching type regardless of region
   for var _ripType in aRipList do
      for var _m in aMedias do
         if ( _m.mediaType = _ripType ) then begin
            Result:= _m;
            Exit;
         end;
end;

function getArcadeSystemName( aSystemId: Integer ): string;
begin
   Result:= '';
   for var _entry in cstArcadeSystems do
      if ( _entry.id = aSystemId ) then
         Exit( _entry.shortName );
end;

end.
