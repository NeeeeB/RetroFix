unit Constantes;

interface

uses
   Vcl.Graphics,
   Types;

resourcestring
   rstBiosScanSummary = 'Total: %d | OK: %d | Present (no hash): %d | MD5 mismatch: %d | Missing: %d';
   rstGamelistScanSummary = 'Systems: %d | Games: %d | Scraped: %d | No media: %d | Missing ROMs: %d | Unscraped: %d | Missing medias: %d | Orphans: %d';
   rstMissingRomsNb = 'Missing ROMs (%d)';
   rstUnscrapedNb = 'Unscraped (%d)';
   rstMissingMediasNb = 'Missing medias (%d)';
   rstOrphansNb = 'Orphans (%d)';
   rstNoMediaNb = 'No media (%d)';
   rstStopWatchStr = 'Done in %.2f sec';
   rstSystemStats = 'Scraped: %d | Scraped with medias: %d | ROMs on disk: %d';
   rstMissingRoms = 'ROMs referenced in the gamelist but missing on disk';
   rstUnscrapedRoms = 'ROM files present on disk but not referenced in the gamelist';
   rstNoMediaRoms = 'Games present in the gamelist but with no media at all';
   rstMissingMediaRoms = 'Media files referenced in the gamelist but missing on disk';
   rstOrphanFiles = 'Media files present on disk but not referenced in any game';
   rstImage = 'Image';
   rstVideo = 'Video';
   rstMarquee = 'Marquee';
   rstThumbnail = 'Thumbnail';
   rstFanart = 'Fanart';
   rstManual = 'Manual';
   rstBezel = 'Bezel';
   rstBoxBack = 'Box back';
   rstTitleshot = 'Title shot';
   rstMagazine = 'Magazine';
   rstMap = 'Map';
   rstCartridge = 'Cartridge';
   rstBoxArt = 'Box art';
   rstWheel = 'Wheel';
   rstMix = 'Mix';
   rstBiosOK = '✅ OK';
   rstBiosPresentNoHash = '➖ Present (no hash)';
   rstBiosMD5Mismatch = '⚠️ MD5 mismatch';
   rstBiosMissing = '❌ Missing';
   rstScanning = 'Scanning...';
   rstExtractionFailed = 'Extraction failed : ';
   rstComputing    = 'Computing...';
   rstVerifyHashes = 'Verify hashes';
   rstCancelHashVerification = 'Hash verification is running. Cancel it ?';
   rstNoHashMismatch = 'No hash mismatch found !';
   rstHashMismatch = 'ROM files with a hash mismatch between gamelist and actual file';
   rstNoFolderSelected = '● No folder selected';
   rstRetrobatExeFound = '● Retrobat.exe found';
   rstRetrobatExeNotFound = '● Retrobat.exe not found';
   rstConfirmHashVerification = 'Hash verification can take a long time depending on ROM sizes. Continue ?';
   rstDelete = 'Delete';
   rstOpenDlgCaption = 'Select media file for';
   rstWillBeSavedAs = '(will be saved as:';
   rstDeleteOrphans = 'Delete %d selected orphan file(s) ?';
   rstSSUsername = 'ScreenScraper username:';
   rstSSPassword = 'ScreenScraper password:';
   rstSSCredentialsMissing = 'ScreenScraper credentials not found. Scraping features will not be available.';
   rstSSConnectionFailed = 'ScreenScraper connection failed : ';
   rstSSSystemMappingFailed = 'Failed to load systems mapping : ';
   rstGameScrapedSuccessfully = 'Game scraped successfully !';
   rstScraping = 'Scraping';
   rstScrapeSummary  = '%d/%d game(s) scraped successfully';
   rstScrapeMediaSummary = '%d/%d media(s) downloaded successfully';
   rstGameNotFound   = 'Game not found : %s';
   rstQuotaExceeded  = 'ScreenScraper quota exceeded — scraping stopped';
   rstUnexpectedError = 'Unexpected error : ';
   rstDeleteMissingROMs = 'Remove %d game(s) from gamelist?';

