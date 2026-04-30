object frmGamelistDetails: TfrmGamelistDetails
  Left = 0
  Top = 0
  Caption = 'Gamelist Details'
  ClientHeight = 600
  ClientWidth = 900
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 900
    Height = 35
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object lblSystem: TLabel
      Left = 8
      Top = 10
      Width = 44
      Height = 15
      Caption = 'System :'
    end
    object lblStats: TLabel
      Left = 266
      Top = 9
      Width = 38
      Height = 15
      Caption = 'lblStats'
    end
    object cbxSystems: TComboBox
      Left = 60
      Top = 6
      Width = 200
      Height = 23
      Style = csDropDownList
      TabOrder = 0
      OnChange = cbxSystemsChange
    end
    object btnVerifyHashes: TButton
      Left = 266
      Top = 5
      Width = 93
      Height = 25
      Caption = 'Verify Hashes'
      TabOrder = 1
      Visible = False
      OnClick = btnVerifyHashesClick
    end
  end
  object pgcMain: TPageControl
    Left = 0
    Top = 35
    Width = 900
    Height = 565
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
      object lvwMissingRoms: TListView
        Left = 0
        Top = 0
        Width = 892
        Height = 535
        Align = alClient
        Color = 4210752
        Columns = <
          item
            Caption = 'System'
            Width = 120
          end
          item
            Caption = 'Game'
            Width = 200
          end
          item
            Caption = 'Expected path'
            Width = 400
          end>
        GroupView = True
        ReadOnly = True
        RowSelect = True
        ParentShowHint = False
        PopupMenu = popActions
        ShowHint = False
        TabOrder = 0
        ViewStyle = vsReport
        OnContextPopup = lvContextPopup
        OnMouseMove = lvMouseMove
      end
    end
    object tbsUnscraped: TTabSheet
      Hint = 'ROM files present on disk but not referenced in the gamelist'
      Caption = 'Unscraped'
      ParentShowHint = False
      ShowHint = False
      object lvwUnscraped: TListView
        Left = 0
        Top = 0
        Width = 892
        Height = 535
        Align = alClient
        Color = 4210752
        Columns = <
          item
            Caption = 'System'
            Width = 120
          end
          item
            Caption = 'ROM file'
            Width = 500
          end>
        GroupView = True
        ReadOnly = True
        RowSelect = True
        ParentShowHint = False
        PopupMenu = popActions
        ShowHint = False
        TabOrder = 0
        ViewStyle = vsReport
        OnContextPopup = lvContextPopup
        OnMouseMove = lvMouseMove
      end
    end
    object tbsMissingMedias: TTabSheet
      Caption = 'Missing medias'
      ParentShowHint = False
      ShowHint = False
      object lvwMissingMedias: TListView
        Left = 0
        Top = 0
        Width = 892
        Height = 535
        Align = alClient
        Color = 4210752
        Columns = <
          item
            Caption = 'System'
            Width = 120
          end
          item
            Caption = 'Game'
            Width = 200
          end
          item
            Caption = 'Media type'
            Width = 100
          end
          item
            Caption = 'Expected path'
            Width = 400
          end>
        GroupView = True
        ReadOnly = True
        RowSelect = True
        ParentShowHint = False
        PopupMenu = popActions
        ShowHint = False
        TabOrder = 0
        ViewStyle = vsReport
        OnContextPopup = lvContextPopup
        OnMouseMove = lvMouseMove
      end
    end
    object tbsNoMedia: TTabSheet
      Caption = 'No media'
      ImageIndex = 4
      ParentShowHint = False
      ShowHint = False
      object lvwNoMedia: TListView
        Left = 0
        Top = 0
        Width = 892
        Height = 535
        Align = alClient
        Color = 4210752
        Columns = <
          item
            Caption = 'System'
            Width = 120
          end
          item
            Caption = 'Game'
            Width = 600
          end
          item
            Caption = 'ROM Path'
          end>
        GroupView = True
        ReadOnly = True
        RowSelect = True
        ParentShowHint = False
        PopupMenu = popActions
        ShowHint = False
        TabOrder = 0
        ViewStyle = vsReport
        OnContextPopup = lvContextPopup
        OnMouseMove = lvMouseMove
      end
    end
    object tbsOrphans: TTabSheet
      Caption = 'Orphans'
      ParentShowHint = False
      ShowHint = False
      object lvwOrphans: TListView
        Left = 0
        Top = 0
        Width = 892
        Height = 535
        Align = alClient
        Color = 4210752
        Columns = <
          item
            Caption = 'System'
            Width = 120
          end
          item
            Caption = 'File path'
            Width = 600
          end>
        GroupView = True
        ReadOnly = True
        RowSelect = True
        ParentShowHint = False
        PopupMenu = popActions
        ShowHint = False
        TabOrder = 0
        ViewStyle = vsReport
        OnContextPopup = lvContextPopup
        OnMouseMove = lvMouseMove
      end
    end
    object tbsHashMismatch: TTabSheet
      Caption = 'Hash mismatches'
      ImageIndex = 5
      TabVisible = False
      object lvwHashMismatch: TListView
        Left = 0
        Top = 0
        Width = 892
        Height = 535
        Align = alClient
        Color = 4210752
        Columns = <
          item
            Caption = 'System'
            Width = 120
          end
          item
            Caption = 'Game'
            Width = 600
          end
          item
            Caption = 'File'
          end
          item
            Caption = 'Expected'
          end
          item
            Caption = 'Actual'
          end
          item
            Caption = 'Type'
          end>
        ReadOnly = True
        RowSelect = True
        ParentShowHint = False
        PopupMenu = popActions
        ShowHint = False
        TabOrder = 0
        ViewStyle = vsReport
        OnContextPopup = lvContextPopup
        OnMouseMove = lvMouseMove
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
      Caption = 'Delete orphan'
      OnClick = mniDeleteOrphanClick
    end
    object mniAddMissingMedia: TMenuItem
      Caption = 'Add media'
      OnClick = mniAddMissingMediaClick
    end
  end
end
