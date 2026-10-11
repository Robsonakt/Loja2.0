unit uFiscalStorage;

interface

uses
  System.SysUtils,
  System.Variants,
  Data.DB,
  Data.Win.ADODB;

type
  TFiscalStorage = class
  private
    class procedure ExecSQL(AConn: TADOConnection; const ASQL: string); static;
    class function AbrirConsulta(AConn: TADOConnection; const ASQL: string): TADOQuery; static;
  public
    class procedure GarantirEstrutura(AConn: TADOConnection); static;

    class function RegistrarDocumentoVenda(AConn: TADOConnection; const Modelo: string;
      CodVenda, Serie, Numero: Integer; ValorTotal: Currency; Itens: TDataSet): Integer; static;

    class function RegistrarNFeEntrada(AConn: TADOConnection; const Chave: string;
      Numero, Serie: Integer; ValorTotal: Currency; const XmlOriginal: string): Integer; static;

    class procedure RegistrarNFeEntradaItem(AConn: TADOConnection; EntradaId, Item: Integer;
      ProdutoId: Integer; const CodigoFornecedor, EAN, Descricao, NCM, CFOP, Unidade: string;
      Quantidade, ValorUnitario, ValorTotal: Currency); static;

    class function NFeEntradaExiste(AConn: TADOConnection; const Chave: string): Boolean; static;
    class function LocalizarProdutoEntrada(AConn: TADOConnection;
      const CodigoFornecedor, EAN: string): Integer; static;
    class procedure VincularItemEntrada(AConn: TADOConnection;
      EntradaItemId, ProdutoId: Integer); static;
    class procedure ConfirmarNFeEntrada(AConn: TADOConnection;
      EntradaId: Integer); static;

    class procedure CancelarDocumentoFiscal(AConn: TADOConnection; IdFiscal: Integer; const Justificativa: string); static;
    class procedure CancelarDocumentoFiscalPorVenda(AConn: TADOConnection; CodVenda: Integer; const Justificativa: string); static;
  end;

implementation

class procedure TFiscalStorage.ExecSQL(AConn: TADOConnection; const ASQL: string);
var
  Q: TADOQuery;
begin
  Q := TADOQuery.Create(nil);
  try
    Q.Connection := AConn;
    Q.SQL.Text := ASQL;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

class function TFiscalStorage.AbrirConsulta(AConn: TADOConnection; const ASQL: string): TADOQuery;
begin
  Result := TADOQuery.Create(nil);
  Result.Connection := AConn;
  Result.SQL.Text := ASQL;
  Result.Open;
end;

