object frmLogin: TfrmLogin
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'frmLogin'
  ClientHeight = 204
  ClientWidth = 287
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
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
    TabOrder = 0
    ExplicitWidth = 325
    ExplicitHeight = 216
    object Label1: TLabel
      Left = 69
      Top = 72
      Width = 77
      Height = 15
      Caption = 'Digite a senha:'
    end
    object Label2: TLabel
      Left = 72
      Top = 22
      Width = 36
      Height = 15
      Caption = 'Nome:'
    end
    object lbStatus: TLabel
      Left = 1
      Top = 147
      Width = 285
      Height = 15
      Align = alBottom
      Alignment = taCenter
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
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
      Style = csDropDownList
      TabOrder = 0
    end
    object edtSenha: TEdit
      Left = 69
      Top = 93
      Width = 148
      Height = 23
      PasswordChar = '*'
      TabOrder = 1
    end
    object Panel1: TPanel
      Left = 1
      Top = 162
      Width = 285
      Height = 41
      Align = alBottom
      BevelOuter = bvNone
      Caption = 'Panel1'
      TabOrder = 2
      ExplicitLeft = -72
      ExplicitTop = 8
      ExplicitWidth = 185
      object pnConfirmar: TPanel
        Left = 0
        Top = 0
        Width = 242
        Height = 41
        Align = alClient
        BevelOuter = bvNone
        Caption = 'ENTRAR'
        Color = 3355443
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentBackground = False
        ParentFont = False
        TabOrder = 0
        OnClick = pnConfirmarClick
        OnMouseEnter = pnConfirmarMouseEnter
        OnMouseLeave = pnConfirmarMouseLeave
        ExplicitLeft = 1
        ExplicitTop = 155
        ExplicitWidth = 285
        ExplicitHeight = 48
      end
      object pnCancelar: TPanel
        Left = 242
        Top = 0
        Width = 43
        Height = 41
        Align = alRight
        BevelOuter = bvNone
        Caption = 'X'
        Color = 3355443
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentBackground = False
        ParentFont = False
        TabOrder = 1
        OnClick = pnCancelarClick
        OnMouseEnter = pnCancelarMouseEnter
        OnMouseLeave = pnCancelarMouseLeave
        ExplicitLeft = 240
        ExplicitHeight = 39
      end
    end
  end
end
