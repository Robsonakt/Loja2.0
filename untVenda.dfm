object frmCaixaVendas: TfrmCaixaVendas
  Left = 0
  Top = 0
  Caption = 'Caixa de Vendas'
  ClientHeight = 681
  ClientWidth = 1089
  Color = 3289650
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWhite
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 15
  object pnlTopo: TPanel
    Left = 0
    Top = 0
    Width = 1089
    Height = 46
    Align = alTop
    BevelOuter = bvNone
    Color = 2171170
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 16
      Top = 13
      Caption = 'CAIXA DE VENDAS'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblRodapeTop: TLabel
      Left = 960
      Top = 15
      Caption = 'R.RJ'
      Font.Color = clSilver
      Font.Height = -11
      Font.Name = 'Segoe UI'
      ParentFont = False
    end
  end
  object pnlRodape: TPanel
    Left = 0
    Top = 640
    Width = 1089
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    Color = 2171170
    TabOrder = 1
    object lblStatus: TLabel
      Left = 16
      Top = 13
      Caption = 'Conectado   |   Caixa Aberto'
      Font.Color = clSilver
      Font.Height = -11
      Font.Name = 'Segoe UI'
      ParentFont = False
    end
    object lblRodape: TLabel
      Left = 960
      Top = 13
      Caption = 'R.RJ'
      Font.Color = clSilver
      Font.Height = -11
      Font.Name = 'Segoe UI'
      ParentFont = False
    end
  end
  object pnlCliente: TPanel
    Left = 0
    Top = 46
    Width = 1089
    Height = 594
    Align = alClient
    BevelOuter = bvNone
    Color = 3289650
    TabOrder = 2
    object grpIdentificacao: TGroupBox
      Left = 10
      Top = 8
      Width = 680
      Height = 78
      Caption = ' Identificacao da Venda '
      Color = 3289650
      Font.Color = clSilver
      Font.Name = 'Segoe UI'
      Font.Height = -12
      ParentBackground = False
      TabOrder = 0
      object Label1: TLabel
        Left = 12
        Top = 18
        Caption = 'Cod. Cliente (F2)'
        Font.Color = clSilver
        Font.Height = -11
        Font.Name = 'Segoe UI'
        ParentFont = False
      end
      object EdtNameCliente: TEdit
        Left = 12
        Top = 36
        Width = 100
        Height = 26
        Color = 2171170
        Font.Color = clWhite
        Font.Name = 'Segoe UI'
        TabOrder = 0
      end
      object lbNomeCli: TLabel
        Left = 122
        Top = 41
        Width = 3
        Caption = '.'
        Font.Color = clSilver
        Font.Height = -11
        Font.Name = 'Segoe UI'
        ParentFont = False
      end
      object Label2: TLabel
        Left = 330
        Top = 18
        Caption = 'Cod. Venda'
        Font.Color = clSilver
        Font.Height = -11
        Font.Name = 'Segoe UI'
        ParentFont = False
      end
      object edtCodVenda: TEdit
        Left = 330
        Top = 36
        Width = 90
        Height = 26
        Color = 2171170
        Enabled = False
        Font.Color = clSilver
        Font.Name = 'Segoe UI'
        TabOrder = 1
      end
      object lbDataVenda: TLabel
        Left = 436
        Top = 18
        Caption = 'Data da Venda'
        Font.Color = clSilver
        Font.Height = -11
        Font.Name = 'Segoe UI'
        ParentFont = False
      end
      object edtDataVenda: TMaskEdit
        Left = 436
        Top = 36
        Width = 110
        Height = 26
        Color = 2171170
        EditMask = '!99/99/9999;1;_'
        Font.Color = clWhite
        Font.Name = 'Segoe UI'
        MaxLength = 10
        TabOrder = 2
      end
    end
    object grpItens: TGroupBox
      Left = 10
      Top = 95
      Width = 680
      Height = 260
      Caption = ' Itens da Venda '
      Color = 3289650
      Font.Color = clSilver
      Font.Name = 'Segoe UI'
      Font.Height = -12
      ParentBackground = False
      TabOrder = 1
      object DBGrid1: TDBGrid
        Left = 10
        Top = 22
        Width = 658
        Height = 226
        Color = 2171170
        DataSource = DSItensVenda
        Font.Color = clWhite
        Font.Name = 'Segoe UI'
        Font.Height = -12
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clAqua
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = [fsBold]
        Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection]
        TabOrder = 0
        Columns = <
          item
            Expanded = False
            FieldName = 'CodProd'
            Width = 70
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'Descricao'
            Width = 220
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'Quantidade'
            Width = 80
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'ValorUni'
            Width = 90
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'ValorTotal'
            Width = 90
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'CodVenda'
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'CodCli'
            Visible = False
          end>
      end
    end
    object grpProduto: TGroupBox
      Left = 10
      Top = 365
      Width = 680
      Height = 120
      Caption = ' Produto Selecionado '
      Color = 3289650
      Font.Color = clSilver
      Font.Name = 'Segoe UI'
      Font.Height = -12
      ParentBackground = False
      TabOrder = 2
      object edtprod: TLabel
        Left = 12
        Top = 18
        Caption = 'Nome Prod (F2)'
        Font.Color = clSilver
        Font.Height = -11
        Font.Name = 'Segoe UI'
        ParentFont = False
      end
      object edtCodProd: TEdit
        Left = 12
        Top = 36
        Width = 90
        Height = 26
        Color = 2171170
        Font.Color = clWhite
        Font.Name = 'Segoe UI'
        TabOrder = 0
      end
      object lbNomeProd: TLabel
        Left = 112
        Top = 41
        Width = 3
        Caption = '.'
        Font.Color = clSilver
        Font.Height = -11
        Font.Name = 'Segoe UI'
        ParentFont = False
      end
      object lbValorUni: TLabel
        Left = 12
        Top = 70
        Caption = 'Valor Uni.'
        Font.Color = clSilver
        Font.Height = -11
        Font.Name = 'Segoe UI'
        ParentFont = False
      end
      object edtValorProd: TDBEdit
        Left = 12
        Top = 86
        Width = 100
        Height = 26
        Color = 2171170
        Font.Color = clWhite
        Font.Name = 'Segoe UI'
        TabOrder = 1
      end
      object lbquant: TLabel
        Left = 124
        Top = 70
        Caption = 'Qtd. Compra'
        Font.Color = clSilver
        Font.Height = -11
        Font.Name = 'Segoe UI'
        ParentFont = False
      end
      object edtQuant: TEdit
        Left = 124
        Top = 86
        Width = 90
        Height = 26
        Color = 2171170
        Font.Color = clWhite
        Font.Name = 'Segoe UI'
        TabOrder = 2
      end
      object lbValTotal: TLabel
        Left = 226
        Top = 70
        Caption = 'Val. Total'
        Font.Color = clSilver
        Font.Height = -11
        Font.Name = 'Segoe UI'
        ParentFont = False
      end
      object edtValorTotal: TEdit
        Left = 226
        Top = 86
        Width = 100
        Height = 26
        Color = 2171170
        Font.Color = 65280
        Font.Name = 'Segoe UI'
        ReadOnly = True
        TabOrder = 3
      end
      object lbQuantRest: TLabel
        Left = 338
        Top = 70
        Caption = 'Qtd. Restante'
        Font.Color = clSilver
        Font.Height = -11
        Font.Name = 'Segoe UI'
        ParentFont = False
      end
      object edtQuantRest: TDBEdit
        Left = 338
        Top = 86
        Width = 90
        Height = 26
        Color = 2171170
        Font.Color = clSilver
        Font.Name = 'Segoe UI'
        TabOrder = 4
      end
    end
    object pnlDireito: TPanel
      Left = 700
      Top = 8
      Width = 378
      Height = 477
      BevelOuter = bvNone
      Color = 3289650
      TabOrder = 3
      object pnlTotal: TPanel
        Left = 0
        Top = 0
        Width = 378
        Height = 80
        BevelOuter = bvNone
        Color = 2171170
        TabOrder = 0
        object lbTotalVend: TLabel
          Left = 14
          Top = 10
          Caption = 'TOTAL DA VENDA'
          Font.Color = clSilver
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lbvalorDinheiro: TLabel
          Left = 14
          Top = 30
          Caption = 'R$ 0,00'
          Font.Color = 65280
          Font.Height = -24
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
      end
      object grpObs: TGroupBox
        Left = 0
        Top = 90
        Width = 378
        Height = 170
        Caption = ' Observacoes '
        Color = 3289650
        Font.Color = clSilver
        Font.Name = 'Segoe UI'
        Font.Height = -12
        ParentBackground = False
        TabOrder = 1
        object Memo1: TMemo
          Left = 10
          Top = 22
          Width = 356
          Height = 136
          Color = 2171170
          Font.Color = clWhite
          Font.Name = 'Segoe UI'
          ScrollBars = ssVertical
          TabOrder = 0
        end
      end
      object grpAcoes: TGroupBox
        Left = 0
        Top = 270
        Width = 378
        Height = 207
        Caption = ' Acoes '
        Color = 3289650
        Font.Color = clSilver
        Font.Name = 'Segoe UI'
        Font.Height = -12
        ParentBackground = False
        TabOrder = 2
        object btnConfirmar: TBitBtn
          Left = 10
          Top = 24
          Width = 356
          Height = 40
          Caption = 'CONFIRMAR ITEM'
          Font.Color = clWhite
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
        end
        object btnVendas: TBitBtn
          Left = 10
          Top = 74
          Width = 170
          Height = 40
          Caption = 'VENDA'
          Font.Color = clWhite
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 1
        end
        object btnFiados: TBitBtn
          Left = 196
          Top = 74
          Width = 170
          Height = 40
          Caption = 'FIADO'
          Font.Color = clWhite
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 2
        end
        object btnImpressora: TBitBtn
          Left = 10
          Top = 124
          Width = 356
          Height = 36
          Caption = 'Impressora'
          Font.Name = 'Segoe UI'
          Font.Height = -12
          ParentFont = False
          TabOrder = 3
        end
      end
    end
  end
  object DSItensVenda: TDataSource
    DataSet = fdProduto
    Left = 900
    Top = 580
  end
  object fdProduto: TFDMemTable
    FieldDefs = <>
    IndexDefs = <>
    DetailFields = 'CodCli;CodVenda;Quantidade;ValorTotal;ValorUni'
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    StoreDefs = True
    Left = 820
    Top = 580
    object fdProdutoCodProd: TIntegerField
      FieldName = 'CodProd'
    end
    object fdProdutoDescricao: TStringField
      FieldName = 'Descricao'
    end
    object fdProdutoQuantidade: TIntegerField
      FieldName = 'Quantidade'
    end
    object fdProdutoValorUni: TCurrencyField
      FieldName = 'ValorUni'
    end
    object fdProdutoValorTotal: TCurrencyField
      FieldName = 'ValorTotal'
    end
    object fdProdutoCodVenda: TIntegerField
      FieldName = 'CodVenda'
      Visible = False
    end
    object fdProdutoCodCli: TStringField
      FieldName = 'CodCli'
      Visible = False
    end
  end
  object ACBrPosPrinter1: TACBrPosPrinter
    Modelo = ppEscPosEpson
    Porta = 'USB'
    ConfigBarras.MostrarCodigo = False
    ConfigBarras.LarguraLinha = 0
    ConfigBarras.Altura = 0
    ConfigBarras.Margem = 0
    ConfigQRCode.Tipo = 2
    ConfigQRCode.LarguraModulo = 4
    ConfigQRCode.ErrorLevel = 0
    LinhasEntreCupons = 0
    Left = 960
    Top = 580
  end
end
