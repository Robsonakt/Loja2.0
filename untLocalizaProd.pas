unit untLocalizaProd;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids, Vcl.DBGrids,
  Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TfrmLozalizaProd = class(TForm)
    Panel1: TPanel;
    lbConsultaProduto: TLabel;
    edtPesquisaProduto: TEdit;
    gridProduto: TDBGrid;
    DsProdutos: TDataSource;
    Panel2: TPanel;
    procedure edtPesquisaProdutoChange(Sender: TObject);
    procedure LocalizaProduto();
    procedure gridProdutoKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmLozalizaProd: TfrmLozalizaProd;
  LocalizaCodigoProd : string ;


implementation

{$R *.dfm}
uses dmconexao;

procedure TfrmLozalizaProd.edtPesquisaProdutoChange(Sender: TObject);
begin
  LocalizaProduto;
end;

procedure TfrmLozalizaProd.gridProdutoKeyPress(Sender: TObject; var Key: Char);
begin
       if key = #13 then
   begin
     LocalizaCodigoProd  := dmconexoes.qrEstoque.FieldByName('codigo').AsString;
     edtPesquisaProduto.Text := '';
     frmLozalizaProd.Close;

   end;
end;

procedure TfrmLozalizaProd.LocalizaProduto;
begin
  with dmConexoes.qrEstoque do
    begin
      Close;
      sql.Clear;
      sql.Add('SELECT * FROM produtos WHERE (CODIGO IS NOT NULL) ');

      //*** Filtrar Produtos ***//
      if (trim(edtPesquisaProduto.Text) <> '') then
        begin
          SQL.Add('AND (Descricao LIKE :pDescricao');
          SQL.Add('OR CAST(CodBarras AS VARCHAR(50)) LIKE :pCodBarras)');
          Parameters.ParamByName('pDescricao').Value      := '%'+edtPesquisaProduto.Text+'%';
          Parameters.ParamByName('pCodBarras').Value       := '%'+edtPesquisaProduto.Text+'%';
        end;

      Open;
    end;
end;

end.
