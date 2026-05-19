object frmGamelistDetails: TfrmGamelistDetails
  Left = 0
  Top = 0
  Caption = 'Gamelist Details'
  ClientHeight = 600
  ClientWidth = 900
  Color = clBtnFace
  Constraints.MinHeight = 639
  Constraints.MinWidth = 916
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  WindowState = wsMaximized
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 900
    Height = 75
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      900
      75)
    object lblSystem: TLabel
      Left = 8
      Top = 10
      Width = 44
      Height = 15
      Caption = 'System :'
    end
    object lblStats: TLabel
      Left = 8
      Top = 39
      Width = 38
      Height = 15
      Caption = 'lblStats'
    end
    object lblScraping: TLabel
      Left = 512
      Top = 39
      Width = 383
      Height = 15
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = 'Scraping...'
      EllipsisPosition = epEndEllipsis
      Visible = False
    end
    object cbxSystems: TComboBox
      Left = 60
      Top = 6
      Width = 200
      Height = 23
      Style = csDropDownList
      DropDownCount = 20
      TabOrder = 0
      OnChange = cbxSystemsChange
    end
    object btnVerifyHashes: TButton
      Left = 8
      Top = 35
      Width = 93
      Height = 25
      Caption = 'Verify Hashes'
      TabOrder = 1
      Visible = False
      OnClick = btnVerifyHashesClick
    end
    object pbScraping: TProgressBar
      AlignWithMargins = True
      Left = 512
      Top = 6
      Width = 383
      Height = 23
      Anchors = [akTop, akRight]
      Style = pbstMarquee
      TabOrder = 2
      Visible = False
    end
    object btnCancelScrape: TButton
      Left = 431
      Top = 5
      Width = 75
      Height = 25
      Caption = 'Cancel'
      TabOrder = 3
      Visible = False
      OnClick = btnCancelScrapeClick
    end
  end
  object pgcMain: TPageControl
    Left = 0
    Top = 75
    Width = 900
    Height = 525
    ActivePage = tbsMissingRoms
    Align = alClient
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    OnMouseMove = pgcMainMouseMove
    object tbsMissingRoms: TTabSheet
      Caption = 'Missing ROMs'
      ParentShowHint = False
      ShowHint = False
      object vstMissingRoms: TVirtualStringTree
        Left = 0
        Top = 0
        Width = 892
        Height = 495
        AccessibleName = 'Actual MD5'
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = bsNone
        Colors.TreeLineColor = clNone
        DefaultNodeHeight = 19
        Header.AutoSizeIndex = -1
        Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
        LineMode = lmBands
        LineStyle = lsSolid
        PopupMenu = popActions
        TabOrder = 0
        TreeOptions.MiscOptions = [toFullRepaintOnResize]
        TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toShowRoot, toShowTreeLines, toShowVertGridLines, toThemeAware, toUseBlendedImages, toFullVertGridLines]
        TreeOptions.SelectionOptions = [toFullRowSelect, toMultiSelect, toRightClickSelect]
        OnFreeNode = vstMissingRomsFreeNode
        OnGetText = vstMissingRomsGetText
        OnPaintText = vstMissingRomsPaintText
        OnMouseMove = vstMouseMove
        Touch.InteractiveGestures = [igPan, igPressAndTap]
        Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
        Columns = <
          item
            Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coStyleColor]
            Position = 0
            Text = 'System'
            Width = 300
          end
          item
            Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coStyleColor]
            Position = 1
            Text = 'Game'
            Width = 300
          end
          item
            Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAutoSpring, coAllowFocus, coStyleColor]
            Position = 2
            Text = 'Expected path'
            Width = 400
          end>
      end
    end
    object tbsUnscraped: TTabSheet
      Hint = 'ROM files present on disk but not referenced in the gamelist'
      Caption = 'Unscraped'
      ParentShowHint = False
      ShowHint = False
      object vstUnscraped: TVirtualStringTree
        Left = 0
        Top = 0
        Width = 892
        Height = 495
        AccessibleName = 'Actual MD5'
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = bsNone
        Colors.TreeLineColor = clNone
        DefaultNodeHeight = 19
        Header.AutoSizeIndex = -1
        Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
        LineMode = lmBands
        LineStyle = lsSolid
        PopupMenu = popActions
        TabOrder = 0
        TreeOptions.MiscOptions = [toFullRepaintOnResize]
        TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toShowRoot, toShowTreeLines, toShowVertGridLines, toThemeAware, toUseBlendedImages, toFullVertGridLines]
        TreeOptions.SelectionOptions = [toFullRowSelect, toMultiSelect, toRightClickSelect]
        OnFreeNode = vstUnscrapedFreeNode
        OnGetText = vstUnscrapedGetText
        OnPaintText = vstUnscrapedPaintText
        OnMouseMove = vstMouseMove
        Touch.InteractiveGestures = [igPan, igPressAndTap]
        Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
        Columns = <
          item
            Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coStyleColor]
            Position = 0
            Text = 'System'
            Width = 300
          end
          item
            Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coStyleColor]
            Position = 1
            Text = 'ROM File'
            Width = 400
          end>
      end
    end
    object tbsMissingMedias: TTabSheet
      Caption = 'Missing medias'
      ParentShowHint = False
      ShowHint = False
      object vstMissingMedias: TVirtualStringTree
        Left = 0
        Top = 0
        Width = 892
        Height = 495
        AccessibleName = 'Actual MD5'
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = bsNone
        Colors.TreeLineColor = clNone
        DefaultNodeHeight = 19
        Header.AutoSizeIndex = -1
        Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
        LineMode = lmBands
        LineStyle = lsSolid
        PopupMenu = popActions
        TabOrder = 0
        TreeOptions.MiscOptions = [toFullRepaintOnResize]
        TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toShowRoot, toShowTreeLines, toShowVertGridLines, toThemeAware, toUseBlendedImages, toFullVertGridLines]
        TreeOptions.SelectionOptions = [toFullRowSelect, toMultiSelect, toRightClickSelect]
        OnFreeNode = vstMissingMediasFreeNode
        OnGetText = vstMissingMediasGetText
        OnPaintText = vstMissingMediasPaintText
        OnMouseMove = vstMouseMove
        Touch.InteractiveGestures = [igPan, igPressAndTap]
        Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
        Columns = <
          item
            Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coStyleColor]
            Position = 0
            Text = 'System'
            Width = 300
          end
          item
            Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coStyleColor]
            Position = 1
            Text = 'Game'
            Width = 300
          end
          item
            Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coStyleColor]
            Position = 2
            Text = 'Media type'
            Width = 100
          end
          item
            Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coStyleColor]
            Position = 3
            Text = 'Expected path'
            Width = 400
          end>
      end
    end
    object tbsNoMedia: TTabSheet
      Caption = 'No media'
      ImageIndex = 4
      ParentShowHint = False
      ShowHint = False
      object vstNoMedia: TVirtualStringTree
        Left = 0
        Top = 0
        Width = 892
        Height = 495
        AccessibleName = 'Actual MD5'
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = bsNone
        Colors.TreeLineColor = clNone
        DefaultNodeHeight = 19
        Header.AutoSizeIndex = -1
        Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
        LineMode = lmBands
        LineStyle = lsSolid
        PopupMenu = popActions
        TabOrder = 0
        TreeOptions.MiscOptions = [toFullRepaintOnResize]
        TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toShowRoot, toShowTreeLines, toShowVertGridLines, toThemeAware, toUseBlendedImages, toFullVertGridLines]
        TreeOptions.SelectionOptions = [toFullRowSelect, toMultiSelect, toRightClickSelect]
        OnFreeNode = vstNoMediaFreeNode
        OnGetText = vstNoMediaGetText
        OnPaintText = vstNoMediaPaintText
        OnMouseMove = vstMouseMove
        Touch.InteractiveGestures = [igPan, igPressAndTap]
        Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
        Columns = <
          item
            Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coStyleColor]
            Position = 0
            Text = 'System'
            Width = 300
          end
          item
            Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coStyleColor]
            Position = 1
            Text = 'Game'
            Width = 400
          end
          item
            Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coStyleColor]
            Position = 2
            Text = 'ROM Path'
            Width = 400
          end>
      end
    end
    object tbsOrphans: TTabSheet
      Caption = 'Orphans'
      ParentShowHint = False
      ShowHint = False
      object vstOrphans: TVirtualStringTree
        Left = 0
        Top = 0
        Width = 892
        Height = 495
        AccessibleName = 'Actual MD5'
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = bsNone
        Colors.TreeLineColor = clNone
        DefaultNodeHeight = 19
        Header.AutoSizeIndex = -1
        Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
        LineMode = lmBands
        LineStyle = lsSolid
        PopupMenu = popActions
        TabOrder = 0
        TreeOptions.MiscOptions = [toFullRepaintOnResize]
        TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toShowRoot, toShowTreeLines, toShowVertGridLines, toThemeAware, toUseBlendedImages, toFullVertGridLines]
        TreeOptions.SelectionOptions = [toFullRowSelect, toMultiSelect, toRightClickSelect]
        OnFreeNode = vstOrphansFreeNode
        OnGetText = vstOrphansGetText
        OnPaintText = vstOrphansPaintText
        OnMouseMove = vstMouseMove
        Touch.InteractiveGestures = [igPan, igPressAndTap]
        Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
        Columns = <
          item
            Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coStyleColor]
            Position = 0
            Text = 'System'
            Width = 300
          end
          item
            Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coStyleColor]
            Position = 1
            Text = 'File path'
            Width = 400
          end>
      end
    end
    object tbsHashMismatch: TTabSheet
      Caption = 'Hash mismatches'
      ImageIndex = 5
      TabVisible = False
      object vstHashMismatch: TVirtualStringTree
        Left = 0
        Top = 0
        Width = 892
        Height = 495
        AccessibleName = 'Actual MD5'
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = bsNone
        Colors.TreeLineColor = clNone
        DefaultNodeHeight = 19
        Header.AutoSizeIndex = -1
        Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
        LineMode = lmBands
        LineStyle = lsSolid
        PopupMenu = popActions
        TabOrder = 0
        TreeOptions.MiscOptions = [toFullRepaintOnResize]
        TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toShowRoot, toShowTreeLines, toShowVertGridLines, toThemeAware, toUseBlendedImages, toFullVertGridLines]
        TreeOptions.SelectionOptions = [toFullRowSelect, toMultiSelect, toRightClickSelect]
        OnFreeNode = vstMissingMediasFreeNode
        OnGetText = vstMissingMediasGetText
        OnPaintText = vstMissingMediasPaintText
        OnMouseMove = vstMouseMove
        Touch.InteractiveGestures = [igPan, igPressAndTap]
        Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
        Columns = <
          item
            Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coStyleColor]
            Position = 0
            Text = 'System'
            Width = 200
          end
          item
            Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coStyleColor]
            Position = 1
            Text = 'Game'
            Width = 300
          end
          item
            Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coStyleColor]
            Position = 2
            Text = 'File'
            Width = 300
          end
          item
            Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coStyleColor]
            Position = 3
            Text = 'Expected'
            Width = 200
          end
          item
            Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coStyleColor]
            Position = 4
            Text = 'Actual'
            Width = 200
          end
          item
            Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coStyleColor]
            Position = 5
            Text = 'Type'
            Width = 100
          end>
      end
    end
  end
  object popActions: TPopupMenu
    OnPopup = popActionsPopup
    Left = 800
    Top = 496
    object mniOpenFolder: TMenuItem
      Caption = 'Open folder'
      OnClick = mniOpenFolderClick
    end
    object mniDeleteOrphan: TMenuItem
      Caption = 'Delete orphan(s)'
      OnClick = mniDeleteOrphanClick
    end
    object mniAddMissingMedia: TMenuItem
      Caption = 'Add media from disk'
      OnClick = mniAddMissingMediaClick
    end
    object mniCopyExpectedHash: TMenuItem
      Caption = 'Copy expected hash'
      OnClick = mniCopyExpectedHashClick
    end
    object mniScrapeGame: TMenuItem
      Caption = 'Scrape game(s)'
      OnClick = mniScrapeGameClick
    end
    object mniScrapeMedias: TMenuItem
      Caption = 'Scrape media(s)'
      OnClick = mniScrapeMediasClick
    end
    object mniDeleteMissingROM: TMenuItem
      Caption = 'Remove from Gamelist'
      OnClick = mniDeleteMissingROMClick
    end
  end
end
