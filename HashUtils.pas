unit HashUtils;

interface

function fileMD5( const aFileName: string ): string;
function fileCRC32( const aFileName: string ): string;

implementation

uses
   System.SysUtils,
   System.Hash,
   System.Classes,
   System.ZLib;

function fileMD5( const aFileName: string ): string;
begin
   Result:= '';
   if ( not FileExists( aFileName ) ) then
      Exit;
   var _fs:= TFileStream.Create( aFileName, fmOpenRead or fmShareDenyNone );
   try
      Result:= LowerCase( THashMD5.GetHashString( _fs ) );
   finally
      _fs.Free;
   end;
end;

function fileCRC32( const aFileName: string ): string;
const
   cstBufferSize = 65536;
begin
   Result:= '';
   if ( not FileExists( aFileName ) ) then
      Exit;
   var _fs:= TFileStream.Create( aFileName, fmOpenRead or fmShareDenyNone );
   try
      var _buffer: TBytes;
      SetLength( _buffer, cstBufferSize );
      var _crc:= crc32( 0, nil, 0 );
      var _bytesRead: Integer;
      repeat
         _bytesRead:= _fs.Read( _buffer[0], cstBufferSize );
         if ( _bytesRead > 0 ) then
            _crc:= crc32( _crc, @_buffer[0], _bytesRead );
      until ( _bytesRead = 0 );
      Result:= LowerCase( IntToHex( _crc, 8 ) );
   finally
      _fs.Free;
   end;
end;

end.
