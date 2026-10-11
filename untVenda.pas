unit untVenda;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Data.DB, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  ACBrBase, ACBrPosPrinter, ACBrUtil.Strings, ACBrUtil.Base,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  Vcl.Buttons, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls, Vcl.DBCtrls,
  Vcl.Grids, Vcl.DBGrids, Vcl.ComCtrls;

type
  TfrmCaixaVendas = class(TForm)
    pnlTopo: TPanel;
    lblTitulo: TLabel;
    pnlRodape: TPanel;
    lblStatus: TLabel;
    lblRodape: TLabel;
    pnlCliente: TPanel;
    grpIdentificacao: TGroupBox;
    Label1: TLabel;
    lbNomeCli: TLabel;
    Label2: TLabel;
    lbDataVenda: TLabel;
    EdtNameCliente: TEdit;
    edtCodVenda: TEdit;
    edtDataVenda: TMaskEdit;
    grpItens: TGroupBox;
    DBGrid1: TDBGrid;
    grpProduto: TGroupBox;
    edtprod: TLabel;
    lbNomeProd: TLabel;
    lbValorUni: TLabel;
    lbquant: TLabel;
    lbValTotal: TLabel;
    lbQuantRest: TLabel;
    edtCodProd: TEdit;
    edtValorProd: TDBEdit;
    edtQuant: TEdit;
    edtValorTotal: TEdit;
    edtQuantRest: TDBEdit;
    pnlDireito: TPanel;
    pnlTotal: TPanel;
    lbTotalVend: TLabel;
    lbvalorDinheiro: TLabel;
    grpObs: TGroupBox;
    Memo1: TMemo;
    grpAcoes: TGroupBox;
    PnVenda: TPanel;
    Pnfiado: TPanel;
    PnImpressora: TPanel;
    PnConfirmaItem: TPanel;
    DSItensVenda: TDataSource;
    fdProduto: TFDMemTable;
    fdProdutoCodProd: TIntegerField;
    fdProdutoDescricao: TStringField;
    fdProdutoQuantidade: TIntegerField;
    fdProdutoValorUni: TCurrencyField;
    fdProdutoValorTotal: TCurrencyField;
    fdProdutoCodVenda: TIntegerField;
    fdProdutoCodCli: TStringField;
    ACBrPosPrinter1: TACBrPosPrinter;

    procedure PnVendaClick(Sender: TObject);
    procedure PnVendaMouseEnter(Sender: TObject);
    procedure PnVendaMouseLeave(Sender: TObject);
    procedure PnfiadoClick(Sender: TObject);
    procedure PnfiadoMouseEnter(Sender: TObject);
    procedure PnfiadoMouseLeave(Sender: TObject);
    procedure PnImpressoraClick(Sender: TObject);
    procedure PnImpressoraMouseEnter(Sender: TObject);
    procedure PnImpressoraMouseLeave(Sender: TObject);
    procedure PnConfirmaItemClick(Sender: TObject);
    procedure PnConfirmaItemMouseEnter(Sender: TObject);
    procedure PnConfirmaItemMouseLeave(Sender: TObject);
    procedure EdtNameClienteKeyPress(Sender: TObject; var Key: Char);
    procedure EdtNameClienteKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EdtNameClienteChange(Sender: TObject);
    procedure EdtNameClienteExit(Sender: TObject);
    procedure edtCodProdKeyPress(Sender: TObject; var Key: Char);
    procedure edtCodProdKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edtQuantKeyPress(Sender: TObject; var Key: Char);
    procedure edtValorTotalKeyPress(Sender: TObject; var Key: Char);
    procedure edtDataVendaKeyPress(Sender: TObject; var Key: Char);
    procedure DBGrid1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure DSItensVendaDataChange(Sender: TObject; Field: TField);

  private
    FProdQtdeEstoque: Integer;
    FValorTotalEnterCount: Integer;
    procedure AddMemo(ctexto: string);
    procedure VerificaCliente;
    procedure VerificaProduto;
    procedure InsereProd;
    procedure CarregarClientePadrao;
    procedure PrepararNovaVenda;
    procedure LimparTela;
    procedure AtualizarCodVenda;
    procedure RecalcularTotal;
    procedure MontarCupom;
    function QtdNoCarrinho(ACodProd: Integer): Integer;
    function ValidarFinalizacao: Boolean;
    function DataVendaInformada: TDateTime;
    function GravarVenda: Integer;
    procedure GravarFiado(ACodCli: Integer);
    function ImprimirComprovante: Boolean;
  public
    // True depois que uma venda (normal ou fiado) foi gravada nesta tela
    VendaFinalizada: Boolean;
  end;

var
  frmCaixaVendas: TfrmCaixaVendas;
  quantidade: Integer;
  totalvalor: Currency;
  cfg_Empresa: string;
  cfg_Endereco: string;
  cfg_Telefone: string;

implementation

{$R *.dfm}

uses dmConexao, untInicial, untCadastroProd, untLocalizaProd, untLocalizaCli, uFiscalStorage, uEmpresaConfig,
  Data.Win.ADODB;

