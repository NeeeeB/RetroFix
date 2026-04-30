unit Types;

interface

type
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

   TSettings = class
   public
      retrobatPath: string;
      strictMode: Boolean;
      forceExtract: Boolean;
   end;

   TGameMedia = record
      mediaType: TMediaType;
      path: string;
      exists: Boolean;
   end;

   TGameEntry = record
      id: string;
      name: string;
      romPath: string;
      md5: string;
      crc32: string;
      medias: TArray<TGameMedia>;
      isScraped: Boolean;
   end;

   TGamelistResult = class
      systemName: string;
      romDir: string;
      totalRoms: Integer;
      games: TArray<TGameEntry>;
      missingROMs: TArray<string>;
      unscrapedROMs: TArray<string>;
      orphanMedias: TArray<string>;
      missingMedias: TArray<string>
   end;

   TGameEntryRef = class
   public
      systemName: string;
      gameName: string;
      romPath: string;
      mediaPath: string;
      gamelistResult: TGameListResult;
   end;

   TScanOptions = record
      forceExtract: Boolean;
      strictMode: Boolean;
   end;

   TRescanEvent = procedure( Sender: TObject; const aOptions: TScanOptions ) of object;

   TBiosStatus = (
      bsOK,               // Présent + MD5 correct
      bsMD5Mismatch,      // Présent + MD5 incorrect (warning ou erreur selon mode strict)
      bsPresentNoHash,    // Présent + pas de MD5 à vérifier
      bsMissing );        // Absent

   TBiosFileEntry = record
      fileName: string;  // ex: "scph5501.bin"
      subPath: string;  // ex: "" ou "kronos" ou "mame\hash"
      MD5: string;  // vide = pas de hash disponible
   end;

   TBiosSystemEntry = record
      systemKey: string;  // ex: "psx"
      systemName: string;  // ex: "PlayStation"
      files: TArray<TBiosFileEntry>;
   end;

   TBiosResult = record
      systemKey: string;
      systemName: string;
      fileName: string;
      fullPath: string;
      status: TBiosStatus;
      expectedMD5: string;
      actualMD5: string;
   end;

   TBiosSummary = record
      total: Integer;
      ok: Integer;
      presentNoHash: Integer;
      md5Mismatch: Integer;
      missing: Integer;
   end;

   TGamelistSummary = record
      totalSystems: Integer;
      totalGames: Integer;
      totalScraped: Integer;
      totalMissingROMs: Integer;
      totalUnscraped: Integer;
      totalMissingMedias: Integer;
      totalOrphanMedias: Integer;
      totalNoMedia: Integer;
   end;

implementation

end.
