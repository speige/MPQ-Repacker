object frmSettings: TfrmSettings
  Left = 0
  Top = 0
  BorderIcons = [biMinimize, biMaximize]
  BorderStyle = bsSingle
  Caption = 'Additional Settings'
  ClientHeight = 295
  ClientWidth = 192
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
  object lblCompression: TLabel
    Left = 16
    Top = 9
    Width = 43
    Height = 13
    Caption = 'Compression:'
  end
  object lblAnalyze: TLabel
    Left = 16
    Top = 28
    Width = 40
    Height = 13
    Caption = 'Analyze:'
  end
  object cbbCompression: TComboBox
    Left = 65
    Top = 6
    Width = 112
    Height = 21
    Style = csDropDownList
    ItemIndex = 1
    TabOrder = 0
    Text = 'ZLIB'
    Items.Strings = (
      'Huffmann'
      'ZLIB'
      'PKWARE'
      'LZMA'
      'BZIP2'
      'SPARSE'
      'No compression')
  end
  object chklstAnalyze: TCheckListBox
    Left = 15
    Top = 47
    Width = 161
    Height = 99
    Color = clBtnFace
    ItemHeight = 13
    Items.Strings = (
      'war3map.w3*'
      'war3map.imp'
      'war3map.j'
      '*.mdx'
      '*.txt'
      '*.slk'
      '(listfile)')
    TabOrder = 1
  end
  object chkMapRename: TCheckBox
    Left = 27
    Top = 152
    Width = 137
    Height = 34
    Caption = 'Name map from war3map.w3i/wts'
    Checked = True
    State = cbChecked
    TabOrder = 2
    WordWrap = True
  end
  object chkInternalListfile: TCheckBox
    Left = 27
    Top = 192
    Width = 137
    Height = 26
    Caption = 'Ignore internal listfile'
    TabOrder = 3
    WordWrap = True
  end
  object btnOk: TButton
    Left = 27
    Top = 232
    Width = 137
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 4
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 27
    Top = 263
    Width = 137
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 5
    OnClick = btnCancelClick
  end
end
