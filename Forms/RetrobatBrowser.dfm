object frmRetrobatBrowser: TfrmRetrobatBrowser
  Left = 0
  Top = 0
  Caption = 'Retrobat Browser'
  ClientHeight = 600
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
  OnMouseWheel = FormMouseWheel
  OnResize = FormResize
  OnShow = FormShow
  TextHeight = 15
  object SkPaintBox: TSkPaintBox
    Left = 0
    Top = 35
    Width = 900
    Height = 565
    Align = alClient
    OnMouseDown = SkPaintBoxMouseDown
    OnDraw = SkPaintBoxDraw
  end
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
    end
  end
end
