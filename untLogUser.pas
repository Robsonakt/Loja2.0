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

uses dmconexao, untLocalizaCli;

procedure TfrmLogin.btnOkClick(Sender: TObject);
var
  IdUsuario: Integer;
begin
  // Validação básica
  if cbUsuario.ItemIndex < 0 then
  begin
    ShowMessage('Selecione um usuário.');
    Exit;
  end;

  if Trim(edtSenha.Text) = '' then
  begin
    ShowMessage('Informe a senha.');
    edtSenha.SetFocus;
    Exit;
  end;

  // Recupera o ID real do ComboBox
  IdUsuario := NativeInt(cbUsuario.Items.Objects[cbUsuario.ItemIndex]);

  // Reutiliza a mesma query, trocando o SQL
  dmConexoes.qrUsuario.Close;
  dmConexoes.qrUsuario.SQL.Clear;
  dmConexoes.qrUsuario.SQL.Add(
    'SELECT * FROM [LojaNova].[dbo].[Usuarios] ' +
    'WHERE id = :id AND Senha = :senha'
  );

  dmConexoes.qrUsuario.Parameters.ParamByName('id').value := IdUsuario;
dmConexoes.qrUsuario.Parameters.ParamByName('senha').value := edtSenha.Text;
  dmConexoes.qrUsuario.Open;

  // Valida resultado
  if dmConexoes.qrUsuario.RecordCount = 0 then
  begin
    ShowMessage('Usuário ou senha inválidos.');
    edtSenha.SetFocus;
    Exit;
  end;

  // Login OK
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
  // Se ainda não houve login
  if ModalResult <> mrOk then
  begin
    Application.Terminate;
  end;

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
  pnConfirmar.Color := clGreen;
  pnConfirmar.Font.Color := clBlack;
end;

procedure TfrmLogin.pnConfirmarMouseLeave(Sender: TObject);
begin
  pnConfirmar.Color := $00333333;
  pnConfirmar.Font.Color := clWhite;
end;

procedure TfrmLogin.pnCancelarClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfrmLogin.pnCancelarMouseEnter(Sender: TObject);
begin
  pnCancelar.Color := clRed;
  pnCancelar.Font.Color := clWhite;
end;

procedure TfrmLogin.pnCancelarMouseLeave(Sender: TObject);
begin
  pnCancelar.Color := $00333333;
  pnCancelar.Font.Color := clWhite;
end;

procedure TfrmLogin.Validar;
var
  IdUsuario: Integer;
begin

  // Validação básica
  if cbUsuario.ItemIndex < 0 then
  begin
    // ShowMessage('Selecione um usuário.');
    lbStatus.Caption := 'Selecione um usuário.';
    lbStatus.Font.Color := clRed;
    Application.ProcessMessages;
    Exit;
  end;

  if Trim(edtSenha.Text) = '' then
  begin
    //ShowMessage('Informe a senha.');
    lbStatus.Caption := 'Informe a senha.';
    lbStatus.Font.Color := clRed;
    Application.ProcessMessages;

    edtSenha.SetFocus;
    Exit;
  end;

  // Recupera o ID real do ComboBox
  IdUsuario := NativeInt(cbUsuario.Items.Objects[cbUsuario.ItemIndex]);

  // Reutiliza a mesma query, trocando o SQL
  dmConexoes.qrUsuario.Close;
  dmConexoes.qrUsuario.SQL.Clear;
  dmConexoes.qrUsuario.SQL.Add(
    'SELECT * FROM [LojaNova].[dbo].[Usuarios] ' +
    'WHERE id = :id AND Senha = :senha'
  );

  dmConexoes.qrUsuario.Parameters.ParamByName('id').value := IdUsuario;
dmConexoes.qrUsuario.Parameters.ParamByName('senha').value := edtSenha.Text;
  dmConexoes.qrUsuario.Open;

  // Valida resultado
  if dmConexoes.qrUsuario.RecordCount = 0 then
  begin
    // ShowMessage('Usuário ou senha inválidos.');
    lbStatus.Caption := 'Usuário ou senha inválidos.';
    lbStatus.Font.Color := clRed;
    Application.ProcessMessages;

    edtSenha.SetFocus;
    Exit;
  end;

  // Login OK
  // ShowMessage('Login realizado com sucesso!');
  lbStatus.Caption := 'Login realizado com sucesso!';
  lbStatus.Font.Color := clGreen;
  Application.ProcessMessages;
  Sleep(2000);
  ModalResult := mrOk;
end;

end.

