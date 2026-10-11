unit uEmpresaConfig;

interface

uses
  System.SysUtils, Data.Win.ADODB;

type
  TEmpresaDados = record
    Nome: string;
    Documento: string;
    Endereco: string;
    Numero: string;
    CEP: string;
    Telefone: string;
    Responsavel: string;
    Email: string;
    Regime: string;
  end;

  TEmpresaConfig = class
  public
    class procedure GarantirEstrutura(AConexao: TADOConnection); static;
    class function Carregar(AConexao: TADOConnection): TEmpresaDados; static;
    class function NomeExibicao(AConexao: TADOConnection; const AFallback: string = ''): string; static;
    class function RegimeTexto(AIndice: Integer): string; static;
  end;

implementation

class procedure TEmpresaConfig.GarantirEstrutura(AConexao: TADOConnection);
var
  Q: TADOQuery;

  procedure ExecSQL(const ASQL: string);
  begin
    Q.Close;
    Q.SQL.Text := ASQL;
    Q.ExecSQL;
  end;

begin
  if AConexao = nil then
    Exit;

  if not AConexao.Connected then
    AConexao.Connected := True;

  Q := TADOQuery.Create(nil);
  try
    Q.Connection := AConexao;
    ExecSQL(
      'IF OBJECT_ID(''dbo.EMPRESA'', ''U'') IS NULL ' +
      'CREATE TABLE dbo.EMPRESA (' +
      'ID_EMPRESA INT NOT NULL PRIMARY KEY, ' +
      'RAZAO_SOCIAL VARCHAR(100) NULL, ' +
      'NOME_FANTASIA VARCHAR(100) NULL, ' +
      'CNPJ VARCHAR(20) NULL, ' +
      'INSC_ESTADUAL VARCHAR(30) NULL, ' +
      'INSC_MUNICIPAL VARCHAR(30) NULL, ' +
      'REGIME_TRIBUTARIO INT NULL, ' +
      'CEP VARCHAR(10) NULL, ' +
      'LOGRADOURO VARCHAR(100) NULL, ' +
      'NUMERO VARCHAR(10) NULL, ' +
      'COMPLEMENTO VARCHAR(50) NULL, ' +
      'BAIRRO VARCHAR(60) NULL, ' +
      'CIDADE VARCHAR(60) NULL, ' +
      'UF VARCHAR(2) NULL, ' +
      'TELEFONE VARCHAR(20) NULL, ' +
      'CELULAR VARCHAR(20) NULL, ' +
      'EMAIL VARCHAR(100) NULL, ' +
      'SITE VARCHAR(100) NULL, ' +
      'RESPONSAVEL VARCHAR(100) NULL, ' +
      'CNAE VARCHAR(10) NULL, ' +
      'ATIVIDADE VARCHAR(150) NULL, ' +
      'SUFRAMA VARCHAR(20) NULL, ' +
      'SITUACAO INT NULL, ' +
      'PRINCIPAL BIT NOT NULL DEFAULT 0, ' +
      'EMITE_NFCE_VENDA BIT NOT NULL DEFAULT 0, ' +
      'EMITE_NFE_VENDA BIT NOT NULL DEFAULT 0)');

    ExecSQL('IF COL_LENGTH(''dbo.EMPRESA'', ''RESPONSAVEL'') IS NULL ALTER TABLE dbo.EMPRESA ADD RESPONSAVEL VARCHAR(100) NULL');
    ExecSQL('IF COL_LENGTH(''dbo.EMPRESA'', ''EMAIL'') IS NULL ALTER TABLE dbo.EMPRESA ADD EMAIL VARCHAR(100) NULL');
    ExecSQL('IF COL_LENGTH(''dbo.EMPRESA'', ''REGIME_TRIBUTARIO'') IS NULL ALTER TABLE dbo.EMPRESA ADD REGIME_TRIBUTARIO INT NULL');
    ExecSQL('IF COL_LENGTH(''dbo.EMPRESA'', ''PRINCIPAL'') IS NULL ALTER TABLE dbo.EMPRESA ADD PRINCIPAL BIT NOT NULL CONSTRAINT DF_EMPRESA_PRINCIPAL DEFAULT 0');
    ExecSQL('IF COL_LENGTH(''dbo.EMPRESA'', ''EMITE_NFCE_VENDA'') IS NULL ALTER TABLE dbo.EMPRESA ADD EMITE_NFCE_VENDA BIT NOT NULL CONSTRAINT DF_EMPRESA_EMITE_NFCE_VENDA DEFAULT 0');
    ExecSQL('IF COL_LENGTH(''dbo.EMPRESA'', ''EMITE_NFE_VENDA'') IS NULL ALTER TABLE dbo.EMPRESA ADD EMITE_NFE_VENDA BIT NOT NULL CONSTRAINT DF_EMPRESA_EMITE_NFE_VENDA DEFAULT 0');
    ExecSQL('IF EXISTS (SELECT 1 FROM EMPRESA WHERE ISNULL(NULLIF(LTRIM(RTRIM(RAZAO_SOCIAL)), ''''), NULLIF(LTRIM(RTRIM(NOME_FANTASIA)), '''')) IS NOT NULL) AND NOT EXISTS (SELECT 1 FROM EMPRESA WHERE ISNULL(PRINCIPAL, 0) = 1 AND ISNULL(NULLIF(LTRIM(RTRIM(RAZAO_SOCIAL)), ''''), NULLIF(LTRIM(RTRIM(NOME_FANTASIA)), '''')) IS NOT NULL) UPDATE EMPRESA SET PRINCIPAL = CASE WHEN ID_EMPRESA = (SELECT MIN(ID_EMPRESA) FROM EMPRESA WHERE ISNULL(NULLIF(LTRIM(RTRIM(RAZAO_SOCIAL)), ''''), NULLIF(LTRIM(RTRIM(NOME_FANTASIA)), '''')) IS NOT NULL) THEN 1 ELSE 0 END');
  finally
    Q.Free;
  end;
