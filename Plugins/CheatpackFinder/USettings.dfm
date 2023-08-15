object frmSettings: TfrmSettings
  Left = 0
  Top = 0
  BorderIcons = [biMinimize, biMaximize]
  BorderStyle = bsDialog
  Caption = 'Extendable Cheatpack Detector settings:'
  ClientHeight = 253
  ClientWidth = 482
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object mmoCheatStrings: TMemo
    Left = 8
    Top = 6
    Width = 466
    Height = 209
    TabOrder = 0
  end
  object chkReplaceActivator: TCheckBox
    Left = 91
    Top = 227
    Width = 129
    Height = 17
    Caption = 'Replace activator'
    TabOrder = 3
  end
  object btnOk: TButton
    Left = 235
    Top = 223
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 316
    Top = 223
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
