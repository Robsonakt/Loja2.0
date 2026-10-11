unit dmconexao;

interface

uses
  System.SysUtils, System.Classes, Data.DB, Data.Win.ADODB,
  Vcl.Dialogs, Vcl.Forms, IniFiles,Winapi.Messages,Winapi.Windows;

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
    qrClientecliente_padrao: TBooleanField;
    qrEstoquevalorvendaTotal: TBCDField;
    dsVenda: TDataSource;
    qrItensOrcamento: TADOQuery;
    dsOrcitens: TDataSource;
    qrEmpresa: TADOQuery;

    procedure qrEstoqueCalcFields(DataSet: TDataSet);
    procedure CalculoProdutosAfterScroll(DataSet: TDataSet);
    procedure qrEstoquemarkupChange(Sender: TField);
    procedure qrEstoquevalorvendaChange(Sender: TField);
    procedure qrEstoquevalorcustoChange(Sender: TField);
    procedure CarregarConfiguracoes;
    procedure DataModuleCreate(Sender: TObject);

  private
    FAtualizandoPrecos: Boolean;
    FEstruturaVendasOk: Boolean;
public
  // Usuario que fez login (nao depende do qrUsuario, que e reaberto em outras telas)
  UsuarioLogado: string;
  procedure GarantirEstruturaVendas;
  function IdCaixaAtual: Integer;
  function TotalFiadoCaixa(AIdCaixa: Integer): Currency;
  function LucroCaixa(AIdCaixa: Integer): Currency;
  function EstornarVenda(ACodVenda: Integer): Integer;
  function CaixaAberto: Boolean;
  function AbrirCaixa(AValorInicial: Currency): Boolean;
  function TotalVendasCaixaAtual: Currency;
  function FecharCaixa: Boolean;
  function VerificarLicenca: Integer;
  function PortaImpressora: string;
  function NomeEmpresa: string;
  function EnderecoEmpresa: string;
  function TelefoneEmpresa: string;
  function ModeloImpressora: Integer;

  end;
var
  dmConexoes: TdmConexoes;
  cfg_Empresa  : string;
  cfg_Endereco : string;
  cfg_Telefone : string;
  cfg_Porta    : string;
  cfg_Modelo  : Integer;

// Converte texto digitado (ex.: "1.234,56", "1234.56", "R$ 20,98") em valor.
// Retorna False quando o texto nao e um numero valido.
function TryStrParaMoeda(const ATexto: string; out AValor: Currency): Boolean;
function StrParaMoeda(const ATexto: string): Currency;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

// ============================================================
// CONEXAO - le os dados do banco do config.ini (fora do Git)
// ============================================================

procedure TdmConexoes.DataModuleCreate(Sender: TObject);
var
  INI: TIniFile;
  Servidor, Banco, Usuario, Senha: string;
begin
  INI := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'config.ini');
  try
    Servidor := INI.ReadString('Banco', 'Servidor', '.');
    Banco    := INI.ReadString('Banco', 'Banco', 'LojaNova');
    Usuario  := INI.ReadString('Banco', 'Usuario', 'sa');
    Senha    := INI.ReadString('Banco', 'Senha', '');
  finally
    INI.Free;
  end;

  conRobson.Connected := False;
  conRobson.ConnectionString :=
    'Provider=SQLOLEDB.1;Persist Security Info=False;' +
    'User ID=' + Usuario + ';Password="' + Senha + '";' +
    'Initial Catalog=' + Banco + ';Data Source=' + Servidor + ';' +
    'Use Procedure for Prepare=1;Auto Translate=True;Packet Size=4096;' +
    'Use Encryption for Data=False;Tag with column collation when possible=False';
end;

function TryStrParaMoeda(const ATexto: string; out AValor: Currency): Boolean;
var
  S: string;
begin
  S := Trim(StringReplace(ATexto, 'R$', '', [rfReplaceAll, rfIgnoreCase]));
  S := StringReplace(S, ' ', '', [rfReplaceAll]);
  if Pos(',', S) > 0 then
  begin
    // formato brasileiro: ponto = milhar, virgula = decimal
    S := StringReplace(S, '.', '', [rfReplaceAll]);
    S := StringReplace(S, ',', FormatSettings.DecimalSeparator, [rfReplaceAll]);
  end
  else
    S := StringReplace(S, '.', FormatSettings.DecimalSeparator, [rfReplaceAll]);
  Result := (S <> '') and TryStrToCurr(S, AValor);
  if not Result then
    AValor := 0;
end;

function StrParaMoeda(const ATexto: string): Currency;
begin
  TryStrParaMoeda(ATexto, Result);
end;

// ============================================================
// ESTRUTURA - colunas usadas para ligar venda/caixa/produto
// ============================================================

