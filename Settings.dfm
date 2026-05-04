object frmSettings: TfrmSettings
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Settings'
  ClientHeight = 180
  ClientWidth = 350
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
    Width = 350
    Height = 140
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object gbxScreenScraper: TGroupBox
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 344
      Height = 134
      Align = alClient
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
        Top = 60
        Width = 56
        Height = 15
        Caption = 'Password :'
      end
      object edtSSUserId: TEdit
        Left = 80
        Top = 22
        Width = 250
        Height = 23
        TabOrder = 0
      end
      object edtSSPassword: TEdit
        Left = 80
        Top = 57
        Width = 250
        Height = 23
        PasswordChar = '*'
        TabOrder = 1
      end
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 140
    Width = 350
    Height = 40
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnOK: TButton
      Left = 180
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
      Left = 265
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