// ============================================================
// RECALCULA TOTAL A PARTIR DO FDPRODUTO
// ============================================================

procedure TfrmCaixaVendas.RecalcularTotal;
begin
  totalvalor := 0;
  if fdProduto.Active then
  begin
    fdProduto.First;
    while not fdProduto.Eof do
    begin
      totalvalor := totalvalor + fdProduto.FieldByName('ValorTotal').AsCurrency;
      fdProduto.Next;
    end;
  end;
  lbvalorDinheiro.Caption := FormatFloat('"R$" #,##0.00', totalvalor);
  // So permite finalizar quando existe item na venda
  PnVenda.Enabled := fdProduto.Active and (not fdProduto.IsEmpty);
  Pnfiado.Enabled := PnVenda.Enabled;
end;

function TfrmCaixaVendas.QtdNoCarrinho(ACodProd: Integer): Integer;
var
  BM: TBookmark;
begin
  Result := 0;
  if not fdProduto.Active then
    Exit;
  BM := fdProduto.GetBookmark;
  try
    fdProduto.First;
    while not fdProduto.Eof do
    begin
      if fdProduto.FieldByName('CodProd').AsInteger = ACodProd then
        Inc(Result, fdProduto.FieldByName('Quantidade').AsInteger);
      fdProduto.Next;
    end;
    if fdProduto.BookmarkValid(BM) then
      fdProduto.GotoBookmark(BM);
  finally
    fdProduto.FreeBookmark(BM);
  end;
end;

// ============================================================
// AUXILIARES PRIVADAS
// ============================================================

procedure TfrmCaixaVendas.AddMemo(ctexto: string);
begin
  Memo1.Lines.Add(ctexto);
end;

procedure TfrmCaixaVendas.PrepararNovaVenda;
begin
  edtDataVenda.Text := FormatDateTime('dd/mm/yyyy', Date);
  CarregarClientePadrao;
end;

procedure TfrmCaixaVendas.CarregarClientePadrao;
begin
  with dmConexoes do
  begin
    GarantirEstruturaVendas;
    qrCliente.Close;
    qrCliente.SQL.Clear;

    qrCliente.SQL.Add('SELECT TOP 1 * FROM [LojaNova].[dbo].[Cliente] ORDER BY ISNULL(cliente_padrao, 0) DESC, codcli');
    qrCliente.Open;

    if qrCliente.IsEmpty then
    begin
      EdtNameCliente.Clear;
      lbNomeCli.Caption := '';
      Exit;
    end;

    EdtNameCliente.Text := qrCliente.FieldByName('codcli').AsString;
    lbNomeCli.Caption := qrCliente.FieldByName('nome').AsString;
  end;
end;

procedure TfrmCaixaVendas.LimparTela;
begin
  EdtNameCliente.Clear;
  edtCodProd.Clear;
  edtValorProd.Clear;
  edtQuant.Clear;
  edtValorTotal.Clear;
  edtDataVenda.Clear;
  FValorTotalEnterCount := 0;
  lbvalorDinheiro.Caption := 'R$ 0,00';
  lbNomeCli.Caption       := '';
  lbNomeProd.Caption      := '.';
  FProdQtdeEstoque        := 0;
  totalvalor := 0;
  fdProduto.Close;
  fdProduto.Open;
  RecalcularTotal;
  AtualizarCodVenda;
  PrepararNovaVenda;
  edtCodProd.SetFocus;
end;

procedure TfrmCaixaVendas.AtualizarCodVenda;
begin
  with dmConexoes do
  begin
    qrVendas.Close;
    qrVendas.SQL.Clear;
    qrVendas.SQL.Add('SELECT MAX(CodVenda) AS ULTIMOCODIGO FROM [LojaNova].[dbo].[VENDAS]');
    qrVendas.Open;
    edtCodVenda.Text := IntToStr(qrVendas.FieldByName('ULTIMOCODIGO').AsInteger + 1);
    qrVendas.Close;
  end;
end;

// ============================================================
// VERIFICA CLIENTE
// ============================================================

procedure TfrmCaixaVendas.VerificaCliente;
begin
  with dmConexoes do
  begin
    qrCliente.Close;
    qrCliente.SQL.Clear;
    qrCliente.SQL.Add('SELECT * FROM [LojaNova].[dbo].[Cliente] WHERE codcli = :pcod');
    qrCliente.Parameters.ParamByName('pcod').Value := StrToIntDef(Trim(EdtNameCliente.Text), 0);
    qrCliente.Open;

    if qrCliente.IsEmpty then
    begin
      Application.MessageBox('Cliente nao encontrado', 'Atencao', MB_OK + MB_ICONERROR);
      EdtNameCliente.SetFocus;
    end
    else
    begin
      lbNomeCli.Caption := qrCliente.FieldByName('nome').AsString;
      if Trim(StringReplace(edtDataVenda.Text, '/', '', [rfReplaceAll])) = '' then
        edtDataVenda.Text := FormatDateTime('dd/mm/yyyy', Date);
      edtCodProd.SetFocus;
    end;
  end;
end;

// ============================================================
// VERIFICA PRODUTO
// ============================================================

