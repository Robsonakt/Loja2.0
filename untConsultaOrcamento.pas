unit untConsultaOrcamento;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Data.DB, Data.Win.ADODB, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.ComCtrls,
  Vcl.Buttons, StrUtils;

type
  TfrmConsultaOrcamento = class(TForm)
    pnlTopo: TPanel;
    lblTitulo: TLabel;
    pnlRodape: TPanel;
    lblStatus: TLabel;
    lblRodapeDir: TLabel;
    pnlCorpo: TPanel;

    // Toolbar
    pnlToolbar: TPanel;
    pnConsultar: TPanel;
    pnReimprimir: TPanel;
    pnConverterVenda: TPanel;
    pnEnviarEmail: TPanel;

    // Filtros
    grpFiltro: TGroupBox;
    lblDataIni: TLabel;
    lblDataFim: TLabel;
    lblIntervalo: TLabel;
    cbIntervalo: TComboBox;
    dtDataIni: TDateTimePicker;
    dtDataFim: TDateTimePicker;

    // Grid orcamentos
    grpOrcamentos: TGroupBox;
    gridOrcamentos: TDBGrid;
    dsOrcamentos: TDataSource;
    fdOrcamentos: TFDMemTable;
    fdOrcId: TIntegerField;
    fdOrcData: TStringField;
    fdOrcCliente: TStringField;
    fdOrcVendedor: TStringField;
    fdOrcMaoObra: TCurrencyField;
    fdOrcTotal: TCurrencyField;
    fdOrcStatus: TStringField;

    // Grid itens do orcamento selecionado
    grpItens: TGroupBox;
    gridItens: TDBGrid;
    dsItens: TDataSource;
    fdItens: TFDMemTable;
    fdItCodProd: TIntegerField;
    fdItDescricao: TStringField;
    fdItQtd: TIntegerField;
    fdItValUnit: TCurrencyField;
    fdItValTotal: TCurrencyField;

    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);

    procedure pnConsultarClick(Sender: TObject);
    procedure pnConsultarMouseEnter(Sender: TObject);
    procedure pnConsultarMouseLeave(Sender: TObject);

    procedure pnReimprimirClick(Sender: TObject);
    procedure pnReimprimirMouseEnter(Sender: TObject);
    procedure pnReimprimirMouseLeave(Sender: TObject);

    procedure pnConverterVendaClick(Sender: TObject);
    procedure pnConverterVendaMouseEnter(Sender: TObject);
    procedure pnConverterVendaMouseLeave(Sender: TObject);
    procedure pnEnviarEmailClick(Sender: TObject);
    procedure pnEnviarEmailMouseEnter(Sender: TObject);
    procedure pnEnviarEmailMouseLeave(Sender: TObject);


    procedure cbIntervaloChange(Sender: TObject);
    procedure gridOrcamentosDataChange(Sender: TObject; Field: TField);

  private
    procedure Consultar;
    procedure CarregarItens(AIdOrcamento: Integer);
  public
    { Public declarations }
  end;

var
  frmConsultaOrcamento: TfrmConsultaOrcamento;

implementation

{$R *.dfm}

uses dmConexao, untLogUser, UntRelatorioOrcamento, untVenda, uEmailSMTP, uOrcamentoPDF, uEmpresaConfig;

const
  COR_DARK_BG    = 3289650;
  COR_DARK_PANEL = 2171170;
  COR_DARK_BTN   = 3355443;

procedure TfrmConsultaOrcamento.FormCreate(Sender: TObject);
begin
  // nada
end;

procedure TfrmConsultaOrcamento.FormShow(Sender: TObject);
begin
  cbIntervalo.ItemIndex := 0;
  cbIntervaloChange(nil);
  dtDataIni.Date := Date;
  dtDataFim.Date := Date;
  fdOrcamentos.Close;
  fdOrcamentos.Open;
  fdItens.Close;
  fdItens.Open;
