unit untEmissaoXML;

interface

uses
  System.Classes, Vcl.Forms;

type
  TfrmEmissaoXML = class(TForm)
  private
    procedure MontarTela;
    procedure Atualizar(Sender: TObject);
    procedure GerarXML(Sender: TObject);
    function MontarXMLIntegracao(IdFiscal: Integer): string;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  System.SysUtils, Data.DB, Data.Win.ADODB, Xml.XMLDoc, Xml.XMLIntf,
  Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.DBGrids, Vcl.Dialogs,
  dmconexao, uFiscalStorage;

constructor TfrmEmissaoXML.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  MontarTela;
  Atualizar(nil);
end;

procedure TfrmEmissaoXML.MontarTela;
var
  P: TPanel;
  B: TButton;
  L: TLabel;
  Q: TADOQuery;
  DS: TDataSource;
  G: TDBGrid;
begin
  Caption := 'XML - Emissao fiscal';
  Width := 1050; Height := 620; Position := poScreenCenter;
  P := TPanel.Create(Self);
  P.Parent := Self; P.Align := alTop; P.Height := 70;
  B := TButton.Create(Self);
  B.Parent := P; B.SetBounds(12, 10, 120, 30);
  B.Caption := 'Atualizar'; B.OnClick := Atualizar;
  B := TButton.Create(Self);
  B.Parent := P; B.SetBounds(140, 10, 180, 30);
  B.Caption := 'Gerar XML para envio'; B.OnClick := GerarXML;
  L := TLabel.Create(Self);
  L.Parent := P; L.SetBounds(12, 48, 900, 17);
  L.Caption := 'A transmissao SEFAZ exige certificado e configuracao do ACBrNFe.';
  Q := TADOQuery.Create(Self);
  Q.Name := 'qryEmissao'; Q.Connection := dmConexoes.conRobson;
  DS := TDataSource.Create(Self); DS.DataSet := Q;
  G := TDBGrid.Create(Self);
  G.Parent := Self; G.Align := alClient; G.DataSource := DS;
  G.ReadOnly := True; G.Options := G.Options + [dgRowSelect];
end;

procedure TfrmEmissaoXML.Atualizar(Sender: TObject);
var
  Q: TADOQuery;
begin
  TFiscalStorage.GarantirEstrutura(dmConexoes.conRobson);
  Q := FindComponent('qryEmissao') as TADOQuery;
  Q.Close;
  Q.SQL.Text :=
    'SELECT IdFiscal, Modelo, Serie, Numero, CodVenda, StatusFiscal, ' +
    'StatusDescricao, ValorTotal, CriadoEm FROM dbo.FiscalDocumentos ' +
    'ORDER BY CriadoEm DESC';
  Q.Open;
end;

function TfrmEmissaoXML.MontarXMLIntegracao(IdFiscal: Integer): string;
var
  Doc: IXMLDocument;
  Raiz, Cab, Itens, NoItem: IXMLNode;
  Q, QI: TADOQuery;
begin
  Q := TADOQuery.Create(nil);
  QI := TADOQuery.Create(nil);
  try
    Q.Connection := dmConexoes.conRobson;
    Q.SQL.Text := 'SELECT * FROM dbo.FiscalDocumentos WHERE IdFiscal = :Id';
    Q.Parameters.ParamByName('Id').Value := IdFiscal;
    Q.Open;
    if Q.IsEmpty then raise Exception.Create('Documento fiscal nao encontrado.');
    QI.Connection := dmConexoes.conRobson;
    QI.SQL.Text := 'SELECT * FROM dbo.FiscalDocumentoItens WHERE IdFiscal = :Id ORDER BY Item';
    QI.Parameters.ParamByName('Id').Value := IdFiscal;
    QI.Open;

    Doc := TXMLDocument.Create(nil);
    Doc.Active := True;
    Doc.Version := '1.0';
    Doc.Encoding := 'UTF-8';
    Raiz := Doc.AddChild('DocumentoFiscalIntegracao');
    Raiz.Attributes['versao'] := '1.0';
    Cab := Raiz.AddChild('Cabecalho');
    Cab.AddChild('IdFiscal').Text := Q.FieldByName('IdFiscal').AsString;
    Cab.AddChild('Modelo').Text := Q.FieldByName('Modelo').AsString;
    Cab.AddChild('Serie').Text := Q.FieldByName('Serie').AsString;
    Cab.AddChild('Numero').Text := Q.FieldByName('Numero').AsString;
    Cab.AddChild('CodVenda').Text := Q.FieldByName('CodVenda').AsString;
    Cab.AddChild('ValorTotal').Text := StringReplace(
      FormatFloat('0.00', Q.FieldByName('ValorTotal').AsCurrency), ',', '.', []);
    Itens := Raiz.AddChild('Itens');
    while not QI.Eof do
    begin
      NoItem := Itens.AddChild('Item');
      NoItem.Attributes['numero'] := QI.FieldByName('Item').AsInteger;
      NoItem.AddChild('ProdutoId').Text := QI.FieldByName('ProdutoId').AsString;
      NoItem.AddChild('Descricao').Text := QI.FieldByName('Descricao').AsString;
      NoItem.AddChild('Quantidade').Text := QI.FieldByName('Quantidade').AsString;
      NoItem.AddChild('ValorUnitario').Text := QI.FieldByName('ValorUnitario').AsString;
      NoItem.AddChild('ValorTotal').Text := QI.FieldByName('ValorTotal').AsString;
      QI.Next;
    end;
    Result := Doc.XML.Text;
  finally
    QI.Free;
    Q.Free;
  end;
end;

procedure TfrmEmissaoXML.GerarXML(Sender: TObject);
var
  Q, U: TADOQuery;
  Id: Integer;
  XML: string;
begin
  Q := FindComponent('qryEmissao') as TADOQuery;
  if not Q.Active or Q.IsEmpty then Exit;
  Id := Q.FieldByName('IdFiscal').AsInteger;
  try
    XML := MontarXMLIntegracao(Id);
    U := TADOQuery.Create(nil);
    try
      U.Connection := dmConexoes.conRobson;
      U.SQL.Text :=
        'UPDATE dbo.FiscalDocumentos SET XmlEnvio = :XML, ' +
        'StatusFiscal = ''XML_GERADO'', StatusDescricao = ' +
        '''XML de integracao gerado; aguardando assinatura/transmissao ACBrNFe'', ' +
        'AtualizadoEm = GETDATE() WHERE IdFiscal = :Id';
      U.Parameters.ParamByName('XML').DataType := ftMemo;
      U.Parameters.ParamByName('XML').Value := XML;
      U.Parameters.ParamByName('Id').Value := Id;
      U.ExecSQL;
    finally
      U.Free;
    end;
    Atualizar(nil);
    MessageDlg('XML de integracao gerado e armazenado.', mtInformation,
      [mbOK], 0);
  except
    on E: Exception do MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

end.
