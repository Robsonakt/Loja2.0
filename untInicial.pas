unit untInicial;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  Vcl.Imaging.pngimage, Vcl.ExtCtrls, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.Menus, Vcl.StdCtrls, Data.Win.ADODB;

type
  TFormularioPrincipal = class(TForm)
    Panel2: TPanel;
    Panel3: TPanel;
    PnConsultFecha: TPanel;
    PnAbertura: TPanel;
    PnConsulta: TPanel;
    PnOrcamento: TPanel;
    PnFechamento: TPanel;
    MainMenu1: TMainMenu;
    Cadastro1: TMenuItem;
    Estoque1: TMenuItem;
    Cliente1: TMenuItem;
    Empresa1: TMenuItem;
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
    XML1: TMenuItem;
    EntradaXML1: TMenuItem;
    ConsultaXML1: TMenuItem;
    EmissaoXML1: TMenuItem;
    pnlTopoInicial: TPanel;
    lblTituloInicial: TLabel;
    pnlMenuEsq: TPanel;
    lblMenuTitulo: TLabel;
    lblTituloStatus: TLabel;
    lblCaixaLabel: TLabel;
    lblRodapeInicial: TLabel;
    lblRRJ: TLabel;
    Panel1: TPanel;

    procedure PnAberturaMouseEnter(Sender: TObject);
    procedure PnAberturaMouseLeave(Sender: TObject);
    procedure Estoque1Click(Sender: TObject);
    procedure PnAberturaClick(Sender: TObject);
    procedure PnFechamentoClick(Sender: TObject);
    procedure Cliente1Click(Sender: TObject);
    procedure Empresa1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Cadastro2Click(Sender: TObject);
    procedure PnConsultaClick(Sender: TObject);
    procedure PnOrcamentoClick(Sender: TObject);
    procedure PnConsultFechaClick(Sender: TObject);
    procedure Panel1Click(Sender: TObject);
    procedure EntradaXML1Click(Sender: TObject);
    procedure ConsultaXML1Click(Sender: TObject);
    procedure EmissaoXML1Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    procedure AtualizarStatusCaixa;
  end;

var
  FormularioPrincipal: TFormularioPrincipal;
  keyEnter: char = #13;

implementation

uses
  untCadastroProd, untCadastroCli, untConsultavendas, untRelatorioProd,
  untVenda, untRelatorioVenda, dmconexao, untCadastroUsuario, untLogUser,
  untOrcamento, untConsultaOrcamento, untConsultaFechamento,
  untCadastroEmpresa, untEntradaNotasXML, untConsultaXML, untEmissaoXML;

{$R *.dfm}

procedure TFormularioPrincipal.EntradaXML1Click(Sender: TObject);
var
  F: TfrmEntradaNotasXML;
begin
  F := TfrmEntradaNotasXML.Create(Self);
  try
    F.ShowModal;
  finally
    F.Free;
  end;
end;

procedure TFormularioPrincipal.ConsultaXML1Click(Sender: TObject);
var
  F: TfrmConsultaXML;
begin
  F := TfrmConsultaXML.Create(Self);
  try
    F.ShowModal;
  finally
    F.Free;
  end;
end;

procedure TFormularioPrincipal.EmissaoXML1Click(Sender: TObject);
var
  F: TfrmEmissaoXML;
begin
  F := TfrmEmissaoXML.Create(Self);
  try
    F.ShowModal;
  finally
    F.Free;
  end;
end;

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

procedure TFormularioPrincipal.Empresa1Click(Sender: TObject);
begin
  Application.CreateForm(TfrmCadastroEmpresa, frmCadastroEmpresa);
  frmCadastroEmpresa.ShowModal;
  frmCadastroEmpresa.Free;
end;

procedure TFormularioPrincipal.PnFechamentoClick(Sender: TObject);
var
  ValorAbertura, TotalVendas, TotalFiado, TotalLucro, ValorFinal: Currency;
  IdCaixa: Integer;
  Msg: string;
