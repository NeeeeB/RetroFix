unit Rpcs3Utils;

interface

uses
   System.SysUtils, System.Classes, System.IOUtils,
   System.Generics.Collections;

// Builds a dictionary normalized_title -> serial
// by scanning all PARAM.SFO files in the RPCS3 game folder
function buildRpcs3TitleMap( const aRetrobatPath: string ): TDictionary<string, string>;

// Returns the serial for a given game name, or empty string if not found
function findRpcs3Serial( aMap: TDictionary<string, string>;
                          const aGameName: string;
                          out aSerial: string ): Boolean;

implementation

function normalizeTitle( const aTitle: string ): string;
begin
   var _result:= TStringBuilder.Create;
   try
      for var _c in aTitle.ToLower do
         if ( CharInSet( _c, ['a'..'z', '0'..'9'] ) ) then
            _result.Append( _c );
      Result:= _result.ToString;
   finally
      _result.Free;
   end;
end;

function readSfoTitle( const aSfoPath: string ): string;
var
   _magic: array[0..3] of Byte;
   _keyOffset: Cardinal;
   _dataOffset: Cardinal;
   _numEntries: Cardinal;
   _keyOff: Word;
   _dataOff: Cardinal;
   _dataLen: Cardinal;
   _dataType: Word;
   _keyBuf: TBytes;
   _valBuf: TBytes;
   _keyName: string;
begin
   Result:= '';
   if ( not TFile.Exists( aSfoPath ) ) then Exit;
   try
      var _stream:= TFileStream.Create( aSfoPath, fmOpenRead or fmShareDenyNone );
      try
         // Check magic: 00 50 53 46
         _stream.Read( _magic, 4 );
         if ( _magic[0] <> $00 ) or ( _magic[1] <> $50 ) or
            ( _magic[2] <> $53 ) or ( _magic[3] <> $46 ) then Exit;

         // Skip version (4 bytes)
         _stream.Seek( 4, soFromCurrent );

         // Key table offset (4 bytes LE)
         _stream.Read( _keyOffset, 4 );
         // Data table offset (4 bytes LE)
         _stream.Read( _dataOffset, 4 );
         // Number of entries (4 bytes LE)
         _stream.Read( _numEntries, 4 );

         // Each index entry is 16 bytes:
         // key_offset(2) + unknown(2) + data_type(2) + data_len(4) + data_max_len(4) + data_offset(4)
         // but actually: key_offset(2) + param_fmt(2) + param_len(4) + param_max_len(4) + data_offset(4) = 16 bytes
         for var ii:= 0 to Integer( _numEntries ) - 1 do begin
            _stream.Seek( 20 + ii * 16, soFromBeginning );

            _stream.Read( _keyOff,  2 );
            _stream.Read( _dataType, 2 );
            _stream.Read( _dataLen,  4 );
            var _dataMaxLen: Cardinal;
            _stream.Read( _dataMaxLen, 4 );
            _stream.Read( _dataOff,  4 );

            // Read key name
            _stream.Seek( _keyOffset + _keyOff, soFromBeginning );
            SetLength( _keyBuf, 64 );
            var _b: Byte;
            var _len: Integer:= 0;
            repeat
               _stream.Read( _b, 1 );
               if ( _b <> 0 ) then begin
                  _keyBuf[_len]:= _b;
                  Inc( _len );
               end;
            until ( _b = 0 ) or ( _len >= 63 );
            _keyName:= TEncoding.UTF8.GetString( _keyBuf, 0, _len );

            if ( _keyName = 'TITLE' ) then begin
               // Read value
               _stream.Seek( _dataOffset + _dataOff, soFromBeginning );
               SetLength( _valBuf, _dataLen );
               _stream.Read( _valBuf[0], _dataLen );
               // Find null terminator
               var _strLen: Integer:= 0;
               while ( _strLen < Integer( _dataLen ) ) and
                     ( _valBuf[_strLen] <> 0 ) do
                  Inc( _strLen );
               Result:= TEncoding.UTF8.GetString( _valBuf, 0, _strLen );
               Exit;
            end;
         end;
      finally
         _stream.Free;
      end;
   except
   end;
end;

function buildRpcs3TitleMap( const aRetrobatPath: string ): TDictionary<string, string>;
begin
   Result:= TDictionary<string, string>.Create;
   var _gameDir:= TPath.Combine( aRetrobatPath,
                                 'saves\ps3\rpcs3\dev_hdd0\game' );
   if ( not TDirectory.Exists( _gameDir ) ) then Exit;

   for var _serial in TDirectory.GetDirectories( _gameDir ) do begin
      var _sfoPath:= TPath.Combine( _serial, 'PARAM.SFO' );
      var _title  := readSfoTitle( _sfoPath );
      if ( _title.IsEmpty ) then Continue;
      var _norm:= normalizeTitle( _title );
      if ( not _norm.IsEmpty ) then
         Result.AddOrSetValue( _norm, TPath.GetFileName( _serial ) );
   end;
end;

function findRpcs3Serial( aMap: TDictionary<string, string>;
                          const aGameName: string;
                          out aSerial: string ): Boolean;
begin
   aSerial:= '';
   if ( aMap = nil ) then
      Exit( False );
   Result:= aMap.TryGetValue( normalizeTitle( aGameName ), aSerial );
end;

end.