procedure TfrmCaixaVendas.VerificaProduto;
var
  CodigoDigitado: string;
begin
  CodigoDigitado := Trim(edtCodProd.Text);

  with dmConexoes do
  begin
    qrEstoque.Close;
    qrEstoque.SQL.Clear;
    qrEstoque.SQL.Add('SELECT * FROM PRODUTOS');
    qrEstoque.SQL.Add('WHERE CODIGO = :pcod OR CodBarras = :pcodbarras');
    qrEstoque.Parameters.ParamByName('pcod').Value := StrToIntDef(CodigoDigitado, 0);
    qrEstoque.Parameters.ParamByName('pcodbarras').Value := CodigoDigitado;
    qrEstoque.Open;

    if qrEstoque.IsEmpty then
    begin
      Application.MessageBox('Produto nao encontrado', 'Atencao', MB_OK + MB_ICONERROR);
      edtCodProd.SetFocus;
    end
    else
    begin
      edtCodProd.Text    := qrEstoque.FieldByName('codigo').AsString;
      lbNomeProd.Caption := qrEstoque.FieldByName('descricao').AsString;
      FProdQtdeEstoque   := qrEstoque.FieldByName('quantidade').AsInteger;
      FValorTotalEnterCount := 0;
      edtQuant.SetFocus;
    end;
  end;
end;

// ============================================================
// INSERE PRODUTO NA GRID (FDMemTable)
// ============================================================

procedure TfrmCaixaVendas.InsereProd;
var
  Qtd: Integer;
  ValorUni: Currency;
begin
  Qtd      := StrToIntDef(edtQuant.Text, 0);
  ValorUni := dmConexoes.qrEstoque.FieldByName('valorvenda').AsCurrency;

  fdProduto.Active := True;
  fdProduto.Insert;
  fdProduto.FieldByName('Descricao').AsString    := dmConexoes.qrEstoque.FieldByName('descricao').AsString;
  fdProduto.FieldByName('CodVenda').AsInteger    := StrToIntDef(edtCodVenda.Text, 0);
  fdProduto.FieldByName('CodProd').AsInteger     := dmConexoes.qrEstoque.FieldByName('codigo').AsInteger;
  fdProduto.FieldByName('ValorUni').AsCurrency   := ValorUni;
  fdProduto.FieldByName('Quantidade').AsInteger  := Qtd;
  fdProduto.FieldByName('ValorTotal').AsCurrency := ValorUni * Qtd;
  fdProduto.Post;

  // Recalcula total do zero para garantir precisao
  RecalcularTotal;
  MontarCupom;
end;

procedure TfrmCaixaVendas.MontarCupom;
var
  i: Integer;
begin
  Memo1.Lines.Clear;
  AddMemo('</zera>');
  AddMemo(PadCenter('<e><in>' + cfg_Empresa + '</in></e>', 40));
  AddMemo(PadCenter('<in>Nao tem valor Fiscal</in>', 48));
  AddMemo(PadCenter('<in>' + cfg_Endereco + '</in>', 48));
  AddMemo(PadCenter('<in>' + cfg_Telefone + '</in>', 48));
  AddMemo('</linha_simples>');
  AddMemo('Cod.Vend: ' + edtCodVenda.Text);
  AddMemo('</linha_dupla>');
  AddMemo('<n>COD.PROD      DESCRICAO');
  AddMemo('QTD x VL.UNI');
  AddMemo('</linha_dupla>');

  fdProduto.First;
  while not fdProduto.Eof do
  begin
    AddMemo('<n>' + IntToStrZero(fdProdutoCodProd.Value, 6) + ' | ' + fdProdutoDescricao.AsString);
    AddMemo(fdProdutoQuantidade.AsString + 'UN  x  ' + FormatFloat('#,##0.00', fdProdutoValorUni.AsCurrency));
    AddMemo('</linha_simples>');
    fdProduto.Next;
  end;

  AddMemo('Cliente: ' + lbNomeCli.Caption);
  AddMemo('Total: ' + lbvalorDinheiro.Caption);
  for i := 1 to 7 do
    AddMemo('');
end;

// ============================================================
// FORMSHOW
// ============================================================

procedure TfrmCaixaVendas.FormShow(Sender: TObject);
begin
  // Carrega configuracoes do INI via dmConexoes
  dmConexoes.CarregarConfiguracoes;
  dmConexoes.GarantirEstruturaVendas;

  cfg_Empresa  := dmConexoes.NomeEmpresa;
  cfg_Endereco := dmConexoes.EnderecoEmpresa;
  cfg_Telefone := dmConexoes.TelefoneEmpresa;

  edtValorProd.Clear;
  edtQuantRest.Clear;
  FProdQtdeEstoque := 0;
  FValorTotalEnterCount := 0;
  fdProduto.Open;
  AtualizarCodVenda;
  // Mantem itens ja carregados (ex.: orcamento convertido) e recalcula o total
  RecalcularTotal;
  if not fdProduto.IsEmpty then
    MontarCupom;
  PrepararNovaVenda;
  edtCodProd.SetFocus;
end;

// ============================================================
// EVENTOS DOS CAMPOS - CLIENTE
// ============================================================

