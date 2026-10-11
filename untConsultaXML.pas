unit untConsultaXML;

interface

uses
  System.Classes, Vcl.Forms;

type
  TfrmConsultaXML = class(TForm)
  private
    procedure MontarTela;
    procedure Atualizar(Sender: TObject);
    procedure SalvarXML(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  System.SysUtils, System.IOUtils, Data.DB, Data.Win.ADODB, Vcl.Controls,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.DBGrids, Vcl.Dialogs, dmconexao,
  uFiscalStorage;

constructor TfrmConsultaXML.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  MontarTela;
  Atualizar(nil);
end;

procedure TfrmConsultaXML.MontarTela;
var
  P: TPanel;
  B: TButton;
  Q: TADOQuery;
  DS: TDataSource;
  G: TDBGrid;
begin
  Caption := 'XML - Consulta fiscal';
  Width := 1050; Height := 620; Position := poScreenCenter;
  P := TPanel.Create(Self);
  P.Parent := Self; P.Align := alTop; P.Height := 52;
  B := TButton.Create(Self);
  B.Parent := P; B.SetBounds(12, 11, 120, 30);
  B.Caption := 'Atualizar'; B.OnClick := Atualizar;
  B := TButton.Create(Self);
  B.Parent := P; B.SetBounds(140, 11, 160, 30);
  B.Caption := 'Salvar XML selecionado'; B.OnClick := SalvarXML;
  Q := TADOQuery.Create(Self);
  Q.Name := 'qryConsulta'; Q.Connection := dmConexoes.conRobson;
  DS := TDataSource.Create(Self);
  DS.DataSet := Q;
  G := TDBGrid.Create(Self);
  G.Parent := Self; G.Align := alClient; G.DataSource := DS;
  G.ReadOnly := True; G.Options := G.Options + [dgRowSelect];
end;

procedure TfrmConsultaXML.Atualizar(Sender: TObject);
var
  Q: TADOQuery;
begin
  TFiscalStorage.GarantirEstrutura(dmConexoes.conRobson);
  Q := FindComponent('qryConsulta') as TADOQuery;
  Q.Close;
  Q.SQL.Text :=
    'SELECT ''SAIDA'' AS Tipo, IdFiscal AS ID, Modelo, Numero, Serie, ' +
    'ChaveAcesso, StatusFiscal AS Status, StatusDescricao, ValorTotal, ' +
    'CriadoEm, COALESCE(XmlAutorizado, XmlEnvio) AS XML ' +
    'FROM dbo.FiscalDocumentos UNION ALL ' +
    'SELECT ''ENTRADA'', IdEntradaFiscal, ''55'', Numero, Serie, ChaveAcesso, ' +
    'StatusEntrada, NULL, ValorTotal, CriadoEm, XmlOriginal ' +
    'FROM dbo.FiscalNFeEntradas ORDER BY CriadoEm DESC';
  Q.Open;
  if Q.FindField('XML') <> nil then Q.FieldByName('XML').Visible := False;
end;

procedure TfrmConsultaXML.SalvarXML(Sender: TObject);
var
  Q: TADOQuery;
  D: TSaveDialog;
  Conteudo: string;
begin
  Q := FindComponent('qryConsulta') as TADOQuery;
  if not Q.Active or Q.IsEmpty then Exit;
  Conteudo := Q.FieldByName('XML').AsString;
  if Trim(Conteudo) = '' then
  begin
    MessageDlg('Este registro ainda nao possui XML.', mtWarning, [mbOK], 0);
    Exit;
  end;
  D := TSaveDialog.Create(nil);
  try
    D.Filter := 'Arquivo XML (*.xml)|*.xml';
    D.DefaultExt := 'xml';
    D.FileName := Q.FieldByName('Tipo').AsString + '_' +
      Q.FieldByName('ID').AsString + '.xml';
    if D.Execute then
      TFile.WriteAllText(D.FileName, Conteudo, TEncoding.UTF8);
  finally
    D.Free;
  end;
end;

end.