procedure TdmConexoes.GarantirEstruturaVendas;
var
  Q: TADOQuery;
begin
  if FEstruturaVendasOk then
    Exit;
  Q := TADOQuery.Create(nil);
  try
    Q.Connection := conRobson;
    Q.SQL.Text :=
      'IF COL_LENGTH(''dbo.ItensVenda'', ''CodProd'') IS NULL ' +
      '  ALTER TABLE dbo.ItensVenda ADD CodProd INT NULL; ' +
      'IF COL_LENGTH(''dbo.VENDAS'', ''IdCaixa'') IS NULL ' +
      '  ALTER TABLE dbo.VENDAS ADD IdCaixa INT NULL; ' +
      'IF COL_LENGTH(''dbo.Cliente'', ''cliente_padrao'') IS NULL ' +
      '  ALTER TABLE dbo.Cliente ADD cliente_padrao BIT NOT NULL ' +
      '  CONSTRAINT DF_CLIENTE_CLIENTE_PADRAO DEFAULT 0;';
    Q.ExecSQL;
    FEstruturaVendasOk := True;
  finally
    Q.Free;
  end;
end;

function TdmConexoes.IdCaixaAtual: Integer;
var
  Q: TADOQuery;
begin
  Result := 0;
  Q := TADOQuery.Create(nil);
  try
    Q.Connection := conRobson;
    Q.SQL.Text := 'SELECT TOP 1 Id FROM Caixa WHERE Status = ''A'' ORDER BY DataAbertura DESC';
    Q.Open;
    if not Q.IsEmpty then
      Result := Q.Fields[0].AsInteger;
  finally
    Q.Free;
  end;
end;

function TdmConexoes.TotalFiadoCaixa(AIdCaixa: Integer): Currency;
var
  Q: TADOQuery;
begin
  Result := 0;
  if AIdCaixa <= 0 then
    Exit;
  Q := TADOQuery.Create(nil);
  try
    Q.Connection := conRobson;
    Q.SQL.Text :=
      'SELECT ISNULL(SUM(ValorPago), 0) AS TotalFiado FROM PagamentoFiado WHERE IdCaixa = :IdCaixa';
    Q.Parameters.ParamByName('IdCaixa').Value := AIdCaixa;
    Q.Open;
    Result := Q.FieldByName('TotalFiado').AsCurrency;
  finally
    Q.Free;
  end;
end;

function TdmConexoes.LucroCaixa(AIdCaixa: Integer): Currency;
var
  Q: TADOQuery;
begin
  Result := 0;
  if AIdCaixa <= 0 then
    Exit;
  GarantirEstruturaVendas;
  Q := TADOQuery.Create(nil);
  try
    Q.Connection := conRobson;
    // Usa o codigo do produto; a descricao so e usada em itens antigos sem codigo
    Q.SQL.Text :=
      'SELECT ISNULL(SUM((iv.ValorProdUni - ISNULL(p.valorcusto, 0)) * iv.Quantidade), 0) AS TotalLucro ' +
      'FROM ItensVenda iv ' +
      'INNER JOIN VENDAS v ON v.CodVenda = iv.CodVenda ' +
      'INNER JOIN Caixa c ON c.Id = :IdCaixa ' +
      'OUTER APPLY (SELECT TOP 1 pr.valorcusto FROM PRODUTOS pr ' +
      '  WHERE (iv.CodProd IS NOT NULL AND pr.codigo = iv.CodProd) ' +
      '     OR (iv.CodProd IS NULL AND pr.descricao = iv.Descricao)) p ' +
      'WHERE v.IdCaixa = c.Id ' +
      '   OR (v.IdCaixa IS NULL AND v.CodVenda >= c.CodVendaInicial ' +
      '       AND c.Status = ''A'')';
    Q.Parameters.ParamByName('IdCaixa').Value := AIdCaixa;
    Q.Open;
    Result := Q.FieldByName('TotalLucro').AsCurrency;
  finally
    Q.Free;
  end;
end;

// Cancela uma venda: devolve o estoque, apaga itens e venda (tudo ou nada).
// Retorna quantos itens nao tinham codigo do produto (vendas antigas),
// cujo estoque precisa ser conferido manualmente.
function TdmConexoes.EstornarVenda(ACodVenda: Integer): Integer;
var
  Q: TADOQuery;
