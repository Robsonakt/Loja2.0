unit untOrcamento;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Data.DB, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.ComCtrls,
  Vcl.Buttons, Data.Win.ADODB;

type
  TfrmOrcamento = class(TForm)
    pnlTopo: TPanel;
    lblTitulo: TLabel;
    lblNumOrc: TLabel;
    pnlRodape: TPanel;
    lblStatus: TLabel;
    lblRodapeDir: TLabel;
    pnlCliente: TPanel;
    pnlToolbar: TPanel;
    pnNovo: TPanel;
    pnSalvar: TPanel;
    pnImprimir: TPanel;
    grpCabecalho: TGroupBox;
    lblCliente: TLabel;
    lblVendedor: TLabel;
    lblValidade: TLabel;
    lblObs: TLabel;
    lblMaoDeObra: TLabel;
    edtCli: TEdit;
    edtVendedor: TEdit;
    edtValidade: TDateTimePicker;
    memoObs: TMemo;
    edtMaoDeObra: TEdit;
    grpItens: TGroupBox;
    DBGrid1: TDBGrid;
    DSItensOrc: TDataSource;
    fdItens: TFDMemTable;
    fdItensCodProd: TIntegerField;
    fdItensDescricao: TStringField;
    fdItensQuantidade: TIntegerField;
    fdItensValorUni: TCurrencyField;
    fdItensValorTotal: TCurrencyField;
    grpAddItem: TGroupBox;
    lblCodProd: TLabel;
    lblDescProd: TLabel;
    lblQuantAdd: TLabel;
    edtCodProd: TEdit;
    lbNomeProd: TLabel;
    edtQuantAdd: TEdit;
    pnAddItem: TPanel;
    pnlDireito: TPanel;
    pnlTotal: TPanel;
    lblTotalLabel: TLabel;
    lblTotalValor: TLabel;
    lblQtdLabel: TLabel;
    lblQtdValor: TLabel;
    lblMaoDeObraLabel: TLabel;
    lblMaoDeObraValor: TLabel;

    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure pnNovoClick(Sender: TObject);
    procedure pnNovoMouseEnter(Sender: TObject);
    procedure pnNovoMouseLeave(Sender: TObject);
    procedure pnSalvarClick(Sender: TObject);
    procedure pnSalvarMouseEnter(Sender: TObject);
    procedure pnSalvarMouseLeave(Sender: TObject);
    procedure pnImprimirClick(Sender: TObject);
    procedure pnImprimirMouseEnter(Sender: TObject);
    procedure pnImprimirMouseLeave(Sender: TObject);
    procedure pnCancelarClick(Sender: TObject);
    procedure pnAddItemClick(Sender: TObject);
    procedure pnAddItemMouseEnter(Sender: TObject);
    procedure pnAddItemMouseLeave(Sender: TObject);
    procedure edtCodProdKeyPress(Sender: TObject; var Key: Char);
    procedure edtCodProdKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edtQuantAddKeyPress(Sender: TObject; var Key: Char);
    procedure DBGrid1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edtCliKeyPress(Sender: TObject; var Key: Char);
    procedure edtMaoDeObraKeyPress(Sender: TObject; var Key: Char);
    procedure edtMaoDeObraExit(Sender: TObject);

  private
    FTotalOrcamento: Currency;
    FIdOrcamento: Integer;
    procedure LimparTela;
    procedure AtualizarTotal;
    procedure AdicionarItem;
    procedure RemoverItemSelecionado;
    procedure HabilitarCampos(AHabilitar: Boolean);
    procedure VerificaProduto;
  public
    { Public declarations }
  end;

var
  frmOrcamento: TfrmOrcamento;

implementation

{$R *.dfm}

uses dmConexao, untLogUser, untLocalizaProd, untInicial, UntRelatorioOrcamento;

const
  COR_DARK_BG    = 3289650;
  COR_DARK_PANEL = 2171170;
  COR_DARK_BTN   = 3355443;