end;

// ============================================================
// CONSULTAR
// ============================================================
procedure TfrmConsultaOrcamento.Consultar;
var
  qrTemp: TADOQuery;
  sWhere: string;
begin
  sWhere := '';

  if cbIntervalo.ItemIndex = 1 then
    sWhere := ' AND CAST(DataOrcamento AS DATE) BETWEEN ' +
      QuotedStr(FormatDateTime('yyyy-mm-dd', dtDataIni.Date)) +
      ' AND ' +
      QuotedStr(FormatDateTime('yyyy-mm-dd', dtDataFim.Date));

  fdOrcamentos.Close;
  fdOrcamentos.Open;
  fdItens.Close;
  fdItens.Open;

  qrTemp := TADOQuery.Create(nil);
  try
    qrTemp.Connection := dmConexoes.conRobson;
    qrTemp.SQL.Add(
      'SELECT Id, DataOrcamento, Cliente, Vendedor, MaoDeObra, ValorTotal, Status ' +
      'FROM Orcamento WHERE 1=1 ' + sWhere +
      ' ORDER BY DataOrcamento DESC'
    );
    qrTemp.Open;

    while not qrTemp.Eof do
    begin
      fdOrcamentos.Insert;
      fdOrcamentos.FieldByName('Id').AsInteger       := qrTemp.FieldByName('Id').AsInteger;
      fdOrcamentos.FieldByName('Data').AsString      := FormatDateTime('dd/mm/yyyy', qrTemp.FieldByName('DataOrcamento').AsDateTime);
      fdOrcamentos.FieldByName('Cliente').AsString   := qrTemp.FieldByName('Cliente').AsString;
      fdOrcamentos.FieldByName('Vendedor').AsString  := qrTemp.FieldByName('Vendedor').AsString;
      fdOrcamentos.FieldByName('MaoObra').AsCurrency := qrTemp.FieldByName('MaoDeObra').AsCurrency;
      fdOrcamentos.FieldByName('Total').AsCurrency   := qrTemp.FieldByName('ValorTotal').AsCurrency;
      if qrTemp.FieldByName('Status').AsString = 'A' then
        fdOrcamentos.FieldByName('Status').AsString := 'Ativo'
      else if qrTemp.FieldByName('Status').AsString = 'F' then
        fdOrcamentos.FieldByName('Status').AsString := 'Convertido'
      else
        fdOrcamentos.FieldByName('Status').AsString := 'Cancelado';
      fdOrcamentos.Post;
      qrTemp.Next;
    end;
  finally
    qrTemp.Free;
  end;
end;
// ============================================================
// CARREGAR ITENS DO ORCAMENTO SELECIONADO
// ============================================================
procedure TfrmConsultaOrcamento.CarregarItens(AIdOrcamento: Integer);
var
  qrTemp: TADOQuery;
begin
  fdItens.Close;
  fdItens.Open;
  if AIdOrcamento = 0 then Exit;

  qrTemp := TADOQuery.Create(nil);
  try
    qrTemp.Connection := dmConexoes.conRobson;
    qrTemp.SQL.Add(
      'SELECT CodigoProd, Descricao, Quantidade, ValorUnitario, ValorTotal ' +
      'FROM ItensOrcamento WHERE IdOrcamento = :IdOrc'
    );
    qrTemp.Parameters.ParamByName('IdOrc').Value := AIdOrcamento;
    qrTemp.Open;

    while not qrTemp.Eof do
    begin
      fdItens.Insert;
      fdItens.FieldByName('CodProd').AsInteger   := qrTemp.FieldByName('CodigoProd').AsInteger;
      fdItens.FieldByName('Descricao').AsString  := qrTemp.FieldByName('Descricao').AsString;
      fdItens.FieldByName('Qtd').AsInteger       := qrTemp.FieldByName('Quantidade').AsInteger;
      fdItens.FieldByName('ValUnit').AsCurrency  := qrTemp.FieldByName('ValorUnitario').AsCurrency;
      fdItens.FieldByName('ValTotal').AsCurrency := qrTemp.FieldByName('ValorTotal').AsCurrency;
      fdItens.Post;
      qrTemp.Next;
    end;
  finally
    qrTemp.Free;
  end;
