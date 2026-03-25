unit untVenda;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Data.DB, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  ACBrBase, ACBrPosPrinter, ACBrUtil.Strings, ACBrUtil.Base, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
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
    procedure AddMemo(ctexto: string);
    procedure VerificaCliente;
    procedure VerificaProduto;
    procedure InsereProd;
    procedure LimparTela;
    procedure AtualizarCodVenda;
    procedure RecalcularTotal;
  public
    { Public declarations }
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

uses dmConexao, untInicial, untCadastroProd, untLocalizaProd, untLocalizaCli;

// ============================================================
// RECALCULA TOTAL A PARTIR DO FDPRODUTO
// ============================================================

procedure TfrmCaixaVendas.RecalcularTotal;
begin
  totalvalor := 0;
  fdProduto.First;
  while not fdProduto.Eof do
  begin
    totalvalor := totalvalor + fdProduto.FieldByName('ValorTotal').AsCurrency;
    fdProduto.Next;
  end;
  lbvalorDinheiro.Caption := FormatFloat('"R$" #,##0.00', totalvalor);
end;

// ============================================================
// AUXILIARES PRIVADAS
// ============================================================

procedure TfrmCaixaVendas.AddMemo(ctexto: string);
begin
  Memo1.Lines.Add(ctexto);
end;

procedure TfrmCaixaVendas.LimparTela;
begin
  EdtNameCliente.Clear;
  edtCodProd.Clear;
  edtValorProd.Clear;
  edtQuant.Clear;
  edtValorTotal.Clear;
  edtDataVenda.Clear;
  lbvalorDinheiro.Caption := 'R$ 0,00';
  lbNomeCli.Caption       := '';
  lbNomeProd.Caption      := '.';
  FProdQtdeEstoque        := 0;
  totalvalor := 0;
  fdProduto.Close;
  fdProduto.Open;
  EdtNameCliente.SetFocus;
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
      edtDataVenda.SetFocus;
    end;
  end;
end;

// ============================================================
// VERIFICA PRODUTO
// ============================================================

procedure TfrmCaixaVendas.VerificaProduto;
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
      edtCodProd.SetFocus;
    end
    else
    begin
      lbNomeProd.Caption := qrEstoque.FieldByName('descricao').AsString;
      FProdQtdeEstoque   := qrEstoque.FieldByName('quantidade').AsInteger;
      edtQuant.SetFocus;
    end;
  end;
end;

// ============================================================
// INSERE PRODUTO NA GRID (FDMemTable)
// ============================================================

procedure TfrmCaixaVendas.InsereProd;
var
  i: Integer;
begin
  fdProduto.Active := True;
  fdProduto.Insert;
  fdProduto.FieldByName('Descricao').AsString    := lbNomeProd.Caption;
  fdProduto.FieldByName('CodVenda').AsInteger    := StrToIntDef(edtCodVenda.Text, 0);
  fdProduto.FieldByName('CodProd').AsInteger     := StrToIntDef(edtCodProd.Text, 0);
  fdProduto.FieldByName('ValorUni').AsCurrency   := dmConexoes.qrEstoque.FieldByName('valorvenda').AsCurrency;
  fdProduto.FieldByName('Quantidade').AsInteger  := StrToIntDef(edtQuant.Text, 0);
  fdProduto.FieldByName('ValorTotal').AsCurrency := dmConexoes.qrEstoque.FieldByName('valorvenda').AsCurrency * StrToIntDef(edtQuant.Text, 0);
  fdProduto.Post;

  // Recalcula total do zero para garantir precisao
  RecalcularTotal;

  // Monta cupom no Memo
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
    AddMemo(fdProdutoQuantidade.AsString + 'UN  x  ' + FloatToStr(fdProdutoValorUni.AsFloat));
    AddMemo('</linha_simples>');
    fdProduto.Next;
  end;

  AddMemo('Cliente: ' + EdtNameCliente.Text);
  AddMemo('Total: ' + lbvalorDinheiro.Caption);
  for i := 1 to 7 do
    AddMemo('');