procedure TfrmOrcamento.FormCreate(Sender: TObject);
begin
  FTotalOrcamento := 0;
  FIdOrcamento    := 0;
end;

procedure TfrmOrcamento.FormShow(Sender: TObject);
begin
  edtVendedor.Text := dmConexoes.qrUsuario.FieldByName('Usuario').AsString;
  edtValidade.Date := Date + 7;

  with dmConexoes.qrComando do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT ISNULL(MAX(Id), 0) + 1 AS PROXIMO FROM Orcamento');
    Open;
    lblNumOrc.Caption := 'N' + #186 + ' ' + FieldByName('PROXIMO').AsString +
                         '   |   ' + FormatDateTime('dd/mm/yyyy', Date);
    Close;
  end;

  fdItens.Close;
  fdItens.Open;
  AtualizarTotal;
  HabilitarCampos(False);
  ActiveControl := pnNovo;
end;

procedure TfrmOrcamento.HabilitarCampos(AHabilitar: Boolean);
begin
  if AHabilitar then
  begin
    edtCli.Enabled       := True;
    edtValidade.Enabled  := True;
    memoObs.Enabled      := True;
    edtMaoDeObra.Enabled := True;
    edtCodProd.Enabled   := True;
    edtQuantAdd.Enabled  := True;
    pnAddItem.Enabled    := True;
    pnSalvar.Enabled     := True;
    pnImprimir.Enabled   := True;
    DBGrid1.Enabled      := True;
  end
  else
  begin
    edtCli.Enabled       := False;
    edtValidade.Enabled  := False;
    memoObs.Enabled      := False;
    edtMaoDeObra.Enabled := False;
    edtCodProd.Enabled   := False;
    edtQuantAdd.Enabled  := False;
    pnAddItem.Enabled    := False;
    pnSalvar.Enabled     := False;
    pnImprimir.Enabled   := False;
    DBGrid1.Enabled      := False;
  end;
end;

procedure TfrmOrcamento.AtualizarTotal;
var
  TotProd, TotMdo: Currency;
  Qtd: Integer;
  ValStr: string;
begin
  TotProd := 0;
  Qtd     := 0;
  fdItens.First;
  while not fdItens.Eof do
  begin
    TotProd := TotProd + fdItens.FieldByName('ValorTotal').AsCurrency;
    Inc(Qtd);
    fdItens.Next;
  end;

  ValStr := Trim(edtMaoDeObra.Text);
  ValStr := StringReplace(ValStr, '.', '', [rfReplaceAll]);
  ValStr := StringReplace(ValStr, ',', '.', [rfReplaceAll]);
  TotMdo := StrToCurrDef(ValStr, 0);

  FTotalOrcamento           := TotProd + TotMdo;
  lblQtdValor.Caption       := IntToStr(Qtd) + ' iten(s)';
  lblMaoDeObraValor.Caption := 'R$ ' + FormatFloat('#,##0.00', TotMdo);
  lblTotalValor.Caption     := 'R$ ' + FormatFloat('#,##0.00', FTotalOrcamento);
end;

procedure TfrmOrcamento.VerificaProduto;
begin
  with dmConexoes do
  begin
    qrEstoque.Close;
    qrEstoque.SQL.Clear;
    qrEstoque.SQL.Add('SELECT * FROM PRODUTOS WHERE CODIGO = :pcod');
    qrEstoque.Parameters.ParamByName('pcod').Value := StrToIntDef(edtCodProd.Text, 0);
    qrEstoque.Open;

    if qrEstoque.IsEmpty then
    begin
      Application.MessageBox('Produto nao encontrado', 'Atencao', MB_OK + MB_ICONERROR);
      lbNomeProd.Caption    := 'Produto nao encontrado';
      lbNomeProd.Font.Color := clRed;
      edtCodProd.SetFocus;
    end
    else
    begin
      lbNomeProd.Caption := qrEstoque.FieldByName('descricao').AsString +
        '  |  R$ ' + FormatFloat('#,##0.00', qrEstoque.FieldByName('valorvenda').AsCurrency) +
        '  |  Estoque: ' + qrEstoque.FieldByName('quantidade').AsString;
      lbNomeProd.Font.Color := clLime;
      edtQuantAdd.SetFocus;
    end;
  end;