end;

// ============================================================
// DATACHANGE DA GRID - carrega itens ao navegar
// ============================================================

procedure TfrmConsultaOrcamento.gridOrcamentosDataChange(Sender: TObject; Field: TField);
begin
  if fdOrcamentos.IsEmpty then Exit;
  CarregarItens(fdOrcamentos.FieldByName('Id').AsInteger);
end;

// ============================================================
// REIMPRIMIR
// ============================================================

procedure TfrmConsultaOrcamento.pnReimprimirClick(Sender: TObject);
var
  frmRel: TfrmRelatorioOrcamento;
  IdOrc: Integer;
  TotProd, MaoObra: Currency;
  Qtd: Integer;
begin
  if fdOrcamentos.IsEmpty then
  begin
    ShowMessage('Selecione um orcamento para reimprimir.');
    Exit;
  end;

  IdOrc   := fdOrcamentos.FieldByName('Id').AsInteger;
  MaoObra := fdOrcamentos.FieldByName('MaoObra').AsCurrency;

  TotProd := 0;
  Qtd     := 0;
  fdItens.First;
  while not fdItens.Eof do
  begin
    TotProd := TotProd + fdItens.FieldByName('ValTotal').AsCurrency;
    Inc(Qtd);
    fdItens.Next;
  end;
  fdItens.First;

  frmRel := TfrmRelatorioOrcamento.Create(Self);
  try
    frmRel.SetDados(
      'N' + #186 + ' ' + IntToStr(IdOrc) + '   |   ' + fdOrcamentos.FieldByName('Data').AsString,
      fdOrcamentos.FieldByName('Cliente').AsString,
      fdOrcamentos.FieldByName('Vendedor').AsString,
      fdOrcamentos.FieldByName('Data').AsString,
      '',
      Qtd,
      TotProd,
      MaoObra,
      TotProd + MaoObra,
      dsItens
    );
    frmRel.rlr_Orcamento.Preview;
  finally
    frmRel.Free;
  end;
end;

// ============================================================
// CONVERTER EM VENDA
// ============================================================

procedure TfrmConsultaOrcamento.pnConverterVendaClick(Sender: TObject);
var
  IdOrc: Integer;
  Convertida: Boolean;
