unit untConsultaFechamento;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Data.DB, Data.Win.ADODB, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.ComCtrls;

type
  TfrmConsultaFechamento = class(TForm)
    pnlTopo: TPanel;
    lblTitulo: TLabel;
    pnlRodape: TPanel;
    lblStatus: TLabel;
    lblRodapeDir: TLabel;
    pnlCorpo: TPanel;
    pnlToolbar: TPanel;
    pnConsultar: TPanel;
    pnFechar: TPanel;
    grpFiltro: TGroupBox;
    lblIntervalo: TLabel;
    lblDataIni: TLabel;
    lblDataFim: TLabel;
    lblStatusFiltro: TLabel;
    cbIntervalo: TComboBox;
    dtDataIni: TDateTimePicker;
    dtDataFim: TDateTimePicker;
    cbStatus: TComboBox;
    grpGrid: TGroupBox;
    gridFechamento: TDBGrid;
    dsFechamento: TDataSource;
    fdFechamento: TFDMemTable;
    fdId: TIntegerField;
    fdDataAbertura: TStringField;
    fdDataFechamento: TStringField;
    fdValorAbertura: TCurrencyField;
    fdValorVendas: TCurrencyField;
    fdSaldoFinal: TCurrencyField;
    fdStatus: TStringField;
    fdUsuarioAbertura: TStringField;
    fdUsuarioFechamento: TStringField;
    grpTotais: TGroupBox;
    lblTotAberturaLabel: TLabel;
    lblTotAbertura: TLabel;
    lblTotVendasLabel: TLabel;
    lblTotVendas: TLabel;
    lblTotSaldoLabel: TLabel;
    lblTotSaldo: TLabel;

    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure pnConsultarClick(Sender: TObject);
    procedure pnConsultarMouseEnter(Sender: TObject);
    procedure pnConsultarMouseLeave(Sender: TObject);
    procedure pnFecharClick(Sender: TObject);
    procedure pnFecharMouseEnter(Sender: TObject);
    procedure pnFecharMouseLeave(Sender: TObject);
    procedure cbIntervaloChange(Sender: TObject);

  private
    procedure Consultar;
    procedure AtualizarTotais;
    procedure LimparTotais;
  public
    { Public declarations }
  end;

var
  frmConsultaFechamento: TfrmConsultaFechamento;

implementation

{$R *.dfm}

uses dmConexao;

const
  COR_DARK_BG    = 3289650;
  COR_DARK_PANEL = 2171170;
  COR_DARK_BTN   = 3355443;

procedure TfrmConsultaFechamento.FormCreate(Sender: TObject);
begin
  // nada
end;

procedure TfrmConsultaFechamento.FormShow(Sender: TObject);
begin
  cbIntervalo.ItemIndex := 0;
  cbStatus.ItemIndex    := 0;
  cbIntervaloChange(nil);
  dtDataIni.Date := Date;
  dtDataFim.Date := Date;
  fdFechamento.Close;
  fdFechamento.Open;
  LimparTotais;
end;

procedure TfrmConsultaFechamento.LimparTotais;
begin
  lblTotAbertura.Caption := 'R$ 0,00';
  lblTotVendas.Caption   := 'R$ 0,00';
  lblTotSaldo.Caption    := 'R$ 0,00';
end;

// ============================================================
// CONSULTAR
// ============================================================

procedure TfrmConsultaFechamento.Consultar;
var
  qrTemp: TADOQuery;
  sWhere: string;
