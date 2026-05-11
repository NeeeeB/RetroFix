unit HashUtils;

interface

uses
   System.Classes,
   Types;

function fileMD5( const aFileName: string ): string;
function fileCRC32( const aFileName: string ): string;
function streamMD5( aStream: TStream ): string;
function streamSHA1( aStream: TStream ): string;
function fileSHA1( const aFilePath: string ): string;
function getRomHashInfo( const aFilePath: string;
                         aExtractFromArchive: Boolean ): TRomHashInfo;

implementation

uses
   System.SysUtils,
   System.IOUtils,
   System.Hash,
   System.ZLib,
   System.Zip;

function streamMD5( aStream: TStream ): string;
begin
   var _md5:= THashMD5.Create;
   Result:= LowerCase( _md5.GetHashString( aStream ) );
end;

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

function streamSHA1( aStream: TStream ): string;
begin
   Result:= LowerCase( THashSHA1.GetHashString( aStream ) );
end;

function fileSHA1( const aFilePath: string ): string;
begin
   Result:= LowerCase( THashSHA1.GetHashStringFromFile( aFilePath ) );
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

function getRomHashInfo( const aFilePath: string;
                         aExtractFromArchive: Boolean ): TRomHashInfo;
begin
   Result:= Default( TRomHashInfo );
   if ( not TFile.Exists( aFilePath ) ) then Exit;

   var _ext:= LowerCase( TPath.GetExtension( aFilePath ) );

   if ( aExtractFromArchive ) and
      ( _ext = '.zip' ) and
      ( TZipFile.IsValid( aFilePath ) ) then begin
      var _zip:= TZipFile.Create;
      try
         _zip.Open( aFilePath, zmRead );
         if ( ( _zip.FileCount > 0 ) ) then begin
            // CRC32 from zip header — no extraction needed
            Result.crc32:= LowerCase( IntToHex( _zip.FileInfo[0].CRC32, 8 ) );
            Result.size:= _zip.FileInfo[0].UncompressedSize;

            // MD5 requires extraction
            var _bytes: TBytes;
            _zip.Read( 0, _bytes );
            var _stream:= TBytesStream.Create( _bytes );
            try
               _stream.Position:= 0;
               Result.md5:= streamMD5( _stream );

               // SHA1 requires extraction too
               _stream.Position:= 0;
               Result.sha1:= streamSHA1( _stream );
            finally
               _stream.Free;
            end;
         end;
         _zip.Close;
      finally
         _zip.Free;
      end;
   end else begin
      Result.md5:= fileMD5( aFilePath );
      Result.crc32:= fileCRC32( aFilePath );
      Result.sha1:= fileSHA1( aFilePath );
      Result.size:= TFile.GetSize( aFilePath );
   end;
end;

end.
