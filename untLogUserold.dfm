object frmLogin: TfrmLogin
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Login'
  ClientHeight = 204
  ClientWidth = 287
  Color = 3289650
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWhite
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  TextHeight = 15
  object pnPrincipal: TPanel
    Left = 0
    Top = 0
    Width = 287
    Height = 204
    Align = alClient
    BevelOuter = bvNone
    Color = 3289650
    ParentBackground = False
    TabOrder = 0
    object Label2: TLabel
      Left = 72
      Top = 22
      Width = 36
      Height = 15
      Caption = 'Nome:'
      Font.Color = clSilver
      ParentFont = False
    end
    object Label1: TLabel
      Left = 69
      Top = 72
      Width = 77
      Height = 15
      Caption = 'Digite a senha:'
      Font.Color = clSilver
      ParentFont = False
    end
    object lbStatus: TLabel
      Left = 1
      Top = 147
      Width = 285
      Height = 15
      Align = alBottom
      Alignment = taCenter
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clSilver
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      ExplicitWidth = 3
    end
    object cbUsuario: TComboBox
      Left = 72
      Top = 43
      Width = 145
      Height = 23
      Color = 2171170
      Font.Color = clWhite
      ParentFont = False
      Style = csDropDownList
      TabOrder = 0
      OnKeyPress = cbUsuarioKeyPress
    end
    object edtSenha: TEdit
      Left = 69
      Top = 93
      Width = 148
      Height = 23
      Color = 2171170
      Font.Color = clWhite
      ParentFont = False
      PasswordChar = '*'
      TabOrder = 1
      OnKeyPress = edtSenhaKeyPress
    end
    object Panel1: TPanel
      Left = 1
      Top = 162
      Width = 285
      Height = 41
      Align = alBottom
      BevelOuter = bvNone
      Color = 3289650
      ParentBackground = False
      TabOrder = 2
      object pnConfirmar: TPanel
        Left = 0
        Top = 0
        Width = 242
        Height = 41
        Align = alClient
        BevelOuter = bvNone
        Caption = 'ENTRAR'
        Color = 2236962
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentBackground = False
        ParentFont = False
        TabOrder = 0
        OnClick = pnConfirmarClick
        OnMouseEnter = pnConfirmarMouseEnter
        OnMouseLeave = pnConfirmarMouseLeave
      end
      object pnCancelar: TPanel
        Left = 242
        Top = 0
        Width = 43
        Height = 41
        Align = alRight
        BevelOuter = bvNone
        Caption = 'X'
        Color = 2236962
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentBackground = False
        ParentFont = False
        TabOrder = 1
        OnClick = pnCancelarClick
        OnMouseEnter = pnCancelarMouseEnter
        OnMouseLeave = pnCancelarMouseLeave
      end
    end
  end
end
