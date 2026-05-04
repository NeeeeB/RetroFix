unit ScreenScraperApi;

interface

uses
   System.Generics.Collections,
   Types;

function loadSystemsMapping( const aSSId, aSSPassword: string;
                              out aMapping: TDictionary<string, Integer>;
                              out aError: string ): Boolean;

function getGameInfo( const aSSId, aSSPassword: string;
                      const aSystemId: Integer;
                      const aRomPath: string;
                      const aLanguage: string;
                      out aGameInfo: TSSGameInfo;
                      out aError: string ): TSSResult;

function downloadMedia( const aUrl: string;
                        const aDestPath: string;
                        out aError: string ): Boolean;

function getUserInfo( const aSSId, aSSPassword: string;
                      out aUserInfo: TSSUserInfo;
                      out aError: string ): Boolean;

implementation

uses
   System.SysUtils,
   System.IOUtils,
   System.Classes,
   System.Net.HttpClient,
   System.Net.HttpClientComponent,
   System.Net.URLClient,
   System.NetEncoding,
   System.JSON,
   HashUtils,
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
                      const aSystemId: Integer;
                      const aRomPath: string;
                      const aLanguage: string;
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
   var _md5:= fileMD5( aRomPath );
   var _crc32:= fileCRC32( aRomPath );
   var _size:= TFile.GetSize( aRomPath );
   var _romName:= TPath.GetFileName( aRomPath );

   var _url:= cstSSBaseUrl+cstSSApiGameInfo+
              buildBaseParams( aSSId, aSSPassword )+
              cstSSSystemeId+IntToStr( aSystemId )+
              cstSSRomType+
              cstSSRomNom+TNetEncoding.URL.Encode( _romName )+
              cstSSRomTaille+IntToStr( _size )+
              cstSSMd5+_md5+
              cstSSCrc+_crc32;

   var _response: string;
   if ( not httpGet( _url, _response, aError ) ) then
      Exit;

   var _json:= TJSONObject.ParseJSONValue( _response ) as TJSONObject;
   if ( _json = nil ) then begin
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

      aGameInfo.id:= _jeu.GetValue<string>( cstSSId, '' );

      var _noms:= _jeu.GetValue<TJSONArray>( cstSSNoms, nil );
      if ( _noms <> nil ) then begin
         var _bestName:= '';
         for var ii:= 0 to Pred( _noms.Count ) do begin
            var _nomObj:= _noms.Items[ii] as TJSONObject;
            var _region:= _nomObj.GetValue<string>( cstSSRegion, '' );
            var _nom:= _nomObj.GetValue<string>( cstSSText, '' );
            // Get best name — priority: aLanguage > wor > first available
            if ( _region = aLanguage ) then begin
               _bestName:= _nom;
               Break;
            end else if ( _region = cstSSRegionWor ) or
                        ( _bestName.IsEmpty ) then
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
            // Get best description — priority: aLanguage > wor > first available
            if ( _region = aLanguage ) then begin
               _bestDesc:= _text;
               Break;
            end else if ( _region = cstSSRegionWor ) or
                        ( _bestDesc.IsEmpty ) then
               _bestDesc:= _text;
         end;
         aGameInfo.desc:= _bestDesc;
      end;

      // Developer
      var _devArr:= _jeu.GetValue<TJSONArray>( cstSSDeveloppeur, nil );
      if ( _devArr <> nil ) and
         ( _devArr.Count > 0 ) then
         aGameInfo.developer:= ( _devArr.Items[0] as TJSONObject ).GetValue<string>( cstSSText, '' );

      // Publisher
      var _pubArr:= _jeu.GetValue<TJSONArray>( cstSSEditeur, nil );
      if ( _pubArr <> nil ) and
         ( _pubArr.Count > 0 ) then
         aGameInfo.publisher:= ( _pubArr.Items[0] as TJSONObject ).GetValue<string>( cstSSText, '' );

      // Genre — take first available
      var _genres:= _jeu.GetValue<TJSONArray>( cstSSGenres, nil );
      if ( _genres <> nil ) and
         ( _genres.Count > 0 ) then begin
         var _genreObj:= _genres.Items[0] as TJSONObject;
         var _genreNoms:= _genreObj.GetValue<TJSONArray>( cstSSNoms, nil );
         if ( _genreNoms <> nil ) and
            ( _genreNoms.Count > 0 ) then
            aGameInfo.genre:= ( _genreNoms.Items[0] as TJSONObject ).GetValue<string>( cstSSText, '' );
      end;

      aGameInfo.players:= _jeu.GetValue<string>( cstSSJoueurs, '' );
      aGameInfo.rating:= _jeu.GetValue<string>( cstSSNote, '' );

      // Release date — take first available
      var _dates:= _jeu.GetValue<TJSONArray>( cstSSDates, nil );
      if ( _dates <> nil ) and
         ( _dates.Count > 0 ) then
         aGameInfo.releaseDate:= ( _dates.Items[0] as TJSONObject ).GetValue<string>( cstSSText, '' );

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

end.