begin
  sWhere := '';

  if cbIntervalo.ItemIndex = 1 then
    sWhere := sWhere +
      ' AND CAST(DataAbertura AS DATE) BETWEEN ' +
      QuotedStr(FormatDateTime('yyyy-mm-dd', dtDataIni.Date)) +
      ' AND ' +
      QuotedStr(FormatDateTime('yyyy-mm-dd', dtDataFim.Date));

  case cbStatus.ItemIndex of
    1: sWhere := sWhere + ' AND Status = ''A''';
    2: sWhere := sWhere + ' AND Status = ''F''';
  end;

  fdFechamento.Close;
  fdFechamento.Open;
  LimparTotais;

  qrTemp := TADOQuery.Create(nil);
  try
    qrTemp.Connection := dmConexoes.conRobson;
    qrTemp.SQL.Add(
      'SELECT c.Id, c.DataAbertura, c.DataFechamento, ' +
      'c.ValorAbertura, c.ValorFechamento, c.Status, ' +
      'ISNULL(c.UsuarioAbertura, ''---'') AS UsuarioAbertura, ' +
      'ISNULL(c.UsuarioFechamento, ''---'') AS UsuarioFechamento, ' +
      'ISNULL(( ' +
      '  SELECT SUM(v.ValorTotal) FROM VENDAS v ' +
      '  WHERE CAST(v.DataVenda AS DATE) >= CAST(c.DataAbertura AS DATE) ' +
      '  AND (c.DataFechamento IS NULL OR CAST(v.DataVenda AS DATE) <= CAST(c.DataFechamento AS DATE)) ' +
      '), 0) AS TotalVendas ' +
      'FROM Caixa c WHERE 1=1 ' + sWhere +
      ' ORDER BY c.DataAbertura DESC'
    );
    qrTemp.Open;

    while not qrTemp.Eof do
    begin
      fdFechamento.Insert;
      fdFechamento.FieldByName('Id').AsInteger := qrTemp.FieldByName('Id').AsInteger;

      fdFechamento.FieldByName('DataAbertura').AsString :=
        FormatDateTime('dd/mm/yyyy hh:nn', qrTemp.FieldByName('DataAbertura').AsDateTime);

      if qrTemp.FieldByName('DataFechamento').IsNull then
        fdFechamento.FieldByName('DataFechamento').AsString := '---'
      else
        fdFechamento.FieldByName('DataFechamento').AsString :=
          FormatDateTime('dd/mm/yyyy hh:nn', qrTemp.FieldByName('DataFechamento').AsDateTime);

      fdFechamento.FieldByName('ValorAbertura').AsCurrency :=
        qrTemp.FieldByName('ValorAbertura').AsCurrency;

      fdFechamento.FieldByName('ValorVendas').AsCurrency :=
        qrTemp.FieldByName('TotalVendas').AsCurrency;

      fdFechamento.FieldByName('SaldoFinal').AsCurrency :=
        qrTemp.FieldByName('ValorFechamento').AsCurrency;

      fdFechamento.FieldByName('UsuarioAbertura').AsString :=
        qrTemp.FieldByName('UsuarioAbertura').AsString;

      fdFechamento.FieldByName('UsuarioFechamento').AsString :=
        qrTemp.FieldByName('UsuarioFechamento').AsString;

      if qrTemp.FieldByName('Status').AsString = 'A' then
        fdFechamento.FieldByName('Status').AsString := 'Aberto'
      else
        fdFechamento.FieldByName('Status').AsString := 'Fechado';

      fdFechamento.Post;
      qrTemp.Next;
    end;
  finally
    qrTemp.Free;
  end;

  AtualizarTotais;
end;

// ============================================================
// ATUALIZAR TOTAIS
// ============================================================

procedure TfrmConsultaFechamento.AtualizarTotais;
var
  TotAbertura, TotVendas, TotSaldo: Currency;
begin
  TotAbertura := 0;
  TotVendas   := 0;
  TotSaldo    := 0;

  fdFechamento.First;
  while not fdFechamento.Eof do
  begin
    TotAbertura := TotAbertura + fdFechamento.FieldByName('ValorAbertura').AsCurrency;
    TotVendas   := TotVendas   + fdFechamento.FieldByName('ValorVendas').AsCurrency;
    TotSaldo    := TotSaldo    + fdFechamento.FieldByName('SaldoFinal').AsCurrency;
    fdFechamento.Next;
  end;

  lblTotAbertura.Caption := 'R$ ' + FormatFloat('#,##0.00', TotAbertura);
  lblTotVendas.Caption   := 'R$ ' + FormatFloat('#,##0.00', TotVendas);
  lblTotSaldo.Caption    := 'R$ ' + FormatFloat('#,##0.00', TotSaldo);
end;

// ============================================================
// EVENTOS
// ============================================================

procedure TfrmConsultaFechamento.pnConsultarClick(Sender: TObject);
begin
  Consultar;
end;

procedure TfrmConsultaFechamento.pnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmConsultaFechamento.cbIntervaloChange(Sender: TObject);
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

procedure TfrmConsultaFechamento.pnConsultarMouseEnter(Sender: TObject);
begin pnConsultar.Color := $001E8FBF; pnConsultar.Font.Color := clWhite; end;
procedure TfrmConsultaFechamento.pnConsultarMouseLeave(Sender: TObject);
begin pnConsultar.Color := COR_DARK_BTN; pnConsultar.Font.Color := clWhite; end;

procedure TfrmConsultaFechamento.pnFecharMouseEnter(Sender: TObject);
begin pnFechar.Color := clRed; pnFechar.Font.Color := clWhite; end;
procedure TfrmConsultaFechamento.pnFecharMouseLeave(Sender: TObject);
begin pnFechar.Color := COR_DARK_BTN; pnFechar.Font.Color := clWhite; end;

end.
