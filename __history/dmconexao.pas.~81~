unit dmconexao;

interface

uses
  System.SysUtils, System.Classes, Data.DB, Data.Win.ADODB, Vcl.Dialogs;

type
  TdmConexoes = class(TDataModule)
    conRobson: TADOConnection;

    // -------------------------------------------------------
    // qrEstoque - Query principal de produtos
    // -------------------------------------------------------
    qrEstoque: TADOQuery;
    qrEstoquecodigo: TAutoIncField;
    qrEstoquequantidade: TIntegerField;
    qrEstoquedescricao: TWideStringField;
    qrEstoquedata: TDateTimeField;
    qrEstoquevalorvenda: TBCDField;
    qrEstoquetipo: TStringField;
    qrEstoquevalorcusto: TBCDField;
    qrEstoqueCodBarras: TStringField;
    qrEstoquelinha: TStringField;
    qrEstoquegrupo: TStringField;
    qrEstoquencm: TStringField;
    qrEstoquemodelo: TStringField;
    qrEstoqueunidade: TStringField;
    qrEstoquepesogramas: TBCDField;
    qrEstoquefornecedor: TStringField;
    qrEstoquedata_compra: TWideStringField;
    qrEstoqueestoque_inicial: TIntegerField;
    qrEstoquecusto_unitario: TBCDField;
    qrEstoquecusto_total: TBCDField;
    qrEstoquetamanho: TStringField;
    qrEstoquecor: TStringField;
    qrEstoquecod_tamanho: TIntegerField;
    qrEstoqueqtde_minima: TIntegerField;
    qrEstoquemargem_lucro: TBCDField;
    qrEstoquepreco_de: TBCDField;
    qrEstoquemarkup: TBCDField;
    // Tributacoes
    qrEstoquecfop: TStringField;
    qrEstoqueorigem: TStringField;
    qrEstoqueun_trib: TStringField;
    qrEstoquecsosn: TStringField;
    qrEstoquealiq_icms: TBCDField;
    qrEstoquebc_icms: TBCDField;
    qrEstoquecst_pis: TStringField;
    qrEstoquealiq_pis: TBCDField;
    qrEstoquecst_cofins: TStringField;
    qrEstoquealiq_cofins: TBCDField;

    // -------------------------------------------------------
    // Queries auxiliares
    // -------------------------------------------------------
    vwGerarNumCliente: TADOQuery;

    qrComanda: TADOQuery;
    qrComandaCod_Comanda: TIntegerField;
    qrComandaNom_Comanda: TStringField;
    qrComandaStatus_Comanda: TStringField;
    qrComandaEstad_Comanda: TStringField;

    qrVendas: TADOQuery;
    qrItensVenda: TADOQuery;
    qrComando: TADOQuery;

    dsEstoque: TDataSource;
    dsCliente: TDataSource;
    dsProduto: TDataSource;

    qrCaixa: TADOQuery;

    qrCliente: TADOQuery;

    qrUsuario: TADOQuery;
    dsUsuario: TDataSource;

    // Grid auxiliar de calculo (usado no DBGrid de valores)
    ADOQueryGrid: TADOQuery;
    ADOQueryGridquantidade: TIntegerField;
    ADOQueryGridvalorcusto: TBCDField;
    ADOQueryGridcusto_total: TBCDField;
    ADOQueryGridmarkup: TBCDField;
    ADOQueryGridvalorvenda: TBCDField;

    // Query de calculo por produto especifico
    CalculoProdutos: TADOQuery;
    CalculoProdutosquantidade: TIntegerField;
    CalculoProdutosvalorcusto: TBCDField;
    CalculoProdutoscusto_total: TBCDField;
    CalculoProdutosmarkup: TBCDField;
    CalculoProdutosvalorvenda: TBCDField;

    // Query de estoque para markup (sem fields persistentes)
    Estoquemarkup: TADOQuery;
    qrClienteCodCli: TAutoIncField;
    qrClientenome: TWideStringField;
    qrClienteendereco: TWideStringField;
    qrClientenumeroresidencia: TWideStringField;
    qrClientetelefone: TStringField;
    qrClientecpf: TStringField;
    qrClienterg: TStringField;
    qrClienteproduto: TWideStringField;
    qrClientevalor: TIntegerField;
    qrClientevalorfiado: TBCDField;
    qrClientedatacadastrocliente: TDateTimeField;
    qrEstoquevalorvendaTotal: TBCDField;
    dsVenda: TDataSource;

    procedure qrEstoqueCalcFields(DataSet: TDataSet);
    procedure CalculoProdutosAfterScroll(DataSet: TDataSet);
    procedure qrEstoquemarkupChange(Sender: TField);

  private
    { Private declarations }
  public
    function CaixaAberto: Boolean;
    function AbrirCaixa(AValorInicial: Currency): Boolean;
    function TotalVendasCaixaAtual: Currency;
    function FecharCaixa: Boolean;
  end;

var
  dmConexoes: TdmConexoes;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

// ============================================================
// CAIXA
// ============================================================

