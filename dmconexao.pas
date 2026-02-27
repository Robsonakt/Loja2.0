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
    qrEstoqueCodBarras: TStringField;       // VARCHAR - nao Integer
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
    qrVendasCodCli: TIntegerField;
    qrVendasData: TWideStringField;
    qrVendasValorTotal: TBCDField;
    qrVendasValorRestante: TBCDField;
    qrVendasValorPago: TBCDField;
    qrVendasDataVenda: TDateTimeField;
    qrVendasCodVenda: TIntegerField;
    qrVendasDescriProd: TStringField;
    qrVendasQuantidade: TIntegerField;
    qrVendasValorProdUni: TBCDField;

    qrItensVenda: TADOQuery;
    qrItensVendaCodigo: TIntegerField;
    qrItensVendaCodItem: TIntegerField;
    qrItensVendaCodVenda: TIntegerField;
    qrItensVendaDescricao: TStringField;
    qrItensVendaValorTotal: TBCDField;
    qrItensVendaQuantidade: TIntegerField;
    qrItensVendaValorProdUni: TBCDField;
    qrItensVendaDataVenda: TDateTimeField;

    dsEstoque: TDataSource;
    dsCliente: TDataSource;
    dsProduto: TDataSource;

    qrCaixa: TADOQuery;

    qrCliente: TADOQuery;
    qrClientecodigo: TAutoIncField;
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

    procedure qrEstoqueCalcFields(DataSet: TDataSet);
    procedure CalculoProdutosAfterScroll(DataSet: TDataSet);
    procedure qrEstoquemarkupChange(Sender: TField);

  private
    { Private declarations }
  public
    function CaixaAberto: Boolean;
    function AbrirCaixa(AValorInicial: Currency): Boolean;
    function FecharCaixa(AValorFinal: Currency): Boolean;
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

function TdmConexoes.FecharCaixa(AValorFinal: Currency): Boolean;
begin
  Result := False;
  if not CaixaAberto then Exit;

  qrCaixa.Close;
  qrCaixa.SQL.Clear;
  qrCaixa.SQL.Add(
    'UPDATE Caixa SET ' +
    'DataFechamento = GETDATE(), ' +
    'ValorFechamento = :ValorFinal, ' +
    'Status = ''F'' ' +
    'WHERE Status = ''A'' ' +
    'AND DataAbertura = (' +
    '  SELECT MAX(DataAbertura) FROM Caixa WHERE Status = ''A'' ' +
    ')'
  );
  qrCaixa.Parameters.ParamByName('ValorFinal').Value := AValorFinal;
  qrCaixa.ExecSQL;
  Result := True;
end;

// ============================================================
// ESTOQUE - CALCFIELDS
// Calcula custo_total e valorvenda automaticamente ao navegar
// ============================================================

procedure TdmConexoes.qrEstoqueCalcFields(DataSet: TDataSet);
var
  Qtde, Custo, Markup, Denominador: Double;
begin
  if DataSet.State in [dsEdit, dsInsert] then
    Exit;

  try
    Qtde   := DataSet.FieldByName('quantidade').AsFloat;
    Custo  := DataSet.FieldByName('valorcusto').AsFloat;
    Markup := DataSet.FieldByName('markup').AsFloat;

    DataSet.FieldByName('custo_total').AsFloat := Qtde * Custo;

    Denominador := 1 - (Markup / 100);
    if (Custo > 0) and (Denominador > 0) then
      DataSet.FieldByName('valorvenda').AsFloat := Custo / Denominador
    else
      DataSet.FieldByName('valorvenda').AsFloat := 0;

  except
    on E: Exception do
      ShowMessage('Erro no CalcFields: ' + E.Message);
  end;
end;

// ============================================================
// ESTOQUE - ONCHANGE DO MARKUP
// Recalcula valor de venda em tempo real quando usuario
// digita novo markup na DBGrid e pressiona Enter
// ============================================================

procedure TdmConexoes.qrEstoquemarkupChange(Sender: TField);
var
  Custo, Markup, Denominador: Double;
begin
  try
    Custo  := qrEstoquevalorcusto.AsFloat;
    Markup := qrEstoquemarkup.AsFloat;

    Denominador := 1 - (Markup / 100);

    if (Custo > 0) and (Denominador > 0) then
      qrEstoquevalorvenda.AsFloat := Custo / Denominador
    else
      qrEstoquevalorvenda.AsFloat := 0;

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
