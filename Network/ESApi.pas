unit ESApi;

interface

uses
   System.SysUtils,
   Types;

type
   TESApi = class
   private
      class var GESHost: string;
      class function findESHost: string; static;

      class function getBaseUrl: string; static;

      class function httpGet( const aUrl: string; out aResponse,
                              aError: string ): Boolean; static;

      class function httpGetWithTimeout( const aUrl: string;
                                         out aResponse: string;
                                         out aError: string;
                                         const aTimeout: Integer ): Boolean; static;

      class function httpPost( const aUrl, aBody, aContentType: string;
                               out aError: string ): Boolean; static;

      class function httpPostBytes( const aUrl: string;
                                    aBytes: TBytes;
                                    const aContentType:
                                    string; out
                                    aError: string): Boolean; static;
      class function checkAvailable( aSettings: TSettings;
                                     out aError: string ): Boolean; static;

   public
      class function isESAvailable( aSettings: TSettings ): Boolean;

      class function reloadGames( aSettings: TSettings;
                                  out aError: string ): Boolean;

      class function launchGame( aSettings: TSettings;
                                 const aRomPath: string;
                                 out aError: string ): Boolean;

      class function getSystemList( aSettings: TSettings;
                                    out aResponse: string;
                                    out aError: string ): Boolean;

      class function getSystem( aSettings: TSettings;
                                const aSystemName: string;
                                out aResponse: string;
                                out aError: string ): Boolean;

      class function getSystemLogo( aSettings: TSettings;
                                    const aSystemName: string;
                                    out aBytes: TBytes;
                                    out aError: string ): Boolean;

      class function getSystemGames( aSettings: TSettings;
                                     const aSystemName: string;
                                     out aResponse: string;
                                     out aError: string ): Boolean;

      class function getGame( aSettings: TSettings;
                              const aSystemName: string;
                              const aGameId: string;
                              out aResponse: string;
                              out aError: string ): Boolean;

      class function getGameMedia( aSettings: TSettings;
                                   const aSystemName: string;
                                   const aGameId: string;
                                   const aMediaType: string;
                                   out aBytes: TBytes;
                                   out aError: string ): Boolean;

      class function getRunningGame( aSettings: TSettings;
                                     out aResponse: string;
                                     out aError: string ): Boolean;

      class function getCaps( aSettings: TSettings;
                              out aResponse: string;
                              out aError: string ): Boolean;

      class function sendMessageBox( aSettings: TSettings;
                                     const aMessage: string;
                                     out aError: string ): Boolean;

      class function sendNotify( aSettings: TSettings;
                                 const aMessage: string;
                                 out aError: string ): Boolean;

      class function restartES( aSettings: TSettings;
                                out aError: string ): Boolean;

      class function quitES( aSettings: TSettings;
                             out aError: string ): Boolean;

      class function killEmulator( aSettings: TSettings;
                                   out aError: string ): Boolean;

      class function addGames( aSettings: TSettings;
                               const aSystemName: string;
                               const aGamelistXml: string;
                               out aError: string ): Boolean;

      class function removeGames( aSettings: TSettings;
                                  const aSystemName: string;
                                  const aGamelistXml: string;
                                  out aError: string ): Boolean;

      class function updateGameMetadata( aSettings: TSettings;
                                         const aSystemName: string;
                                         const aGameId: string;
                                         const aJson: string;
                                         out aError: string ): Boolean;

      class function uploadGameMedia( aSettings: TSettings;
                                      const aSystemName: string;
                                      const aGameId: string;
                                      const aMediaType: string;
                                      const aFilePath: string;
                                      out aError: string ): Boolean;
   end;



implementation

uses
   System.Classes,
   System.Net.HttpClientComponent,
   System.Net.URLClient,
   System.IOUtils,
   Constantes;

class function TESApi.httpGet( const aUrl: string;
                               out aResponse: string;
                               out aError: string ): Boolean;
begin
   Result:= False;
   aResponse:= '';
   aError:= '';
   var _client:= TNetHTTPClient.Create( nil );
   try
      _client.ConnectionTimeout:= 3000;
      _client.ResponseTimeout:= 5000;
      try
         var _resp:= _client.Get( aUrl );
         aResponse:= _resp.ContentAsString( TEncoding.UTF8 );
         Result:= True;
      except
         on E: Exception do
            aError:= E.Message;
      end;
   finally
      _client.Free;
   end;
