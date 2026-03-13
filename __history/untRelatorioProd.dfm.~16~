object FrmRelatorioProd: TFrmRelatorioProd
  Left = 0
  Top = 0
  Caption = 'Cadastro de Produto'
  ClientHeight = 847
  ClientWidth = 818
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object rlr_RelatorioProdutos: TRLReport
    Left = 16
    Top = -12
    Width = 794
    Height = 1123
    DataSource = dmConexoes.dsEstoque
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    PageSetup.PaperSize = fpCustom
    PageSetup.PaperWidth = 210.000000000000000000
    PageSetup.PaperHeight = 297.000000000000000000
    Transparent = False
    object RLBand_Cabecalho: TRLBand
      Left = 38
      Top = 38
      Width = 718
      Height = 67
      BandType = btHeader
      Borders.Sides = sdCustom
      Borders.DrawLeft = False
      Borders.DrawTop = False
      Borders.DrawRight = False
      Borders.DrawBottom = True
      object RLSystemInfo1: TRLSystemInfo
        Left = 0
        Top = 0
        Width = 39
        Height = 16
        Align = faLeftTop
        Borders.Sides = sdCustom
        Borders.DrawLeft = False
        Borders.DrawTop = False
        Borders.DrawRight = False
        Borders.DrawBottom = False
        Text = ''
      end
      object RLLabel_Cabecalho: TRLLabel
        Left = 315
        Top = 22
        Width = 88
        Height = 22
        Align = faCenter
        Caption = 'Relat'#243'rio'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -19
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object RLSystemInfo2: TRLSystemInfo
        Left = 647
        Top = 0
        Width = 71
        Height = 19
        Align = faRightTop
        AutoSize = False
        Borders.Sides = sdCustom
        Borders.DrawLeft = False
        Borders.DrawTop = False
        Borders.DrawRight = False
        Borders.DrawBottom = False
        Info = itHour
        Text = ''
      end
    end
    object RLBand1: TRLBand
      Left = 38
      Top = 105
      Width = 718
      Height = 40
      BandType = btTitle
      Borders.Sides = sdCustom
      Borders.DrawLeft = False
      Borders.DrawTop = False
      Borders.DrawRight = False
      Borders.DrawBottom = True
      object RLLabel1: TRLLabel
        Left = 16
        Top = 6
        Width = 44
        Height = 16
        Caption = 'C'#243'digo'
      end
      object RLLabel2: TRLLabel
        Left = 80
        Top = 6
        Width = 62
        Height = 16
        Caption = 'Descri'#231#227'o'
      end
      object RLLabel3: TRLLabel
        Left = 359
        Top = 6
        Width = 29
        Height = 16
        Caption = 'Qtd.'
      end
      object RLLabel4: TRLLabel
        Left = 624
        Top = 6
        Width = 58
        Height = 16
        Caption = 'Vlr. Vend'
      end
      object RLLabel5: TRLLabel
        Left = 536
        Top = 6
        Width = 51
        Height = 16
        Caption = 'Vlr.Cust'
      end
      object RLLabel6: TRLLabel
        Left = 452
        Top = 6
        Width = 28
        Height = 16
        Caption = 'Tipo'
      end
    end
    object RLSubDetail1: TRLSubDetail
      Left = 38
      Top = 145
      Width = 718
      Height = 64
      DataSource = dmConexoes.dsEstoque
      object RLBand2: TRLBand
        Left = 0
        Top = 0
        Width = 718
        Height = 61
        object RLDBText1: TRLDBText
          Left = 16
          Top = 14
          Width = 42
          Height = 16
          DataField = 'codigo'
          DataSource = dmConexoes.dsEstoque
          Text = ''
        end
        object RLDBText2: TRLDBText
          Left = 82
          Top = 14
          Width = 60
          Height = 16
          DataField = 'descricao'
          DataSource = dmConexoes.dsEstoque
          Text = ''
        end
        object RLDBText3: TRLDBText
          Left = 359
          Top = 16
          Width = 67
          Height = 16
          DataField = 'quantidade'
          DataSource = dmConexoes.dsEstoque
          Text = ''
        end
        object RLDBText4: TRLDBText
          Left = 452
          Top = 16
          Width = 25
          Height = 16
          DataField = 'tipo'
          DataSource = dmConexoes.dsEstoque
          Text = ''
        end
        object RLDBText5: TRLDBText
          Left = 536
          Top = 16
          Width = 62
          Height = 16
          DataField = 'valorcusto'
          DataSource = dmConexoes.dsEstoque
          Text = ''
        end
        object RLDBText6: TRLDBText
          Left = 624
          Top = 16
          Width = 63
          Height = 16
          DataField = 'valorvenda'
          DataSource = dmConexoes.dsEstoque
          Text = ''
        end
      end
    end
  end
end
