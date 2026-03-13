unit untConsultaVendas;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids, Vcl.DBGrids,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls, Vcl.ExtCtrls;

type
  TfrmConsulta_Venda = class(TForm)
    pnFrontal: TPanel;
    pnSuperior: TPanel;
    btnEfetuarConsulta: TSpeedButton;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    cbIntervalo: TComboBox;
    dtInicial: TDateTimePicker;
    dtFinal: TDateTimePicker;
    pnInferior: TPanel;
    btnRelatorio: TBitBtn;
    btnExcel: TBitBtn;
    GroupBox1: TGroupBox;
    dbProdutos: TDBGrid;
    GroupBox2: TGroupBox;
    gridConsultaItens: TDBGrid;
    dsVenda: TDataSource;
    dsItensVenda: TDataSource;
    procedure FormShow(Sender: TObject);
    procedure cbIntervaloChange(Sender: TObject);
    procedure cbIntervaloKeyPress(Sender: TObject; var Key: Char);
    procedure dtFinalKeyPress(Sender: TObject; var Key: Char);
    procedure dtInicialKeyPress(Sender: TObject; var Key: Char);
    procedure consultaHorario;
    procedure btnRelatorioClick(Sender: TObject);
    procedure dsVendaDataChange(Sender: TObject; Field: TField);
    procedure btnEfetuarConsultaClick(Sender: TObject);
  private
    { Private declarations }
  public
    function VerificaCamposConsulta(): Boolean;
  end;

var
  frmConsulta_Venda: TfrmConsulta_Venda;

implementation

{$R *.dfm}

uses
  untCadastroProd, untCadastroCli, UntRelatorioVenda, untRelatorioProd,
  untVenda, dmconexao, untCadastroUsuario, untLogUser;

// -------------------------------------------------------
// SQL de Vendas com formatação R$ direto na query
// -------------------------------------------------------
function SQLVendasFormatado(filtroData: string): string;
begin
  Result :=
    'SELECT ' +
    '  CodVenda, ' +
    '  DescriProd, ' +
    '  DataVenda, ' +
    '  ''R$ '' + TRIM(REPLACE(CONVERT(VARCHAR(20), CAST(ValorTotal AS NUMERIC(15,2))), ''.'', '','')) AS ValorTotal, ' +
    '  ''R$ '' + TRIM(REPLACE(CONVERT(VARCHAR(20), CAST(ValorPago  AS NUMERIC(15,2))), ''.'', '','')) AS ValorPago ' +
    'FROM [lojanova].[dbo].[VENDAS] ' +
    'WHERE 1=1 ' + filtroData +
    ' ORDER BY DataVenda DESC';
end;

// -------------------------------------------------------
// SQL de Itens com formatação R$ direto na query
// -------------------------------------------------------
function SQLItensFormatado(codVenda: Integer): string;
begin
  Result :=
    'SELECT ' +
    '  CodItem, ' +
    '  CodVenda, ' +
    '  Descricao, ' +
    '  ''R$ '' + TRIM(REPLACE(CONVERT(VARCHAR(20), CAST(ValorProdUni AS NUMERIC(15,2))), ''.'', '','')) AS ValorProdUni, ' +
    '  Quantidade, ' +
    '  ''R$ '' + TRIM(REPLACE(CONVERT(VARCHAR(20), CAST(ValorTotal   AS NUMERIC(15,2))), ''.'', '','')) AS ValorTotal ' +
    'FROM itensVenda ' +
    'WHERE codVenda = ' + IntToStr(codVenda);
end;

procedure TfrmConsulta_Venda.btnEfetuarConsultaClick(Sender: TObject);
begin
  VerificaCamposConsulta;
  consultaHorario;
end;

procedure TfrmConsulta_Venda.btnRelatorioClick(Sender: TObject);
begin
  with dmconexoes do
  begin
    qrVendas.Close;
    qrVendas.SQL.Clear;
    qrVendas.SQL.Add(SQLVendasFormatado(''));
    qrVendas.Open;
    frmRelatorioVendas := TfrmRelatorioVendas.Create(Self);
    frmRelatorioVendas.rlr_RelatorioVendas.Preview;
  end;
