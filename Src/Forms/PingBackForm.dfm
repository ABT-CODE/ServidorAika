object frmPingback: TfrmPingback
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Pingback - Aika Caligula'
  ClientHeight = 195
  ClientWidth = 612
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  TextHeight = 13
  object memLog: TMemo
    Left = 0
    Top = -5
    Width = 615
    Height = 161
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object btnClearLog: TButton
    Left = 529
    Top = 162
    Width = 75
    Height = 25
    Caption = 'Limpar Log'
    TabOrder = 1
  end
end
