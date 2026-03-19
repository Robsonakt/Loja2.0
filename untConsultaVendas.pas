unit untConsultaVendas;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids, Vcl.DBGrids,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls, Vcl.ExtCtrls,ShellAPI,ComObj,Math;

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
    procedure btnExcelClick(Sender: TObject);
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

procedure TfrmConsulta_Venda.btnExcelClick(Sender: TObject);
var
  XL, WB, WS  : OleVariant;
  OutputPath   : String;
  Row, TotRow  : Integer;
  Col          : Integer;
  TotalGeral   : Currency;
  ValorStr     : String;
begin
  if not dmconexoes.qrVendas.Active or dmconexoes.qrVendas.IsEmpty then
  begin
    Application.MessageBox('Nenhum dado para exportar.',
      'Aviso - [Excel Vendas]', MB_OK + MB_ICONWARNING);
    Exit;
  end;

  OutputPath := ExtractFilePath(Application.ExeName) + 'RelatorioVendas.xlsx';

  try
    XL := CreateOleObject('Excel.Application');
  except
    Application.MessageBox('Microsoft Excel não encontrado.',
      'Aviso - [Excel Vendas]', MB_OK + MB_ICONERROR);
    Exit;
  end;

  try
    XL.Visible := False;
    WB := XL.Workbooks.Add;
    WS := WB.Worksheets[1];
    WS.Name := 'Vendas';

    // --- Título ---
    WS.Range['A1:D1'].Merge;
    WS.Cells[1, 1].Value               := 'Relatório de Vendas';
    WS.Cells[1, 1].Font.Bold           := True;
    WS.Cells[1, 1].Font.Size           := 14;
    WS.Cells[1, 1].Font.Color          := $007E3F1F;
    WS.Cells[1, 1].HorizontalAlignment := 3;
    WS.Rows[1].RowHeight               := 30;

    // --- Cabeçalho ---
    Row := 2;
    WS.Cells[Row, 1].Value := 'Cód. Venda';
    WS.Cells[Row, 2].Value := 'Produto';
    WS.Cells[Row, 3].Value := 'Data Venda';
    WS.Cells[Row, 4].Value := 'Valor Total';

    for Col := 1 to 4 do
    begin
      WS.Cells[Row, Col].Font.Bold           := True;
      WS.Cells[Row, Col].Font.Color          := $00FFFFFF;
      WS.Cells[Row, Col].Interior.Color      := $007E3F1F;
      WS.Cells[Row, Col].HorizontalAlignment := 3;
    end;
    WS.Rows[Row].RowHeight := 20;

    // --- Dados direto do qrVendas ---
    Row := 3;
    dmconexoes.qrVendas.First;
    while not dmconexoes.qrVendas.Eof do
    begin
      WS.Cells[Row, 1].Value               := dmconexoes.qrVendas.FieldByName('CodVenda').AsString;
      WS.Cells[Row, 1].HorizontalAlignment := 3;

      WS.Cells[Row, 2].Value               := dmconexoes.qrVendas.FieldByName('DescriProd').AsString;

      WS.Cells[Row, 3].Value               := dmconexoes.qrVendas.FieldByName('DataVenda').AsString;
      WS.Cells[Row, 3].HorizontalAlignment := 3;

      WS.Cells[Row, 4].Value               := dmconexoes.qrVendas.FieldByName('ValorTotal').AsString;
      WS.Cells[Row, 4].HorizontalAlignment := 4;

      Inc(Row);
      dmconexoes.qrVendas.Next;
    end;

    // --- Calcula total percorrendo o dataset novamente ---
    TotalGeral := 0;
    dmconexoes.qrVendas.First;
    while not dmconexoes.qrVendas.Eof do
    begin
      ValorStr := Trim(dmconexoes.qrVendas.FieldByName('ValorTotal').AsString);
      ValorStr := StringReplace(ValorStr, 'R$', '', [rfReplaceAll]);
      ValorStr := StringReplace(ValorStr, '.', '', [rfReplaceAll]);
      ValorStr := Trim(ValorStr);
      // Não troca vírgula — usa diretamente com separador pt-BR
      TotalGeral := TotalGeral + StrToCurrDef(ValorStr, 0);
      dmconexoes.qrVendas.Next;
    end;

    // --- Linha de Totais ---
    TotRow := Row;

    WS.Cells[TotRow, 1].Value               := 'TOTAIS';
    WS.Cells[TotRow, 1].Font.Bold           := True;
    WS.Cells[TotRow, 1].Interior.Color      := $00D2E1F2;
    WS.Cells[TotRow, 1].HorizontalAlignment := 3;

    WS.Cells[TotRow, 2].Value               := 'Qtd. de Vendas: ' + IntToStr(TotRow - 3);
    WS.Cells[TotRow, 2].Font.Bold           := True;
    WS.Cells[TotRow, 2].Interior.Color      := $00D2E1F2;

    WS.Cells[TotRow, 3].Interior.Color      := $00D2E1F2;

    WS.Cells[TotRow, 4].Value               := 'R$ ' + FormatFloat('#,##0.00', TotalGeral);
    WS.Cells[TotRow, 4].Font.Bold           := True;
    WS.Cells[TotRow, 4].Interior.Color      := $00D2E1F2;
    WS.Cells[TotRow, 4].HorizontalAlignment := 4;

    // --- Largura das colunas ---
    WS.Columns[1].ColumnWidth := 12;
    WS.Columns[2].ColumnWidth := 40;
    WS.Columns[3].ColumnWidth := 14;
    WS.Columns[4].ColumnWidth := 18;

    // --- Salva ---
    WB.SaveAs(OutputPath);
    WB.Close(False);
    XL.Quit;
    XL := Unassigned;

    if Application.MessageBox('Excel gerado com sucesso! Deseja abrir o arquivo?',
         'Aviso - [Excel Vendas]', MB_YESNO + MB_ICONINFORMATION) = IDYES then
      ShellExecute(0, 'open', PChar(OutputPath), nil, nil, SW_SHOWNORMAL);

  except
    on E: Exception do
    begin
      try WB.Close(False); except end;
      try XL.Quit;         except end;
      XL := Unassigned;
      Application.MessageBox(PChar('Erro ao gerar Excel:' + #13 + E.Message),
        'Erro - [Excel Vendas]', MB_OK + MB_ICONERROR);
    end;
  end;
end;

procedure TfrmConsulta_Venda.btnRelatorioClick(Sender: TObject);
var
  TotalValor: Currency;
  QtdVendas: Integer;
  ValorStr: String;
begin
  if not dmconexoes.qrVendas.Active then
  begin
    ShowMessage('Realize a consulta antes de gerar o relatório.');
    Exit;
  end;

  // Calcula totais — igual ao que já faz no Excel
  TotalValor := 0;
  QtdVendas  := 0;
  dmconexoes.qrVendas.First;
  while not dmconexoes.qrVendas.Eof do
  begin
    ValorStr := Trim(dmconexoes.qrVendas.FieldByName('ValorTotal').AsString);
    ValorStr := StringReplace(ValorStr, 'R$', '', [rfReplaceAll]);
    ValorStr := StringReplace(ValorStr, '.', '', [rfReplaceAll]);
    ValorStr := Trim(ValorStr);
    TotalValor := TotalValor + StrToCurrDef(ValorStr, 0);
    Inc(QtdVendas);
    dmconexoes.qrVendas.Next;
  end;
  dmconexoes.qrVendas.First;

  frmRelatorioVendas := TfrmRelatorioVendas.Create(Self);
  frmRelatorioVendas.SetTotais(QtdVendas, TotalValor);
  frmRelatorioVendas.rlr_RelatorioVendas.Preview;
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
        dInicial := FormatDateTime('yyyy-mm-dd', dtInicial.Date) + ' 00:00:00';
        dFinal   := FormatDateTime('yyyy-mm-dd', dtFinal.Date)   + ' 23:59:59';
        filtro   := ' AND (DATAVENDA BETWEEN ''' + dInicial + ''' AND ''' + dFinal + ''')';
      except


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