procedure TfrmCaixaVendas.EdtNameClienteKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    LocalizaCodigoCli := dmConexoes.qrCliente.FieldByName('codcli').AsString;
    VerificaCliente;
  end;
end;

procedure TfrmCaixaVendas.EdtNameClienteKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F2 then
  begin
    Application.CreateForm(TfrmLocalizaCli, frmLocalizaCli);
    frmLocalizaCli.ShowModal;
    frmLocalizaCli.Free;
    EdtNameCliente.Text := LocalizaCodigoCli;
    EdtNameClienteKeyPress(Self, keyEnter);
  end;
end;

procedure TfrmCaixaVendas.EdtNameClienteChange(Sender: TObject);
begin
  edtValorProd.Clear;
  edtQuantRest.Clear;
end;

procedure TfrmCaixaVendas.EdtNameClienteExit(Sender: TObject);
begin
  if Trim(EdtNameCliente.Text) <> '' then
    VerificaCliente;
end;

// ============================================================
// EVENTOS DOS CAMPOS - PRODUTO
// ============================================================

procedure TfrmCaixaVendas.edtCodProdKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F2 then
  begin
    Application.CreateForm(TfrmLocalizaProd, frmLocalizaProd);
    frmLocalizaProd.ShowModal;
    frmLocalizaProd.Free;
    edtCodProd.Text := LocalizaCodigoProd;
    edtCodProdKeyPress(Self, keyEnter);
  end;
end;

procedure TfrmCaixaVendas.edtCodProdKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #13) and (edtCodProd.Text <> '') then
  begin
    Key := #0;
    VerificaProduto;
  end;
end;

procedure TfrmCaixaVendas.edtQuantKeyPress(Sender: TObject; var Key: Char);
var
  valorUni: Currency;
begin
  if Key = #13 then
  begin
    valorUni := dmConexoes.qrEstoque.FieldByName('valorvenda').AsCurrency;
    edtValorProd.Text  := FormatFloat('"R$" #,##0.00', valorUni);
    edtValorTotal.Text := FormatFloat('#,##0.00', valorUni * StrToIntDef(edtQuant.Text, 0));
    FValorTotalEnterCount := 0;
    edtValorTotal.SetFocus;
  end;
end;

procedure TfrmCaixaVendas.edtValorTotalKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    Inc(FValorTotalEnterCount);
    PnConfirmaItem.Color      := clGreen;
    PnConfirmaItem.Font.Color := clWhite;

    if FValorTotalEnterCount >= 2 then
    begin
      FValorTotalEnterCount := 0;
      PnConfirmaItemClick(Sender);
    end;
  end;
end;

procedure TfrmCaixaVendas.edtDataVendaKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #32 then
  begin
    edtDataVenda.Text := FormatDateTime('dd/mm/yyyy', Date);
    edtCodProd.SetFocus;
  end;
end;

// ============================================================
// GRID - DELETE item com tecla DEL e recalcula total
// ============================================================

procedure TfrmCaixaVendas.DBGrid1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_DELETE) and fdProduto.Active and (not fdProduto.IsEmpty) then
  begin
    if Application.MessageBox('Deseja deletar o produto?', 'Atencao',
      MB_ICONQUESTION + MB_YESNO) = IDYES then
    begin
      fdProduto.Delete;
      RecalcularTotal;
      MontarCupom;
    end;
  end;
end;

procedure TfrmCaixaVendas.DSItensVendaDataChange(Sender: TObject; Field: TField);
begin
  // nada
end;

// ============================================================
// PAINEL CONFIRMA ITEM
// ============================================================

procedure TfrmCaixaVendas.PnConfirmaItemClick(Sender: TObject);
var
  Qtd, CodProd, Saldo: Integer;
begin
  // Validacao: quantidade nao informada ou igual a zero
  Qtd := StrToIntDef(Trim(edtQuant.Text), 0);
  if Qtd <= 0 then
  begin
    Application.MessageBox(
      'Por favor, informe a quantidade antes de confirmar o item.',
      'Quantidade Invalida', MB_OK + MB_ICONWARNING);
    edtQuant.SetFocus;
    Exit;
  end;

  // Se o codigo foi alterado sem Enter, o produto carregado seria outro:
  // consulta de novo para nao lancar (e baixar estoque) do produto errado.
  with dmConexoes do
    if (not qrEstoque.Active) or qrEstoque.IsEmpty or
       (qrEstoque.FindField('codigo') = nil) or
       (qrEstoque.FieldByName('codigo').AsString <> Trim(edtCodProd.Text)) then
    begin
      if Trim(edtCodProd.Text) = '' then
      begin
        Application.MessageBox('Informe o produto.', 'Atencao', MB_OK + MB_ICONWARNING);
        edtCodProd.SetFocus;
        Exit;
      end;
      VerificaProduto;
      if (not qrEstoque.Active) or qrEstoque.IsEmpty then
        Exit;
    end;

  CodProd := dmConexoes.qrEstoque.FieldByName('codigo').AsInteger;
  Saldo   := dmConexoes.qrEstoque.FieldByName('quantidade').AsInteger
             - QtdNoCarrinho(CodProd) - Qtd;

  if Saldo <= 0 then
  begin
    if Application.MessageBox(
      'Voce ficara sem estoque deste produto, Deseja continuar a venda?',
      'Atencao', MB_YESNO + MB_ICONINFORMATION) = IDYES then
      InsereProd
    else
      Application.MessageBox('Venda de produto Cancelada', 'Atencao', MB_OK + MB_ICONINFORMATION);
  end
  else
    InsereProd;

  edtCodProd.SetFocus;
  edtCodProd.Clear;
  edtQuant.Clear;
  edtValorProd.Clear;
  edtValorTotal.Clear;
  edtQuantRest.Clear;