end;

class function TESApi.httpGetWithTimeout( const aUrl: string;
                                          out aResponse: string;
                                          out aError: string;
                                          const aTimeout: Integer ): Boolean;
begin
   Result:= False;
   aResponse:= '';
   aError:= '';
   var _client:= TNetHTTPClient.Create( nil );
   try
      _client.ConnectionTimeout:= aTimeout;
      _client.ResponseTimeout:= aTimeout;
      try
         var _resp:= _client.Get( aUrl );
         aResponse:= _resp.ContentAsString( TEncoding.UTF8 );
         Result:= True;
      except
         on E: Exception do
            aError:= E.Message;
      end;
   finally
      _client.Free;
   end;
end;

class function TESApi.httpPost( const aUrl: string;
                                const aBody: string;
                                const aContentType: string;
                                out aError: string ): Boolean;
begin
   Result:= False;
   aError:= '';
   var _client:= TNetHTTPClient.Create( nil );
   try
      _client.ConnectionTimeout:= 3000;
      _client.ResponseTimeout:= 5000;
      try
         var _stream:= TStringStream.Create( aBody, TEncoding.UTF8 );
         try
            _client.Post( aUrl, _stream, nil,
                          [TNameValuePair.Create( 'Content-Type', aContentType )] );
            Result:= True;
         finally
            _stream.Free;
         end;
      except
         on E: Exception do
            aError:= E.Message;
      end;
   finally
      _client.Free;
   end;
end;

class function TESApi.httpPostBytes( const aUrl: string;
                                     aBytes: TBytes;
                                     const aContentType: string;
                                     out aError: string ): Boolean;
begin
   Result:= False;
   aError:= '';
   var _client:= TNetHTTPClient.Create( nil );
   try
      _client.ConnectionTimeout:= 3000;
      _client.ResponseTimeout:= 30000;
      try
         var _stream:= TBytesStream.Create( aBytes );
         try
            _client.Post( aUrl, _stream, nil,
                          [TNameValuePair.Create( 'Content-Type', aContentType )] );
            Result:= True;
         finally
            _stream.Free;
         end;
      except
         on E: Exception do
            aError:= E.Message;
      end;
   finally
      _client.Free;
   end;
end;

class function TESApi.checkAvailable( aSettings: TSettings;
                                      out aError: string ): Boolean;
begin
   aError:= '';
   Result:= isESAvailable( aSettings );
   if ( not Result ) then
      aError:= rstApiDisabledOrUnavailable;
end;

class function TESApi.getBaseUrl: string;
begin
   Result:= 'http://' + GESHost + ':' + cstESApiPort;
end;

class function TESApi.findESHost: string;
begin
   var _response, _error: string;
   if ( httpGetWithTimeout( 'http://' + cstESApiLocalHost + ':' + cstESApiPort + cstESApiIsIdle,
                            _response, _error, 1000 ) ) then
      Exit( cstESApiLocalHost );
   if ( httpGetWithTimeout( 'http://' + cstESApiDefaultHost + ':' + cstESApiPort + cstESApiIsIdle,
                            _response, _error, 1000 ) ) then
      Exit( cstESApiDefaultHost );
   Result:= '';
end;

class function TESApi.isESAvailable( aSettings: TSettings ): Boolean;
begin
   Result:= False;
   if ( not aSettings.apiEnabled ) then Exit;
   if ( GESHost.IsEmpty ) then
      GESHost:= findESHost;
   Result:= not GESHost.IsEmpty;
end;

class function TESApi.reloadGames( aSettings: TSettings;
                                   out aError: string ): Boolean;
begin
   Result:= False;
   aError:= '';
   if ( not checkAvailable( aSettings, aError ) ) then Exit;

   var _response: string;
   Result:= httpGet( getBaseUrl + cstESApiReloadGames, _response, aError );
end;

class function TESApi.launchGame( aSettings: TSettings;
                                  const aRomPath: string;
                                  out aError: string ): Boolean;
begin
   Result:= False;
   aError:= '';
   if ( not checkAvailable( aSettings, aError ) ) then Exit;

   Result:= httpPost( getBaseUrl + cstESApiLaunch,
                      aRomPath, 'text/plain', aError );
end;

class function TESApi.getSystemList( aSettings: TSettings;
                                     out aResponse: string;
                                     out aError: string ): Boolean;
