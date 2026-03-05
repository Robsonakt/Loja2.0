unit untVenda;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Data.DB, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  ACBrBase, ACBrPosPrinter, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  Vcl.Buttons, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls, Vcl.DBCtrls,
  Vcl.Grids, Vcl.DBGrids, Vcl.ComCtrls;

type
  TfrmCaixaVendas = class(TForm)
    pnlTopo: TPanel;
    lblTitulo: TLabel;
    pnlRodape: TPanel;
    lblStatus: TLabel;
    lblRodape: TLabel;
    pnlCliente: TPanel;
    grpIdentificacao: TGroupBox;
    Label1: TLabel;
    lbNomeCli: TLabel;
    Label2: TLabel;
    lbDataVenda: TLabel;
    EdtNameCliente: TEdit;
    edtCodVenda: TEdit;
    edtDataVenda: TMaskEdit;
    grpItens: TGroupBox;
    DBGrid1: TDBGrid;
    grpProduto: TGroupBox;
    edtprod: TLabel;
    lbNomeProd: TLabel;
    lbValorUni: TLabel;
    lbquant: TLabel;
    lbValTotal: TLabel;
    lbQuantRest: TLabel;
    edtCodProd: TEdit;
    edtValorProd: TDBEdit;
    edtQuant: TEdit;
    edtValorTotal: TEdit;
    edtQuantRest: TDBEdit;
    pnlDireito: TPanel;
    pnlTotal: TPanel;
    lbTotalVend: TLabel;
    lbvalorDinheiro: TLabel;
    grpObs: TGroupBox;
    Memo1: TMemo;
    grpAcoes: TGroupBox;
    PnVenda: TPanel;
    Pnfiado: TPanel;
    PnImpressora: TPanel;
    PnConfirmaItem: TPanel;
    DSItensVenda: TDataSource;
    fdProduto: TFDMemTable;
    fdProdutoCodProd: TIntegerField;
    fdProdutoDescricao: TStringField;
    fdProdutoQuantidade: TIntegerField;
    fdProdutoValorUni: TCurrencyField;
    fdProdutoValorTotal: TCurrencyField;
    fdProdutoCodVenda: TIntegerField;
    fdProdutoCodCli: TStringField;
    ACBrPosPrinter1: TACBrPosPrinter;

    procedure PnVendaClick(Sender: TObject);
    procedure PnVendaMouseEnter(Sender: TObject);
    procedure PnVendaMouseLeave(Sender: TObject);
    procedure PnfiadoClick(Sender: TObject);
    procedure PnfiadoMouseEnter(Sender: TObject);
    procedure PnfiadoMouseLeave(Sender: TObject);
    procedure PnImpressoraClick(Sender: TObject);
    procedure PnImpressoraMouseEnter(Sender: TObject);
    procedure PnImpressoraMouseLeave(Sender: TObject);
    procedure PnConfirmaItemClick(Sender: TObject);
    procedure PnConfirmaItemMouseEnter(Sender: TObject);
    procedure PnConfirmaItemMouseLeave(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCaixaVendas: TfrmCaixaVendas;
  quantidade: Integer;
  totalvalor: Currency;
  cfg_Empresa: string;
  cfg_Endereco: string;
  cfg_Telefone: string;

implementation

{$R *.dfm}

uses dmConexao, untInicial, untCadastroProd;

procedure TfrmCaixaVendas.PnVendaClick(Sender: TObject);
begin
  // TODO: finalizar venda
end;

procedure TfrmCaixaVendas.PnVendaMouseEnter(Sender: TObject);
begin
  PnVenda.Color := clGreen;
  PnVenda.Font.Color := clWhite;
end;

procedure TfrmCaixaVendas.PnVendaMouseLeave(Sender: TObject);
begin
  PnVenda.Color := 2236962;
  PnVenda.Font.Color := clWhite;
end;

procedure TfrmCaixaVendas.PnfiadoClick(Sender: TObject);
begin
  // TODO: registrar fiado
end;

procedure TfrmCaixaVendas.PnfiadoMouseEnter(Sender: TObject);
begin
  Pnfiado.Color := $001E8FBF;
  Pnfiado.Font.Color := clWhite;
end;

procedure TfrmCaixaVendas.PnfiadoMouseLeave(Sender: TObject);
begin
  Pnfiado.Color := 2236962;
  Pnfiado.Font.Color := clWhite;
end;

procedure TfrmCaixaVendas.PnImpressoraClick(Sender: TObject);
begin
  // TODO: imprimir
end;

procedure TfrmCaixaVendas.PnImpressoraMouseEnter(Sender: TObject);
begin
  PnImpressora.Color := $00CC6600;
  PnImpressora.Font.Color := clWhite;
end;

procedure TfrmCaixaVendas.PnImpressoraMouseLeave(Sender: TObject);
begin
  PnImpressora.Color := 2236962;
  PnImpressora.Font.Color := clWhite;
end;

procedure TfrmCaixaVendas.PnConfirmaItemClick(Sender: TObject);
begin
  // TODO: confirmar item
end;

procedure TfrmCaixaVendas.PnConfirmaItemMouseEnter(Sender: TObject);
begin
  PnConfirmaItem.Color := clGreen;
  PnConfirmaItem.Font.Color := clWhite;
end;

procedure TfrmCaixaVendas.PnConfirmaItemMouseLeave(Sender: TObject);
begin
  PnConfirmaItem.Color := 2236962;
  PnConfirmaItem.Font.Color := clWhite;
end;

end.