end;

// ============================================================
// PAINEL VENDA - Finaliza venda normal
// ============================================================

function TfrmCaixaVendas.ValidarFinalizacao: Boolean;
begin
  Result := False;
  RecalcularTotal;
  if (not fdProduto.Active) or fdProduto.IsEmpty or (totalvalor <= 0) then
  begin
    Application.MessageBox('Adicione ao menos um produto antes de finalizar a venda.',
      'Atencao', MB_OK + MB_ICONWARNING);
    Exit;
  end;
  if not dmConexoes.CaixaAberto then
  begin
    Application.MessageBox('O caixa esta fechado. Abra o caixa antes de finalizar a venda.',
      'Caixa', MB_OK + MB_ICONWARNING);
    Exit;
  end;
  Result := True;
end;

function TfrmCaixaVendas.DataVendaInformada: TDateTime;
begin
  if not TryStrToDate(Trim(edtDataVenda.Text), Result) then
    Result := Date;
end;

// Baixa o estoque de um item. Gera erro se o produto nao existir,
// para que a venda inteira seja desfeita (nada fica pela metade).
procedure BaixarEstoque(Q: TADOQuery; ACodProd, AQtd: Integer; const ADescricao: string);
begin
  Q.Close;
  Q.SQL.Text :=
    'UPDATE PRODUTOS SET quantidade = ISNULL(quantidade, 0) - :Qtd WHERE codigo = :Codigo';
  Q.Parameters.ParamByName('Qtd').Value    := AQtd;
  Q.Parameters.ParamByName('Codigo').Value := ACodProd;
  if Q.ExecSQL = 0 then
    raise Exception.CreateFmt('Produto %d (%s) nao encontrado no cadastro. Estoque nao baixado.',
      [ACodProd, ADescricao]);
end;

// Grava venda + itens + baixa de estoque numa unica transacao.
// Retorna o codigo REAL da venda gravada no banco.
function TfrmCaixaVendas.GravarVenda: Integer;
var
  Q: TADOQuery;
  IdCaixa, ProxItem: Integer;
  DataV: TDateTime;
  Descr: string;

  procedure SetPar(const ANome: string; const AValor: Variant; ATipo: TFieldType);
  begin
    Q.Parameters.ParamByName(ANome + '1').DataType := ATipo;
    Q.Parameters.ParamByName(ANome + '1').Value    := AValor;
    Q.Parameters.ParamByName(ANome + '2').DataType := ATipo;
    Q.Parameters.ParamByName(ANome + '2').Value    := AValor;
  end;