begin
  Result := 0;
  GarantirEstruturaVendas;
  Q := TADOQuery.Create(nil);
  try
    Q.Connection := conRobson;
    conRobson.BeginTrans;
    try
      Q.SQL.Text :=
        'SELECT COUNT(*) FROM ItensVenda WHERE CodVenda = :CodVenda AND CodProd IS NULL';
      Q.Parameters.ParamByName('CodVenda').Value := ACodVenda;
      Q.Open;
      Result := Q.Fields[0].AsInteger;
      Q.Close;

      Q.SQL.Text :=
        'UPDATE p SET p.quantidade = ISNULL(p.quantidade, 0) + i.Qtd ' +
        'FROM PRODUTOS p INNER JOIN ( ' +
        '  SELECT CodProd, SUM(Quantidade) AS Qtd FROM ItensVenda ' +
        '  WHERE CodVenda = :CodVenda AND CodProd IS NOT NULL GROUP BY CodProd) i ' +
        '  ON i.CodProd = p.codigo';
      Q.Parameters.ParamByName('CodVenda').Value := ACodVenda;
      Q.ExecSQL;

      Q.SQL.Text := 'DELETE FROM ItensVenda WHERE CodVenda = :CodVenda';
      Q.Parameters.ParamByName('CodVenda').Value := ACodVenda;
      Q.ExecSQL;

      Q.SQL.Text := 'DELETE FROM VENDAS WHERE CodVenda = :CodVenda';
      Q.Parameters.ParamByName('CodVenda').Value := ACodVenda;
      Q.ExecSQL;

      conRobson.CommitTrans;
    except
      if conRobson.InTransaction then
        conRobson.RollbackTrans;
      raise;
    end;
  finally
    Q.Free;
  end;
end;

procedure TdmConexoes.CarregarConfiguracoes;
var
  INI: TIniFile;
begin
if not FileExists(ExtractFilePath(Application.ExeName) + 'config.ini') then
 begin
  Application.MessageBox(
  pchar('Arquivo config.ini não foi encontrado.'+ExtractFilePath(Application.ExeName) + 'config.ini'),
  'Erro de configuração',
  MB_OK + MB_ICONERROR
);
 end;


  INI := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'config.ini');
  try
    cfg_Empresa  := INI.ReadString('Empresa',    'Nome',      cfg_Empresa);
    cfg_Endereco := INI.ReadString('Empresa',    'Endereco',  cfg_Endereco);
    cfg_Telefone := INI.ReadString('Empresa',    'Telefone',  cfg_Telefone);
    cfg_Porta    := INI.ReadString('Impressora', 'Porta',     cfg_Porta );
    cfg_Modelo   := INI.ReadInteger('Impressora', 'Modelo', cfg_Modelo);
  finally
    INI.Free;
  end;
end;

function TdmConexoes.ModeloImpressora: Integer;
begin
  Result := cfg_Modelo;
end;

function TdmConexoes.PortaImpressora: string;
begin
  Result := cfg_Porta;
end;

function TdmConexoes.NomeEmpresa: string;
begin
  Result := cfg_Empresa;
end;

function TdmConexoes.EnderecoEmpresa: string;
begin
  Result := cfg_Endereco;
end;

function TdmConexoes.TelefoneEmpresa: string;
begin
  Result := cfg_Telefone;
end;

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
var
  qrTemp: TADOQuery;
  ProxCod: Integer;
begin
  Result := False;
  if AValorInicial < 0 then Exit;
  if CaixaAberto then Exit;

  // Busca o proximo CodVenda
  qrTemp := TADOQuery.Create(nil);
  try
    qrTemp.Connection := conRobson;
    qrTemp.SQL.Add('SELECT ISNULL(MAX(CodVenda), 0) + 1 AS PROXIMO FROM VENDAS');
    qrTemp.Open;
    ProxCod := qrTemp.FieldByName('PROXIMO').AsInteger;
  finally
    qrTemp.Free;
  end;

  qrCaixa.Close;
  qrCaixa.SQL.Clear;
  qrCaixa.SQL.Add(
    'INSERT INTO Caixa (DataAbertura, ValorAbertura, Status, UsuarioAbertura, CodVendaInicial) ' +
    'VALUES (GETDATE(), :Valor, ''A'', :Usuario, :CodInicial)'
  );
  qrCaixa.Parameters.ParamByName('Valor').Value      := AValorInicial;
  qrCaixa.Parameters.ParamByName('Usuario').Value    := UsuarioLogado;
  qrCaixa.Parameters.ParamByName('CodInicial').Value := ProxCod;
  qrCaixa.ExecSQL;
  Result := True;
end;
function TdmConexoes.TotalVendasCaixaAtual: Currency;
var
  qrTemp: TADOQuery;
  IdCaixa: Integer;