class procedure TFiscalStorage.GarantirEstrutura(AConn: TADOConnection);
begin
  ExecSQL(AConn,
    'IF OBJECT_ID(''dbo.FiscalDocumentos'', ''U'') IS NULL ' +
    'CREATE TABLE dbo.FiscalDocumentos (' +
    'IdFiscal INT IDENTITY(1,1) NOT NULL PRIMARY KEY, ' +
    'Modelo VARCHAR(2) NOT NULL, Serie INT NOT NULL, Numero INT NOT NULL, ' +
    'CodVenda INT NULL, ChaveAcesso VARCHAR(44) NULL, Protocolo VARCHAR(60) NULL, ' +
    'StatusFiscal VARCHAR(30) NOT NULL, StatusCodigo INT NULL, StatusDescricao VARCHAR(255) NULL, ' +
    'ValorTotal DECIMAL(18,2) NOT NULL DEFAULT 0, XmlEnvio NVARCHAR(MAX) NULL, XmlAutorizado NVARCHAR(MAX) NULL, ' +
    'CriadoEm DATETIME NOT NULL DEFAULT GETDATE(), AtualizadoEm DATETIME NULL, EnviadoContabilidade BIT NOT NULL DEFAULT 0, ' +
    'EnviadoContabilidadeEm DATETIME NULL)');

  ExecSQL(AConn,
    'IF OBJECT_ID(''dbo.FiscalDocumentoItens'', ''U'') IS NULL ' +
    'CREATE TABLE dbo.FiscalDocumentoItens (' +
    'IdItemFiscal INT IDENTITY(1,1) NOT NULL PRIMARY KEY, IdFiscal INT NOT NULL, ' +
    'Item INT NOT NULL, ProdutoId INT NULL, Descricao VARCHAR(255) NOT NULL, ' +
    'Quantidade DECIMAL(18,4) NOT NULL DEFAULT 0, ValorUnitario DECIMAL(18,4) NOT NULL DEFAULT 0, ' +
    'ValorTotal DECIMAL(18,2) NOT NULL DEFAULT 0, NCM VARCHAR(8) NULL, CFOP VARCHAR(5) NULL, CSTCSOSN VARCHAR(4) NULL, ' +
    'CONSTRAINT FK_FiscalDocumentoItens_Documentos FOREIGN KEY (IdFiscal) REFERENCES dbo.FiscalDocumentos(IdFiscal))');

  ExecSQL(AConn,
    'IF OBJECT_ID(''dbo.FiscalNFeEntradas'', ''U'') IS NULL ' +
    'CREATE TABLE dbo.FiscalNFeEntradas (' +
    'IdEntradaFiscal INT IDENTITY(1,1) NOT NULL PRIMARY KEY, ChaveAcesso VARCHAR(44) NOT NULL, ' +
    'Numero INT NULL, Serie INT NULL, ValorTotal DECIMAL(18,2) NOT NULL DEFAULT 0, ' +
    'StatusEntrada VARCHAR(30) NOT NULL, XmlOriginal NVARCHAR(MAX) NULL, CriadoEm DATETIME NOT NULL DEFAULT GETDATE(), ' +
    'EnviadoContabilidade BIT NOT NULL DEFAULT 0, EnviadoContabilidadeEm DATETIME NULL)');

  ExecSQL(AConn,
    'IF OBJECT_ID(''dbo.FiscalNFeEntradaItens'', ''U'') IS NULL ' +
    'CREATE TABLE dbo.FiscalNFeEntradaItens (' +
    'IdEntradaItemFiscal INT IDENTITY(1,1) NOT NULL PRIMARY KEY, IdEntradaFiscal INT NOT NULL, ' +
    'Item INT NOT NULL, ProdutoId INT NULL, CodigoFornecedor VARCHAR(60) NULL, Descricao VARCHAR(255) NOT NULL, ' +
    'NCM VARCHAR(8) NULL, CFOP VARCHAR(5) NULL, Unidade VARCHAR(6) NULL, Quantidade DECIMAL(18,4) NOT NULL DEFAULT 0, ' +
    'ValorUnitario DECIMAL(18,4) NOT NULL DEFAULT 0, ValorTotal DECIMAL(18,2) NOT NULL DEFAULT 0, ' +
    'CONSTRAINT FK_FiscalNFeEntradaItens_Entradas FOREIGN KEY (IdEntradaFiscal) REFERENCES dbo.FiscalNFeEntradas(IdEntradaFiscal))');

  ExecSQL(AConn,
    'IF COL_LENGTH(''dbo.FiscalNFeEntradaItens'', ''EAN'') IS NULL ' +
    'ALTER TABLE dbo.FiscalNFeEntradaItens ADD EAN VARCHAR(20) NULL');

  ExecSQL(AConn,
    'IF OBJECT_ID(''dbo.FiscalProdutoFornecedor'', ''U'') IS NULL ' +
    'CREATE TABLE dbo.FiscalProdutoFornecedor (' +
    'IdVinculo INT IDENTITY(1,1) NOT NULL PRIMARY KEY, ProdutoId INT NOT NULL, ' +
    'CodigoFornecedor VARCHAR(60) NOT NULL, EAN VARCHAR(20) NULL, ' +
    'CriadoEm DATETIME NOT NULL DEFAULT GETDATE())');

  ExecSQL(AConn,
    'IF OBJECT_ID(''dbo.FiscalEventos'', ''U'') IS NULL ' +
    'CREATE TABLE dbo.FiscalEventos (' +
    'IdEventoFiscal INT IDENTITY(1,1) NOT NULL PRIMARY KEY, IdFiscal INT NULL, TipoEvento VARCHAR(30) NOT NULL, ' +
    'Descricao VARCHAR(255) NULL, XmlEvento NVARCHAR(MAX) NULL, CriadoEm DATETIME NOT NULL DEFAULT GETDATE())');