function TdmConexoes.CaixaAberto: Boolean;
begin
  qrCaixa.Close;
  qrCaixa.SQL.Clear;
  qrCaixa.SQL.Add('SELECT TOP 1 1 FROM Caixa WHERE Status = :Status');
  qrCaixa.Parameters.ParamByName('Status').Value := 'A';
  qrCaixa.Open;
  Result := not qrCaixa.IsEmpty;
end;

function TdmConexoes.AbrirCaixa(AValorInicial: Currency): Boolean;
begin
  Result := False;
  if AValorInicial < 0 then Exit;
  if CaixaAberto then Exit;

  qrCaixa.Close;
  qrCaixa.SQL.Clear;
  qrCaixa.SQL.Add(
    'INSERT INTO Caixa (DataAbertura, ValorAbertura, Status) ' +
    'VALUES (GETDATE(), :Valor, ''A'')'
  );
  qrCaixa.Parameters.ParamByName('Valor').Value := AValorInicial;
  qrCaixa.ExecSQL;
  Result := True;
end;

function TdmConexoes.TotalVendasCaixaAtual: Currency;
var
  qrTemp: TADOQuery;
begin
  Result := 0;
  qrTemp := TADOQuery.Create(nil);
  try
    qrTemp.Connection := conRobson;
    qrTemp.SQL.Add(
      'SELECT ISNULL(SUM(ValorTotal), 0) AS TotalVendas ' +
      'FROM VENDAS ' +
      'WHERE CAST(DataVenda AS DATE) >= (' +
      '  SELECT CAST(MAX(DataAbertura) AS DATE) FROM Caixa WHERE Status = ''A''' +
      ')'
    );
    qrTemp.Open;
    Result := qrTemp.FieldByName('TotalVendas').AsCurrency;
  finally
    qrTemp.Free;
  end;
end;

function TdmConexoes.FecharCaixa: Boolean;
var
  ValorAbertura, TotalVendas, ValorFinal: Currency;
begin
  Result := False;
  if not CaixaAberto then Exit;

  // Busca o valor de abertura do caixa atual
  qrCaixa.Close;
  qrCaixa.SQL.Clear;
  qrCaixa.SQL.Add(
    'SELECT ValorAbertura FROM Caixa ' +
    'WHERE Status = ''A'' ' +
    'AND DataAbertura = (SELECT MAX(DataAbertura) FROM Caixa WHERE Status = ''A'')'
  );
  qrCaixa.Open;
  ValorAbertura := qrCaixa.FieldByName('ValorAbertura').AsCurrency;

  // Soma as vendas desde a abertura do caixa
  TotalVendas := TotalVendasCaixaAtual;

  // Saldo final = valor inicial + total vendas
  ValorFinal := ValorAbertura + TotalVendas;

  // Fecha o caixa com o saldo calculado
  qrCaixa.Close;
  qrCaixa.SQL.Clear;
  qrCaixa.SQL.Add(
    'UPDATE Caixa SET ' +
    'DataFechamento = GETDATE(), ' +
    'ValorFechamento = :ValorFinal, ' +
    'Status = ''F'' ' +
    'WHERE Status = ''A'' ' +
    'AND DataAbertura = (SELECT MAX(DataAbertura) FROM Caixa WHERE Status = ''A'')'
  );
  qrCaixa.Parameters.ParamByName('ValorFinal').Value := ValorFinal;
  qrCaixa.ExecSQL;
  Result := True;
end;

// ============================================================
// ESTOQUE - CALCFIELDS
// ============================================================

procedure TdmConexoes.qrEstoqueCalcFields(DataSet: TDataSet);
begin
  try
    DataSet.FieldByName('custo_total').AsFloat :=
      DataSet.FieldByName('quantidade').AsFloat *
      DataSet.FieldByName('valorcusto').AsFloat;

    DataSet.FieldByName('valorvenda').AsFloat :=
      DataSet.FieldByName('valorcusto').AsFloat *
      (1 + DataSet.FieldByName('markup').AsFloat / 100);
  except
  end;
end;

// ============================================================
// ESTOQUE - ONCHANGE DO MARKUP
// ============================================================

procedure TdmConexoes.qrEstoquemarkupChange(Sender: TField);
var
  Custo, Markup: Double;
begin
  try
    Custo  := qrEstoquevalorcusto.AsFloat;
    Markup := qrEstoquemarkup.AsFloat;

    qrEstoquevalorvenda.AsFloat  := Custo * (1 + Markup / 100);
    qrEstoquecusto_total.AsFloat := qrEstoquequantidade.AsFloat * Custo;
  except
    on E: Exception do
      ShowMessage('Erro no calculo do Markup: ' + E.Message);
  end;
end;

// ============================================================
// CALCULO PRODUTOS - AFTERSCROLL
// ============================================================

procedure TdmConexoes.CalculoProdutosAfterScroll(DataSet: TDataSet);
begin
  dmConexoes.ADOQueryGrid.Close;
  dmConexoes.ADOQueryGrid.Parameters.ParamByName('pcodigo').Value :=
    dmConexoes.CalculoProdutos.FieldByName('codigo').AsInteger;
  dmConexoes.ADOQueryGrid.Open;
end;

end.