end;

procedure TfrmOrcamento.AdicionarItem;
var
  Qtd: Integer;
  ValUni, ValTot: Currency;
begin
  if Trim(edtCodProd.Text) = '' then
  begin
    ShowMessage('Informe o codigo do produto.');
    edtCodProd.SetFocus;
    Exit;
  end;

  Qtd := StrToIntDef(Trim(edtQuantAdd.Text), 0);
  if Qtd <= 0 then
  begin
    ShowMessage('Informe uma quantidade valida.');
    edtQuantAdd.SetFocus;
    Exit;
  end;

  with dmConexoes.qrEstoque do
  begin
    if IsEmpty then
    begin
      ShowMessage('Busque um produto valido antes de adicionar.');
      edtCodProd.SetFocus;
      Exit;
    end;

    ValUni := FieldByName('valorvenda').AsCurrency;
    ValTot := ValUni * Qtd;

    fdItens.Insert;
    fdItens.FieldByName('CodProd').AsInteger     := FieldByName('codigo').AsInteger;
    fdItens.FieldByName('Descricao').AsString    := FieldByName('descricao').AsString;
    fdItens.FieldByName('Quantidade').AsInteger  := Qtd;
    fdItens.FieldByName('ValorUni').AsCurrency   := ValUni;
    fdItens.FieldByName('ValorTotal').AsCurrency := ValTot;
    fdItens.Post;
  end;

  AtualizarTotal;
  edtCodProd.Clear;
  edtQuantAdd.Clear;
  lbNomeProd.Caption    := 'Digite o codigo do produto';
  lbNomeProd.Font.Color := clSilver;
  edtCodProd.SetFocus;
end;

procedure TfrmOrcamento.RemoverItemSelecionado;
begin
  if fdItens.IsEmpty then Exit;
  if Application.MessageBox('Remover este item do orcamento?', 'Confirmar',
    MB_YESNO + MB_ICONQUESTION) = IDYES then
  begin
    fdItens.Delete;
    AtualizarTotal;
  end;
end;

procedure TfrmOrcamento.LimparTela;
begin
  edtCli.Clear;
  edtMaoDeObra.Clear;
  edtValidade.Date      := Date + 7;
  memoObs.Clear;
  edtCodProd.Clear;
  edtQuantAdd.Clear;
  lbNomeProd.Caption    := 'Digite o codigo do produto';
  lbNomeProd.Font.Color := clSilver;
  FTotalOrcamento       := 0;
  fdItens.Close;
  fdItens.Open;
  AtualizarTotal;

  with dmConexoes.qrComando do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT ISNULL(MAX(Id), 0) + 1 AS PROXIMO FROM Orcamento');
    Open;
    lblNumOrc.Caption := 'N' + #186 + ' ' + FieldByName('PROXIMO').AsString +
                         '   |   ' + FormatDateTime('dd/mm/yyyy', Date);
    Close;
  end;
end;

procedure TfrmOrcamento.pnSalvarClick(Sender: TObject);
var
  IdOrc: Integer;
  ValMdo: Currency;
  ValStr: string;
