unit untLogUser;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.WinXPickers, Vcl.StdCtrls, Vcl.Mask,
  Vcl.ExtCtrls, Vcl.DBCtrls, Data.DB;

type
  TfrmLogin = class(TForm)
    pnPrincipal: TPanel;
    Label1: TLabel;
    edtSenha: TEdit;
    Label2: TLabel;
    cbUsuario: TComboBox;
    pnConfirmar: TPanel;
    lbStatus: TLabel;
    Panel1: TPanel;
    pnCancelar: TPanel;
    procedure FormShow(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Validar();
    procedure pnConfirmarClick(Sender: TObject);
    procedure pnCancelarClick(Sender: TObject);
    procedure pnConfirmarMouseEnter(Sender: TObject);
    procedure pnConfirmarMouseLeave(Sender: TObject);
    procedure pnCancelarMouseEnter(Sender: TObject);
    procedure pnCancelarMouseLeave(Sender: TObject);
    procedure cbUsuarioKeyPress(Sender: TObject; var Key: Char);
    procedure edtSenhaKeyPress(Sender: TObject; var Key: Char);
  private

  public
    { Public declarations }
  end;

var
  frmLogin: TfrmLogin;

implementation

{$R *.dfm}

uses dmconexao, untLocalizaCli, untLicenca;

procedure TfrmLogin.btnOkClick(Sender: TObject);
var
  IdUsuario: Integer;
begin
  if cbUsuario.ItemIndex < 0 then
  begin
    ShowMessage('Selecione um usuario.');
    Exit;
  end;

  if Trim(edtSenha.Text) = '' then
  begin
    ShowMessage('Informe a senha.');
    edtSenha.SetFocus;
    Exit;
  end;

  IdUsuario := NativeInt(cbUsuario.Items.Objects[cbUsuario.ItemIndex]);

  dmConexoes.qrUsuario.Close;
  dmConexoes.qrUsuario.SQL.Clear;
  dmConexoes.qrUsuario.SQL.Add(
    'SELECT * FROM [LojaNova].[dbo].[Usuarios] ' +
    'WHERE id = :id AND Senha = :senha'
  );
  dmConexoes.qrUsuario.Parameters.ParamByName('id').value    := IdUsuario;
  dmConexoes.qrUsuario.Parameters.ParamByName('senha').value := edtSenha.Text;
  dmConexoes.qrUsuario.Open;

  if dmConexoes.qrUsuario.RecordCount = 0 then
  begin
    ShowMessage('Usuario ou senha invalidos.');
    edtSenha.SetFocus;
    Exit;
  end;

  ShowMessage('Login realizado com sucesso!');
  ModalResult := mrOk;
end;

procedure TfrmLogin.cbUsuarioKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    edtSenha.SetFocus;
end;

procedure TfrmLogin.edtSenhaKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    Validar();
end;

procedure TfrmLogin.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if ModalResult <> mrOk then
    Application.Terminate;
  CanClose := True;
end;

procedure TfrmLogin.FormShow(Sender: TObject);
begin
  cbUsuario.Clear;

  dmConexoes.qrUsuario.Close;
  dmConexoes.qrUsuario.SQL.Text :=
    'SELECT * FROM [LojaNova].[dbo].[Usuarios] ORDER BY Usuario';
  dmConexoes.qrUsuario.Open;

  while not dmConexoes.qrUsuario.Eof do
  begin
    cbUsuario.Items.AddObject(
      dmConexoes.qrUsuario.FieldByName('Usuario').AsString,
      TObject(NativeInt(dmConexoes.qrUsuario.FieldByName('id').AsInteger))
    );
    dmConexoes.qrUsuario.Next;
  end;
end;

procedure TfrmLogin.pnConfirmarClick(Sender: TObject);
begin
  Validar();
end;

procedure TfrmLogin.pnConfirmarMouseEnter(Sender: TObject);
begin
  pnConfirmar.Color      := clGreen;
  pnConfirmar.Font.Color := clBlack;
end;

procedure TfrmLogin.pnConfirmarMouseLeave(Sender: TObject);
begin
  pnConfirmar.Color      := $00333333;
  pnConfirmar.Font.Color := clWhite;
end;

procedure TfrmLogin.pnCancelarClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfrmLogin.pnCancelarMouseEnter(Sender: TObject);
begin
  pnCancelar.Color      := clRed;
  pnCancelar.Font.Color := clWhite;
end;

procedure TfrmLogin.pnCancelarMouseLeave(Sender: TObject);
begin
  pnCancelar.Color      := $00333333;
  pnCancelar.Font.Color := clWhite;
end;

procedure TfrmLogin.Validar;
var
  IdUsuario: Integer;
  Dias: Integer;
  frmLic: TfrmLicenca;
begin
  // Validacao basica
  if cbUsuario.ItemIndex < 0 then
  begin
    lbStatus.Caption    := 'Selecione um usuario.';
    lbStatus.Font.Color := clRed;
    Application.ProcessMessages;
    Exit;
  end;

  if Trim(edtSenha.Text) = '' then
  begin
    lbStatus.Caption    := 'Informe a senha.';
    lbStatus.Font.Color := clRed;
    Application.ProcessMessages;
    edtSenha.SetFocus;
    Exit;
  end;

  // Recupera o ID do usuario
  IdUsuario := NativeInt(cbUsuario.Items.Objects[cbUsuario.ItemIndex]);

  dmConexoes.qrUsuario.Close;
  dmConexoes.qrUsuario.SQL.Clear;
  dmConexoes.qrUsuario.SQL.Add(
    'SELECT * FROM [LojaNova].[dbo].[Usuarios] ' +
    'WHERE id = :id AND Senha = :senha'
  );
  dmConexoes.qrUsuario.Parameters.ParamByName('id').value    := IdUsuario;
  dmConexoes.qrUsuario.Parameters.ParamByName('senha').value := edtSenha.Text;
  dmConexoes.qrUsuario.Open;

  if dmConexoes.qrUsuario.RecordCount = 0 then
  begin
    lbStatus.Caption    := 'Usuario ou senha invalidos.';
    lbStatus.Font.Color := clRed;
    Application.ProcessMessages;
    edtSenha.SetFocus;
    Exit;
  end;
   // Carrega configuracoes do INI apos login validado
  dmConexoes.CarregarConfiguracoes;

  // ============================================================
  // VERIFICACAO DE LICENCA
  // ============================================================
  Dias := dmConexoes.VerificarLicenca;

  // Licenca expirada — abre tela de ativacao obrigatoria
  if Dias = -1 then
  begin
    lbStatus.Caption    := 'Licenca expirada. Aguardando ativacao...';
    lbStatus.Font.Color := clRed;
    Application.ProcessMessages;

    frmLic := TfrmLicenca.Create(Self);
    try
      if frmLic.ShowModal <> mrOk then
      begin
        // Nao ativou — encerra o sistema
        Application.Terminate;
        Exit;
      end;
    finally
      frmLic.Free;
    end;
  end
  // Aviso de proximidade (10 dias ou menos)
  else if Dias <= 10 then
  begin
    Application.MessageBox(
      PChar('ATENCAO: Sua licenca expira em ' + IntToStr(Dias) + ' dia(s).' +
            #13#10 + 'Entre em contato com o suporte para renovar.'),
      'Aviso de Licenca', MB_OK + MB_ICONWARNING
    );
  end;

  // Login OK
  lbStatus.Caption    := 'Login realizado com sucesso!';
  lbStatus.Font.Color := clGreen;
  Application.ProcessMessages;
  Sleep(2000);
  ModalResult := mrOk;
end;

end.
