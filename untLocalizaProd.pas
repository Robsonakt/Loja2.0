unit untLocalizaProd;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids, Vcl.DBGrids,
  Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TfrmLocalizaProd = class(TForm)
    Panel1: TPanel;
    lbConsultaProduto: TLabel;
    edtPesquisaProduto: TEdit;
    gridProduto: TDBGrid;
    DsProdutos: TDataSource;
    Panel2: TPanel;
    procedure edtPesquisaProdutoChange(Sender: TObject);
    procedure LocalizaProduto();
    procedure gridProdutoKeyPress(Sender: TObject; var Key: Char);
    procedure gridProdutoDblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmLocalizaProd: TfrmLocalizaProd;
  LocalizaCodigoProd: string;

implementation

{$R *.dfm}
uses dmconexao;

procedure TfrmLocalizaProd.FormShow(Sender: TObject);
begin
  LocalizaCodigoProd := '';
  DsProdutos.DataSet := dmConexoes.qrComando;
  LocalizaProduto;
  gridProduto.Columns[0].Width := 60;  // codigo
  gridProduto.Columns[1].Width := 70;  // quantidade
  gridProduto.Columns[2].Width := 250; // descricao
  gridProduto.Columns[3].Width := 80;  // data
  gridProduto.Columns[4].Width := 90;  // valorvenda
  gridProduto.Columns[5].Width := 60;  // tipo
  gridProduto.Columns[6].Width := 90;  // valorcusto
  gridProduto.Columns[7].Width := 100; // CodBarras
  edtPesquisaProduto.SetFocus;
end;

procedure TfrmLocalizaProd.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  dmConexoes.qrComando.Close;
end;

procedure TfrmLocalizaProd.edtPesquisaProdutoChange(Sender: TObject);
begin
  LocalizaProduto;
end;

procedure TfrmLocalizaProd.gridProdutoKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    LocalizaCodigoProd := dmConexoes.qrComando.FieldByName('codigo').AsString;
    frmLocalizaProd.Close;
  end;
end;

procedure TfrmLocalizaProd.gridProdutoDblClick(Sender: TObject);
begin
  LocalizaCodigoProd := dmConexoes.qrComando.FieldByName('codigo').AsString;
  edtPesquisaProduto.Text := '';
  frmLocalizaProd.Close;
end;

procedure TfrmLocalizaProd.LocalizaProduto;
begin
  with dmConexoes.qrComando do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT');
    SQL.Add('  codigo,');
    SQL.Add('  quantidade,');
    SQL.Add('  descricao,');
    SQL.Add('  data,');
    SQL.Add('  ''R$ '' + REPLACE(CONVERT(VARCHAR, CAST(valorvenda AS NUMERIC(15,2))), ''.'', '','') AS valorvenda,');
    SQL.Add('  tipo,');
    SQL.Add('  ''R$ '' + REPLACE(CONVERT(VARCHAR, CAST(valorcusto AS NUMERIC(15,2))), ''.'', '','') AS valorcusto,');
    SQL.Add('  CodBarras');
    SQL.Add('FROM [LojaNova].[dbo].[PRODUTOS]');
    SQL.Add('WHERE (CODIGO IS NOT NULL)');
    if Trim(edtPesquisaProduto.Text) <> '' then
    begin
      SQL.Add('AND (Descricao LIKE :pDescricao');
      SQL.Add('OR CAST(CodBarras AS VARCHAR(50)) LIKE :pCodBarras)');
      Parameters.ParamByName('pDescricao').Value := '%' + edtPesquisaProduto.Text + '%';
      Parameters.ParamByName('pCodBarras').Value := '%' + edtPesquisaProduto.Text + '%';
    end;

    Open;
  end;
end;

end.