begin
  if fdOrcamentos.IsEmpty then
  begin
    ShowMessage('Selecione um orcamento para converter em venda.');
    Exit;
  end;

  if fdOrcamentos.FieldByName('Status').AsString <> 'Ativo' then
  begin
    ShowMessage('Somente orcamentos ativos podem ser convertidos em venda.');
    Exit;
  end;

  if fdItens.IsEmpty then
  begin
    ShowMessage('Este orcamento nao possui itens.');
    Exit;
  end;

  if not dmConexoes.CaixaAberto then
  begin
    ShowMessage('O caixa esta fechado. Abra o caixa antes de converter o orcamento em venda.');
    Exit;
  end;

  if Application.MessageBox(
    PChar('Deseja converter o orcamento de ' +
          fdOrcamentos.FieldByName('Cliente').AsString +
          ' em venda?'),
    'Converter em Venda', MB_YESNO + MB_ICONQUESTION) <> IDYES then
    Exit;

  IdOrc := fdOrcamentos.FieldByName('Id').AsInteger;
  Convertida := False;

  Application.CreateForm(TfrmCaixaVendas, frmCaixaVendas);
  try
    frmCaixaVendas.VendaFinalizada := False;
    frmCaixaVendas.fdProduto.Close;
    frmCaixaVendas.fdProduto.Open;
    fdItens.First;
    while not fdItens.Eof do
    begin
      frmCaixaVendas.fdProduto.Insert;
      frmCaixaVendas.fdProduto.FieldByName('CodProd').AsInteger     := fdItens.FieldByName('CodProd').AsInteger;
      frmCaixaVendas.fdProduto.FieldByName('Descricao').AsString    := fdItens.FieldByName('Descricao').AsString;
      frmCaixaVendas.fdProduto.FieldByName('Quantidade').AsInteger  := fdItens.FieldByName('Qtd').AsInteger;
      frmCaixaVendas.fdProduto.FieldByName('ValorUni').AsCurrency   := fdItens.FieldByName('ValUnit').AsCurrency;
      frmCaixaVendas.fdProduto.FieldByName('ValorTotal').AsCurrency := fdItens.FieldByName('ValTotal').AsCurrency;
      frmCaixaVendas.fdProduto.Post;
      fdItens.Next;
    end;
    fdItens.First;
    // O total e recalculado pela tela de venda ao abrir (FormShow)
    frmCaixaVendas.ShowModal;
    Convertida := frmCaixaVendas.VendaFinalizada;
  finally
    frmCaixaVendas.Free;
    frmCaixaVendas := nil;
  end;

  if not Convertida then
  begin
    ShowMessage('A venda nao foi finalizada. O orcamento continua ativo.');
    Exit;
  end;

  with dmConexoes.qrComando do
  begin
    Close;
    SQL.Clear;
    SQL.Add('UPDATE Orcamento SET Status = ''F'' WHERE Id = :IdOrc');
    Parameters.ParamByName('IdOrc').Value := IdOrc;
    ExecSQL;
  end;
  Consultar;
end;

// ============================================================
// ENVIAR POR E-MAIL
// ============================================================
procedure TfrmConsultaOrcamento.pnEnviarEmailClick(Sender: TObject);
var
  IdOrc: Integer;
  TotProd, MaoObra: Currency;
  Qtd: Integer;
  EmailDestinatario: string;
  Assunto: string;
  Mensagem: string;
  CaminhoPDF: string;
  EmpresaTitulo: string;
begin
  if fdOrcamentos.IsEmpty then
  begin
    ShowMessage('Selecione um orcamento para enviar por e-mail.');
    Exit;
  end;

  IdOrc := fdOrcamentos.FieldByName('Id').AsInteger;
  MaoObra := fdOrcamentos.FieldByName('MaoObra').AsCurrency;

  TotProd := 0;
  Qtd := 0;
  fdItens.First;
  while not fdItens.Eof do
  begin
    TotProd := TotProd + fdItens.FieldByName('ValTotal').AsCurrency;
    Inc(Qtd);
    fdItens.Next;
  end;
  fdItens.First;

  EmailDestinatario := '';
  if not InputQuery('Enviar orcamento por e-mail', 'Informe o e-mail do cliente:', EmailDestinatario) then
    Exit;

  EmailDestinatario := Trim(EmailDestinatario);
  if not TEmailSMTP.EmailValido(EmailDestinatario) then
  begin
    MessageDlg('Informe um e-mail valido.', mtWarning, [mbOK], 0);
    Exit;
  end;

  EmpresaTitulo := TEmpresaConfig.NomeExibicao(dmConexoes.conRobson, dmConexoes.NomeEmpresa);
  Assunto := EmpresaTitulo + ' - Orcamento N ' + IntToStr(IdOrc);
  Mensagem := 'Ola, ' + fdOrcamentos.FieldByName('Cliente').AsString + sLineBreak + sLineBreak +
    'Segue em anexo o orcamento N ' + IntToStr(IdOrc) + ' em PDF.' + sLineBreak +
    'Quantidade de itens: ' + IntToStr(Qtd) + sLineBreak +
    'Produtos: R$ ' + FormatFloat('#,##0.00', TotProd) + sLineBreak +
    'Mao de obra: R$ ' + FormatFloat('#,##0.00', MaoObra) + sLineBreak +
    'Total: R$ ' + FormatFloat('#,##0.00', TotProd + MaoObra) + sLineBreak + sLineBreak +
    'Atenciosamente, ' + EmpresaTitulo;

  try
    CaminhoPDF := ExtractFilePath(Application.ExeName) + 'Orcamento_' + IntToStr(IdOrc) + '.pdf';
    TOrcamentoPDF.Gerar(CaminhoPDF, EmpresaTitulo,
      'N' + #186 + ' ' + IntToStr(IdOrc) + '   |   ' + fdOrcamentos.FieldByName('Data').AsString,
      fdOrcamentos.FieldByName('Cliente').AsString,
      fdOrcamentos.FieldByName('Vendedor').AsString,
      fdOrcamentos.FieldByName('Data').AsString, '', Qtd, TotProd, MaoObra,
      TotProd + MaoObra, dsItens.DataSet);
    TEmailSMTP.EnviarEmailComAnexo(EmailDestinatario, Assunto, Mensagem, CaminhoPDF);
    MessageDlg('Orcamento enviado por e-mail com sucesso.', mtInformation, [mbOK], 0);
  except
    on E: Exception do
      MessageDlg('Nao foi possivel enviar o orcamento por e-mail.' + sLineBreak + E.Message,
        mtError, [mbOK], 0);
  end;
