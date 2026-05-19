object frmBiosDetails: TfrmBiosDetails
  Left = 0
  Top = 0
  Caption = 'BIOS Details'
  ClientHeight = 601
  ClientWidth = 984
  Color = clBtnFace
  Constraints.MinHeight = 640
  Constraints.MinWidth = 1000
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  WindowState = wsMaximized
  OnCreate = FormCreate
  TextHeight = 15
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 984
    Height = 50
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object rgpGroupMode: TRadioGroup
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 150
      Height = 44
      Align = alLeft
      Caption = 'Group by'
      Columns = 2
      ItemIndex = 0
      Items.Strings = (
        'System'
        'Status')
      TabOrder = 0
      OnClick = rgpGroupModeClick
    end
    object gbxFilters: TGroupBox
      AlignWithMargins = True
      Left = 159
      Top = 3
      Width = 514
      Height = 44
      Align = alLeft
      Caption = 'Filters'
      TabOrder = 1
      object chkFilterOK: TCheckBox
        Left = 14
        Top = 19
        Width = 54
        Height = 17
        Caption = #9989' OK'
        Checked = True
        State = cbChecked
        TabOrder = 0
        OnClick = chkFilterClick
      end
      object chkFilterNoHash: TCheckBox
        Left = 74
        Top = 19
        Width = 132
        Height = 17
        Caption = #10134' Present (no hash)'
        Checked = True
        State = cbChecked
        TabOrder = 1
        OnClick = chkFilterClick
      end
      object chkFilterMismatch: TCheckBox
        Left = 212
        Top = 19
        Width = 122
        Height = 17
        Caption = #9888#65039' MD5 mismatch'
        Checked = True
        State = cbChecked
        TabOrder = 2
        OnClick = chkFilterClick
      end
      object chkFilterMissing: TCheckBox
        Left = 340
        Top = 19
        Width = 82
        Height = 17
        Caption = #10060' Missing'
        Checked = True
        State = cbChecked
        TabOrder = 3
        OnClick = chkFilterClick
      end
      object chkPartial: TCheckBox
        Left = 428
        Top = 19
        Width = 82
        Height = 17
        Caption = #9888#65039' Partial'
        Checked = True
        State = cbChecked
        TabOrder = 4
        OnClick = chkFilterClick
      end
    end
    object gbxActions: TGroupBox
      AlignWithMargins = True
      Left = 679
      Top = 3
      Width = 302
      Height = 44
      Align = alClient
      Caption = 'Actions'
      TabOrder = 2
      DesignSize = (
        302
        44)
      object btnRescan: TButton
        Left = 8
        Top = 15
        Width = 75
        Height = 25
        Caption = 'Rescan'
        TabOrder = 0
        OnClick = btnRescanClick
      end
      object chkRescanForceExtract: TCheckBox
        Left = 89
        Top = 10
        Width = 129
        Height = 17
        Hint = 
          'Force Bios list extraction from batocera-systems.exe'#13#10'if bios.js' +
          'on already exists (useful when Retrobat has been updated)'
        Caption = 'Force extraction'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
      end
      object chkRescanStrictMode: TCheckBox
        Left = 89
        Top = 25
        Width = 129
        Height = 17
        Hint = 
          'Apply only on BIOS with MD5'#13#10'If checked, will be considered miss' +
          'ing if MD5 mismatch'#13#10'Else will just display a mismatch warning'
        Caption = 'Strict mode'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
      end
      object btnExportCSV: TButton
        Left = 205
        Top = 15
        Width = 89
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Export as CSV'
        TabOrder = 3
        OnClick = btnExportCSVClick
      end
    end
  end
  object vstBios: TVirtualStringTree
    Left = 0
    Top = 50
    Width = 984
    Height = 551
    AccessibleName = 'Actual MD5'
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    Colors.TreeLineColor = clNone
    DefaultNodeHeight = 19
    Header.AutoSizeIndex = 3
    Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
    LineMode = lmBands
    LineStyle = lsSolid
    PopupMenu = popupMenu
    TabOrder = 1
    TreeOptions.MiscOptions = [toFullRepaintOnResize]
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toShowRoot, toShowTreeLines, toShowVertGridLines, toThemeAware, toUseBlendedImages, toFullVertGridLines]
    TreeOptions.SelectionOptions = [toFullRowSelect, toRightClickSelect]
    OnFreeNode = vstBiosFreeNode
    OnGetText = vstBiosGetText
    OnPaintText = vstBiosPaintText
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
        Text = 'File'
        Width = 300
      end
      item
        Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coStyleColor]
        Position = 2
        Text = 'Status'
        Width = 200
      end
      item
        Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAutoSpring, coAllowFocus, coStyleColor]
        Position = 3
        Text = 'Full path'
        Width = 482
      end
      item
        Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coStyleColor]
        Position = 4
        Text = 'Expected MD5'
        Width = 200
      end
      item
        Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coStyleColor]
        Position = 5
        Text = 'Actual MD5'
        Width = 200
      end>
  end
  object popupMenu: TPopupMenu
    OnPopup = popupMenuPopup
    Left = 864
    Top = 472
    object mniCopyMD5: TMenuItem
      Caption = 'Copy expected MD5'
      OnClick = mniCopyMD5Click
    end
    object mniOpenFolder: TMenuItem
      Caption = 'Open folder'
      OnClick = mniOpenFolderClick
    end
  end
end
