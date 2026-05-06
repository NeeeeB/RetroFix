object frmSettings: TfrmSettings
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Settings'
  ClientHeight = 399
  ClientWidth = 420
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  TextHeight = 15
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 420
    Height = 359
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitHeight = 440
    object gbxScreenScraper: TGroupBox
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 414
      Height = 110
      Align = alTop
      Caption = 'ScreenScraper credentials'
      TabOrder = 0
      object lblSSUserId: TLabel
        Left = 10
        Top = 25
        Width = 59
        Height = 15
        Caption = 'Username :'
      end
      object lblSSPassword: TLabel
        Left = 10
        Top = 55
        Width = 56
        Height = 15
        Caption = 'Password :'
      end
      object lblLanguage: TLabel
        Left = 10
        Top = 85
        Width = 58
        Height = 15
        Caption = 'Language :'
      end
      object edtSSUserId: TEdit
        Left = 80
        Top = 22
        Width = 320
        Height = 23
        TabOrder = 0
      end
      object edtSSPassword: TEdit
        Left = 80
        Top = 52
        Width = 320
        Height = 23
        PasswordChar = '*'
        TabOrder = 1
      end
      object cbxLanguage: TComboBox
        Left = 80
        Top = 82
        Width = 320
        Height = 23
        Style = csDropDownList
        TabOrder = 2
      end
    end
    object gbxScrapeOptions: TGroupBox
      AlignWithMargins = True
      Left = 3
      Top = 119
      Width = 414
      Height = 237
      Align = alClient
      Caption = 'Scrape options'
      TabOrder = 1
      ExplicitHeight = 290
      object lblScrapeImage: TLabel
        Left = 10
        Top = 25
        Width = 77
        Height = 15
        Caption = 'Image source :'
      end
      object lblScrapeThumb: TLabel
        Left = 10
        Top = 55
        Width = 83
        Height = 15
        Caption = 'Thumb source :'
      end
      object lblScrapeLogo: TLabel
        Left = 10
        Top = 85
        Width = 71
        Height = 15
        Caption = 'Logo source :'
      end
      object lblScrapeRegion: TLabel
        Left = 10
        Top = 115
        Width = 43
        Height = 15
        Caption = 'Region :'
      end
      object cbxScrapeImage: TComboBox
        Left = 100
        Top = 22
        Width = 300
        Height = 23
        Style = csDropDownList
        TabOrder = 0
      end
      object cbxScrapeThumb: TComboBox
        Left = 100
        Top = 52
        Width = 300
        Height = 23
        Style = csDropDownList
        TabOrder = 1
      end
      object cbxScrapeLogo: TComboBox
        Left = 100
        Top = 82
        Width = 300
        Height = 23
        Style = csDropDownList
        TabOrder = 2
      end
      object cbxScrapeRegion: TComboBox
        Left = 100
        Top = 112
        Width = 300
        Height = 23
        Style = csDropDownList
        TabOrder = 3
      end
      object chkScrapeVideos: TCheckBox
        Left = 10
        Top = 148
        Width = 150
        Height = 17
        Caption = 'Videos'
        TabOrder = 4
      end
      object chkScrapeFanart: TCheckBox
        Left = 170
        Top = 148
        Width = 150
        Height = 17
        Caption = 'Fanart'
        TabOrder = 5
      end
      object chkScrapeBoxBack: TCheckBox
        Left = 10
        Top = 175
        Width = 150
        Height = 17
        Caption = 'Box back'
        TabOrder = 6
      end
      object chkScrapeManual: TCheckBox
        Left = 170
        Top = 175
        Width = 150
        Height = 17
        Caption = 'Manual'
        TabOrder = 7
      end
      object chkScrapeMap: TCheckBox
        Left = 10
        Top = 202
        Width = 150
        Height = 17
        Caption = 'Map'
        TabOrder = 8
      end
      object chkScrapeBezel: TCheckBox
        Left = 170
        Top = 202
        Width = 150
        Height = 17
        Caption = 'Bezel'
        TabOrder = 9
      end
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 359
    Width = 420
    Height = 40
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = 440
    object btnOK: TButton
      Left = 255
      Top = 8
      Width = 75
      Height = 25
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 340
      Top = 8
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
end
