unit Constantes;

interface

uses
   Vcl.Graphics,
   Types;

resourcestring
   rstBiosScanSummary = 'Total: %d | OK: %d | Present: %d | MD5 mismatch: %d | Missing: %d | Partial: %d';
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
   rstBiosMD5Mismatch = '⚠ MD5 mismatch';
   rstBiosMissing = '❌ Missing';
   rstBiosPartial = '⚠️Partial (missing a file)';
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
   rstApiDisabledOrUnavailable = 'Retrobat is not running or API is not enabled';
   rstFilenotFound = 'File not found: ';
   rstUnsupportedMediatype = 'Unsupported media type: ';

const
   {$INCLUDE 'screenscraper_credentials.inc'}

   cstMargin = 5;
   cstMainFormHeight = 350;

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

   // ES settings
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
   cstEsPublicApiKey     = 'PublicWebAccess';
   cstDefaultRegion      = 'us';
   cstDefaultImageSrc    = cstSSMediaSs;
   cstDefaultLogoSrc     = cstSSMediaLogo;
   cstDefaultThumbSrc    = cstSSMediaBox2D;
   cstThumbFileSuffix    = 'thumb';

   cstGreen = $7FFF00;
   cstYellow = $00D7FF;
   cstOrange = $4763FF;
   cstRed = $3C14DC;

   // ES Web API
   cstESApiDefaultHost  = 'retrobat';
   cstESApiLocalHost    = '127.0.0.1';
   cstESApiPort         = '1234';
   cstESApiCaps         = '/caps';
   cstESApiReloadGames  = '/reloadgames';
   cstESApiRunningGame  = '/runningGame';
   cstESApiIsIdle       = '/isIdle';
   cstESApiSystems      = '/systems';
   cstESApiLaunch       = '/launch';
   cstESApiMessageBox   = '/messagebox';
   cstESApiNotify       = '/notify';
   cstESApiQuit         = '/quit';
   cstESApiRestart      = '/restart';
   cstESApiEmuKill      = '/emukill';
   cstESApiAddGames     = '/addgames';
   cstESApiRemoveGames  = '/removegames';

   cstExcludedRomExtensions: TArray<string> = ['.xml', '.ini', '.m3u', '.txt', '.dat', '.cfg', '.log', '.pak'];

   cstBiosAlternativePaths: array[0..2] of TBiosAlternativePath =
      ( ( systemKey: 'neogeo'; fileName: 'neogeo.zip'; altRelPath: 'roms\neogeo\neogeo.zip' ),
        ( systemKey: 'naomi'; fileName: 'naomi.zip'; altRelPath: 'emulators\flycast\data\naomi.zip' ),
        ( systemKey: 'naomi2'; fileName: 'naomi2.zip'; altRelPath: 'emulators\flycast\data\naomi2.zip' ) );

   cstBiosStatusColors: array[TBiosStatus] of TColor = (
      cstGreen,
      cstYellow,
      clWhite,
      cstRed,
      cstOrange
   );

   cstBiosStatusStrings: array[TBiosStatus] of string = (
      rstBiosOK,
      rstBiosMD5Mismatch,
      rstBiosPresentNoHash,
      rstBiosMissing,
      rstBiosPartial
   );

   cstValidFolderColors: array[tValidFolder] of TColor =
      ( clGray,
        cstGreen,
        cstRed );

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

   cstShortToFullSystemName: array[0..237] of record
      shortName: string;
      fullName: string;
   end = (
      (shortName: '2ship'; fullName: '2 Ship 2 Harkinian'),
      (shortName: '3do'; fullName: 'Panasonic 3DO'),
      (shortName: '3ds'; fullName: 'Nintendo 3DS'),
      (shortName: 'actionmax'; fullName: 'Action Max'),
      (shortName: 'adam'; fullName: 'Coleco Adam'),
      (shortName: 'advision'; fullName: 'Entex Adventure Vision'),
      (shortName: 'amazon'; fullName: 'Amazon Games'),
      (shortName: 'amiga1200'; fullName: 'Commodore Amiga 1200'),
      (shortName: 'amiga4000'; fullName: 'Commodore Amiga 4000'),
      (shortName: 'amiga500'; fullName: 'Commodore Amiga 500'),
      (shortName: 'amigacd32'; fullName: 'Commodore Amiga CD32'),
      (shortName: 'amigacdtv'; fullName: 'Commodore Amiga CDTV'),
      (shortName: 'amstradcpc'; fullName: 'Amstrad CPC'),
      (shortName: 'apfm1000'; fullName: 'APF-M1000'),
      (shortName: 'apple2'; fullName: 'Apple II'),
      (shortName: 'apple2gs'; fullName: 'Apple IIGS'),
      (shortName: 'aquarius'; fullName: 'Mattel Aquarius'),
      (shortName: 'arcadia'; fullName: 'Emerson Arcadia 2001'),
      (shortName: 'archimedes'; fullName: 'Acorn Archimedes'),
      (shortName: 'arduboy'; fullName: 'Arduboy'),
      (shortName: 'astrocade'; fullName: 'Bally Astrocade'),
      (shortName: 'atari2600'; fullName: 'Atari 2600'),
      (shortName: 'atari5200'; fullName: 'Atari 5200'),
      (shortName: 'atari7800'; fullName: 'Atari 7800'),
      (shortName: 'atari800'; fullName: 'Atari 8-bit'),
      (shortName: 'atarist'; fullName: 'Atari ST'),
      (shortName: 'atom'; fullName: 'Acorn Atom'),
      (shortName: 'atomiswave'; fullName: 'Sammy Atomiswave'),
      (shortName: 'bbcmicro'; fullName: 'BBC Micro'),
      (shortName: 'bennugd'; fullName: 'BennuGD'),
      (shortName: 'bk'; fullName: 'Elektronika BK'),
      (shortName: 'bstone'; fullName: 'Blake Stone'),
      (shortName: 'bsyndrome'; fullName: 'Blues Brothers Syndrome'),
      (shortName: 'c128'; fullName: 'Commodore 128'),
      (shortName: 'c16'; fullName: 'Commodore 16'),
      (shortName: 'c20'; fullName: 'Commodore VIC-20'),
      (shortName: 'c64'; fullName: 'Commodore 64'),
      (shortName: 'camplynx'; fullName: 'Camputers Lynx'),
      (shortName: 'cannonball'; fullName: 'OutRun Cannonball'),
      (shortName: 'cassettevision'; fullName: 'Epoch Cassette Vision'),
      (shortName: 'cave'; fullName: 'Cave Story Engine'),
      (shortName: 'cavestory'; fullName: 'Cave Story'),
      (shortName: 'cdi'; fullName: 'Philips CD-i'),
      (shortName: 'cdogs'; fullName: 'C-Dogs SDL'),
      (shortName: 'cgenius'; fullName: 'Commander Genius'),
      (shortName: 'channelf'; fullName: 'Fairchild Channel F'),
      (shortName: 'chihiro'; fullName: 'Sega Chihiro'),
      (shortName: 'coco'; fullName: 'Tandy Color Computer'),
      (shortName: 'colecovision'; fullName: 'ColecoVision'),
      (shortName: 'corsixth'; fullName: 'CorsixTH'),
      (shortName: 'cplus4'; fullName: 'Commodore Plus/4'),
      (shortName: 'cps1'; fullName: 'Capcom Play System I'),
      (shortName: 'cps2'; fullName: 'Capcom Play System II'),
      (shortName: 'cps3'; fullName: 'Capcom Play System III'),
      (shortName: 'crvision'; fullName: 'CreatiVision'),
      (shortName: 'daphne'; fullName: 'Daphne Laserdisc'),
      (shortName: 'devilutionx'; fullName: 'Diablo / DevilutionX'),
      (shortName: 'dice'; fullName: 'DICE Engine'),
      (shortName: 'dinothawr'; fullName: 'Dinothawr'),
      (shortName: 'doom3'; fullName: 'DOOM 3'),
      (shortName: 'dos'; fullName: 'MS-DOS'),
      (shortName: 'dragon32'; fullName: 'Dragon 32'),
      (shortName: 'dreamcast'; fullName: 'Sega Dreamcast'),
      (shortName: 'eagames'; fullName: 'Electronic Arts Games'),
      (shortName: 'easyrpg'; fullName: 'EasyRPG'),
      (shortName: 'ecwolf'; fullName: 'ECWolf'),
      (shortName: 'eduke32'; fullName: 'EDuke32'),
      (shortName: 'electron'; fullName: 'Acorn Electron'),
      (shortName: 'enterprise'; fullName: 'Enterprise 128'),
      (shortName: 'epic'; fullName: 'Epic Games'),
      (shortName: 'exodos'; fullName: 'eXoDOS'),
      (shortName: 'exowin3x'; fullName: 'eXoWin3x'),
      (shortName: 'exowin9x'; fullName: 'eXoWin9x'),
      (shortName: 'fbneo'; fullName: 'FinalBurn Neo'),
      (shortName: 'fds'; fullName: 'Famicom Disk System'),
      (shortName: 'flash'; fullName: 'Adobe Flash'),
      (shortName: 'fm7'; fullName: 'Fujitsu FM-7'),
      (shortName: 'fmtowns'; fullName: 'Fujitsu FM Towns'),
      (shortName: 'fpinball'; fullName: 'Future Pinball'),
      (shortName: 'gaelco'; fullName: 'Gaelco Arcade'),
      (shortName: 'gamate'; fullName: 'Bit Corporation Gamate'),
      (shortName: 'gameandwatch'; fullName: 'Nintendo Game & Watch'),
      (shortName: 'gamecom'; fullName: 'Tiger Game.com'),
      (shortName: 'gamecube'; fullName: 'Nintendo GameCube'),
      (shortName: 'gamegear'; fullName: 'Sega Game Gear'),
      (shortName: 'gamepock'; fullName: 'Epoch Game Pocket Computer'),
      (shortName: 'gb'; fullName: 'Nintendo Game Boy'),
      (shortName: 'gb2players'; fullName: 'Nintendo Game Boy 2 Players'),
      (shortName: 'gba'; fullName: 'Nintendo Game Boy Advance'),
      (shortName: 'gba2players'; fullName: 'Nintendo Game Boy Advance 2 Players'),
      (shortName: 'gbc'; fullName: 'Nintendo Game Boy Color'),
      (shortName: 'gbc2players'; fullName: 'Nintendo Game Boy Color 2 Players'),
      (shortName: 'gemrb'; fullName: 'GemRB'),
      (shortName: 'ghostship'; fullName: 'Ghostship Engine'),
      (shortName: 'gmaster'; fullName: 'Hartung Game Master'),
      (shortName: 'gog'; fullName: 'GOG'),
      (shortName: 'gp32'; fullName: 'GamePark GP32'),
      (shortName: 'gx4000'; fullName: 'Amstrad GX4000'),
      (shortName: 'gzdoom'; fullName: 'GZDoom'),
      (shortName: 'halflife'; fullName: 'Half-Life'),
      (shortName: 'hbmame'; fullName: 'HBMAME'),
      (shortName: 'hikaru'; fullName: 'Sega Hikaru'),
      (shortName: 'ikemen'; fullName: 'Ikemen GO'),
      (shortName: 'intellivision'; fullName: 'Mattel Intellivision'),
      (shortName: 'j2me'; fullName: 'Java 2 Micro Edition'),
      (shortName: 'jaguar'; fullName: 'Atari Jaguar'),
      (shortName: 'jaguarcd'; fullName: 'Atari Jaguar CD'),
      (shortName: 'karaoke'; fullName: 'Karaoke'),
      (shortName: 'laseractive'; fullName: 'Pioneer LaserActive'),
      (shortName: 'lcdgames'; fullName: 'LCD Handheld Games'),
      (shortName: 'loopy'; fullName: 'Casio Loopy'),
      (shortName: 'love'; fullName: 'LÖVE'),
      (shortName: 'lowresnx'; fullName: 'LowRes NX'),
      (shortName: 'lutro'; fullName: 'Lutro'),
      (shortName: 'lynx'; fullName: 'Atari Lynx'),
      (shortName: 'mame'; fullName: 'Multiple Arcade Machine Emulator'),
      (shortName: 'mastersystem'; fullName: 'Sega Master System'),
      (shortName: 'megacd'; fullName: 'Sega Mega-CD'),
      (shortName: 'megadrive'; fullName: 'Sega Mega Drive'),
      (shortName: 'megadrive-msu'; fullName: 'Sega Mega Drive MSU'),
      (shortName: 'megaduck'; fullName: 'Mega Duck'),
      (shortName: 'model2'; fullName: 'Sega Model 2'),
      (shortName: 'model3'; fullName: 'Sega Model 3'),
      (shortName: 'msx1'; fullName: 'MSX'),
      (shortName: 'msx2'; fullName: 'MSX2'),
      (shortName: 'msx2+'; fullName: 'MSX2+'),
      (shortName: 'msxturbor'; fullName: 'MSX Turbo R'),
      (shortName: 'mugen'; fullName: 'M.U.G.E.N'),
      (shortName: 'multivision'; fullName: 'Othello Multivision'),
      (shortName: 'n64'; fullName: 'Nintendo 64'),
      (shortName: 'n64dd'; fullName: 'Nintendo 64DD'),
      (shortName: 'namco2x6'; fullName: 'Namco System 246'),
      (shortName: 'namco3xx'; fullName: 'Namco System 357'),
      (shortName: 'naomi'; fullName: 'Sega NAOMI'),
      (shortName: 'naomi2'; fullName: 'Sega NAOMI 2'),
      (shortName: 'nds'; fullName: 'Nintendo DS'),
      (shortName: 'neogeo'; fullName: 'SNK Neo Geo'),
      (shortName: 'neogeo64'; fullName: 'SNK Neo Geo 64'),
      (shortName: 'neogeocd'; fullName: 'SNK Neo Geo CD'),
      (shortName: 'nes'; fullName: 'Nintendo Entertainment System'),
      (shortName: 'ngage'; fullName: 'Nokia N-Gage'),
      (shortName: 'ngp'; fullName: 'Neo Geo Pocket'),
      (shortName: 'ngpc'; fullName: 'Neo Geo Pocket Color'),
      (shortName: 'odyssey2'; fullName: 'Magnavox Odyssey²'),
      (shortName: 'openbor'; fullName: 'OpenBOR'),
      (shortName: 'opengoal'; fullName: 'OpenGOAL'),
      (shortName: 'openjazz'; fullName: 'OpenJazz'),
      (shortName: 'openlara'; fullName: 'OpenLara'),
      (shortName: 'oricatmos'; fullName: 'Oric Atmos'),
      (shortName: 'p2000t'; fullName: 'Philips P2000T'),
      (shortName: 'pb'; fullName: 'PICO-8 BBS'),
      (shortName: 'pc88'; fullName: 'NEC PC-8801'),
      (shortName: 'pc98'; fullName: 'NEC PC-9801'),
      (shortName: 'pcengine'; fullName: 'NEC PC Engine'),
      (shortName: 'pcenginecd'; fullName: 'NEC PC Engine CD'),
      (shortName: 'pcfx'; fullName: 'NEC PC-FX'),
      (shortName: 'pdark'; fullName: 'Perfect Dark PC Port'),
      (shortName: 'pegasus'; fullName: 'Pegasus Frontend'),
      (shortName: 'pet'; fullName: 'Commodore PET'),
      (shortName: 'pico8'; fullName: 'PICO-8'),
      (shortName: 'pinballfx'; fullName: 'Pinball FX'),
      (shortName: 'pinballfx2'; fullName: 'Pinball FX2'),
      (shortName: 'pinballfx3'; fullName: 'Pinball FX3'),
      (shortName: 'pinballm'; fullName: 'Pinball M'),
      (shortName: 'pokemini'; fullName: 'Pokémon Mini'),
      (shortName: 'ports'; fullName: 'Ports'),
      (shortName: 'prboom'; fullName: 'PrBoom'),
      (shortName: 'ps2'; fullName: 'Sony PlayStation 2'),
      (shortName: 'ps3'; fullName: 'Sony PlayStation 3'),
      (shortName: 'ps4'; fullName: 'Sony PlayStation 4'),
      (shortName: 'psp'; fullName: 'Sony PlayStation Portable'),
      (shortName: 'psvita'; fullName: 'Sony PlayStation Vita'),
      (shortName: 'psx'; fullName: 'Sony PlayStation'),
      (shortName: 'pv1000'; fullName: 'Casio PV-1000'),
      (shortName: 'quake'; fullName: 'Quake'),
      (shortName: 'quake2'; fullName: 'Quake II'),
      (shortName: 'raze'; fullName: 'Raze Engine'),
      (shortName: 'reminiscence'; fullName: 'REminiscence'),
      (shortName: 'rtcw'; fullName: 'Return to Castle Wolfenstein'),
      (shortName: 'samcoupe'; fullName: 'SAM Coupé'),
      (shortName: 'satellaview'; fullName: 'Satellaview'),
      (shortName: 'saturn'; fullName: 'Sega Saturn'),
      (shortName: 'scummvm'; fullName: 'ScummVM'),
      (shortName: 'scv'; fullName: 'Super Cassette Vision'),
      (shortName: 'sega32x'; fullName: 'Sega 32X'),
      (shortName: 'segastv'; fullName: 'Sega ST-V'),
      (shortName: 'sg1000'; fullName: 'Sega SG-1000'),
      (shortName: 'sgb'; fullName: 'Super Game Boy'),
      (shortName: 'sgb-msu1'; fullName: 'Super Game Boy MSU1'),
      (shortName: 'singe'; fullName: 'Singe'),
      (shortName: 'snes'; fullName: 'Super Nintendo Entertainment System'),
      (shortName: 'snes-msu1'; fullName: 'Super Nintendo MSU1'),
      (shortName: 'soh'; fullName: 'Ship of Harkinian'),
      (shortName: 'solarus'; fullName: 'Solarus'),
      (shortName: 'sonic-mania'; fullName: 'Sonic Mania'),
      (shortName: 'sonic3-air'; fullName: 'Sonic 3 A.I.R.'),
      (shortName: 'sonicretro'; fullName: 'Sonic Retro Engine'),
      (shortName: 'spectravideo'; fullName: 'Spectravideo'),
      (shortName: 'starship'; fullName: 'Starship Engine'),
      (shortName: 'steam'; fullName: 'Steam'),
      (shortName: 'sufami'; fullName: 'Sufami Turbo'),
      (shortName: 'superbroswar'; fullName: 'Super Bros War'),
      (shortName: 'supergrafx'; fullName: 'NEC SuperGrafx'),
      (shortName: 'supervision'; fullName: 'Watara Supervision'),
      (shortName: 'supracan'; fullName: 'Funtech Super A''Can'),
      (shortName: 'switch'; fullName: 'Nintendo Switch'),
      (shortName: 'switchupdates'; fullName: 'Nintendo Switch Updates'),
      (shortName: 'teknoparrot'; fullName: 'TeknoParrot'),
      (shortName: 'theforceengine'; fullName: 'The Force Engine'),
      (shortName: 'thomson'; fullName: 'Thomson MO/TO'),
      (shortName: 'ti99'; fullName: 'Texas Instruments TI-99/4A'),
      (shortName: 'tic80'; fullName: 'TIC-80'),
      (shortName: 'triforce'; fullName: 'Triforce Arcade'),
      (shortName: 'tutor'; fullName: 'Tomy Tutor'),
      (shortName: 'tvgames'; fullName: 'TV Games'),
      (shortName: 'uzebox'; fullName: 'Uzebox'),
      (shortName: 'vc4000'; fullName: 'Interton VC 4000'),
      (shortName: 'vectrex'; fullName: 'Vectrex'),
      (shortName: 'vg5k'; fullName: 'Philips VG5000'),
      (shortName: 'vircon32'; fullName: 'Vircon32'),
      (shortName: 'virtualboy'; fullName: 'Nintendo Virtual Boy'),
      (shortName: 'vpinball'; fullName: 'Visual Pinball'),
      (shortName: 'vsmile'; fullName: 'VTech V.Smile'),
      (shortName: 'wasm4'; fullName: 'WASM-4'),
      (shortName: 'wii'; fullName: 'Nintendo Wii'),
      (shortName: 'wiiu'; fullName: 'Nintendo Wii U'),
      (shortName: 'windows'; fullName: 'Windows'),
      (shortName: 'wswan'; fullName: 'WonderSwan'),
      (shortName: 'wswanc'; fullName: 'WonderSwan Color'),
      (shortName: 'x1'; fullName: 'Sharp X1'),
      (shortName: 'x68000'; fullName: 'Sharp X68000'),
      (shortName: 'xbox'; fullName: 'Microsoft Xbox'),
      (shortName: 'xbox360'; fullName: 'Microsoft Xbox 360'),
      (shortName: 'xegs'; fullName: 'Atari XE Game System'),
      (shortName: 'zaccariapinball'; fullName: 'Zaccaria Pinball'),
      (shortName: 'zinc'; fullName: 'ZiNc Arcade'),
      (shortName: 'zx81'; fullName: 'Sinclair ZX81'),
      (shortName: 'zxspectrum'; fullName: 'ZX Spectrum') );

implementation

end.
