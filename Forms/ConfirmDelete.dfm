object frmConfirmDelete: TfrmConfirmDelete
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Confirm'
  ClientHeight = 120
  ClientWidth = 350
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  OnShow = FormShow
  TextHeight = 15
  object lblMessage: TLabel
    Left = 10
    Top = 15
    Width = 330
    Height = 30
    AutoSize = False
    WordWrap = True
  end
  object chkDeleteOrphans: TCheckBox
    Left = 10
    Top = 55
    Width = 330
    Height = 17
    Caption = 'Delete resulting media orphans also'
    TabOrder = 0
  end
  object btnOK: TButton
    Left = 185
    Top = 85
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 265
    Top = 85
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