end;

procedure TfrmConsulta_Venda.cbIntervaloChange(Sender: TObject);
begin
  if cbIntervalo.ItemIndex = 1 then
  begin
    dtInicial.Enabled := True;
    dtFinal.Enabled   := True;
    dtInicial.Date    := Date;
    dtFinal.Date      := Date;
    dtInicial.SetFocus;
  end
  else
  begin
    dtInicial.Enabled := False;
    dtFinal.Enabled   := False;
  end;
end;

procedure TfrmConsulta_Venda.cbIntervaloKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    if cbIntervalo.ItemIndex = 1 then
    begin
      dtInicial.Enabled := True;
      dtFinal.Enabled   := True;
      dtInicial.Date    := Date;
      dtFinal.Date      := Date;
      dtInicial.SetFocus;
    end
    else
    begin
      dtInicial.Enabled := False;
      dtFinal.Enabled   := False;
    end;
  end;
end;

procedure TfrmConsulta_Venda.consultaHorario;
var
  dInicial, dFinal, filtro: String;
begin
  filtro := '';

  with dmconexoes do
  begin
    if cbIntervalo.ItemIndex = 1 then
    begin
      try
        dInicial := FormatDateTime('dd-mm-yyyy', dtInicial.Date) + ' 00:00:00';
        dFinal   := FormatDateTime('dd-mm-yyyy', dtFinal.Date)   + ' 23:59:59';
        filtro   := ' AND (DATAVENDA BETWEEN ''' + dInicial + ''' AND ''' + dFinal + ''')';
      except
        on E: Exception do
        begin
          Application.MessageBox(PChar('Erro no Intervalo de Datas!' + #13 + E.Message),
            'Aviso - [Consulta de Vendas]', MB_OK + MB_ICONWARNING);
          dtInicial.SetFocus;
          Exit;
        end;
      end;
    end;

    qrVendas.Close;
    qrVendas.SQL.Clear;
    qrVendas.SQL.Add(SQLVendasFormatado(filtro));
    qrVendas.Open;
  end;
end;

procedure TfrmConsulta_Venda.dsVendaDataChange(Sender: TObject; Field: TField);
begin
  with dmconexoes do
  begin
    qrItensVenda.Close;
    qrItensVenda.SQL.Clear;
    qrItensVenda.SQL.Add(SQLItensFormatado(qrVendas.FieldByName('CodVenda').AsInteger));
    qrItensVenda.Open;
    gridConsultaItens.Refresh;
  end;
end;

procedure TfrmConsulta_Venda.dtFinalKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    btnEfetuarConsultaClick(Sender);
end;

procedure TfrmConsulta_Venda.dtInicialKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    dtFinal.SetFocus;
end;

procedure TfrmConsulta_Venda.FormShow(Sender: TObject);
begin
  with dmconexoes do
  begin
  dmconexoes.qrVendas.Close;
  dmconexoes.qrItensVenda.Close;
  dtInicial.Date := Date;
  dtFinal.Date   := Date;
  end;
end;

function TfrmConsulta_Venda.VerificaCamposConsulta: Boolean;
var
  dataInicial, dataFinal: String;
begin
  Result := False;
  if cbIntervalo.ItemIndex = 1 then
  begin
    try
      dataInicial := FormatDateTime('dd-mm-yyyy', dtInicial.Date) + ' 00:00:00';
      dataFinal   := FormatDateTime('dd-mm-yyyy', dtFinal.Date)   + ' 23:59:59';
      if dtFinal.Date < dtInicial.Date then
      begin
        Application.MessageBox('Data Final deve ser Maior que a Data Inicial!',
          'Aviso - [Consulta de Vendas]', MB_OK + MB_ICONWARNING);
        Exit;
      end;
    except
      on E: Exception do
      begin
        Application.MessageBox(PChar('Erro no Intervalo de Datas!' + #13 + E.Message),
          'Aviso - [Consulta de Vendas]', MB_OK + MB_ICONWARNING);
        dtInicial.SetFocus;
        Exit;
      end;
    end;
  end;
  Result := True;
end;

end.