end;

class function TEmpresaConfig.Carregar(AConexao: TADOConnection): TEmpresaDados;
var
  Q: TADOQuery;
begin
  Result.Nome := '';
  Result.Documento := '';
  Result.Endereco := '';
  Result.Numero := '';
  Result.CEP := '';
  Result.Telefone := '';
  Result.Responsavel := '';
  Result.Email := '';
  Result.Regime := '';

  if AConexao = nil then
    Exit;

  if not AConexao.Connected then
    AConexao.Connected := True;

  GarantirEstrutura(AConexao);
  Q := TADOQuery.Create(nil);
  try
    Q.Connection := AConexao;
    Q.SQL.Text :=
      'SELECT TOP 1 RAZAO_SOCIAL, NOME_FANTASIA, CNPJ, LOGRADOURO, NUMERO, CEP, ' +
      'TELEFONE, CELULAR, RESPONSAVEL, EMAIL, REGIME_TRIBUTARIO ' +
      'FROM EMPRESA WHERE ISNULL(NULLIF(LTRIM(RTRIM(RAZAO_SOCIAL)), ''''), NULLIF(LTRIM(RTRIM(NOME_FANTASIA)), '''')) IS NOT NULL ORDER BY ISNULL(PRINCIPAL, 0) DESC, ID_EMPRESA';
    Q.Open;
    if Q.IsEmpty then
      Exit;

    Result.Nome := Trim(Q.FieldByName('NOME_FANTASIA').AsString);
    if Result.Nome = '' then
      Result.Nome := Trim(Q.FieldByName('RAZAO_SOCIAL').AsString);
    Result.Documento := Trim(Q.FieldByName('CNPJ').AsString);
    Result.Endereco := Trim(Q.FieldByName('LOGRADOURO').AsString);
    Result.Numero := Trim(Q.FieldByName('NUMERO').AsString);
    Result.CEP := Trim(Q.FieldByName('CEP').AsString);
    Result.Telefone := Trim(Q.FieldByName('TELEFONE').AsString);
    if Result.Telefone = '' then
      Result.Telefone := Trim(Q.FieldByName('CELULAR').AsString);
    Result.Responsavel := Trim(Q.FieldByName('RESPONSAVEL').AsString);
    Result.Email := Trim(Q.FieldByName('EMAIL').AsString);
    Result.Regime := RegimeTexto(Q.FieldByName('REGIME_TRIBUTARIO').AsInteger);
  finally
    Q.Free;
  end;
end;

class function TEmpresaConfig.NomeExibicao(AConexao: TADOConnection; const AFallback: string): string;
var
  Dados: TEmpresaDados;
begin
  Dados := Carregar(AConexao);
  Result := Trim(Dados.Nome);
  if Result = '' then
    Result := Trim(AFallback);
  if Result = '' then
    Result := 'Empresa';
end;

class function TEmpresaConfig.RegimeTexto(AIndice: Integer): string;
begin
  case AIndice of
    0: Result := 'Simples Nacional';
    1: Result := 'MEI';
    2: Result := 'Lucro Real';
  else
    Result := '';
  end;
end;

end.
