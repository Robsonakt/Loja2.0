unit untEntradaNotasXML;

interface

uses
  System.Classes, Vcl.Forms;

type
  TfrmEntradaNotasXML = class(TForm)
  private
    FEntradaId: Integer;
    procedure MontarTela;
    procedure SelecionarXML(Sender: TObject);
    procedure VincularProduto(Sender: TObject);
    procedure ConfirmarEntrada(Sender: TObject);
    procedure AtualizarItens;
    function ImportarXML(const Arquivo: string): Integer;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  System.SysUtils, System.Variants, Data.DB, Data.Win.ADODB,
  Xml.XMLDoc, Xml.XMLIntf, Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Dialogs, Vcl.DBGrids, dmconexao, uFiscalStorage;

function NoFilho(const Node: IXMLNode; const Nome: string): IXMLNode;
begin
  Result := nil;
  if Node <> nil then
    Result := Node.ChildNodes.FindNode(Nome);
end;

function LocalizarNo(const Node: IXMLNode; const Nome: string): IXMLNode;
var
  I: Integer;
begin
  Result := nil;
  if Node = nil then Exit;
  if SameText(Node.NodeName, Nome) then Exit(Node);
  for I := 0 to Node.ChildNodes.Count - 1 do
  begin
    Result := LocalizarNo(Node.ChildNodes[I], Nome);
    if Result <> nil then Exit;
  end;
end;

function TextoNo(const Node: IXMLNode; const Nome: string): string;
var
  N: IXMLNode;
begin
  Result := '';
  N := NoFilho(Node, Nome);
  if N <> nil then Result := Trim(N.Text);
end;

function ValorXML(const S: string): Currency;
begin
  Result := StrToCurrDef(StringReplace(S, '.', FormatSettings.DecimalSeparator,
    [rfReplaceAll]), 0);
end;

constructor TfrmEntradaNotasXML.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  MontarTela;
end;

procedure TfrmEntradaNotasXML.MontarTela;
var
  P: TPanel;
  B: TButton;
  Q: TADOQuery;
  DS: TDataSource;
  G: TDBGrid;
begin
  Name := 'frmEntradaNotasXML';
  Caption := 'XML - Entrada de NF-e';
  Width := 1050;
  Height := 620;
  Position := poScreenCenter;
  Color := $00302F2E;

  P := TPanel.Create(Self);
  P.Parent := Self; P.Align := alTop; P.Height := 58;
  P.BevelOuter := bvNone; P.Color := $00212121;
  B := TButton.Create(Self);
  B.Parent := P; B.SetBounds(12, 14, 145, 30);
  B.Caption := 'Selecionar XML...'; B.OnClick := SelecionarXML;
  B := TButton.Create(Self);
  B.Parent := P; B.SetBounds(165, 14, 145, 30);
  B.Caption := 'Vincular produto'; B.OnClick := VincularProduto;
  B := TButton.Create(Self);
  B.Parent := P; B.SetBounds(318, 14, 170, 30);
  B.Caption := 'Confirmar entrada'; B.OnClick := ConfirmarEntrada;

  Q := TADOQuery.Create(Self);
  Q.Name := 'qryItens';
  Q.Connection := dmConexoes.conRobson;
  DS := TDataSource.Create(Self);
  DS.Name := 'dsItens'; DS.DataSet := Q;
  G := TDBGrid.Create(Self);
  G.Name := 'grdItens'; G.Parent := Self; G.Align := alClient;
  G.DataSource := DS; G.ReadOnly := True;
  G.Options := G.Options + [dgRowSelect];
end;

procedure TfrmEntradaNotasXML.AtualizarItens;
var
  Q: TADOQuery;
begin
  Q := FindComponent('qryItens') as TADOQuery;
  Q.Close;
  Q.SQL.Text :=
    'SELECT I.IdEntradaItemFiscal AS ID, I.Item, I.CodigoFornecedor, I.EAN, ' +
    'I.Descricao, I.NCM, I.CFOP, I.Unidade, I.Quantidade, I.ValorUnitario, ' +
    'I.ValorTotal, I.ProdutoId, P.descricao AS ProdutoVinculado ' +
    'FROM dbo.FiscalNFeEntradaItens I LEFT JOIN dbo.PRODUTOS P ' +
    'ON P.codigo = I.ProdutoId WHERE I.IdEntradaFiscal = :EntradaId ORDER BY I.Item';
  Q.Parameters.ParamByName('EntradaId').Value := FEntradaId;
  Q.Open;
end;

function TfrmEntradaNotasXML.ImportarXML(const Arquivo: string): Integer;
var
  XML: IXMLDocument;
  InfNFe, Ide, Total, ICMSTot, Det, Prod: IXMLNode;
  Chave, XmlOriginal, EAN: string;
  SL: TStringList;
  I, Item, ProdutoId: Integer;
