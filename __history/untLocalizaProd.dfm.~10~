object frmLozalizaProd: TfrmLozalizaProd
  Left = 0
  Top = 0
  Caption = 'frmLozalizaProd'
  ClientHeight = 454
  ClientWidth = 818
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 404
    Width = 818
    Height = 50
    Align = alBottom
    TabOrder = 0
    ExplicitTop = 381
    ExplicitWidth = 786
    object lbConsultaProduto: TLabel
      Left = 16
      Top = 7
      Width = 79
      Height = 15
      Caption = 'Nome Produto'
    end
    object edtPesquisaProduto: TEdit
      Left = 16
      Top = 26
      Width = 390
      Height = 23
      TabOrder = 0
      OnChange = edtPesquisaProdutoChange
      OnKeyPress = edtPesquisaProdutoKeyPress
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 818
    Height = 404
    Align = alClient
    Caption = 'Panel2'
    TabOrder = 1
    ExplicitWidth = 786
    ExplicitHeight = 381
    object gridProduto: TDBGrid
      Left = 0
      Top = 0
      Width = 897
      Height = 353
      DataSource = dmConexoes.dsProduto
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
      Columns = <
        item
          Expanded = False
          FieldName = 'codigo'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'quantidade'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'descricao'
          Width = 289
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'data'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'valorvenda'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'tipo'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'valorcusto'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'CodBarras'
          Visible = True
        end>
    end
  end
  object DsProdutos: TDataSource
    DataSet = dmConexoes.qrEstoque
    Left = 336
    Top = 184
  end
end