begin
   Result:= False;
   aError:= '';
   if ( not checkAvailable( aSettings, aError ) ) then Exit;

   Result:= httpGet( getBaseUrl + cstESApiSystems, aResponse, aError );
end;

class function TESApi.getSystem( aSettings: TSettings;
                                 const aSystemName: string;
                                 out aResponse: string;
                                 out aError: string ): Boolean;
begin
   Result:= False;
   aError:= '';
   if ( not checkAvailable( aSettings, aError ) ) then Exit;

   Result:= httpGet( getBaseUrl + cstESApiSystems + '/' + aSystemName,
                     aResponse, aError );
end;

class function TESApi.getSystemLogo( aSettings: TSettings;
                                     const aSystemName: string;
                                     out aBytes: TBytes;
                                     out aError: string ): Boolean;
begin
   Result:= False;
   SetLength( aBytes, 0 );
   aError:= '';
   if ( not checkAvailable( aSettings, aError ) ) then Exit;
   var _client:= TNetHTTPClient.Create( nil );
   try
      _client.ConnectionTimeout:= 3000;
      _client.ResponseTimeout:= 10000;
      try
         var _stream:= TBytesStream.Create;
         try
            _client.Get( getBaseUrl + cstESApiSystems + '/' + aSystemName + '/logo',
                         _stream );
            aBytes:= Copy( _stream.Bytes, 0, _stream.Size );
            Result:= True;
         finally
            _stream.Free;
         end;
      except
         on E: Exception do
            aError:= E.Message;
      end;
   finally
      _client.Free;
   end;
end;

class function TESApi.getSystemGames( aSettings: TSettings;
                                      const aSystemName: string;
                                      out aResponse: string;
                                      out aError: string ): Boolean;
begin
   Result:= False;
   aError:= '';
   if ( not checkAvailable( aSettings, aError ) ) then Exit;

   Result:= httpGet( getBaseUrl + cstESApiSystems + '/' + aSystemName + '/games',
                     aResponse, aError );
end;

class function TESApi.getGame( aSettings: TSettings;
                               const aSystemName: string;
                               const aGameId: string;
                               out aResponse: string;
                               out aError: string ): Boolean;
begin
   Result:= False;
   aError:= '';
   if ( not checkAvailable( aSettings, aError ) ) then Exit;

   Result:= httpGet( getBaseUrl + cstESApiSystems + '/' + aSystemName +
                     '/games/' + aGameId, aResponse, aError );
end;

class function TESApi.getGameMedia( aSettings: TSettings;
                                    const aSystemName: string;
                                    const aGameId: string;
                                    const aMediaType: string;
                                    out aBytes: TBytes;
                                    out aError: string ): Boolean;
begin
   Result:= False;
   SetLength( aBytes, 0 );
   aError:= '';
   if ( not checkAvailable( aSettings, aError ) ) then Exit;

   var _client:= TNetHTTPClient.Create( nil );
   try
      _client.ConnectionTimeout:= 3000;
      _client.ResponseTimeout:= 30000;
      try
         var _stream:= TBytesStream.Create;
         try
            _client.Get( getBaseUrl + cstESApiSystems + '/' + aSystemName +
                         '/games/' + aGameId + '/media/' + aMediaType, _stream );
            aBytes:= _stream.Bytes;
            SetLength( aBytes, _stream.Size );
            Result:= True;
         finally
            _stream.Free;
         end;
      except
         on E: Exception do
            aError:= E.Message;
      end;
   finally
      _client.Free;
   end;
end;

class function TESApi.getRunningGame( aSettings: TSettings;
                                      out aResponse: string;
                                      out aError: string ): Boolean;
begin
   Result:= False;
   aError:= '';
   if ( not checkAvailable( aSettings, aError ) ) then Exit;

   Result:= httpGet( getBaseUrl + cstESApiRunningGame, aResponse, aError );
end;

class function TESApi.getCaps( aSettings: TSettings;
                               out aResponse: string;
                               out aError: string ): Boolean;
begin
   Result:= False;
   aError:= '';
   if ( not checkAvailable( aSettings, aError ) ) then Exit;

   Result:= httpGet( getBaseUrl + cstESApiCaps, aResponse, aError );
end;

class function TESApi.sendMessageBox( aSettings: TSettings;
                                      const aMessage: string;
                                      out aError: string ): Boolean;