begin
  Result := 0;
  IdCaixa := IdCaixaAtual;
  if IdCaixa <= 0 then
    Exit;
  GarantirEstruturaVendas;
  qrTemp := TADOQuery.Create(nil);
  try
    qrTemp.Connection := conRobson;
    // Vendas novas sao ligadas ao caixa pelo IdCaixa; as antigas pelo CodVendaInicial
    qrTemp.SQL.Text :=
      'SELECT ISNULL(SUM(v.ValorTotal), 0) AS TotalVendas ' +
      'FROM VENDAS v ' +
      'INNER JOIN Caixa c ON c.Id = :IdCaixa ' +
      'WHERE v.IdCaixa = c.Id ' +
      '   OR (v.IdCaixa IS NULL AND v.CodVenda >= c.CodVendaInicial)';
    qrTemp.Parameters.ParamByName('IdCaixa').Value := IdCaixa;
    qrTemp.Open;
    Result := qrTemp.FieldByName('TotalVendas').AsCurrency;
  finally
    qrTemp.Free;
  end;
end;

function TdmConexoes.FecharCaixa: Boolean;
var
  ValorAbertura, TotalVendas, TotalFiado, ValorFinal: Currency;
  IdCaixa: Integer;
begin
  Result := False;
  IdCaixa := IdCaixaAtual;
  if IdCaixa <= 0 then Exit;

  qrCaixa.Close;
  qrCaixa.SQL.Text := 'SELECT ValorAbertura FROM Caixa WHERE Id = :IdCaixa';
  qrCaixa.Parameters.ParamByName('IdCaixa').Value := IdCaixa;
  qrCaixa.Open;
  ValorAbertura := qrCaixa.FieldByName('ValorAbertura').AsCurrency;
  qrCaixa.Close;

  TotalVendas := TotalVendasCaixaAtual;
  TotalFiado  := TotalFiadoCaixa(IdCaixa);
  ValorFinal  := ValorAbertura + TotalVendas + TotalFiado;

  qrCaixa.SQL.Text :=
    'UPDATE Caixa SET ' +
    'DataFechamento = GETDATE(), ' +
    'ValorFechamento = :ValorFinal, ' +
    'Status = ''F'', ' +
    'UsuarioFechamento = :Usuario ' +
    'WHERE Id = :IdCaixa AND Status = ''A''';
  qrCaixa.Parameters.ParamByName('ValorFinal').Value := ValorFinal;
  qrCaixa.Parameters.ParamByName('Usuario').Value    := UsuarioLogado;
  qrCaixa.Parameters.ParamByName('IdCaixa').Value    := IdCaixa;
  qrCaixa.ExecSQL;
  Result := True;
end;

// ============================================================
// LICENCA
// Retorna: -1 = Expirada/Sem licenca, N >= 0 = dias restantes
// ============================================================

function TdmConexoes.VerificarLicenca: Integer;
var
  qrTemp: TADOQuery;
begin
  Result := -1;
  qrTemp := TADOQuery.Create(nil);
  try
    qrTemp.Connection := conRobson;
    qrTemp.SQL.Add(
      'SELECT DATEDIFF(DAY, GETDATE(), DataExpiracao) AS DiasRestantes ' +
      'FROM Licenca WHERE Ativo = 1'
    );
    qrTemp.Open;

    if qrTemp.IsEmpty then Exit;

    Result := qrTemp.FieldByName('DiasRestantes').AsInteger;
    if Result < 0 then
      Result := -1;
  finally
    qrTemp.Free;
  end;
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
  if FAtualizandoPrecos or
     not (qrEstoque.State in [dsEdit, dsInsert]) then
    Exit;

  FAtualizandoPrecos := True;
  try
    try
      Custo  := qrEstoquevalorcusto.AsFloat;
      Markup := qrEstoquemarkup.AsFloat;

      qrEstoquevalorvenda.AsFloat  := Custo * (1 + Markup / 100);
      qrEstoquecusto_total.AsFloat := qrEstoquequantidade.AsFloat * Custo;
    except
      on E: Exception do
        ShowMessage('Erro no calculo do Markup: ' + E.Message);
    end;
  finally
    FAtualizandoPrecos := False;
  end;
end;

// Recalcula o markup quando o valor de venda for digitado na DBGrid.
procedure TdmConexoes.qrEstoquevalorvendaChange(Sender: TField);
var
  Custo, ValorVenda: Double;
begin
  if FAtualizandoPrecos or
     not (qrEstoque.State in [dsEdit, dsInsert]) then
    Exit;

  FAtualizandoPrecos := True;
  try
    Custo      := qrEstoquevalorcusto.AsFloat;
    ValorVenda := qrEstoquevalorvenda.AsFloat;

    if Custo > 0 then
      qrEstoquemarkup.AsFloat := ((ValorVenda / Custo) - 1) * 100
    else
      qrEstoquemarkup.AsFloat := 0;
  finally
    FAtualizandoPrecos := False;
  end;
end;

// Mantem o valor de venda coerente quando o custo for alterado.
procedure TdmConexoes.qrEstoquevalorcustoChange(Sender: TField);
begin
  qrEstoquemarkupChange(qrEstoquemarkup);
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