begin
  IdCaixa := dmConexoes.IdCaixaAtual;
  if IdCaixa <= 0 then
  begin
    ShowMessage('Nao existe caixa aberto para fechamento.');
    Exit;
  end;

  // Valor de abertura do caixa aberto
  dmConexoes.qrCaixa.Close;
  dmConexoes.qrCaixa.SQL.Text := 'SELECT ValorAbertura FROM Caixa WHERE Id = :IdCaixa';
  dmConexoes.qrCaixa.Parameters.ParamByName('IdCaixa').Value := IdCaixa;
  dmConexoes.qrCaixa.Open;
  ValorAbertura := dmConexoes.qrCaixa.FieldByName('ValorAbertura').AsCurrency;
  dmConexoes.qrCaixa.Close;

  // Mesmos calculos usados no fechamento (dmConexoes.FecharCaixa)
  TotalVendas := dmConexoes.TotalVendasCaixaAtual;
  TotalFiado  := dmConexoes.TotalFiadoCaixa(IdCaixa);
  TotalLucro  := dmConexoes.LucroCaixa(IdCaixa);

  // Saldo final = abertura + vendas + fiado recebido
  ValorFinal := ValorAbertura + TotalVendas + TotalFiado;

  // Exibe resumo
  Msg := 'RESUMO DO CAIXA' + #13#10 +
         '____________________________' + #13#10 +
         'Valor inicial:    R$ ' + FormatFloat('#,##0.00', ValorAbertura) + #13#10 +
         'Total de vendas:  R$ ' + FormatFloat('#,##0.00', TotalVendas)  + #13#10 +
         'Fiado recebido:   R$ ' + FormatFloat('#,##0.00', TotalFiado)   + #13#10 +
         '____________________________' + #13#10 +
         'Saldo final:      R$ ' + FormatFloat('#,##0.00', ValorFinal)   + #13#10 +
         'Lucro do caixa:   R$ ' + FormatFloat('#,##0.00', TotalLucro)   + #13#10#10 +
         'Deseja fechar o caixa?';

  if MessageBox(Handle, PChar(Msg), 'Fechamento de Caixa',
       MB_YESNO or MB_ICONQUESTION) = IDYES then
  begin
    if dmConexoes.FecharCaixa then
    begin
      ShowMessage('Caixa fechado com sucesso!');
      AtualizarStatusCaixa;
    end
    else
      ShowMessage('Erro ao fechar o caixa.');
  end;
end;

procedure TFormularioPrincipal.PnOrcamentoClick(Sender: TObject);
var
  frmOrc: TfrmOrcamento;
begin
  frmOrc := TfrmOrcamento.Create(Self);
  try
    frmOrc.ShowModal;
  finally
    frmOrc.Free;
  end;
end;

procedure TFormularioPrincipal.PnAberturaMouseEnter(Sender: TObject);
begin
  TPanel(Sender).Color := $00E2E8E7;
  TPanel(Sender).Font.Color := clBackground;
end;

procedure TFormularioPrincipal.PnAberturaMouseLeave(Sender: TObject);
begin
  TPanel(Sender).Color := $00666666;
  TPanel(Sender).Font.Color := clWhite;
end;

procedure TFormularioPrincipal.PnConsultaClick(Sender: TObject);
begin
      Application.CreateForm(TfrmConsulta_Venda, frmConsulta_Venda);
    try
      frmConsulta_Venda.ShowModal;
    finally
      frmConsulta_Venda.Free;
    end;
    Exit;
end;

procedure TFormularioPrincipal.PnConsultFechaClick(Sender: TObject);
begin
      Application.CreateForm(TfrmConsultaOrcamento, frmConsultaOrcamento);
    try
      frmConsultaOrcamento.ShowModal;
    finally
      frmConsultaOrcamento.Free;
    end;
    Exit;
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

procedure TFormularioPrincipal.Panel1Click(Sender: TObject);
var frmFech: TfrmConsultaFechamento;
begin
  frmFech := TfrmConsultaFechamento.Create(Self);
  try
    frmFech.ShowModal;
  finally
    frmFech.Free;
  end;
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

  if (not TryStrParaMoeda(ValorStr, ValorInicial)) or (ValorInicial < 0) then
  begin
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
