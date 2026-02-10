object frmLozalizaCli: TfrmLozalizaCli
  Left = 0
  Top = 0
  Caption = 'frmLozalizaCli'
  ClientHeight = 490
  ClientWidth = 844
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 440
    Width = 844
    Height = 50
    Align = alBottom
    TabOrder = 0
    object lbNomeCliente: TLabel
      Left = 16
      Top = 7
      Width = 73
      Height = 15
      Caption = 'Nome Cliente'
    end
    object edtPesquisaCLiente: TEdit
      Left = 14
      Top = 23
      Width = 390
      Height = 23
      TabOrder = 0
      OnChange = edtPesquisaCLienteChange
    end
  end
  object GridCLiente: TDBGrid
    Left = 0
    Top = 0
    Width = 844
    Height = 440
    Align = alClient
    DataSource = dsConsultaCliente
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = [fsBold]
    OnKeyPress = GridCLienteKeyPress
    Columns = <
      item
        Expanded = False
        FieldName = 'codigo'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'nome'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'telefone'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'produto'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'valor'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'valorfiado'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'datacadastrocliente'
        Visible = True
      end>
  end
  object dsConsultaCliente: TDataSource
    DataSet = dmConexoes.qrCliente
    Left = 352
    Top = 97
  end
end