end;

// ============================================================
// FORMSHOW
// ============================================================

procedure TfrmCaixaVendas.FormShow(Sender: TObject);
begin
  edtValorProd.Clear;
  edtQuantRest.Clear;
  cfg_Empresa  := 'NOME DA EMPRESA';
  cfg_Endereco := 'ENDERECO DA EMPRESA';
  cfg_Telefone := '(00) 0000-0000';

  FProdQtdeEstoque := 0;
  totalvalor := 0;
  fdProduto.Open;
  AtualizarCodVenda;
  lbvalorDinheiro.Caption := 'R$ 0,00';
  EdtNameCliente.SetFocus;
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
    edtValorTotal.SetFocus;
  end;
end;

procedure TfrmCaixaVendas.edtValorTotalKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    PnConfirmaItem.Color      := clGreen;
    PnConfirmaItem.Font.Color := clWhite;
    PnConfirmaItem.SetFocus;
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
  if Key = VK_DELETE then
  begin
    if Application.MessageBox('Deseja deletar o produto?', 'Atencao',
      MB_ICONQUESTION + MB_YESNO) = IDYES then
    begin
      fdProduto.Delete;
      // Recalcula total apos remover item
      RecalcularTotal;
    end;
  end;
end;

procedure TfrmCaixaVendas.DSItensVendaDataChange(Sender: TObject; Field: TField);
begin
  // nada
end;

// ============================================================
// PAINEL CONFIRMA ITEM - corrigido: atualiza quantidade em memoria
// ============================================================

procedure TfrmCaixaVendas.PnConfirmaItemClick(Sender: TObject);
begin
  with dmConexoes do
  begin
    qrComando.Close;
    qrComando.SQL.Clear;
    qrComando.SQL.Add('SELECT MAX(CodVenda) AS ULTIMOCODIGO FROM [LojaNova].[dbo].[vendas]');
    qrComando.Open;

    if qrEstoque.FieldByName('quantidade').AsInteger - StrToIntDef(edtQuant.Text, 0) <= 0 then
    begin
      if Application.MessageBox(
        'Voce ficara sem estoque deste produto, Deseja continuar a venda?',
        'Atencao', MB_YESNO + MB_ICONINFORMATION) = IDYES then
      begin
        // Apenas armazena em memoria - SEM post no banco
        InsereProd;
      end
      else
      begin
        Application.MessageBox('Venda de produto Cancelada', 'Atencao', MB_OK + MB_ICONINFORMATION);
      end;
    end
    else
    begin
      // Apenas armazena em memoria - SEM post no banco
      InsereProd;
    end;

    edtCodVenda.Text := IntToStr(qrComando.FieldByName('ULTIMOCODIGO').AsInteger + 1);
  end;

  PnVenda.Enabled := True;
  Pnfiado.Enabled := True;
  edtCodProd.SetFocus;
  edtQuant.Clear;
  edtValorProd.Clear;
  edtValorTotal.Clear;
  edtQuantRest.Clear;
end;

// ============================================================
// PAINEL VENDA - Finaliza venda normal
// ============================================================

procedure TfrmCaixaVendas.PnVendaClick(Sender: TObject);
var
  valorPago: Currency;
  troco: Currency;
  sValorPago: string;
  proximoCodItem: Integer;
  proximoCodVenda: Integer;
