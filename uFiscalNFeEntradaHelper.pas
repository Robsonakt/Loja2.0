unit uFiscalNFeEntradaHelper;

interface

type
  TFiscalNFeEntradaHelper = class
  public
    class procedure ExecutarEntradaNFe; static;
  end;

implementation

uses
  System.SysUtils,
  System.Classes,
  System.Variants,
  Vcl.Dialogs,
  Xml.XMLDoc,
  Xml.XMLIntf,
  dmconexao,
  uFiscalStorage;

function TextoNo(const Node: IXMLNode; const Nome: string): string;
var
  Filho: IXMLNode;
begin
  Result := '';
  if Node = nil then
    Exit;

  Filho := Node.ChildNodes.FindNode(Nome);
  if Filho <> nil then
    Result := Trim(Filho.Text);
end;

function ValorXml(const Texto: string): Currency;
begin
  Result := StrToCurrDef(StringReplace(Texto, '.', FormatSettings.DecimalSeparator, [rfReplaceAll]), 0);
end;

function LocalizarNo(const Node: IXMLNode; const Nome: string): IXMLNode;
var
  I: Integer;
begin
  Result := nil;
  if Node = nil then
    Exit;

  if SameText(Node.NodeName, Nome) then
    Exit(Node);

  for I := 0 to Node.ChildNodes.Count - 1 do
  begin
    Result := LocalizarNo(Node.ChildNodes[I], Nome);
    if Result <> nil then
      Exit;
  end;
end;

procedure SomarItens(const Node: IXMLNode; var QuantidadeItens: Integer; var QuantidadeProdutos: Double);
var
  I: Integer;
  Prod: IXMLNode;
begin
  if Node = nil then
    Exit;

  if SameText(Node.NodeName, 'det') then
  begin
    Inc(QuantidadeItens);
    Prod := Node.ChildNodes.FindNode('prod');
    QuantidadeProdutos := QuantidadeProdutos + ValorXml(TextoNo(Prod, 'qCom'));
  end;

  for I := 0 to Node.ChildNodes.Count - 1 do
    SomarItens(Node.ChildNodes[I], QuantidadeItens, QuantidadeProdutos);
end;

procedure RegistrarItensEntrada(const InfNFe: IXMLNode; EntradaId: Integer);
var
  I: Integer;
  Det: IXMLNode;
  Prod: IXMLNode;
  Item: Integer;
begin
  Item := 1;
  for I := 0 to InfNFe.ChildNodes.Count - 1 do
  begin
    Det := InfNFe.ChildNodes[I];
    if not SameText(Det.NodeName, 'det') then
      Continue;

    Prod := Det.ChildNodes.FindNode('prod');
    if Prod = nil then
      Continue;

    TFiscalStorage.RegistrarNFeEntradaItem(dmConexoes.conRobson, EntradaId, Item, 0,
      TextoNo(Prod, 'cProd'),
      TextoNo(Prod, 'cEAN'),
      TextoNo(Prod, 'xProd'),
      TextoNo(Prod, 'NCM'),
      TextoNo(Prod, 'CFOP'),
      TextoNo(Prod, 'uCom'),
      ValorXml(TextoNo(Prod, 'qCom')),
      ValorXml(TextoNo(Prod, 'vUnCom')),
      ValorXml(TextoNo(Prod, 'vProd')));

    Inc(Item);
  end;
end;

function LerArquivoTexto(const Arquivo: string): string;
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    SL.LoadFromFile(Arquivo);
    Result := SL.Text;
  finally
    SL.Free;
  end;
end;

class procedure TFiscalNFeEntradaHelper.ExecutarEntradaNFe;
var
  Dialog: TOpenDialog;
  XML: IXMLDocument;
  InfNFe: IXMLNode;
  Ide: IXMLNode;
  Total: IXMLNode;
  ICMS: IXMLNode;
  Chave: string;
  Numero: string;
  Serie: string;
  ValorTotalTexto: string;
  QuantidadeItens: Integer;
  QuantidadeProdutos: Double;
  Mensagem: string;
  EntradaId: Integer;
  XmlOriginal: string;
begin
  Dialog := TOpenDialog.Create(nil);
  try
    Dialog.Title := 'Selecionar XML da NF-e de entrada';
    Dialog.Filter := 'XML da NF-e (*.xml)|*.xml|Todos os arquivos (*.*)|*.*';

    if not Dialog.Execute then
      Exit;

    XML := TXMLDocument.Create(nil);
    XML.LoadFromFile(Dialog.FileName);
    XML.Active := True;
    XmlOriginal := LerArquivoTexto(Dialog.FileName);

    InfNFe := LocalizarNo(XML.DocumentElement, 'infNFe');
    if InfNFe = nil then
    begin
      MessageDlg('Nao foi possivel localizar a tag infNFe no XML selecionado.', mtWarning, [mbOK], 0);
      Exit;
    end;

    Chave := StringReplace(VarToStr(InfNFe.Attributes['Id']), 'NFe', '', [rfIgnoreCase]);

    Ide := LocalizarNo(InfNFe, 'ide');
    Numero := TextoNo(Ide, 'nNF');
    Serie := TextoNo(Ide, 'serie');

    Total := LocalizarNo(InfNFe, 'total');
    ICMS := LocalizarNo(Total, 'ICMSTot');
    ValorTotalTexto := TextoNo(ICMS, 'vNF');

    QuantidadeItens := 0;
    QuantidadeProdutos := 0;
    SomarItens(InfNFe, QuantidadeItens, QuantidadeProdutos);

    EntradaId := TFiscalStorage.RegistrarNFeEntrada(dmConexoes.conRobson, Chave,
      StrToIntDef(Numero, 0), StrToIntDef(Serie, 0), ValorXml(ValorTotalTexto), XmlOriginal);
    RegistrarItensEntrada(InfNFe, EntradaId);

    Mensagem := 'NF-e de entrada importada e armazenada para conferencia/contabilidade.' + sLineBreak + sLineBreak +
      'Registro fiscal: ' + IntToStr(EntradaId) + sLineBreak +
      'Chave: ' + Chave + sLineBreak +
      'Numero: ' + Numero + sLineBreak +
      'Serie: ' + Serie + sLineBreak +
      'Itens: ' + IntToStr(QuantidadeItens) + sLineBreak +
      'Quantidade total: ' + FormatFloat('#,##0.####', QuantidadeProdutos) + sLineBreak +
      'Valor total: R$ ' + ValorTotalTexto + sLineBreak + sLineBreak +
      'Proximo passo: vincular os itens aos produtos e confirmar a movimentacao de estoque.';

    MessageDlg(Mensagem, mtInformation, [mbOK], 0);
  finally
    Dialog.Free;
  end;
end;

end.
