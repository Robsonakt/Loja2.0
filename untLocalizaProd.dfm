object frmLocalizaProd: TfrmLocalizaProd
  Left = 0
  Top = 0
  Caption = 'Localiza Produto'
  ClientHeight = 494
  ClientWidth = 829
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnClose = FormClose
  OnShow = FormShow
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 430
    Width = 829
    Height = 64
    Align = alBottom
    TabOrder = 0
    object lbConsultaProduto: TLabel
      Left = 16
      Top = 7
      Width = 79
      Height = 15
      Caption = 'Nome Produto'
    end
    object edtPesquisaProduto: TEdit
      Left = 16
      Top = 28
      Width = 390
      Height = 23
      TabOrder = 0
      OnChange = edtPesquisaProdutoChange
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 829
    Height = 430
    Align = alClient
    Caption = 'Panel2'
    TabOrder = 1
    object gridProduto: TDBGrid
      Left = 0
      Top = 0
      Width = 897
      Height = 425
      DataSource = DsProdutos
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
      OnDblClick = gridProdutoDblClick
      OnKeyPress = gridProdutoKeyPress
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
    Left = 336
    Top = 184
  end
end