begin
    if Application.MessageBox('Deseja imprimir o comprovante?', 'Atencao', MB_YESNO) = IDYES then
    begin
      try
        ACBrPosPrinter1.Ativar;
        ACBrPosPrinter1.Buffer.Text := Memo1.Text;
        ACBrPosPrinter1.Imprimir;
        ACBrPosPrinter1.CortarPapel;
        Application.MessageBox('Venda Feita com Sucesso', 'Venda', MB_OK + MB_ICONINFORMATION);
      except
        on E: Exception do
        begin
          if Application.MessageBox(
            PChar('Impressora nao encontrada ou sem conexao.' + #13#10 +
                  'Deseja finalizar a venda sem imprimir o comprovante?'),
            'Aviso - Impressora', MB_YESNO + MB_ICONWARNING) = IDYES then
          begin
            Application.MessageBox('Venda Feita com Sucesso sem impressao.', 'Venda', MB_OK + MB_ICONINFORMATION);
          end
          else
          begin
            // Cancela tudo - desfaz a venda gravada
            dmConexoes.qrVendas.Close;
            dmConexoes.qrVendas.SQL.Clear;
            dmConexoes.qrVendas.SQL.Add('DELETE FROM ItensVenda WHERE CodVenda = ' + IntToStr(proximoCodVenda));
            dmConexoes.qrVendas.ExecSQL;
            dmConexoes.qrVendas.SQL.Clear;
            dmConexoes.qrVendas.SQL.Add('DELETE FROM VENDAS WHERE CodVenda = ' + IntToStr(proximoCodVenda));
            dmConexoes.qrVendas.ExecSQL;
            Application.MessageBox('Venda cancelada. Conecte a impressora e tente novamente.', 'Cancelado', MB_OK + MB_ICONINFORMATION);
            Exit;
          end;
        end;
      end;
    end
    else
      Application.MessageBox('Venda Feita com Sucesso', 'Venda', MB_OK + MB_ICONINFORMATION);

  with dmConexoes do
  begin
    // 1. Busca proximo CodVenda ANTES de gravar
    qrComando.Close;
    qrComando.SQL.Clear;
    qrComando.SQL.Add('SELECT ISNULL(MAX(CodVenda), 0) + 1 AS PROXIMOVENDA FROM [LojaNova].[dbo].[VENDAS]');
    qrComando.Open;
    proximoCodVenda := qrComando.FieldByName('PROXIMOVENDA').AsInteger;
    edtCodVenda.Text := IntToStr(proximoCodVenda);

    // 2. Grava a venda
    qrVendas.Close;
    qrVendas.SQL.Clear;
    qrVendas.SQL.Add('SELECT * FROM [LojaNova].[dbo].[VENDAS]');
    qrVendas.Open;
    qrVendas.Insert;
    qrVendas.FieldByName('ValorTotal').AsCurrency := totalvalor;
    qrVendas.FieldByName('ValorPago').AsCurrency  := totalvalor;
    qrVendas.FieldByName('CodCli').AsString       := Trim(EdtNameCliente.Text);
    qrVendas.FieldByName('DataVenda').AsDateTime  := StrToDateTime(edtDataVenda.Text);
    qrVendas.FieldByName('descriprod').AsString   := fdProduto.FieldByName('Descricao').AsString;
    qrVendas.Post;
    qrVendas.Close;

    // 3. Busca proximo CodItem
    qrComando.Close;
    qrComando.SQL.Clear;
    qrComando.SQL.Add('SELECT ISNULL(MAX(CodItem), 0) + 1 AS PROXIMOITEM FROM [LojaNova].[dbo].[ItensVenda]');
    qrComando.Open;
    proximoCodItem := qrComando.FieldByName('PROXIMOITEM').AsInteger;

    // 4. Abre itens e grava cada um com proximoCodVenda correto
    qrItensVenda.Close;
    qrItensVenda.SQL.Clear;
    qrItensVenda.SQL.Add('SELECT * FROM [LojaNova].[dbo].[ItensVenda]');
    qrItensVenda.Open;

    fdProduto.First;
    while not fdProduto.Eof do
    begin
      qrItensVenda.Insert;
      qrItensVenda.FieldByName('CodItem').AsInteger       := proximoCodItem;
      qrItensVenda.FieldByName('CodVenda').AsInteger      := proximoCodVenda; // <- CORRIGIDO
      qrItensVenda.FieldByName('Descricao').AsString      := fdProduto.FieldByName('Descricao').AsString;
      qrItensVenda.FieldByName('ValorTotal').AsCurrency   := fdProduto.FieldByName('ValorTotal').AsCurrency;
      qrItensVenda.FieldByName('Quantidade').AsInteger    := fdProduto.FieldByName('Quantidade').AsInteger;
      qrItensVenda.FieldByName('ValorProdUni').AsCurrency := fdProduto.FieldByName('ValorUni').AsCurrency;
      qrItensVenda.FieldByName('DataVenda').AsDateTime    := StrToDateTime(edtDataVenda.Text);
      qrItensVenda.Post;
      proximoCodItem := proximoCodItem + 1;
      fdProduto.Next;
    end;

      if Application.MessageBox('Deseja imprimir o comprovante?', 'Atencao', MB_YESNO) = IDYES then
    begin
      try
        ACBrPosPrinter1.Ativar;
        ACBrPosPrinter1.Buffer.Text := Memo1.Text;
        ACBrPosPrinter1.Imprimir;
        ACBrPosPrinter1.CortarPapel;
        Application.MessageBox('Venda Feita com Sucesso', 'Venda', MB_OK + MB_ICONINFORMATION);
      except
        on E: Exception do
        begin
          Application.MessageBox(
            PChar('Impressora nao encontrada ou sem conexao.' + #13#10 +
                  'A venda foi registrada normalmente.' + #13#10#10 +
                  'Verifique a conexao da impressora para proximas vendas.'),
            'Aviso - Impressora', MB_OK + MB_ICONWARNING);
        end;
      end;
    end
    else
      Application.MessageBox('Venda Feita com Sucesso', 'Venda', MB_OK + MB_ICONINFORMATION);
    // 5. Atualiza estoque
    fdProduto.First;
    while not fdProduto.Eof do
    begin
      if qrEstoque.Locate('codigo', fdProduto.FieldByName('CodProd').AsInteger, [loCaseInsensitive]) then
      begin
        qrEstoque.Edit;
        qrEstoque.FieldByName('quantidade').Value :=
          qrEstoque.FieldByName('quantidade').AsInteger -
          fdProduto.FieldByName('Quantidade').AsInteger;
        qrEstoque.Post;
      end;
      fdProduto.Next;
    end;

    LimparTela;
  end;
