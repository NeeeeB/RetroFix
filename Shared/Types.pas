unit Types;

interface

uses
   system.Skia,
   Vcl.ExtCtrls,
   Vcl.Skia;

type
   TBiosStatus = (
      bsOK,
      bsMD5Mismatch,
      bsPresentNoHash,
      bsMissing,
      bsPartial );

   TBiosAlternativePath = record
      systemKey   : string;
      fileName    : string;
      altRelPath  : string;
   end;

   TValidFolder = ( vfUndefined,
                    vfValid,
                    vfInvalid );

   TGroupMode = ( gmSystem,
                  gmStatus );

   TMediaType = ( mtImage,
                  mtVideo,
                  mtMarquee,
                  mtThumbnail,
                  mtFanart,
                  mtTitleshot,
                  mtManual,
                  mtMagazine,
                  mtMap,
                  mtBezel,
                  mtCartridge,
                  mtBoxArt,
                  mtBoxBack,
                  mtWheel,
                  mtMix );

   TSSResult = ( ssrOK,
                 ssrNotFound,
                 ssrError,
                 ssrQuotaExceeded );

   TScrapeLanguage = ( slEnglish,
                       slFrench,
                       slGerman,
                       slSpanish,
                       slItalian,
                       slPortuguese,
                       slJapanese,
                       slChinese );

   TRomHashInfo = record
      md5  : string;
      crc32: string;
      sha1: string;
      size : Int64;
   end;

   TSSMediaInfo = record
      mediaType: string;
      region   : string;
      url      : string;
      format   : string;
   end;

   TSSGameInfo = record
      id          : string;
      name        : string;
      desc        : string;
      developer   : string;
      publisher   : string;
      genre       : string;
      players     : string;
      rating      : string;
      releaseDate : string;
      family      : string;
      arcadeSystem: string;
      region      : string;
      medias      : TArray<TSSMediaInfo>;
   end;

   TSSUserInfo = record
      userId           : string;
      maxThreads       : Integer;
      requestsToday    : Integer;
      maxRequestsPerDay: Integer;
      maxDownloadSpeed : Integer;
   end;

   TSettings = class
   public
      retrobatPath  : string;
      strictMode    : Boolean;
      forceExtract  : Boolean;
      scrapeBezel   : Boolean;
      scrapeBoxBack : Boolean;
      scrapeFanart  : Boolean;
      scrapeManual  : Boolean;
      scrapeMap     : Boolean;
      scrapeVideos  : Boolean;
      favRegion     : string;
      ssUserId      : string;
      ssPassword    : string;
      scrapeLanguage: string;
      scrapeImageSrc: string;
      scrapeLogoSrc : string;
      scrapeThumbSrc: string;
      apiEnabled    : Boolean;
   end;

   TSystemTile = class( TPanel )
   public
      systemName: string;
      gameId    : string;
   end;

   TGameMedia = record
      mediaType: TMediaType;
      path     : string;
      exists   : Boolean;
   end;

   TGameEntry = record
      id          : string;
      name        : string;
      romPath     : string;
      md5         : string;
      crc32       : string;
      desc        : string;
      genre       : string;
      rating      : string;
      releaseDate : string;
      developer   : string;
      publisher   : string;
      family      : string;
      arcadeSystem: string;
      players     : string;
      lang        : string;
      region      : string;
      medias      : TArray<TGameMedia>;
      isScraped   : Boolean;
   end;

   TGamelistResult = class
      systemName   : string;
      romDir       : string;
      totalRoms    : Integer;
      games        : TArray<TGameEntry>;
      missingROMs  : TArray<string>;
      unscrapedROMs: TArray<string>;
      orphanMedias : TArray<string>;
      missingMedias: TArray<string>
   end;

   TGameEntryRef = class
   public
      systemName    : string;
      gameName      : string;
      romPath       : string;
      mediaPath     : string;
      mediaType     : TMediaType;
      gamelistResult: TGameListResult;
   end;

   TScanOptions = record
      forceExtract: Boolean;
      strictMode  : Boolean;
   end;

   TRescanEvent = procedure( Sender: TObject; const aOptions: TScanOptions ) of object;

   TBiosFileEntry = record
      relativePath: string;
      MD5         : string;
   end;

   TBiosSystemEntry = record
      systemKey : string;
      systemName: string;
      files     : TArray<TBiosFileEntry>;
   end;

   TBiosResult = record
      systemKey    : string;
      systemName   : string;
      fileName     : string;
      fullPath     : string;
      altFullPath  : string;
      primaryExists: Boolean;
      altExists    : Boolean;
      status       : TBiosStatus;
      expectedMD5  : string;
      actualMD5    : string;
   end;

   TBiosSummary = record
      total        : Integer;
      ok           : Integer;
      presentNoHash: Integer;
      md5Mismatch  : Integer;
      missing      : Integer;
      partial      : Integer;
   end;

   TGamelistSummary = record
      totalSystems      : Integer;
      totalGames        : Integer;
      totalScraped      : Integer;
      totalMissingROMs  : Integer;
      totalUnscraped    : Integer;
      totalMissingMedias: Integer;
      totalOrphanMedias : Integer;
      totalNoMedia      : Integer;
   end;

   TLangInfo = record
      language: string;
      region  : string;
   end;

   TLangEntry = record
      tokens: string;
      lang  : string;
      region: string;
   end;

   PBiosNodeData = ^TBiosNodeData;
   TBiosNodeData = record
      result   : TBiosResult;
      isAltPath: Boolean;
      isGroup  : Boolean;
      groupText: string;
   end;

   PGamelistNodeData = ^TGamelistNodeData;
   TGamelistNodeData = record
      isGroup  : Boolean;
      groupText: string;
      ref      : TGameEntryRef;
   end;

   PHashMismatchNodeData = ^THashMismatchNodeData;
   THashMismatchNodeData = record
      ref         : TGameEntryRef;
      expectedHash: string;
      actualHash  : string;
      hashType    : string;
   end;

   TCachedImage = class
   public
      svg          : TSkSvg;
      skImage      : ISkImage;
      isSvg        : Boolean;
      viewBoxMinX  : Single;
      viewBoxMinY  : Single;
      viewBoxWidth : Single;
      viewBoxHeight: Single;
      destructor Destroy; override;
   end;

implementation

destructor TCachedImage.Destroy;
begin
   svg.Free;
   inherited;
end;

end.