end;

class function TFiscalStorage.NFeEntradaExiste(AConn: TADOConnection;
  const Chave: string): Boolean;
var
  Q: TADOQuery;
begin
  GarantirEstrutura(AConn);
  Q := TADOQuery.Create(nil);
  try
    Q.Connection := AConn;
    Q.SQL.Text := 'SELECT COUNT(1) FROM dbo.FiscalNFeEntradas WHERE ChaveAcesso = :Chave';
    Q.Parameters.ParamByName('Chave').Value := Chave;
    Q.Open;
    Result := Q.Fields[0].AsInteger > 0;
  finally
    Q.Free;
  end;
end;

class function TFiscalStorage.LocalizarProdutoEntrada(AConn: TADOConnection;
  const CodigoFornecedor, EAN: string): Integer;
var
  Q: TADOQuery;
begin
  Result := 0;
  Q := TADOQuery.Create(nil);
  try
    Q.Connection := AConn;
    Q.SQL.Text :=
      'DECLARE @EAN VARCHAR(20) = :EAN; ' +
      'SELECT TOP 1 codigo FROM dbo.PRODUTOS ' +
      'WHERE (@EAN <> '''' AND CodBarras = @EAN) ORDER BY codigo';
    Q.Parameters.ParamByName('EAN').Value := Trim(EAN);
    Q.Open;
    if not Q.IsEmpty then
      Exit(Q.Fields[0].AsInteger);
    Q.Close;
    Q.SQL.Text :=
      'SELECT TOP 1 ProdutoId FROM dbo.FiscalProdutoFornecedor ' +
      'WHERE CodigoFornecedor = :Codigo ORDER BY IdVinculo DESC';
    Q.Parameters.ParamByName('Codigo').Value := Trim(CodigoFornecedor);
    Q.Open;
    if not Q.IsEmpty then
      Result := Q.Fields[0].AsInteger;
  finally
    Q.Free;
  end;
end;

class procedure TFiscalStorage.VincularItemEntrada(AConn: TADOConnection;
  EntradaItemId, ProdutoId: Integer);
var
  Q: TADOQuery;
begin
  Q := TADOQuery.Create(nil);
  try
    Q.Connection := AConn;
    Q.SQL.Text :=
      'DECLARE @ProdutoId INT = :ProdutoId, @ItemId INT = :ItemId; ' +
      'IF NOT EXISTS (SELECT 1 FROM dbo.PRODUTOS WHERE codigo = @ProdutoId) ' +
      'BEGIN RAISERROR(''Produto informado nao existe.'', 16, 1); RETURN; END; ' +
      'UPDATE dbo.FiscalNFeEntradaItens SET ProdutoId = @ProdutoId ' +
      'WHERE IdEntradaItemFiscal = @ItemId; ' +
      'IF NOT EXISTS (SELECT 1 FROM dbo.FiscalProdutoFornecedor F ' +
      'INNER JOIN dbo.FiscalNFeEntradaItens I ON I.IdEntradaItemFiscal = @ItemId ' +
      'WHERE F.ProdutoId = @ProdutoId AND F.CodigoFornecedor = I.CodigoFornecedor) ' +
      'INSERT INTO dbo.FiscalProdutoFornecedor (ProdutoId, CodigoFornecedor, EAN) ' +
      'SELECT @ProdutoId, CodigoFornecedor, EAN FROM dbo.FiscalNFeEntradaItens ' +
      'WHERE IdEntradaItemFiscal = @ItemId';
    Q.Parameters.ParamByName('ProdutoId').Value := ProdutoId;
    Q.Parameters.ParamByName('ItemId').Value := EntradaItemId;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

class procedure TFiscalStorage.ConfirmarNFeEntrada(AConn: TADOConnection;
  EntradaId: Integer);
var
  Q: TADOQuery;
begin
  GarantirEstrutura(AConn);
  AConn.BeginTrans;
  try
    Q := TADOQuery.Create(nil);
    try
      Q.Connection := AConn;
      Q.SQL.Text :=
        'DECLARE @EntradaId INT = :EntradaId; ' +
        'IF NOT EXISTS (SELECT 1 FROM dbo.FiscalNFeEntradas WITH (UPDLOCK, HOLDLOCK) ' +
        'WHERE IdEntradaFiscal = @EntradaId) BEGIN RAISERROR(''Entrada nao encontrada.'', 16, 1); RETURN; END; ' +
        'IF EXISTS (SELECT 1 FROM dbo.FiscalNFeEntradas WHERE IdEntradaFiscal = @EntradaId ' +
        'AND StatusEntrada = ''CONFIRMADA'') BEGIN RAISERROR(''Entrada ja confirmada.'', 16, 1); RETURN; END; ' +
        'IF EXISTS (SELECT 1 FROM dbo.FiscalNFeEntradaItens WHERE IdEntradaFiscal = @EntradaId ' +
        'AND ProdutoId IS NULL) BEGIN RAISERROR(''Existem itens sem produto vinculado.'', 16, 1); RETURN; END; ' +
        'IF EXISTS (SELECT 1 FROM dbo.FiscalNFeEntradaItens WHERE IdEntradaFiscal = @EntradaId ' +
        'AND Quantidade <> ROUND(Quantidade, 0)) BEGIN RAISERROR(''O estoque atual aceita somente quantidades inteiras.'', 16, 1); RETURN; END; ' +
        'UPDATE P SET ' +
        'valorcusto = CASE WHEN ISNULL(P.quantidade,0) + I.Qtd > 0 THEN ' +
        '((ISNULL(P.quantidade,0) * ISNULL(P.valorcusto,0)) + I.TotalCusto) / ' +
        '(ISNULL(P.quantidade,0) + I.Qtd) ELSE P.valorcusto END, ' +
        'quantidade = ISNULL(P.quantidade,0) + I.Qtd ' +
        'FROM dbo.PRODUTOS P INNER JOIN (' +
        'SELECT ProdutoId, SUM(CAST(ROUND(Quantidade,0) AS INT)) Qtd, ' +
        'SUM(ValorTotal) TotalCusto FROM dbo.FiscalNFeEntradaItens ' +
        'WHERE IdEntradaFiscal = @EntradaId GROUP BY ProdutoId) I ON I.ProdutoId = P.codigo; ' +
        'UPDATE dbo.FiscalNFeEntradas SET StatusEntrada = ''CONFIRMADA'' ' +
        'WHERE IdEntradaFiscal = @EntradaId';
      Q.Parameters.ParamByName('EntradaId').Value := EntradaId;
      Q.ExecSQL;
    finally
      Q.Free;
    end;
    AConn.CommitTrans;
  except
    if AConn.InTransaction then
      AConn.RollbackTrans;
    raise;
  end;
end;

class function TFiscalStorage.RegistrarDocumentoVenda(AConn: TADOConnection; const Modelo: string;
  CodVenda, Serie, Numero: Integer; ValorTotal: Currency; Itens: TDataSet): Integer;
var
  Q: TADOQuery;
  Item: Integer;
begin
  GarantirEstrutura(AConn);

  Q := TADOQuery.Create(nil);
  try
    Q.Connection := AConn;
    Q.SQL.Text :=
      'INSERT INTO dbo.FiscalDocumentos (Modelo, Serie, Numero, CodVenda, StatusFiscal, StatusDescricao, ValorTotal) ' +
      'OUTPUT INSERTED.IdFiscal VALUES (:Modelo, :Serie, :Numero, :CodVenda, :StatusFiscal, :StatusDescricao, :ValorTotal)';
    Q.Parameters.ParamByName('Modelo').Value := Modelo;
    Q.Parameters.ParamByName('Serie').Value := Serie;
    Q.Parameters.ParamByName('Numero').Value := Numero;
    Q.Parameters.ParamByName('CodVenda').Value := CodVenda;
    Q.Parameters.ParamByName('StatusFiscal').Value := 'PENDENTE_EMISSAO';
    Q.Parameters.ParamByName('StatusDescricao').Value := 'Aguardando integracao com ACBrNFe/SEFAZ';
    Q.Parameters.ParamByName('ValorTotal').Value := ValorTotal;
    Q.Open;
    Result := Q.Fields[0].AsInteger;
  finally
    Q.Free;
  end;

  if (Itens <> nil) and Itens.Active then
  begin
    Itens.DisableControls;
    try
      Itens.First;
      Item := 1;
      while not Itens.Eof do
      begin
        Q := TADOQuery.Create(nil);
        try
          Q.Connection := AConn;
          Q.SQL.Text :=
            'INSERT INTO dbo.FiscalDocumentoItens ' +
            '(IdFiscal, Item, ProdutoId, Descricao, Quantidade, ValorUnitario, ValorTotal) ' +
            'VALUES (:IdFiscal, :Item, :ProdutoId, :Descricao, :Quantidade, :ValorUnitario, :ValorTotal)';
          Q.Parameters.ParamByName('IdFiscal').Value := Result;
          Q.Parameters.ParamByName('Item').Value := Item;
          Q.Parameters.ParamByName('ProdutoId').Value := Itens.FieldByName('CodProd').AsInteger;
          Q.Parameters.ParamByName('Descricao').Value := Copy(Itens.FieldByName('Descricao').AsString, 1, 255);
          Q.Parameters.ParamByName('Quantidade').Value := Itens.FieldByName('Quantidade').AsCurrency;
          Q.Parameters.ParamByName('ValorUnitario').Value := Itens.FieldByName('ValorUni').AsCurrency;
          Q.Parameters.ParamByName('ValorTotal').Value := Itens.FieldByName('ValorTotal').AsCurrency;
          Q.ExecSQL;
        finally
          Q.Free;
        end;
        Inc(Item);
        Itens.Next;
      end;
    finally
      Itens.EnableControls;
    end;
  end;
end;

class function TFiscalStorage.RegistrarNFeEntrada(AConn: TADOConnection; const Chave: string;
  Numero, Serie: Integer; ValorTotal: Currency; const XmlOriginal: string): Integer;
var
  Q: TADOQuery;
begin
  GarantirEstrutura(AConn);

  Q := TADOQuery.Create(nil);
  try
    Q.Connection := AConn;
    Q.SQL.Text :=
      'INSERT INTO dbo.FiscalNFeEntradas (ChaveAcesso, Numero, Serie, ValorTotal, StatusEntrada, XmlOriginal) ' +
      'OUTPUT INSERTED.IdEntradaFiscal VALUES (:ChaveAcesso, :Numero, :Serie, :ValorTotal, :StatusEntrada, :XmlOriginal)';
    Q.Parameters.ParamByName('ChaveAcesso').Value := Chave;
    Q.Parameters.ParamByName('Numero').Value := Numero;
    Q.Parameters.ParamByName('Serie').Value := Serie;
    Q.Parameters.ParamByName('ValorTotal').Value := ValorTotal;
    Q.Parameters.ParamByName('StatusEntrada').Value := 'IMPORTADA';
    Q.Parameters.ParamByName('XmlOriginal').DataType := ftMemo;
    Q.Parameters.ParamByName('XmlOriginal').Value := XmlOriginal;
    Q.Open;
    Result := Q.Fields[0].AsInteger;
  finally
    Q.Free;
  end;
end;

class procedure TFiscalStorage.RegistrarNFeEntradaItem(AConn: TADOConnection; EntradaId, Item: Integer;
  ProdutoId: Integer; const CodigoFornecedor, EAN, Descricao, NCM, CFOP, Unidade: string;
  Quantidade, ValorUnitario, ValorTotal: Currency);
var
  Q: TADOQuery;
begin
  Q := TADOQuery.Create(nil);
  try
    Q.Connection := AConn;
    Q.SQL.Text :=
      'INSERT INTO dbo.FiscalNFeEntradaItens ' +
      '(IdEntradaFiscal, Item, ProdutoId, CodigoFornecedor, EAN, Descricao, NCM, CFOP, Unidade, Quantidade, ValorUnitario, ValorTotal) ' +
      'VALUES (:IdEntradaFiscal, :Item, :ProdutoId, :CodigoFornecedor, :EAN, :Descricao, :NCM, :CFOP, :Unidade, :Quantidade, :ValorUnitario, :ValorTotal)';
    Q.Parameters.ParamByName('IdEntradaFiscal').Value := EntradaId;
    Q.Parameters.ParamByName('Item').Value := Item;
    if ProdutoId > 0 then
      Q.Parameters.ParamByName('ProdutoId').Value := ProdutoId
    else
      Q.Parameters.ParamByName('ProdutoId').Value := Null;
    Q.Parameters.ParamByName('CodigoFornecedor').Value := Copy(CodigoFornecedor, 1, 60);
    Q.Parameters.ParamByName('EAN').Value := Copy(EAN, 1, 20);
    Q.Parameters.ParamByName('Descricao').Value := Copy(Descricao, 1, 255);
    Q.Parameters.ParamByName('NCM').Value := Copy(NCM, 1, 8);
    Q.Parameters.ParamByName('CFOP').Value := Copy(CFOP, 1, 5);
    Q.Parameters.ParamByName('Unidade').Value := Copy(Unidade, 1, 6);
    Q.Parameters.ParamByName('Quantidade').Value := Quantidade;
    Q.Parameters.ParamByName('ValorUnitario').Value := ValorUnitario;
    Q.Parameters.ParamByName('ValorTotal').Value := ValorTotal;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

class procedure TFiscalStorage.CancelarDocumentoFiscal(AConn: TADOConnection; IdFiscal: Integer; const Justificativa: string);
var
  Q: TADOQuery;
begin
  GarantirEstrutura(AConn);

  Q := AbrirConsulta(AConn, 'SELECT IdFiscal FROM dbo.FiscalDocumentos WHERE IdFiscal = ' + IntToStr(IdFiscal));
  try
    if Q.IsEmpty then
      raise Exception.Create('Documento fiscal nao encontrado no controle fiscal.');
  finally
    Q.Free;
  end;

  Q := TADOQuery.Create(nil);
  try
    Q.Connection := AConn;
    Q.SQL.Text :=
      'UPDATE dbo.FiscalDocumentos SET StatusFiscal = :StatusFiscal, StatusDescricao = :StatusDescricao, ' +
      'AtualizadoEm = GETDATE() WHERE IdFiscal = :IdFiscal';
    Q.Parameters.ParamByName('StatusFiscal').Value := 'CANCELADO';
    Q.Parameters.ParamByName('StatusDescricao').Value := Copy(Justificativa, 1, 255);
    Q.Parameters.ParamByName('IdFiscal').Value := IdFiscal;
    Q.ExecSQL;
  finally
    Q.Free;
  end;

  Q := TADOQuery.Create(nil);
  try
    Q.Connection := AConn;
    Q.SQL.Text :=
      'INSERT INTO dbo.FiscalEventos (IdFiscal, TipoEvento, Descricao) VALUES (:IdFiscal, :TipoEvento, :Descricao)';
    Q.Parameters.ParamByName('IdFiscal').Value := IdFiscal;
    Q.Parameters.ParamByName('TipoEvento').Value := 'CANCELAMENTO';
    Q.Parameters.ParamByName('Descricao').Value := Copy(Justificativa, 1, 255);
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

class procedure TFiscalStorage.CancelarDocumentoFiscalPorVenda(AConn: TADOConnection; CodVenda: Integer; const Justificativa: string);
var
  Q: TADOQuery;
  IdsFiscais: array of Integer;
  I: Integer;
begin
  GarantirEstrutura(AConn);

  Q := TADOQuery.Create(nil);
  try
    Q.Connection := AConn;
    Q.SQL.Text := 'SELECT IdFiscal FROM dbo.FiscalDocumentos WHERE CodVenda = :CodVenda AND StatusFiscal <> ''CANCELADO''';
    Q.Parameters.ParamByName('CodVenda').Value := CodVenda;
    Q.Open;

    while not Q.Eof do
    begin
      SetLength(IdsFiscais, Length(IdsFiscais) + 1);
      IdsFiscais[High(IdsFiscais)] := Q.FieldByName('IdFiscal').AsInteger;
      Q.Next;
    end;
  finally
    Q.Free;
  end;

  for I := Low(IdsFiscais) to High(IdsFiscais) do
    CancelarDocumentoFiscal(AConn, IdsFiscais[I], Justificativa);
end;
end.