begin
  Result := 0;
  dmConexoes.GarantirEstruturaVendas;
  IdCaixa := dmConexoes.IdCaixaAtual;
  DataV   := DataVendaInformada;
  RecalcularTotal;
  fdProduto.First;
  Descr := fdProduto.FieldByName('Descricao').AsString;

  Q := TADOQuery.Create(nil);
  try
    Q.Connection := dmConexoes.conRobson;
    dmConexoes.conRobson.BeginTrans;
    try
      // 1. Venda - usa o codigo gerado pelo banco (IDENTITY) quando existir
      Q.SQL.Text :=
        'SET NOCOUNT ON; ' +
        'DECLARE @Cod INT; ' +
        'IF COLUMNPROPERTY(OBJECT_ID(''dbo.VENDAS''), ''CodVenda'', ''IsIdentity'') = 1 ' +
        'BEGIN ' +
        '  INSERT INTO dbo.VENDAS (ValorTotal, ValorPago, CodCli, DataVenda, descriprod, IdCaixa) ' +
        '  VALUES (:Total1, :Pago1, :Cli1, :Data1, :Desc1, :Caixa1); ' +
        '  SET @Cod = CAST(SCOPE_IDENTITY() AS INT); ' +
        'END ' +
        'ELSE ' +
        'BEGIN ' +
        '  SELECT @Cod = ISNULL(MAX(CodVenda), 0) + 1 FROM dbo.VENDAS WITH (UPDLOCK, HOLDLOCK); ' +
        '  INSERT INTO dbo.VENDAS (CodVenda, ValorTotal, ValorPago, CodCli, DataVenda, descriprod, IdCaixa) ' +
        '  VALUES (@Cod, :Total2, :Pago2, :Cli2, :Data2, :Desc2, :Caixa2); ' +
        'END; ' +
        'SELECT @Cod AS CodVenda;';
      SetPar('Total', totalvalor, ftBCD);
      SetPar('Pago',  totalvalor, ftBCD);
      SetPar('Cli',   Trim(EdtNameCliente.Text), ftString);
      SetPar('Data',  DataV, ftDateTime);
      SetPar('Desc',  Descr, ftString);
      if IdCaixa > 0 then
        SetPar('Caixa', IdCaixa, ftInteger)
      else
        SetPar('Caixa', Null, ftInteger);
      Q.Open;
      Result := Q.FieldByName('CodVenda').AsInteger;
      Q.Close;
      if Result <= 0 then
        raise Exception.Create('Nao foi possivel obter o codigo da venda.');

      // 2. Proximo codigo de item (bloqueado ate o fim da transacao)
      Q.SQL.Text := 'SELECT ISNULL(MAX(CodItem), 0) + 1 FROM dbo.ItensVenda WITH (UPDLOCK, HOLDLOCK)';
      Q.Open;
      ProxItem := Q.Fields[0].AsInteger;
      Q.Close;

      // 3. Itens + baixa de estoque de CADA item
      fdProduto.First;
      while not fdProduto.Eof do
      begin
        Q.SQL.Text :=
          'INSERT INTO dbo.ItensVenda (CodItem, CodVenda, CodProd, Descricao, ValorTotal, ' +
          'Quantidade, ValorProdUni, DataVenda) VALUES (:CodItem, :CodVenda, :CodProd, ' +
          ':Descricao, :ValorTotal, :Quantidade, :ValorProdUni, :DataVenda)';
        Q.Parameters.ParamByName('CodItem').Value      := ProxItem;
        Q.Parameters.ParamByName('CodVenda').Value     := Result;
        Q.Parameters.ParamByName('CodProd').Value      := fdProduto.FieldByName('CodProd').AsInteger;
        Q.Parameters.ParamByName('Descricao').Value    := fdProduto.FieldByName('Descricao').AsString;
        Q.Parameters.ParamByName('ValorTotal').DataType   := ftBCD;
        Q.Parameters.ParamByName('ValorTotal').Value      := fdProduto.FieldByName('ValorTotal').AsCurrency;
        Q.Parameters.ParamByName('Quantidade').Value   := fdProduto.FieldByName('Quantidade').AsInteger;
        Q.Parameters.ParamByName('ValorProdUni').DataType := ftBCD;
        Q.Parameters.ParamByName('ValorProdUni').Value    := fdProduto.FieldByName('ValorUni').AsCurrency;
        Q.Parameters.ParamByName('DataVenda').DataType := ftDateTime;
        Q.Parameters.ParamByName('DataVenda').Value    := DataV;
        Q.ExecSQL;

        BaixarEstoque(Q, fdProduto.FieldByName('CodProd').AsInteger,
          fdProduto.FieldByName('Quantidade').AsInteger,
          fdProduto.FieldByName('Descricao').AsString);

        Inc(ProxItem);
        fdProduto.Next;
      end;

      dmConexoes.conRobson.CommitTrans;
    except
      if dmConexoes.conRobson.InTransaction then
        dmConexoes.conRobson.RollbackTrans;
      raise;
    end;
  finally
    Q.Free;
  end;
end;