const
   {$INCLUDE 'screenscraper_credentials.inc'}

   cstMargin = 5;

   cstSettingsFileName       = 'config.json';
   cstRetrobatExeFilename    = 'retrobat.exe';
   cstBiosFileName           = 'bios.json';
   cstEmulationStationFolder = 'emulationstation';
   cstBatoceraExeName        = 'batocera-systems.exe';
   cstRetroFixExtractPs1     = 'retrofix_extract.ps1';
   cstRetroFixBiosJson       = 'retrofix_bios.json';
   cstName                   = 'name';
   cstBiosfiles              = 'biosFiles';
   cstFile                   = 'file';
   cstBios                   = 'bios';
   cstMD5                    = 'md5';
   cstRescan                 = 'Rescan';
   cstXmlPath                = 'path';
   cstXmlName                = 'name';
   cstXmlImage               = 'image';
   cstXmlVideo               = 'video';
   cstXmlMarquee             = 'marquee';
   cstXmlThumbnail           = 'thumbnail';
   cstXmlFanart              = 'fanart';
   cstXmlBezel               = 'bezel';
   cstXmlBoxBack             = 'boxback';
   cstXmlManual              = 'manual';
   cstXmlTitleshot           = 'titleshot';
   cstXmlMagazine            = 'magazine';
   cstXmlMap                 = 'map';
   cstXmlCartridge           = 'cartridge';
   cstXmlBoxArt              = 'boxart';
   cstXmlWheel               = 'wheel';
   cstXmlMix                 = 'mix';
   cstXmlMD5                 = 'md5';
   cstXmlHash                = 'hash';
   cstXmlGame                = 'game';
   cstXmlId                  = 'id';
   cstXmlDesc                = 'desc';
   cstXmlGenre               = 'genre';
   cstXmlRating              = 'rating';
   cstXmlReleaseDate         = 'releasedate';
   cstXmlDeveloper           = 'developer';
   cstXmlPublisher           = 'publisher';
   cstXmlFamily              = 'family';
   cstXmlArcadeSystem        = 'arcadesystemname';
   cstXmlPlayers             = 'players';
   cstXmlLang                = 'lang';
   cstXmlRegion              = 'region';
   cstXmlScrap               = 'scrap';
   cstGamelistFile           = 'gamelist.xml';
   cstRomsFolder             = 'roms';
   cstImages                 = 'images';
   cstVideos                 = 'videos';
   cstManuals                = 'manuals';
   cstXmlExtension           = '.xml';
   cstXmlGameList            = 'gameList';

   // API ScreenScraper
   cstSSSoftName         = 'RetroFix';
   cstSSBaseUrl          = 'https://www.screenscraper.fr/api2/';
   cstEsSettingsFile     = 'es_settings.cfg';
   cstEsLanguageKey      = 'Language';
   cstDefaultLanguage    = 'en';
   cstSSUserKey          = 'ScreenScraperUser';
   cstSSPasswordKey      = 'ScreenScraperPass';
   cstSSApiSystemes      = 'systemesListe.php';
   cstSSApiUserInfo      = 'ssuserInfos.php';
   cstSSApiGameInfo      = 'jeuInfos.php';
   cstSSNomRecalbox      = 'nom_recalbox';
   cstSSHeader           = 'header';
   cstSSSuccess          = 'success';
   cstSSError            = 'error';
   cstSSResponse         = 'response';
   cstSSSystemes         = 'systemes';
   cstSSNoms             = 'noms';
   cstSSId               = 'id';
   cstSSUser             = 'ssuser';
   cstSSMaxThreads       = 'maxthreads';
   cstSSRequestsToday    = 'requeststoday';
   cstSSMaxRequests      = 'maxrequestsperday';
   cstSSMaxDownload      = 'maxdownloadspeed';
   cstSSJeu              = 'jeu';
   cstSSSynopsis         = 'synopsis';
   cstSSDeveloppeur      = 'developpeur';
   cstSSEditeur          = 'editeur';
   cstSSGenres           = 'genres';
   cstSSJoueurs          = 'joueurs';
   cstSSNote             = 'note';
   cstSSDates            = 'dates';
   cstSSMedias           = 'medias';
   cstSSText             = 'text';
   cstSSRegion           = 'region';
   cstSSLangue           = 'langue';
   cstSSFamilles         = 'familles';
   cstSSType             = 'type';
   cstSSUrl              = 'url';
   cstSSFormat           = 'format';
   cstSSSystemeId        = '&systemeid=';
   cstSSRomType          = '&romtype=rom';
   cstSSRomNom           = '&romnom=';
   cstSSRomTaille        = '&romtaille=';
   cstSSMd5              = '&md5=';
   cstSSCrc              = '&crc=';
   cstSSSha1             = '&sha1=';
   cstSSRegionWor        = 'wor';
   cstSSJeuIntrouvable   = 'Jeu introuvable';
   cstSSNotFound         = 'not found';
   cstSSQuota            = 'quota';
   cstSSMediaVideo       = 'video';
   cstSSMediaBoxBack     = 'box-2D-back';
   cstSSMediaFanart      = 'fanart';
   cstSSMediaManual      = 'manuel';
   cstSSMediaBezel       = 'bezel-16-9';
   cstSSMediaMap         = 'maps';
   cstSSMediaNone        = 'none';
   cstSSScrapName        = 'name';
   cstSSScrapSource      = 'ScreenScraper';
   cstSSScrapDate        = 'date';
   cstSSScrapDateFormat  = 'yyyymmdd"T"hhnnss';
   cstSSRomId            = 'romid';
   cstSSRoms             = 'roms';
   cstSSRegions          = 'regions';
   cstSSRegionsShortname = 'regions_shortname';
   cstSSMediaSs              = 'ss';
   cstSSMediaSsTitle         = 'sstitle';
   cstSSMediaMixV1           = 'mixrbv1';
   cstSSMediaMixV2           = 'mixrbv2';
   cstSSMediaBox2D           = 'box-2D';
   cstSSMediaBox3D           = 'box-3D';
   cstSSMediaWheel           = 'wheel';
   cstSSMediaWheelHD         = 'wheel-hd';
   cstSSMediaWheelSteel      = 'wheel-steel';
   cstSSMediaWheelCarbon     = 'wheel-carbon';
   cstSSMediaScreenMarquee   = 'screenmarquee';
   cstSSMediaScreenMarqueeSm = 'screenmarqueesmall';
   cstSSMediaVideoNorm       = 'video-normalized';
   cstSSMediaLogo            = 'logo';
   cstSSSysteme              = 'systeme';
   cstEsScrapperImageKey = 'ScrapperImageSrc';
   cstEsScrapperLogoKey  = 'ScrapperLogoSrc';
   cstEsScrapperThumbKey = 'ScrapperThumbSrc';
   cstEsScrapeBezelKey   = 'ScrapeBezel';
   cstEsScrapeBoxBackKey = 'ScrapeBoxBack';
   cstEsScrapeFanartKey  = 'ScrapeFanart';
   cstEsScrapeManualKey  = 'ScrapeManual';
   cstEsScrapeMapKey     = 'ScrapeMap';
   cstEsScrapeVideosKey  = 'ScrapeVideos';
   cstEsScraperRegionKey = 'ScraperRegion';
   cstDefaultRegion      = 'us';
   cstDefaultImageSrc    = cstSSMediaSs;
   cstDefaultLogoSrc     = cstSSMediaLogo;
   cstDefaultThumbSrc    = cstSSMediaBox2D;
   cstThumbFileSuffix    = 'thumb';

   cstExcludedRomExtensions: TArray<string> = ['.xml', '.ini', '.m3u', '.txt', '.dat', '.cfg', '.log', '.pak'];

   cstValidFolderColors: array[tValidFolder] of TColor =
      ( clGray,
        clGreen,
        clRed );

   cstValidFolderStrings: array[TValidFolder] of string =
      ( rstNoFolderSelected,
        rstRetrobatExeFound,
        rstRetrobatExeNotFound );

   cstMediaTypeTags: array[TMediaType] of string =
      ( cstXmlImage,
        cstXmlVideo,
        cstXmlMarquee,
        cstXmlThumbnail,
        cstXmlFanart,
        cstXmlTitleshot,
        cstXmlManual,
        cstXmlMagazine,
        cstXmlMap,
        cstXmlBezel,
        cstXmlCartridge,
        cstXmlBoxArt,
        cstXmlBoxBack,
        cstXmlWheel,
        cstXmlMix );

   cstHints: array[0..5] of string =
      ( rstMissingRoms,
        rstUnscrapedRoms,
        rstMissingMediaRoms,
        rstNoMediaRoms,
        rstOrphanFiles,
        rstHashMismatch );

   cstScrapeLanguageCodes: array[TScrapeLanguage] of string =
      ( 'en',
        'fr',
        'de',
        'es',
        'it',
        'pt',
        'ja',
        'zh' );

   cstArcadeSystems: array[0..61] of record
      id       : Integer;
      shortName: string;
      longName : string;
   end = (
      ( id: 6;   shortName: 'cps1';           longName: 'CPS-1' ),
      ( id: 7;   shortName: 'cps2';           longName: 'CPS-2' ),
      ( id: 8;   shortName: 'cps3';           longName: 'CPS-3' ),
      ( id: 35;  shortName: 'aae';            longName: 'Another Arcade Emulator' ),
      ( id: 47;  shortName: 'cave';           longName: 'Cave' ),
      ( id: 49;  shortName: 'daphne';         longName: 'Daphne' ),
      ( id: 53;  shortName: 'atomiswave';     longName: 'Atomiswave' ),
      ( id: 54;  shortName: 'model2';         longName: 'Sega Model 2' ),
      ( id: 55;  shortName: 'model3';         longName: 'Sega Model 3' ),
      ( id: 56;  shortName: 'naomi';          longName: 'Naomi' ),
      ( id: 68;  shortName: 'neogeomvs';      longName: 'Neo-Geo MVS' ),
      ( id: 69;  shortName: 'segastv';        longName: 'Sega ST-V' ),
      ( id: 112; shortName: 'taitox';         longName: 'Taito Type X' ),
      ( id: 142; shortName: 'neogeo';         longName: 'Neo-Geo' ),
      ( id: 147; shortName: 'sega';           longName: 'Sega' ),
      ( id: 148; shortName: 'irem';           longName: 'Irem' ),
      ( id: 149; shortName: 'seta';           longName: 'Seta' ),
      ( id: 150; shortName: 'midway';         longName: 'Midway' ),
      ( id: 151; shortName: 'capcom';         longName: 'Capcom' ),
      ( id: 152; shortName: 'eighting';       longName: 'Eighting/Raizing' ),
      ( id: 153; shortName: 'tecmo';          longName: 'Tecmo' ),
      ( id: 154; shortName: 'snk';            longName: 'SNK' ),
      ( id: 155; shortName: 'namco';          longName: 'Namco' ),
      ( id: 156; shortName: 'namco22';        longName: 'Namco System 22' ),
      ( id: 157; shortName: 'taito';          longName: 'Taito' ),
      ( id: 158; shortName: 'konami';         longName: 'Konami' ),
      ( id: 159; shortName: 'jaleco';         longName: 'Jaleco' ),
      ( id: 160; shortName: 'atari';          longName: 'Atari' ),
      ( id: 161; shortName: 'nintendo';       longName: 'Nintendo' ),
      ( id: 162; shortName: 'dataeast';       longName: 'Data East' ),
      ( id: 163; shortName: 'nmk';            longName: 'NMK' ),
      ( id: 164; shortName: 'sammy';          longName: 'Sammy' ),
      ( id: 165; shortName: 'exidy';          longName: 'Exidy' ),
      ( id: 166; shortName: 'acclaim';        longName: 'Acclaim' ),
      ( id: 167; shortName: 'psikyo';         longName: 'Psikyo' ),
      ( id: 169; shortName: 'technos';        longName: 'Technos' ),
      ( id: 170; shortName: 'alg';            longName: 'American Laser Games' ),
      ( id: 173; shortName: 'dynax';          longName: 'Dynax' ),
      ( id: 174; shortName: 'kaneko';         longName: 'Kaneko' ),
      ( id: 175; shortName: 'vsc';            longName: 'Video System Co.' ),
      ( id: 176; shortName: 'igs';            longName: 'IGS' ),
      ( id: 177; shortName: 'comad';          longName: 'Comad' ),
      ( id: 178; shortName: 'amcoe';          longName: 'Amcoe' ),
      ( id: 179; shortName: 'centurye';       longName: 'Century Electronics' ),
      ( id: 180; shortName: 'nichibutsu';     longName: 'Nichibutsu' ),
      ( id: 181; shortName: 'visco';          longName: 'Visco' ),
      ( id: 182; shortName: 'alphadenshi';    longName: 'Alpha Denshi Co.' ),
      ( id: 183; shortName: 'coleco';         longName: 'Coleco' ),
      ( id: 184; shortName: 'playchoice';     longName: 'PlayChoice' ),
      ( id: 185; shortName: 'atlus';          longName: 'Atlus' ),
      ( id: 186; shortName: 'banpresto';      longName: 'Banpresto' ),
      ( id: 187; shortName: 'semicom';        longName: 'SemiCom' ),
      ( id: 188; shortName: 'universal';      longName: 'Universal' ),
      ( id: 189; shortName: 'mitchell';       longName: 'Mitchell' ),
      ( id: 190; shortName: 'seibukaihatsu';  longName: 'Seibu Kaihatsu' ),
      ( id: 191; shortName: 'toaplan';        longName: 'Toaplan' ),
      ( id: 192; shortName: 'cinematronics';  longName: 'Cinematronics' ),
      ( id: 193; shortName: 'incredibletech'; longName: 'Incredible Technologies' ),
      ( id: 194; shortName: 'gaelco';         longName: 'Gaelco' ),
      ( id: 195; shortName: 'megatech';       longName: 'Mega-Tech' ),
      ( id: 196; shortName: 'megaplay';       longName: 'Mega-Play' ),
      ( id: 209; shortName: 'gottlieb';       longName: 'Gottlieb' ) );

   cstEntries: array[0..21] of TLangEntry = (
      ( tokens: 'usa,us,u';                        lang: 'en'; region: 'us' ),
      ( tokens: 'europe,eu,e,ue,euro';             lang: '';   region: 'eu' ),
      ( tokens: 'w,wor,world';                     lang: 'en'; region: 'wr' ),
      ( tokens: 'uk,gb';                           lang: 'en'; region: 'eu' ),
      ( tokens: 'es,spain,s';                      lang: 'es'; region: 'eu' ),
      ( tokens: 'fr,france,fre,french,f';          lang: 'fr'; region: 'eu' ),
      ( tokens: 'de,germany,d';                    lang: 'de'; region: 'eu' ),
      ( tokens: 'it,italy,i';                      lang: 'it'; region: 'eu' ),
      ( tokens: 'nl,netherlands';                  lang: 'nl'; region: 'eu' ),
      ( tokens: 'gr,greece';                       lang: 'gr'; region: 'eu' ),
      ( tokens: 'no';                              lang: 'no'; region: 'eu' ),
      ( tokens: 'sw,sweden,se';                    lang: 'sw'; region: 'eu' ),
      ( tokens: 'pt,portugal';                     lang: 'pt'; region: 'eu' ),
      ( tokens: 'pl,poland';                       lang: 'pl'; region: 'eu' ),
      ( tokens: 'en';                              lang: 'en'; region: '' ),
      ( tokens: 'jp,japan,ja,j';                   lang: 'jp'; region: 'jp' ),
      ( tokens: 'br,brazil';                       lang: 'br'; region: 'br' ),
      ( tokens: 'ru,r';                            lang: 'ru'; region: 'ru' ),
      ( tokens: 'kr,korea,k';                      lang: 'kr'; region: 'kr' ),
      ( tokens: 'cn,china,hong,kong,ch,hk,as,tw';  lang: 'cn'; region: 'cn' ),
      ( tokens: 'canada,ca,c,fc';                  lang: 'fr'; region: 'wr' ),
      ( tokens: 'in,india';                        lang: 'in'; region: 'in' ) );

   cstJapanDefaults = 'pc88|pc98|pcenginecd|pcfx|satellaview|sg1000|sufami|wswan|wswanc|x68000';

   cNoExtractSystems: TArray<string> =
      [ 'arcade',
        'mame',
        'fbneo',
        'neogeo',
        'daphne',
        'lutro',
        'dreamcast',
        'atomiswave',
        'naomi' ];

implementation

end.
