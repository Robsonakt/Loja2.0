unit untLocalizaCli;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids, Vcl.DBGrids,
  Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TfrmLocalizaCli = class(TForm)
    Panel1: TPanel;
    lbNomeCliente: TLabel;
    edtPesquisaCLiente: TEdit;
    GridCLiente: TDBGrid;
    dsConsultaCliente: TDataSource;
    procedure edtPesquisaCLienteChange(Sender: TObject);
    procedure LocalizaCliente();
    procedure GridCLienteKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmLocalizaCli: TfrmLocalizaCli;
  LocalizaCodigoCli: string;

implementation

{$R *.dfm}
uses dmconexao;

procedure TfrmLocalizaCli.FormShow(Sender: TObject);
begin
  LocalizaCodigoCli := '';
  dsConsultaCliente.DataSet := dmConexoes.qrComando;
  LocalizaCliente;
  edtPesquisaCLiente.SetFocus;
end;

procedure TfrmLocalizaCli.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  dmConexoes.qrComando.Close;
end;

procedure TfrmLocalizaCli.edtPesquisaCLienteChange(Sender: TObject);
begin
  LocalizaCliente;
end;

procedure TfrmLocalizaCli.GridCLienteKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    // coluna chave da tabela Cliente e codcli
    LocalizaCodigoCli := dmConexoes.qrComando.FieldByName('codcli').AsString;
    frmLocalizaCli.Close;
  end;
end;

procedure TfrmLocalizaCli.LocalizaCliente;
begin
  with dmConexoes.qrComando do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT codcli, nome, cpf, telefone');
    SQL.Add('FROM [LojaNova].[dbo].[Cliente]');
    SQL.Add('WHERE (codcli IS NOT NULL)');

    if Trim(edtPesquisaCLiente.Text) <> '' then
    begin
      SQL.Add('AND (Nome LIKE :pNome');
      SQL.Add('OR Cpf LIKE :pCpf');
      SQL.Add('OR Telefone LIKE :pTelefone)');
      Parameters.ParamByName('pNome').Value     := '%' + edtPesquisaCLiente.Text + '%';
      Parameters.ParamByName('pCpf').Value      := '%' + edtPesquisaCLiente.Text + '%';
      Parameters.ParamByName('pTelefone').Value := '%' + edtPesquisaCLiente.Text + '%';
    end;

    Open;
  end;
end;

end.