function TfrmCaixaVendas.ImprimirComprovante: Boolean;
begin
  Result := False;
  try
    // Garante que a porta esta fechada antes de abrir
    if ACBrPosPrinter1.Ativo then
      ACBrPosPrinter1.Desativar;

    // Porta e Modelo vem do config.ini via dmConexoes
    ACBrPosPrinter1.Porta  := dmConexoes.PortaImpressora;
    ACBrPosPrinter1.Modelo := TACBrPosPrinterModelo(dmConexoes.ModeloImpressora);
    ACBrPosPrinter1.Ativar;
    ACBrPosPrinter1.Buffer.Text := Memo1.Text;
    ACBrPosPrinter1.Imprimir;
    ACBrPosPrinter1.CortarPapel;
    ACBrPosPrinter1.Desativar; // libera a porta apos imprimir
    Result := True;
  except
    on E: Exception do
    begin
      try ACBrPosPrinter1.Desativar; except end;
      Application.MessageBox(
        PChar('Impressora nao encontrada ou sem conexao.' + #13#10 + 'Erro: ' + E.Message),
        'Aviso - Impressora', MB_OK + MB_ICONWARNING);
    end;
  end;
end;

procedure TfrmCaixaVendas.PnVendaClick(Sender: TObject);
var
  valorPago: Currency;
  troco: Currency;
  sValorPago: string;
  CodVenda: Integer;
  gerarNFCe: Boolean;
  gerarNFe: Boolean;
  idFiscal: Integer;
  ItensSemCodigo: Integer;
begin
  if not ValidarFinalizacao then
    Exit;

  gerarNFCe := False;
  gerarNFe := False;
  if Application.MessageBox('Precisa de ajuda com o troco?', 'Troco',
    MB_YESNO + MB_ICONQUESTION) = IDYES then
  begin
    sValorPago := '';
    if not InputQuery('Valor Recebido', 'Digite o valor recebido pelo cliente:', sValorPago) then
      Exit;
    if not TryStrParaMoeda(sValorPago, valorPago) then
    begin
      Application.MessageBox('Valor invalido. Exemplo: 50,00', 'Atencao', MB_OK + MB_ICONWARNING);
      Exit;
    end;
    if valorPago < totalvalor then
    begin
      Application.MessageBox('Valor insuficiente para cobrir a venda!', 'Atencao',
        MB_OK + MB_ICONWARNING);
      Exit;
    end;
    troco := valorPago - totalvalor;
    Application.MessageBox(
      PChar('Troco: R$ ' + FormatFloat('#,##0.00', troco)),
      'Troco', MB_OK + MB_ICONINFORMATION);
  end;

  with dmConexoes do
  begin
    TEmpresaConfig.GarantirEstrutura(conRobson);
    qrComando.Close;
    qrComando.SQL.Text := 'SELECT TOP 1 ISNULL(EMITE_NFCE_VENDA, 0) AS EMITE_NFCE_VENDA, ISNULL(EMITE_NFE_VENDA, 0) AS EMITE_NFE_VENDA FROM EMPRESA ORDER BY ISNULL(PRINCIPAL, 0) DESC, ID_EMPRESA';
    qrComando.Open;
    if not qrComando.IsEmpty then
    begin
      gerarNFCe := qrComando.FieldByName('EMITE_NFCE_VENDA').AsBoolean;
      gerarNFe := (not gerarNFCe) and qrComando.FieldByName('EMITE_NFE_VENDA').AsBoolean;
    end;
    qrComando.Close;
  end;

  // 1. Grava venda, itens e estoque (tudo ou nada)
  try
    CodVenda := GravarVenda;
  except
    on E: Exception do
    begin
      Application.MessageBox(
        PChar('Nao foi possivel gravar a venda. Nada foi salvo e o estoque nao foi alterado.' +
              #13#10 + 'Erro: ' + E.Message),
        'Venda', MB_OK + MB_ICONERROR);
      Exit;
    end;
  end;

  VendaFinalizada := True;
  edtCodVenda.Text := IntToStr(CodVenda);
  MontarCupom; // cupom com o codigo real da venda

  // 2. Impressao APOS gravar tudo
  if Application.MessageBox('Deseja imprimir o comprovante?', 'Atencao', MB_YESNO) = IDYES then
  begin
    if not ImprimirComprovante then
    begin
      if Application.MessageBox(
        'A venda ja foi gravada. Deseja manter a venda sem imprimir?' + #13#10 +
        '(Nao = cancelar a venda e devolver o estoque)',
        'Aviso - Impressora', MB_YESNO + MB_ICONWARNING) = IDNO then
      begin
        try
          ItensSemCodigo := dmConexoes.EstornarVenda(CodVenda);
          if ItensSemCodigo = 0 then
            VendaFinalizada := False;
          Application.MessageBox('Venda cancelada e estoque devolvido. Conecte a impressora e tente novamente.',
            'Cancelado', MB_OK + MB_ICONINFORMATION);
        except
          on E: Exception do
            Application.MessageBox(PChar('Nao foi possivel cancelar a venda ' + IntToStr(CodVenda) +
              '. Cancele pela Consulta de Vendas.' + #13#10 + 'Erro: ' + E.Message),
              'Erro', MB_OK + MB_ICONERROR);
        end;
        AtualizarCodVenda;
        Exit; // mantem os itens na tela para tentar de novo
      end;
    end;
  end;

  Application.MessageBox('Venda Feita com Sucesso', 'Venda', MB_OK + MB_ICONINFORMATION);

  if gerarNFCe or gerarNFe then
  begin
    try
      if gerarNFCe then
        idFiscal := TFiscalStorage.RegistrarDocumentoVenda(dmConexoes.conRobson, '65',
          CodVenda, 1, CodVenda, totalvalor, fdProduto)
      else
        idFiscal := TFiscalStorage.RegistrarDocumentoVenda(dmConexoes.conRobson, '55',
          CodVenda, 1, CodVenda, totalvalor, fdProduto);
      if gerarNFCe then
        Application.MessageBox(
          PChar('NFC-e registrada para emissao. Venda: ' + IntToStr(CodVenda) + #13#10 +
                'Registro fiscal: ' + IntToStr(idFiscal) + #13#10 +
                'Status: pendente de envio ACBrNFe/SEFAZ.'),
          'NFC-e', MB_OK + MB_ICONINFORMATION)
      else
        Application.MessageBox(
          PChar('NF-e modelo 55 registrada para emissao. Venda: ' + IntToStr(CodVenda) + #13#10 +
                'Registro fiscal: ' + IntToStr(idFiscal) + #13#10 +
                'Status: pendente de envio ACBrNFe/SEFAZ.'),
          'NF-e', MB_OK + MB_ICONINFORMATION);
    except
      on E: Exception do
        Application.MessageBox(PChar('A venda foi gravada, mas o registro fiscal falhou: ' + E.Message),
          'Fiscal', MB_OK + MB_ICONWARNING);
    end;
  end;

  LimparTela;
end;

// ============================================================
// PAINEL FIADO - Finaliza venda como fiado
// ============================================================

procedure TfrmCaixaVendas.GravarFiado(ACodCli: Integer);
var
  Q: TADOQuery;
begin
  Q := TADOQuery.Create(nil);
  try
    Q.Connection := dmConexoes.conRobson;
    dmConexoes.conRobson.BeginTrans;
    try
      Q.SQL.Text :=
        'UPDATE Cliente SET valorfiado = ISNULL(valorfiado, 0) + :Valor WHERE codcli = :CodCli';
      Q.Parameters.ParamByName('Valor').DataType := ftBCD;
      Q.Parameters.ParamByName('Valor').Value    := totalvalor;
      Q.Parameters.ParamByName('CodCli').Value   := ACodCli;
      if Q.ExecSQL = 0 then
        raise Exception.Create('Cliente nao encontrado.');

      fdProduto.First;
      while not fdProduto.Eof do
      begin
        BaixarEstoque(Q, fdProduto.FieldByName('CodProd').AsInteger,
          fdProduto.FieldByName('Quantidade').AsInteger,
          fdProduto.FieldByName('Descricao').AsString);
        fdProduto.Next;
      end;

      dmConexoes.conRobson.CommitTrans;
    except
      if dmConexoes.conRobson.InTransaction then
        dmConexoes.conRobson.RollbackTrans;
      raise;
    end;
  finally
    Q.Free;
  end;
end;

procedure TfrmCaixaVendas.PnfiadoClick(Sender: TObject);
var
  CodCli: Integer;
  NomeCli: string;
begin
  if not ValidarFinalizacao then
    Exit;

  CodCli := StrToIntDef(Trim(EdtNameCliente.Text), 0);
  NomeCli := '';
  with dmConexoes do
  begin
    qrCliente.Close;
    qrCliente.SQL.Text := 'SELECT * FROM [LojaNova].[dbo].[Cliente] WHERE codcli = :pcod';
    qrCliente.Parameters.ParamByName('pcod').Value := CodCli;
    qrCliente.Open;
    if not qrCliente.IsEmpty then
      NomeCli := qrCliente.FieldByName('nome').AsString;
  end;

  if (CodCli <= 0) or (NomeCli = '') then
  begin
    Application.MessageBox('Informe um cliente valido para registrar a venda fiado.',
      'Fiado', MB_OK + MB_ICONWARNING);
    EdtNameCliente.SetFocus;
    Exit;
  end;

  if Application.MessageBox(
    PChar('Registrar venda fiado de R$ ' + FormatFloat('#,##0.00', totalvalor) +
          ' para ' + NomeCli + '?'),
    'Fiado', MB_YESNO + MB_ICONQUESTION) <> IDYES then
    Exit;

  try
    GravarFiado(CodCli);
  except
    on E: Exception do
    begin
      Application.MessageBox(
        PChar('Nao foi possivel registrar o fiado. Nada foi salvo e o estoque nao foi alterado.' +
              #13#10 + 'Erro: ' + E.Message),
        'Fiado', MB_OK + MB_ICONERROR);
      Exit;
    end;
  end;

  VendaFinalizada := True;
  Application.MessageBox('Venda Fiado Registrada!', 'Fiado', MB_OK + MB_ICONINFORMATION);
  LimparTela;
end;

// ============================================================
// PAINEL IMPRESSORA
// ============================================================

procedure TfrmCaixaVendas.PnImpressoraClick(Sender: TObject);
begin
end;

// ============================================================
// MOUSE ENTER / LEAVE DOS PAINEIS
// ============================================================

procedure TfrmCaixaVendas.PnVendaMouseEnter(Sender: TObject);
begin PnVenda.Color := clGreen; PnVenda.Font.Color := clWhite; end;
procedure TfrmCaixaVendas.PnVendaMouseLeave(Sender: TObject);
begin PnVenda.Color := 2236962; PnVenda.Font.Color := clWhite; end;

procedure TfrmCaixaVendas.PnfiadoMouseEnter(Sender: TObject);
begin Pnfiado.Color := $001E8FBF; Pnfiado.Font.Color := clWhite; end;
procedure TfrmCaixaVendas.PnfiadoMouseLeave(Sender: TObject);
begin Pnfiado.Color := 2236962; Pnfiado.Font.Color := clWhite; end;

procedure TfrmCaixaVendas.PnImpressoraMouseEnter(Sender: TObject);
begin PnImpressora.Color := $00CC6600; PnImpressora.Font.Color := clWhite; end;
procedure TfrmCaixaVendas.PnImpressoraMouseLeave(Sender: TObject);
begin PnImpressora.Color := 2236962; PnImpressora.Font.Color := clWhite; end;

procedure TfrmCaixaVendas.PnConfirmaItemMouseEnter(Sender: TObject);
begin PnConfirmaItem.Color := clGreen; PnConfirmaItem.Font.Color := clWhite; end;
procedure TfrmCaixaVendas.PnConfirmaItemMouseLeave(Sender: TObject);
begin PnConfirmaItem.Color := 2236962; PnConfirmaItem.Font.Color := clWhite; end;

end.
