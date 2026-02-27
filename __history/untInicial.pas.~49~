unit untInicial;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  Vcl.Imaging.pngimage, Vcl.ExtCtrls, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.Menus, Vcl.StdCtrls;

type
  TFormularioPrincipal = class(TForm)
    Panel2: TPanel;
    Panel3: TPanel;
    PnConsultFecha: TPanel;
    PnAbertura: TPanel;
    PnConsulta: TPanel;
    PnVenda: TPanel;
    PnFechamento: TPanel;
    MainMenu1: TMainMenu;
    Cadastro1: TMenuItem;
    Estoque1: TMenuItem;
    Cliente1: TMenuItem;
    dsCliente: TDataSource;
    dsProduto: TDataSource;
    fdCliente: TFDMemTable;
    fdClienteNumero: TIntegerField;
    fdClienteDataVencimento: TDateField;
    fdClienteValor: TCurrencyField;
    fdProduto: TFDMemTable;
    IntegerField1: TIntegerField;
    DateField1: TDateField;
    CurrencyField1: TCurrencyField;
    FDMemTable1: TFDMemTable;
    IntegerField2: TIntegerField;
    DateField2: TDateField;
    CurrencyField2: TCurrencyField;
    DataSource1: TDataSource;
    lblTextoAbertura: TLabel;
    lblCaixa: TLabel;
    Usurio1: TMenuItem;
    Cadastro2: TMenuItem;
    pnlTopoInicial: TPanel;
    lblTituloInicial: TLabel;
    pnlMenuEsq: TPanel;
    lblMenuTitulo: TLabel;
    AtualizarStatusCaixaPanel: TPanel;
    lblTituloStatus: TLabel;
    lblCaixaLabel: TLabel;
    lblRodapeInicial: TLabel;
    lblRRJ: TLabel;

    procedure PnAberturaMouseEnter(Sender: TObject);
    procedure PnAberturaMouseLeave(Sender: TObject);
    procedure Estoque1Click(Sender: TObject);
    procedure PnAberturaClick(Sender: TObject);
    procedure PnFechamentoClick(Sender: TObject);
    procedure Cliente1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Cadastro2Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    procedure AtualizarStatusCaixa;
  end;

var
  FormularioPrincipal: TFormularioPrincipal;

implementation

uses
  untCadastroProd, untCadastroCli, untConsultavendas, untRelatorioProd,
  untVenda, untRelatorioVenda, dmconexao, untCadastroUsuario, untLogUser;

{$R *.dfm}

procedure TFormularioPrincipal.AtualizarStatusCaixa;
begin
  if dmConexoes.CaixaAberto then
  begin
    lblCaixa.Caption := 'Caixa Aberto';
    lblCaixa.Font.Color := clGreen;
    lblTextoAbertura.Caption := 'Iniciar Vendas';
  end
  else
  begin
    lblCaixa.Caption := 'Caixa Fechado';
    lblCaixa.Font.Color := clRed;
    lblTextoAbertura.Caption := 'Abrir Caixa';
  end;
end;

procedure TFormularioPrincipal.Cadastro2Click(Sender: TObject);
begin
  Application.CreateForm(TFrmCadastroUsuario, FrmCadastroUsuario);
  FrmCadastroUsuario.ShowModal;
  FrmCadastroUsuario.Free;
end;

procedure TFormularioPrincipal.Cliente1Click(Sender: TObject);
begin
  Application.CreateForm(TfrmCadastroCliente, frmCadastroCliente);
  frmCadastroCliente.ShowModal;
  frmCadastroCliente.Free;
end;

procedure TFormularioPrincipal.PnFechamentoClick(Sender: TObject);
var
  ValorStr: string;
  ValorFinal: Currency;
begin
  if not dmConexoes.CaixaAberto then
  begin
    ShowMessage('N'#227'o existe caixa aberto para fechamento.');
    Exit;
  end;

  ValorStr := '0,00';

  if not InputQuery('Fechamento de Caixa', 'Informe o valor final em caixa:', ValorStr) then
    Exit;

  if ValorStr.Trim = '' then
    Exit;

  try
    ValorFinal := StrToCurr(ValorStr);
  except
    ShowMessage('Valor inv'#225'lido.');
    Exit;
  end;

  if dmConexoes.FecharCaixa(ValorFinal) then
  begin
    ShowMessage('Caixa fechado com sucesso!');
    AtualizarStatusCaixa;
  end
  else
    ShowMessage('Erro ao fechar o caixa.');
end;

procedure TFormularioPrincipal.PnAberturaMouseEnter(Sender: TObject);
begin
  TPanel(Sender).Color := $00333333;
  TPanel(Sender).Font.Color := clWhite;
end;

procedure TFormularioPrincipal.PnAberturaMouseLeave(Sender: TObject);
begin
  TPanel(Sender).Color := $00666666;
  TPanel(Sender).Font.Color := clWhite;
end;

procedure TFormularioPrincipal.Estoque1Click(Sender: TObject);
begin
  Application.CreateForm(TfrmCadastroProdutos, frmCadastroProdutos);
  frmCadastroProdutos.ShowModal;
  frmCadastroProdutos.Free;
end;

procedure TFormularioPrincipal.FormShow(Sender: TObject);
begin
  AtualizarStatusCaixa;
  Application.CreateForm(TfrmLogin, frmLogin);
  frmLogin.ShowModal;
  frmLogin.Free;
end;

procedure TFormularioPrincipal.PnAberturaClick(Sender: TObject);
var
  ValorStr: string;
  ValorInicial: Currency;
begin
  if dmConexoes.CaixaAberto then
  begin
    Application.CreateForm(TfrmCaixaVendas, frmCaixaVendas);
    try
      frmCaixaVendas.ShowModal;
    finally
      frmCaixaVendas.Free;
    end;
    Exit;
  end;

  MessageBox(
    Handle,
    'Caixa fechado.'#13#10''#201' necess'#225'rio abrir o caixa para iniciar as vendas.',
    'Caixa',
    MB_OK or MB_ICONWARNING
  );

  ValorStr := '0,00';

  if not InputQuery('Abertura de Caixa', 'Informe o valor inicial do caixa:', ValorStr) then
    Exit;

  if ValorStr.Trim = '' then
    Exit;

  try
    ValorInicial := StrToCurr(ValorStr);
  except
    ShowMessage('Valor inv'#225'lido.');
    Exit;
  end;

  if dmConexoes.AbrirCaixa(ValorInicial) then
  begin
    ShowMessage('Caixa aberto com sucesso!');
    AtualizarStatusCaixa;
    Application.CreateForm(TfrmCaixaVendas, frmCaixaVendas);
    try
      frmCaixaVendas.ShowModal;
    finally
      frmCaixaVendas.Free;
    end;
  end;
end;

end.
