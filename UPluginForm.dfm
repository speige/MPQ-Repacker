object frmPlugins: TfrmPlugins
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Plugins'
  ClientHeight = 212
  ClientWidth = 457
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnDestroy = FormDestroy
  OnKeyUp = FormKeyUp
  PixelsPerInch = 96
  TextHeight = 13
  object lblPlgInfo: TLabel
    AlignWithMargins = True
    Left = 239
    Top = 3
    Width = 215
    Height = 174
    AutoSize = False
    Caption = 'Author: '#13#10'Name: '#13#10'Description: '
    WordWrap = True
  end
  object chklstPlugins: TCheckListBox
    Left = 0
    Top = 0
    Width = 233
    Height = 212
    OnClickCheck = chklstPluginsClickCheck
    Align = alLeft
    ItemHeight = 13
    TabOrder = 0
    OnClick = chklstPluginsClick
  end
  object btnSettings: TButton
    Left = 239
    Top = 184
    Width = 215
    Height = 25
    Caption = 'Plugin settings'
    Enabled = False
    TabOrder = 1
    OnClick = btnSettingsClick
  end
end
