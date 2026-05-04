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
   rstSystemStats = 'Games: %d | Scraped: %d | ROMs on disk: %d';
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
   rstReady = 'Ready';
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
   cstXmlN                   = 'n';
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
   cstXmlGameTagOpen         = '<game';
   cstXmlGameTagClose        = '</game>';

   // API ScreenScraper
   cstSSSoftName       = 'RetroFix';
   cstSSBaseUrl        = 'https://www.screenscraper.fr/api2/';
   cstEsSettingsFile   = 'es_settings.cfg';
   cstEsLanguageKey    = 'Language';
   cstDefaultLanguage  = 'en';
   cstSSUserKey        = 'ScreenScraperUser';
   cstSSPasswordKey    = 'ScreenScraperPass';
   cstSSApiSystemes    = 'systemesListe.php';
   cstSSApiUserInfo    = 'ssuserInfos.php';
   cstSSApiGameInfo    = 'jeuInfos.php';
   cstSSNomRecalbox    = 'nom_recalbox';
   cstSSHeader         = 'header';
   cstSSSuccess        = 'success';
   cstSSError          = 'error';
   cstSSResponse       = 'response';
   cstSSSystemes       = 'systemes';
   cstSSNoms           = 'noms';
   cstSSId             = 'id';
   cstSSUser           = 'ssuser';
   cstSSMaxThreads     = 'maxthreads';
   cstSSRequestsToday  = 'requeststoday';
   cstSSMaxRequests    = 'maxrequestsperday';
   cstSSMaxDownload    = 'maxdownloadspeed';
   cstSSJeu            = 'jeu';
   cstSSSynopsis       = 'synopsis';
   cstSSDeveloppeur    = 'developpeur';
   cstSSEditeur        = 'editeur';
   cstSSGenres         = 'genres';
   cstSSJoueurs        = 'joueurs';
   cstSSNote           = 'note';
   cstSSDates          = 'dates';
   cstSSMedias         = 'medias';
   cstSSText           = 'text';
   cstSSRegion         = 'region';
   cstSSLangue         = 'langue';
   cstSSType           = 'type';
   cstSSUrl            = 'url';
   cstSSFormat         = 'format';
   cstSSSystemeId      = '&systemeid=';
   cstSSRomType        = '&romtype=rom';
   cstSSRomNom         = '&romnom=';
   cstSSRomTaille      = '&romtaille=';
   cstSSMd5            = '&md5=';
   cstSSCrc            = '&crc=';
   cstSSRegionWor      = 'wor';
   cstSSJeuIntrouvable = 'Jeu introuvable';
   cstSSNotFound       = 'not found';
   cstSSQuota          = 'quota';

   cstValidFolderColors: array[tValidFolder] of TColor =
      ( clGray, clGreen, clRed );

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

implementation

end.
