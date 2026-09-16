unit EsSystemsReader;

interface

uses
   System.Generics.Collections;

function readEsSystemsExtensions( const aRetrobatPath: string ): TDictionary<string, TArray<string>>;

implementation

uses
   System.SysUtils,
   System.IOUtils,
   Neslib.Xml,
   Constantes,
   Tools;

function readEsSystemsExtensions( const aRetrobatPath: string ): TDictionary<string, TArray<string>>;
begin
   Result:= TDictionary<string, TArray<string>>.Create;
   var _path:= TPath.Combine( aRetrobatPath,
                              TPath.Combine( cstEmulationStationFolder,
                                             TPath.Combine( '.emulationstation', cstEsSystemsFile ) ) );
   if ( not TFile.Exists( _path ) ) then Exit;

   var _doc:= TXmlDocument.Create;
   try
      _doc.Load( loadXmlBytes( _path ) );
   except
      on E: Exception do begin
         logError( cstEsSystemsFile, _path, E );
         Exit;
      end;
   end;
   var _root:= _doc.DocumentElement;
   if ( _root.IsEmpty ) then Exit;

   var _system:= _root.FirstChild;
   while ( not _system.IsEmpty ) do begin
      if ( _system.NodeType = TXmlNodeType.Element ) and
         ( _system.Value = cstXmlSystem ) then begin
         var _name:= _system.ElementByName( cstXmlName ).Text;
         var _pathStr:= _system.ElementByName( cstXmlPath ).Text;
         var _extStr:= _system.ElementByName( cstXmlExtensionTag ).Text;
         if ( not _pathStr.IsEmpty ) then
            _name:= TPath.GetFileName( ExcludeTrailingPathDelimiter( _pathStr.Replace( '/', '\' ) ) );
         if ( not _name.IsEmpty ) and ( not _extStr.IsEmpty ) then begin
            // Parse extensions : ".smc .sfc .zip" → ['smc', 'sfc', 'zip']
            var _exts: TArray<string>;
            for var _e in _extStr.Split( [' ', #9] ) do begin
               var _ext:= LowerCase( _e.Trim );
               if ( not _ext.IsEmpty ) then
                  _exts:= _exts + [_ext];
            end;
            if ( Length( _exts ) > 0 ) then
               Result.AddOrSetValue( LowerCase( _name ), _exts );
         end;
      end;
      _system:= _system.NextSibling;
   end;
end;

end.
