object frmConfirmDelete: TfrmConfirmDelete
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Confirm'
  ClientHeight = 139
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
  object chkDeleteRpcs3Data: TCheckBox
    Left = 10
    Top = 75
    Width = 330
    Height = 17
    Caption = 'Delete RPCS3 game data also (PS3 games detected)'
    TabOrder = 1
    Visible = False
  end
  object btnOK: TButton
    Left = 185
    Top = 105
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 265
    Top = 105
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
end