begin
  if Trim(edtCli.Text) = '' then
  begin
    ShowMessage('Informe o nome do cliente.');
    edtCli.SetFocus;
    Exit;
  end;

  if fdItens.IsEmpty then
  begin
    ShowMessage('Adicione ao menos um item ao orcamento.');
    Exit;
  end;

  ValStr := Trim(edtMaoDeObra.Text);
  ValStr := StringReplace(ValStr, '.', '', [rfReplaceAll]);
  ValStr := StringReplace(ValStr, ',', '.', [rfReplaceAll]);
  ValMdo := StrToCurrDef(ValStr, 0);

  with dmConexoes do
  begin
    qrComando.Close;
    qrComando.SQL.Clear;
    qrComando.SQL.Add(
      'INSERT INTO Orcamento (DataOrcamento, Cliente, Vendedor, Observacoes, MaoDeObra, ValorTotal, Status) ' +
      'VALUES (GETDATE(), :Cliente, :Vendedor, :Obs, :MaoDeObra, :ValorTotal, ''A''); ' +
      'SELECT SCOPE_IDENTITY() AS NovoId'
    );
    qrComando.Parameters.ParamByName('Cliente').Value    := edtCli.Text;
    qrComando.Parameters.ParamByName('Vendedor').Value   := edtVendedor.Text;
    qrComando.Parameters.ParamByName('Obs').Value        := memoObs.Text;
    qrComando.Parameters.ParamByName('MaoDeObra').Value  := ValMdo;
    qrComando.Parameters.ParamByName('ValorTotal').Value := FTotalOrcamento;
    qrComando.Open;
    IdOrc := qrComando.FieldByName('NovoId').AsInteger;
    qrComando.Close;

    fdItens.First;
    while not fdItens.Eof do
    begin
      qrComando.Close;
      qrComando.SQL.Clear;
      qrComando.SQL.Add(
        'INSERT INTO ItensOrcamento (IdOrcamento, CodigoProd, Descricao, Quantidade, ValorUnitario, ValorTotal) ' +
        'VALUES (:IdOrc, :CodProd, :Desc, :Qtd, :ValUni, :ValTot)'
      );
      qrComando.Parameters.ParamByName('IdOrc').Value   := IdOrc;
      qrComando.Parameters.ParamByName('CodProd').Value := fdItens.FieldByName('CodProd').AsInteger;
      qrComando.Parameters.ParamByName('Desc').Value    := fdItens.FieldByName('Descricao').AsString;
      qrComando.Parameters.ParamByName('Qtd').Value     := fdItens.FieldByName('Quantidade').AsInteger;
      qrComando.Parameters.ParamByName('ValUni').Value  := fdItens.FieldByName('ValorUni').AsCurrency;
      qrComando.Parameters.ParamByName('ValTot').Value  := fdItens.FieldByName('ValorTotal').AsCurrency;
      qrComando.ExecSQL;
      fdItens.Next;
    end;
  end;

  FIdOrcamento := IdOrc;
  Application.MessageBox('Orcamento salvo com sucesso!', 'Sucesso', MB_OK + MB_ICONINFORMATION);
end;

procedure TfrmOrcamento.pnImprimirClick(Sender: TObject);
var
  frmRel: TfrmRelatorioOrcamento;
  ValStr: string;
  ValMdo, TotProd: Currency;
  Qtd: Integer;
begin
  if FIdOrcamento = 0 then
  begin
    ShowMessage('Salve o orcamento antes de imprimir.');
    Exit;
  end;

  TotProd := 0;
  Qtd     := 0;
  fdItens.First;
  while not fdItens.Eof do
  begin
    TotProd := TotProd + fdItens.FieldByName('ValorTotal').AsCurrency;
    Inc(Qtd);
    fdItens.Next;
  end;
  fdItens.First;

  ValStr := Trim(edtMaoDeObra.Text);
  ValStr := StringReplace(ValStr, '.', '', [rfReplaceAll]);
  ValStr := StringReplace(ValStr, ',', '.', [rfReplaceAll]);
  ValMdo := StrToCurrDef(ValStr, 0);

  frmRel := TfrmRelatorioOrcamento.Create(Self);
  try
    frmRel.SetDados(
      lblNumOrc.Caption,
      edtCli.Text,
      edtVendedor.Text,
      FormatDateTime('dd/mm/yyyy', edtValidade.Date),
      memoObs.Text,
      Qtd,
      TotProd,
      ValMdo,
      TotProd + ValMdo,
      DSItensOrc   // <-- passa o datasource local diretamente
    );
    frmRel.rlr_Orcamento.Preview;
  finally
    frmRel.Free;
  end;