end;

// ============================================================
// PAINEL FIADO - Finaliza venda como fiado
// ============================================================

procedure TfrmCaixaVendas.PnfiadoClick(Sender: TObject);
var
  soma: Currency;
begin
  with dmConexoes do
  begin
    qrCliente.Close;
    qrCliente.SQL.Clear;
    qrCliente.SQL.Add('SELECT * FROM [LojaNova].[dbo].[Cliente] WHERE codcli = :pcod');
    qrCliente.Parameters.ParamByName('pcod').Value := Trim(EdtNameCliente.Text);
    qrCliente.Open;

    if not qrCliente.IsEmpty then
    begin
      soma := qrCliente.FieldByName('valorfiado').AsCurrency + totalvalor;
      qrCliente.Edit;
      qrCliente.FieldByName('valorfiado').AsCurrency := soma;
      qrCliente.Post;
    end;

    Application.MessageBox('Venda Fiado Registrada!', 'Fiado', MB_OK + MB_ICONINFORMATION);
    // Atualiza estoque de cada produto
    fdProduto.First;
    while not fdProduto.Eof do
    begin
      if qrEstoque.Locate('codigo', fdProduto.FieldByName('CodProd').AsInteger, [loCaseInsensitive]) then
      begin
        qrEstoque.Edit;
        qrEstoque.FieldByName('quantidade').Value :=
          qrEstoque.FieldByName('quantidade').AsInteger -
          fdProduto.FieldByName('Quantidade').AsInteger;
        qrEstoque.Post;
      end;
      fdProduto.Next;
    end;
    fdProduto.First;
    LimparTela;
  end;
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
