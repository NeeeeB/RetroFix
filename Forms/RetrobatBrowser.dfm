object frmRetrobatBrowser: TfrmRetrobatBrowser
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Retrobat Browser'
  ClientHeight = 790
  ClientWidth = 900
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 15
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 900
    Height = 35
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblBreadcrumb: TLabel
      Left = 10
      Top = 10
      Width = 46
      Height = 15
      Caption = 'Systems'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btnBack: TButton
      Left = 10
      Top = 5
      Width = 75
      Height = 25
      Caption = '< Back'
      TabOrder = 0
      Visible = False
      OnClick = btnBackClick
    end
  end
  object ControlList1: TControlList
    Left = 0
    Top = 35
    Width = 900
    Height = 755
    Align = alClient
    ItemHeight = 250
    ItemMargins.Left = 0
    ItemMargins.Top = 0
    ItemMargins.Right = 0
    ItemMargins.Bottom = 0
    ParentColor = False
    TabOrder = 1
    OnBeforeDrawItem = ControlList1BeforeDrawItem
    ExplicitHeight = 565
    object imgCol0: TImage
      Left = 15
      Top = 10
      Width = 190
      Height = 190
      Center = True
      Proportional = True
      Stretch = True
      OnClick = OnGameClick
    end
    object lblCol0: TLabel
      Left = 15
      Top = 205
      Width = 190
      Height = 30
      Alignment = taCenter
      AutoSize = False
      Caption = 'Game 0'
      WordWrap = True
      OnClick = OnGameClick
    end
    object imgCol1: TImage
      Tag = 1
      Left = 235
      Top = 10
      Width = 190
      Height = 190
      Center = True
      Proportional = True
      Stretch = True
      OnClick = OnGameClick
    end
    object lblCol1: TLabel
      Tag = 1
      Left = 235
      Top = 205
      Width = 190
      Height = 30
      Alignment = taCenter
      AutoSize = False
      Caption = 'Game 1'
      WordWrap = True
      OnClick = OnGameClick
    end
    object imgCol2: TImage
      Tag = 2
      Left = 455
      Top = 10
      Width = 190
      Height = 190
      Center = True
      Proportional = True
      Stretch = True
      OnClick = OnGameClick
    end
    object lblCol2: TLabel
      Tag = 2
      Left = 455
      Top = 205
      Width = 190
      Height = 30
      Alignment = taCenter
      AutoSize = False
      Caption = 'Game 2'
      WordWrap = True
      OnClick = OnGameClick
    end
    object imgCol3: TImage
      Tag = 3
      Left = 675
      Top = 10
      Width = 190
      Height = 190
      Center = True
      Proportional = True
      Stretch = True
      OnClick = OnGameClick
    end
    object lblCol3: TLabel
      Tag = 3
      Left = 675
      Top = 205
      Width = 190
      Height = 30
      Alignment = taCenter
      AutoSize = False
      Caption = 'Game 3'
      WordWrap = True
      OnClick = OnGameClick
    end
  end
end
