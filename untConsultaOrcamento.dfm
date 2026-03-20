object frmConsultaOrcamento: TfrmConsultaOrcamento
  Left = 0
  Top = 0
  Caption = 'Consulta de Orcamentos'
  ClientHeight = 681
  ClientWidth = 1089
  Color = 3289650
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWhite
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 17
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
      Width = 206
      Height = 20
      Caption = 'CONSULTA DE ORCAMENTOS'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
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
      Width = 204
      Height = 13
      Caption = 'Conectado   |   Consulta de Orcamentos'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clSilver
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object lblRodapeDir: TLabel
      Left = 1040
      Top = 13
      Width = 21
      Height = 13
      Caption = 'R.RJ'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clSilver
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object pnlCorpo: TPanel
    Left = 0
    Top = 46
    Width = 1089
    Height = 594
    Align = alClient
    BevelOuter = bvNone
    Color = 3289650
    TabOrder = 2
    object pnlToolbar: TPanel
      Left = 0
      Top = 0
      Width = 1089
      Height = 44
      BevelOuter = bvNone
      Color = 2171170
      TabOrder = 0
      object pnConsultar: TPanel
        Left = 10
        Top = 6
        Width = 120
        Height = 32
        Caption = 'CONSULTAR [F8]'
        Color = 3355443
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentBackground = False
        ParentFont = False
        TabOrder = 0
        OnClick = pnConsultarClick
        OnMouseEnter = pnConsultarMouseEnter
        OnMouseLeave = pnConsultarMouseLeave
      end
      object pnReimprimir: TPanel
        Left = 140
        Top = 6
        Width = 120
        Height = 32
        Caption = 'REIMPRIMIR'
        Color = 3355443
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentBackground = False
        ParentFont = False
        TabOrder = 1
        OnClick = pnReimprimirClick
        OnMouseEnter = pnReimprimirMouseEnter
        OnMouseLeave = pnReimprimirMouseLeave
      end
      object pnConverterVenda: TPanel
        Left = 270
        Top = 6
        Width = 150
        Height = 32
        Caption = 'CONVERTER EM VENDA'
        Color = 3355443
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentBackground = False
        ParentFont = False
        TabOrder = 2
        OnClick = pnConverterVendaClick
        OnMouseEnter = pnConverterVendaMouseEnter
        OnMouseLeave = pnConverterVendaMouseLeave
      end
    end
    object grpFiltro: TGroupBox
      Left = 10
      Top = 54
      Width = 1069
      Height = 60
      Caption = ' Filtro '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clSilver
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentBackground = False
      ParentFont = False
      TabOrder = 1
      object lblIntervalo: TLabel
        Left = 12
        Top = 18
        Width = 45
        Height = 13
        Caption = 'Intervalo'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clSilver
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblDataIni: TLabel
        Left = 230
        Top = 18
        Width = 57
        Height = 13
        Caption = 'Data Inicial'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clSilver
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblDataFim: TLabel
        Left = 400
        Top = 18
        Width = 52
        Height = 13
        Caption = 'Data Final'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clSilver
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object cbIntervalo: TComboBox
        Left = 12
        Top = 34
        Width = 200
        Height = 23
        Color = 2171170
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OnChange = cbIntervaloChange
        Items.Strings = (
          'Sem Intervalo de Datas'
          'Com Intervalo de Datas')
      end
      object dtDataIni: TDateTimePicker
        Left = 230
        Top = 34
        Width = 150
        Height = 23
        Date = 46101.000000000000000000
        Time = 0.444543587960652100
        Enabled = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
      end
      object dtDataFim: TDateTimePicker
        Left = 400
        Top = 34
        Width = 150
        Height = 23
        Date = 46101.000000000000000000
        Time = 0.444543587960652100
        Enabled = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
      end
    end
    object grpOrcamentos: TGroupBox
      Left = 10
      Top = 124
      Width = 1069
      Height = 240
      Caption = ' Orcamentos '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clSilver
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentBackground = False
      ParentFont = False
      TabOrder = 2
      object gridOrcamentos: TDBGrid
        Left = 10
        Top = 22
        Width = 1047
        Height = 206
        Color = 2171170
        DataSource = dsOrcamentos
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection]
        ParentFont = False
        ReadOnly = True
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clSilver
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = [fsBold]
        Columns = <
          item
            Expanded = False
            FieldName = 'Id'
            Title.Caption = 'N'#186
            Width = 50
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'Data'
            Width = 90
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'Cliente'
            Width = 280
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'Vendedor'
            Width = 150
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'MaoObra'
            Title.Caption = 'Mao de Obra'
            Width = 110
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'Total'
            Width = 110
            Visible = True
          end>
      end
    end
    object grpItens: TGroupBox
      Left = 10
      Top = 374
      Width = 1069
      Height = 210
      Caption = ' Itens do Orcamento Selecionado '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clSilver
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentBackground = False
      ParentFont = False
      TabOrder = 3
      object gridItens: TDBGrid
        Left = 10
        Top = 22
        Width = 1047
        Height = 176
        Color = 2171170
        DataSource = dsItens
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection]
        ParentFont = False
        ReadOnly = True
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clSilver
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = [fsBold]
        Columns = <
          item
            Expanded = False
            FieldName = 'CodProd'
            Title.Caption = 'Codigo'
            Width = 70
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'Descricao'
            Width = 400
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'Qtd'
            Width = 60
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'ValUnit'
            Title.Caption = 'Vl. Unit.'
            Width = 120
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'ValTotal'
            Title.Caption = 'Vl. Total'
            Width = 120
            Visible = True
          end>
      end
    end
  end
  object dsOrcamentos: TDataSource
    DataSet = fdOrcamentos
    OnDataChange = gridOrcamentosDataChange
    Left = 900
    Top = 560
  end
  object fdOrcamentos: TFDMemTable
    FieldDefs = <>
    IndexDefs = <>
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    StoreDefs = True
    Left = 796
    Top = 560
    object fdOrcId: TIntegerField
      FieldName = 'Id'
    end
    object fdOrcData: TStringField
      FieldName = 'Data'
    end
    object fdOrcCliente: TStringField
      FieldName = 'Cliente'
      Size = 200
    end
    object fdOrcVendedor: TStringField
      FieldName = 'Vendedor'
      Size = 100
    end
    object fdOrcMaoObra: TCurrencyField
      FieldName = 'MaoObra'
      DisplayFormat = '"R$" #,##0.00'
    end
    object fdOrcTotal: TCurrencyField
      FieldName = 'Total'
      DisplayFormat = '"R$" #,##0.00'
    end
    object fdOrcStatus: TStringField
      FieldName = 'Status'
    end
  end
  object dsItens: TDataSource
    DataSet = fdItens
    Left = 980
    Top = 560
  end
  object fdItens: TFDMemTable
    FieldDefs = <>
    IndexDefs = <>
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    StoreDefs = True
    Left = 900
    Top = 620
    object fdItCodProd: TIntegerField
      FieldName = 'CodProd'
    end
    object fdItDescricao: TStringField
      FieldName = 'Descricao'
      Size = 200
    end
    object fdItQtd: TIntegerField
      FieldName = 'Qtd'
    end
    object fdItValUnit: TCurrencyField
      FieldName = 'ValUnit'
      DisplayFormat = '"R$" #,##0.00'
    end
    object fdItValTotal: TCurrencyField
      FieldName = 'ValTotal'
      DisplayFormat = '"R$" #,##0.00'
    end
  end
end