begin
   Result:= False;
   aError:= '';
   if ( not checkAvailable( aSettings, aError ) ) then Exit;

   Result:= httpPost( getBaseUrl + cstESApiMessageBox,
                      aMessage, 'text/plain', aError );
end;

class function TESApi.sendNotify( aSettings: TSettings;
                                  const aMessage: string;
                                  out aError: string ): Boolean;
begin
   Result:= False;
   aError:= '';
   if ( not checkAvailable( aSettings, aError ) ) then Exit;

   Result:= httpPost( getBaseUrl + cstESApiNotify,
                      aMessage, 'text/plain', aError );
end;

class function TESApi.restartES( aSettings: TSettings;
                                 out aError: string ): Boolean;
begin
   Result:= False;
   aError:= '';
   if ( not checkAvailable( aSettings, aError ) ) then Exit;

   var _response: string;
   Result:= httpGet( getBaseUrl + cstESApiRestart, _response, aError );
end;

class function TESApi.quitES( aSettings: TSettings;
                              out aError: string ): Boolean;
begin
   Result:= False;
   aError:= '';
   if ( not checkAvailable( aSettings, aError ) ) then Exit;

   var _response: string;
   Result:= httpGet( getBaseUrl + cstESApiQuit, _response, aError );
end;

class function TESApi.killEmulator( aSettings: TSettings;
                                    out aError: string ): Boolean;
begin
   Result:= False;
   aError:= '';
   if ( not checkAvailable( aSettings, aError ) ) then Exit;

   var _response: string;
   Result:= httpGet( getBaseUrl + cstESApiEmuKill, _response, aError );
end;

class function TESApi.addGames( aSettings: TSettings;
                                const aSystemName: string;
                                const aGamelistXml: string;
                                out aError: string ): Boolean;
begin
   Result:= False;
   aError:= '';
   if ( not checkAvailable( aSettings, aError ) ) then Exit;

   Result:= httpPost( getBaseUrl + cstESApiAddGames + '/' + aSystemName,
                      aGamelistXml, 'application/xml', aError );
end;

class function TESApi.removeGames( aSettings: TSettings;
                                   const aSystemName: string;
                                   const aGamelistXml: string;
                                   out aError: string ): Boolean;
begin
   Result:= False;
   aError:= '';
   if ( not checkAvailable( aSettings, aError ) ) then Exit;

   Result:= httpPost( getBaseUrl + cstESApiRemoveGames + '/' + aSystemName,
                      aGamelistXml, 'application/xml', aError );
end;

class function TESApi.updateGameMetadata( aSettings: TSettings;
                                          const aSystemName: string;
                                          const aGameId: string;
                                          const aJson: string;
                                          out aError: string ): Boolean;
begin
   Result:= False;
   aError:= '';
   if ( not checkAvailable( aSettings, aError ) ) then Exit;

   Result:= httpPost( getBaseUrl + cstESApiSystems + '/' + aSystemName +
                      '/games/' + aGameId,
                      aJson, 'application/json', aError );
end;

class function TESApi.uploadGameMedia( aSettings: TSettings;
                                       const aSystemName: string;
                                       const aGameId: string;
                                       const aMediaType: string;
                                       const aFilePath: string;
                                       out aError: string ): Boolean;
begin
   Result:= False;
   aError:= '';
   if ( not checkAvailable( aSettings, aError ) ) then Exit;

   if ( not TFile.Exists( aFilePath ) ) then begin
      aError:= rstFilenotFound + aFilePath;
      Exit;
   end;

   // Determine content type from extension
   var _ext:= LowerCase( TPath.GetExtension( aFilePath ) );
   var _contentType:= '';
   if ( _ext = '.jpg' ) or
      ( _ext = '.jpeg' ) then
      _contentType:= 'image/jpeg'
   else if ( _ext = '.png' ) then
      _contentType:= 'image/png'
   else if ( _ext = '.mp4' ) then
      _contentType:= 'video/mp4'
   else if ( _ext = '.pdf' ) then
      _contentType:= 'application/pdf'
   else begin
      aError:= rstUnsupportedMediatype + _ext;
      Exit;
   end;

   var _bytes:= TFile.ReadAllBytes( aFilePath );
   Result:= httpPostBytes( getBaseUrl + cstESApiSystems + '/' + aSystemName +
                           '/games/' + aGameId + '/media/' + aMediaType,
                           _bytes, _contentType, aError );
end;

end.