end;

// ============================================================
// CONSULTAR CLICK
// ============================================================

procedure TfrmConsultaOrcamento.pnConsultarClick(Sender: TObject);
begin
  Consultar;
end;


// ============================================================
// COMBOBOX INTERVALO
// ============================================================

procedure TfrmConsultaOrcamento.cbIntervaloChange(Sender: TObject);
begin
  if cbIntervalo.ItemIndex = 1 then
  begin
    dtDataIni.Enabled := True;
    dtDataFim.Enabled := True;
  end
  else
  begin
    dtDataIni.Enabled := False;
    dtDataFim.Enabled := False;
  end;
end;

// ============================================================
// MOUSE ENTER / LEAVE
// ============================================================

procedure TfrmConsultaOrcamento.pnConsultarMouseEnter(Sender: TObject);
begin pnConsultar.Color := $001E8FBF; pnConsultar.Font.Color := clWhite; end;
procedure TfrmConsultaOrcamento.pnConsultarMouseLeave(Sender: TObject);
begin pnConsultar.Color := COR_DARK_BTN; pnConsultar.Font.Color := clWhite; end;

procedure TfrmConsultaOrcamento.pnReimprimirMouseEnter(Sender: TObject);
begin pnReimprimir.Color := $00CC6600; pnReimprimir.Font.Color := clWhite; end;
procedure TfrmConsultaOrcamento.pnReimprimirMouseLeave(Sender: TObject);
begin pnReimprimir.Color := COR_DARK_BTN; pnReimprimir.Font.Color := clWhite; end;

procedure TfrmConsultaOrcamento.pnConverterVendaMouseEnter(Sender: TObject);
begin pnConverterVenda.Color := clGreen; pnConverterVenda.Font.Color := clWhite; end;
procedure TfrmConsultaOrcamento.pnConverterVendaMouseLeave(Sender: TObject);
begin pnConverterVenda.Color := COR_DARK_BTN; pnConverterVenda.Font.Color := clWhite; end;

procedure TfrmConsultaOrcamento.pnEnviarEmailMouseEnter(Sender: TObject);
begin pnEnviarEmail.Color := $006666CC; pnEnviarEmail.Font.Color := clWhite; end;
procedure TfrmConsultaOrcamento.pnEnviarEmailMouseLeave(Sender: TObject);
begin pnEnviarEmail.Color := COR_DARK_BTN; pnEnviarEmail.Font.Color := clWhite; end;


end.