begin
  XML := TXMLDocument.Create(nil);
  XML.LoadFromFile(Arquivo);
  XML.Active := True;
  InfNFe := LocalizarNo(XML.DocumentElement, 'infNFe');
  if InfNFe = nil then
    raise Exception.Create('O arquivo selecionado nao contem uma NF-e valida.');
  Chave := StringReplace(VarToStr(InfNFe.Attributes['Id']), 'NFe', '',
    [rfIgnoreCase]);
  if Length(Chave) <> 44 then
    raise Exception.Create('Chave de acesso invalida no XML.');
  if TFiscalStorage.NFeEntradaExiste(dmConexoes.conRobson, Chave) then
    raise Exception.Create('Esta NF-e ja foi importada.');

  SL := TStringList.Create;
  try
    SL.LoadFromFile(Arquivo);
    XmlOriginal := SL.Text;
  finally
    SL.Free;
  end;
  Ide := LocalizarNo(InfNFe, 'ide');
  Total := LocalizarNo(InfNFe, 'total');
  ICMSTot := LocalizarNo(Total, 'ICMSTot');

  dmConexoes.conRobson.BeginTrans;
  try
    Result := TFiscalStorage.RegistrarNFeEntrada(dmConexoes.conRobson, Chave,
      StrToIntDef(TextoNo(Ide, 'nNF'), 0),
      StrToIntDef(TextoNo(Ide, 'serie'), 0),
      ValorXML(TextoNo(ICMSTot, 'vNF')), XmlOriginal);
    Item := 0;
    for I := 0 to InfNFe.ChildNodes.Count - 1 do
    begin
      Det := InfNFe.ChildNodes[I];
      if not SameText(Det.NodeName, 'det') then Continue;
      Prod := NoFilho(Det, 'prod');
      if Prod = nil then Continue;
      Inc(Item);
      EAN := TextoNo(Prod, 'cEAN');
      if SameText(EAN, 'SEM GTIN') then EAN := '';
      ProdutoId := TFiscalStorage.LocalizarProdutoEntrada(dmConexoes.conRobson,
        TextoNo(Prod, 'cProd'), EAN);
      TFiscalStorage.RegistrarNFeEntradaItem(dmConexoes.conRobson, Result,
        Item, ProdutoId, TextoNo(Prod, 'cProd'), EAN,
        TextoNo(Prod, 'xProd'), TextoNo(Prod, 'NCM'),
        TextoNo(Prod, 'CFOP'), TextoNo(Prod, 'uCom'),
        ValorXML(TextoNo(Prod, 'qCom')), ValorXML(TextoNo(Prod, 'vUnCom')),
        ValorXML(TextoNo(Prod, 'vProd')));
    end;
    if Item = 0 then
      raise Exception.Create('A NF-e nao possui itens de produtos.');
    dmConexoes.conRobson.CommitTrans;
  except
    if dmConexoes.conRobson.InTransaction then
      dmConexoes.conRobson.RollbackTrans;
    raise;
  end;
end;

procedure TfrmEntradaNotasXML.SelecionarXML(Sender: TObject);
var
  D: TOpenDialog;
begin
  D := TOpenDialog.Create(nil);
  try
    D.Filter := 'XML da NF-e (*.xml)|*.xml';
    D.Options := [ofFileMustExist, ofEnableSizing];
    if not D.Execute then Exit;
    try
      FEntradaId := ImportarXML(D.FileName);
      AtualizarItens;
      MessageDlg('NF-e importada. Confira e vincule os itens pendentes.',
        mtInformation, [mbOK], 0);
    except
      on E: Exception do MessageDlg(E.Message, mtError, [mbOK], 0);
    end;
  finally
    D.Free;
  end;
end;

procedure TfrmEntradaNotasXML.VincularProduto(Sender: TObject);
var
  Q: TADOQuery;
  S: string;
  ProdutoId: Integer;
begin
  Q := FindComponent('qryItens') as TADOQuery;
  if not Q.Active or Q.IsEmpty then Exit;
  S := Q.FieldByName('ProdutoId').AsString;
  if not InputQuery('Vincular produto', 'Codigo do produto cadastrado:', S) then Exit;
  ProdutoId := StrToIntDef(Trim(S), 0);
  try
    TFiscalStorage.VincularItemEntrada(dmConexoes.conRobson,
      Q.FieldByName('ID').AsInteger, ProdutoId);
    AtualizarItens;
  except
    on E: Exception do MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TfrmEntradaNotasXML.ConfirmarEntrada(Sender: TObject);
begin
  if FEntradaId <= 0 then
  begin
    MessageDlg('Selecione primeiro um XML.', mtWarning, [mbOK], 0);
    Exit;
  end;
  if MessageDlg('Confirmar a entrada e atualizar estoque e custo medio?',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;
  try
    TFiscalStorage.ConfirmarNFeEntrada(dmConexoes.conRobson, FEntradaId);
    dmConexoes.qrEstoque.Close;
    dmConexoes.qrEstoque.Open;
    MessageDlg('Entrada confirmada e estoque atualizado.', mtInformation,
      [mbOK], 0);
    Close;
  except
    on E: Exception do MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

end.