end;

procedure TfrmOrcamento.pnNovoClick(Sender: TObject);
begin
  if Application.MessageBox('Deseja iniciar um novo orcamento?', 'Novo Orcamento',
    MB_YESNO + MB_ICONQUESTION) = IDYES then
  begin
    FIdOrcamento := 0;
    HabilitarCampos(True);
    LimparTela;
    edtCli.SetFocus;
  end;
end;

procedure TfrmOrcamento.pnCancelarClick(Sender: TObject);
begin
  if Application.MessageBox('Deseja fechar o orcamento?', 'Fechar',
    MB_YESNO + MB_ICONQUESTION) = IDYES then
    Close;
end;

procedure TfrmOrcamento.pnAddItemClick(Sender: TObject);
begin
  AdicionarItem;
end;

procedure TfrmOrcamento.edtCodProdKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #13) and (edtCodProd.Text <> '') then
  begin
    Key := #0;
    VerificaProduto;
  end;
end;

procedure TfrmOrcamento.edtCodProdKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  KeyChar: Char;
begin
  if Key = VK_F2 then
  begin
    Key := 0;
    Application.CreateForm(TfrmLocalizaProd, frmLocalizaProd);
    frmLocalizaProd.ShowModal;
    frmLocalizaProd.Free;
    edtCodProd.Text := LocalizaCodigoProd;
    KeyChar := #13;
    edtCodProdKeyPress(Self, KeyChar);
  end;
end;

procedure TfrmOrcamento.edtQuantAddKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    AdicionarItem;
  end
  else if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmOrcamento.DBGrid1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then
    RemoverItemSelecionado;
end;

procedure TfrmOrcamento.edtCliKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    edtCodProd.SetFocus;
  end;
end;

procedure TfrmOrcamento.edtMaoDeObraKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    AtualizarTotal;
    edtCodProd.SetFocus;
  end
  else if not (Key in ['0'..'9', ',', #8]) then
    Key := #0;
end;

procedure TfrmOrcamento.edtMaoDeObraExit(Sender: TObject);
begin
  AtualizarTotal;
end;

procedure TfrmOrcamento.pnNovoMouseEnter(Sender: TObject);
begin pnNovo.Color := $001E8FBF; pnNovo.Font.Color := clWhite; end;
procedure TfrmOrcamento.pnNovoMouseLeave(Sender: TObject);
begin pnNovo.Color := COR_DARK_BTN; pnNovo.Font.Color := clWhite; end;

procedure TfrmOrcamento.pnSalvarMouseEnter(Sender: TObject);
begin pnSalvar.Color := clGreen; pnSalvar.Font.Color := clWhite; end;
procedure TfrmOrcamento.pnSalvarMouseLeave(Sender: TObject);
begin pnSalvar.Color := COR_DARK_BTN; pnSalvar.Font.Color := clWhite; end;

procedure TfrmOrcamento.pnImprimirMouseEnter(Sender: TObject);
begin pnImprimir.Color := $00CC6600; pnImprimir.Font.Color := clWhite; end;
procedure TfrmOrcamento.pnImprimirMouseLeave(Sender: TObject);
begin pnImprimir.Color := COR_DARK_BTN; pnImprimir.Font.Color := clWhite; end;

procedure TfrmOrcamento.pnAddItemMouseEnter(Sender: TObject);
begin pnAddItem.Color := clGreen; pnAddItem.Font.Color := clWhite; end;
procedure TfrmOrcamento.pnAddItemMouseLeave(Sender: TObject);
begin pnAddItem.Color := COR_DARK_BTN; pnAddItem.Font.Color := clWhite; end;

end.
