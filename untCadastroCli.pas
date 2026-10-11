unit untCadastroCli;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.WinXPickers, Vcl.StdCtrls, Vcl.Mask,
  Vcl.ExtCtrls, Vcl.DBCtrls, Data.DB;

type
  TfrmCadastroCliente = class(TForm)
    Panel1: TPanel;
    PnNovo: TPanel;
    PnEditar: TPanel;
    PnCancelar: TPanel;
    PnExcluir: TPanel;
    PnGravar: TPanel;
    PnSair: TPanel;
    PnUltimo: TPanel;
    PnProximo: TPanel;
    PnAnterior: TPanel;
    PnPrimeiro: TPanel;
    PnLocaliza: TPanel;
    PnPago: TPanel;
    Panel2: TPanel;
    lbEndereco: TLabel;
    LbNomeCli: TLabel;
    lbNumero: TLabel;
    lbNumeroTelefone: TLabel;
    LbDataNascCli: TLabel;
    edtNomeCliente: TDBEdit;
    edtEndereco: TDBEdit;
    edtTel: TDBEdit;
    edtNResidente: TDBEdit;
    DBEdit6: TDBEdit;
    Label3: TLabel;
    Label1: TLabel;
    DBEdit4: TDBEdit;
    DatePicker1: TDatePicker;
    DBEdit2: TDBEdit;
    chkClientePadrao: TDBCheckBox;
    procedure PnNovoClick(Sender: TObject);
    procedure PnEditarClick(Sender: TObject);
    procedure PnCancelarClick(Sender: TObject);
    procedure PnExcluirClick(Sender: TObject);
    procedure PnGravarClick(Sender: TObject);
    procedure PnSairClick(Sender: TObject);
    procedure PnLocalizaClick(Sender: TObject);
    procedure PnPrimeiroClick(Sender: TObject);
    procedure PnAnteriorClick(Sender: TObject);
    procedure PnProximoClick(Sender: TObject);
    procedure PnUltimoClick(Sender: TObject);
    procedure PnNovoMouseLeave(Sender: TObject);
    procedure PnNovoMouseEnter(Sender: TObject);
    procedure PnEditarMouseEnter(Sender: TObject);
    procedure PnCancelarMouseEnter(Sender: TObject);
    procedure PnExcluirMouseEnter(Sender: TObject);
    procedure PnGravarMouseEnter(Sender: TObject);
    procedure PnPagoMouseEnter(Sender: TObject);
    procedure PnSairMouseEnter(Sender: TObject);
    procedure PnLocalizaMouseEnter(Sender: TObject);
    procedure PnEditarMouseLeave(Sender: TObject);
    procedure PnAnteriorMouseEnter(Sender: TObject);
    procedure PnAnteriorMouseLeave(Sender: TObject);
    procedure PnProximoMouseEnter(Sender: TObject);
    procedure PnProximoMouseLeave(Sender: TObject);
    procedure PnUltimoMouseEnter(Sender: TObject);
    procedure PnUltimoMouseLeave(Sender: TObject);
    procedure PnSairMouseLeave(Sender: TObject);
    procedure PnPrimeiroMouseEnter(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edtNomeClienteKeyPress(Sender: TObject; var Key: Char);
    procedure edtEnderecoKeyPress(Sender: TObject; var Key: Char);
    procedure edtNResidenteKeyPress(Sender: TObject; var Key: Char);
    procedure PnPagoClick(Sender: TObject);
  private
    procedure GarantirCampoClientePadrao;
    procedure AtualizarClientePadrao;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCadastroCliente: TfrmCadastroCliente;

implementation

{$R *.dfm}

uses dmconexao, untLocalizaCli, Data.Win.ADODB;

procedure TfrmCadastroCliente.GarantirCampoClientePadrao;
begin
  with dmConexoes do
  begin
    qrComando.Close;
    qrComando.SQL.Text := 'IF COL_LENGTH(''dbo.Cliente'', ''cliente_padrao'') IS NULL ALTER TABLE dbo.Cliente ADD cliente_padrao BIT NOT NULL CONSTRAINT DF_CLIENTE_CLIENTE_PADRAO DEFAULT 0';
    qrComando.ExecSQL;
  end;
end;

procedure TfrmCadastroCliente.AtualizarClientePadrao;
var
  CodCliAtual: Integer;
begin
  if dmConexoes.qrCliente.IsEmpty then
    Exit;

  if dmConexoes.qrCliente.FindField('cliente_padrao') = nil then
    Exit;

  if not dmConexoes.qrCliente.FieldByName('cliente_padrao').AsBoolean then
    Exit;

  CodCliAtual := dmConexoes.qrCliente.FieldByName('CodCli').AsInteger;
  if CodCliAtual <= 0 then
    Exit;

  with dmConexoes do
  begin
    qrComando.Close;
    qrComando.SQL.Text := 'UPDATE [LojaNova].[dbo].[Cliente] SET cliente_padrao = 0 WHERE CodCli <> :pCodCli';
    qrComando.Parameters.ParamByName('pCodCli').Value := CodCliAtual;
    qrComando.ExecSQL;
  end;
end;
procedure TfrmCadastroCliente.edtEnderecoKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    edtNResidente.SetFocus;
end;

procedure TfrmCadastroCliente.edtNomeClienteKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    edtEndereco.SetFocus;
end;

procedure TfrmCadastroCliente.edtNResidenteKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    edtTel.SetFocus;
end;

procedure TfrmCadastroCliente.FormShow(Sender: TObject);
begin
  GarantirCampoClientePadrao;
  with dmConexoes do
  begin
    qrCliente.Close;
    qrCliente.SQL.Clear;
    qrCliente.SQL.Add('SELECT * FROM [LojaNova].[dbo].[cliente] ORDER BY ISNULL(cliente_padrao, 0) DESC, codcli');
    qrCliente.Open;
    qrCliente.First;
  end;
end;

// ============================================================
// PAGO - deduz valor pago do fiado e adiciona ao caixa
// ============================================================

procedure TfrmCadastroCliente.PnPagoClick(Sender: TObject);
var
  sValorPago: string;
  ValorPago, ValorFiadoAtual, NovoFiado: Currency;
  CodCli, IdCaixa: Integer;
  NomeCli: string;
  qrTemp: TADOQuery;
begin
  if dmConexoes.qrCliente.IsEmpty then
  begin
    ShowMessage('Nenhum cliente selecionado.');
    Exit;
  end;

  // O recebimento entra no caixa: sem caixa aberto o dinheiro nao seria registrado
  IdCaixa := dmConexoes.IdCaixaAtual;
  if IdCaixa <= 0 then
  begin
    ShowMessage('O caixa esta fechado. Abra o caixa antes de receber pagamento de fiado.');
    Exit;
  end;

  CodCli          := dmConexoes.qrCliente.FieldByName('CodCli').AsInteger;
  NomeCli         := dmConexoes.qrCliente.FieldByName('nome').AsString;
  ValorFiadoAtual := dmConexoes.qrCliente.FieldByName('valorfiado').AsCurrency;

  if ValorFiadoAtual <= 0 then
  begin
    ShowMessage('Este cliente nao possui valor em aberto.');
    Exit;
  end;

  // Pergunta o valor pago
  sValorPago := FormatFloat('#,##0.00', ValorFiadoAtual);
  if not InputQuery('Pagamento de Fiado',
    'Cliente: ' + NomeCli + #13#10 +
    'Valor em aberto: R$ ' + FormatFloat('#,##0.00', ValorFiadoAtual) + #13#10 +
    'Informe o valor recebido:',
    sValorPago) then Exit;

  if (not TryStrParaMoeda(sValorPago, ValorPago)) or (ValorPago <= 0) then
  begin
    ShowMessage('Valor invalido. Use virgula como separador. Ex: 20,98');
    Exit;
  end;

  // Nao aceita receber mais do que o cliente deve (o excesso ficaria no caixa sem origem)
  if ValorPago > ValorFiadoAtual then
  begin
    Application.MessageBox(
      PChar('O valor informado (R$ ' + FormatFloat('#,##0.00', ValorPago) +
            ') e maior que o valor em aberto (R$ ' + FormatFloat('#,##0.00', ValorFiadoAtual) + ').' +
            #13#10 + 'Sera registrado apenas o valor em aberto. Devolva o troco ao cliente.'),
      'Atencao', MB_OK + MB_ICONWARNING);
    ValorPago := ValorFiadoAtual;
  end;

  // Confirma pagamento
  if Application.MessageBox(
    PChar('Confirmar recebimento de R$ ' + FormatFloat('#,##0.00', ValorPago) +
          ' do cliente ' + NomeCli + '?'),
    'Confirmar Pagamento', MB_YESNO + MB_ICONQUESTION) <> IDYES then Exit;

  NovoFiado := ValorFiadoAtual - ValorPago;

  // Baixa o fiado e registra o pagamento no caixa juntos (tudo ou nada)
  qrTemp := TADOQuery.Create(nil);
  try
    qrTemp.Connection := dmConexoes.conRobson;
    dmConexoes.conRobson.BeginTrans;
    try
      qrTemp.SQL.Text :=
        'UPDATE Cliente SET valorfiado = CASE WHEN ISNULL(valorfiado, 0) - :Valor1 < 0 ' +
        'THEN 0 ELSE ISNULL(valorfiado, 0) - :Valor2 END WHERE CodCli = :CodCli';
      qrTemp.Parameters.ParamByName('Valor1').DataType := ftBCD;
      qrTemp.Parameters.ParamByName('Valor1').Value    := ValorPago;
      qrTemp.Parameters.ParamByName('Valor2').DataType := ftBCD;
      qrTemp.Parameters.ParamByName('Valor2').Value    := ValorPago;
      qrTemp.Parameters.ParamByName('CodCli').Value    := CodCli;
      qrTemp.ExecSQL;

      qrTemp.SQL.Text :=
        'INSERT INTO PagamentoFiado (IdCaixa, CodCli, ValorPago) VALUES (:IdCaixa, :CodCli, :Valor)';
      qrTemp.Parameters.ParamByName('IdCaixa').Value  := IdCaixa;
      qrTemp.Parameters.ParamByName('CodCli').Value   := CodCli;
      qrTemp.Parameters.ParamByName('Valor').DataType := ftBCD;
      qrTemp.Parameters.ParamByName('Valor').Value    := ValorPago;
      qrTemp.ExecSQL;

      dmConexoes.conRobson.CommitTrans;
    except
      on E: Exception do
      begin
        if dmConexoes.conRobson.InTransaction then
          dmConexoes.conRobson.RollbackTrans;
        ShowMessage('Nao foi possivel registrar o pagamento. Nada foi alterado.' + sLineBreak + E.Message);
        Exit;
      end;
    end;
  finally
    qrTemp.Free;
  end;

  // Atualiza a tela com o valor gravado no banco
  dmConexoes.qrCliente.Close;
  dmConexoes.qrCliente.Open;
  dmConexoes.qrCliente.Locate('CodCli', CodCli, []);

  Application.MessageBox(
    PChar('Pagamento registrado com sucesso!' + #13#10 +
          'Valor recebido: R$ ' + FormatFloat('#,##0.00', ValorPago) + #13#10 +
          'Saldo restante: R$ ' + FormatFloat('#,##0.00', NovoFiado)),
    'Pagamento', MB_OK + MB_ICONINFORMATION
  );
end;

procedure TfrmCadastroCliente.PnAnteriorClick(Sender: TObject);
begin
  with dmConexoes.qrCliente do
  begin
    if not Bof then
      Prior
    else
      ShowMessage('Primeiro registro!');
  end;
end;

procedure TfrmCadastroCliente.PnAnteriorMouseEnter(Sender: TObject);
begin
  TPanel(Sender).Color      := $00333333;
  TPanel(Sender).Font.Color := clWhite;
end;

procedure TfrmCadastroCliente.PnAnteriorMouseLeave(Sender: TObject);
begin
  TPanel(Sender).Color      := $00666666;
  TPanel(Sender).Font.Color := 0;
end;

procedure TfrmCadastroCliente.PnPagoMouseEnter(Sender: TObject);
begin
  TPanel(Sender).Color      := clGreen;
  TPanel(Sender).Font.Color := clWhite;
end;

procedure TfrmCadastroCliente.PnCancelarClick(Sender: TObject);
begin
  with dmConexoes do
  begin
    if qrCliente.State in [dsEdit, dsInsert] then
      qrCliente.Cancel;
    qrCliente.Close;
    qrCliente.SQL.Clear;
    qrCliente.SQL.Add('SELECT * FROM [LojaNova].[dbo].[Cliente] ORDER BY ISNULL(cliente_padrao, 0) DESC, codcli');
    qrCliente.Open;
    qrCliente.First;
  end;

  MessageDlg('Cadastro cancelado', mtInformation, [mbOK], 0);

  PnEditar.Enabled   := True;
  PnExcluir.Enabled  := True;
  PnPrimeiro.Enabled := True;
  PnAnterior.Enabled := True;
  PnProximo.Enabled  := True;
  PnUltimo.Enabled   := True;
  PnCancelar.Enabled := True;
  PnSair.Enabled     := True;
  PnGravar.Enabled   := False;

  PnEditar.Font.Color   := 0;
  PnExcluir.Font.Color  := 0;
  PnPrimeiro.Font.Color := 0;
  PnAnterior.Font.Color := 0;
  PnProximo.Font.Color  := 0;
  PnUltimo.Font.Color   := 0;
  PnSair.Font.Color     := 0;
  PnGravar.Font.Color   := $00333333;

  edtNomeCliente.Enabled   := False;
  edtEndereco.Enabled      := False;
  edtTel.Enabled           := False;
  edtNResidente.Enabled    := False;
  DatePicker1.Enabled      := False;
  chkClientePadrao.Enabled := False;
end;

procedure TfrmCadastroCliente.PnCancelarMouseEnter(Sender: TObject);
begin
  TPanel(Sender).Color      := $00333333;
  TPanel(Sender).Font.Color := clWhite;
end;

procedure TfrmCadastroCliente.PnEditarClick(Sender: TObject);
begin
  edtNomeCliente.Enabled := True;
  edtEndereco.Enabled    := True;
  edtTel.Enabled         := True;
  edtNResidente.Enabled  := True;
  DatePicker1.Enabled    := True;
  chkClientePadrao.Enabled := True;

  PnGravar.Enabled      := True;
  PnCancelar.Enabled    := True;
  PnGravar.Font.Color   := 0;
  PnCancelar.Font.Color := 0;

  PnEditar.Font.Color   := $00333333;
  PnExcluir.Font.Color  := $00333333;
  PnPrimeiro.Font.Color := $00333333;
  PnAnterior.Font.Color := $00333333;
  PnProximo.Font.Color  := $00333333;
  PnUltimo.Font.Color   := $00333333;

  PnEditar.Enabled   := False;
  PnExcluir.Enabled  := False;
  PnPrimeiro.Enabled := False;
  PnAnterior.Enabled := False;
  PnProximo.Enabled  := False;
  PnUltimo.Enabled   := False;
end;

procedure TfrmCadastroCliente.PnEditarMouseEnter(Sender: TObject);
begin
  TPanel(Sender).Color      := $00333333;
  TPanel(Sender).Font.Color := clWhite;
end;

procedure TfrmCadastroCliente.PnEditarMouseLeave(Sender: TObject);
begin
  TPanel(Sender).Color      := $00666666;
  TPanel(Sender).Font.Color := 0;
end;

procedure TfrmCadastroCliente.PnExcluirClick(Sender: TObject);
begin
  if dmConexoes.qrCliente.IsEmpty then
    Exit;
  if dmConexoes.qrCliente.FieldByName('valorfiado').AsCurrency > 0 then
  begin
    ShowMessage('Este cliente possui fiado em aberto (R$ ' +
      FormatFloat('#,##0.00', dmConexoes.qrCliente.FieldByName('valorfiado').AsCurrency) +
      '). Receba o valor antes de excluir.');
    Exit;
  end;
  if MessageDlg('Deseja excluir este registro?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    try
      dmConexoes.qrCliente.Delete;
      ShowMessage('Registro excluido com sucesso!');
    except
      on E: Exception do
        ShowMessage('Erro ao excluir: ' + E.Message);
    end;
  end;
end;

procedure TfrmCadastroCliente.PnExcluirMouseEnter(Sender: TObject);
begin
  TPanel(Sender).Color      := $00333333;
  TPanel(Sender).Font.Color := clWhite;
end;

procedure TfrmCadastroCliente.PnGravarClick(Sender: TObject);
var
  CodCliAtual: Integer;
begin
  if Application.MessageBox('Deseja gravar o cliente?', 'Cadastro',
    MB_YESNO + MB_ICONQUESTION) <> IDYES then
  begin
    if dmConexoes.qrCliente.State in [dsEdit, dsInsert] then
      dmConexoes.qrCliente.Cancel;
    PnGravar.Enabled      := False;
    PnGravar.Font.Color   := $00333333;
    edtNomeCliente.Enabled := False;
    edtEndereco.Enabled    := False;
    edtTel.Enabled         := False;
    edtNResidente.Enabled  := False;
    DatePicker1.Enabled    := False;
    chkClientePadrao.Enabled := False;
    Exit;
  end;

  edtNomeCliente.Enabled := False;
  edtEndereco.Enabled    := False;
  edtTel.Enabled         := False;
  edtNResidente.Enabled  := False;
  DatePicker1.Enabled    := False;
  chkClientePadrao.Enabled := False;

  with dmConexoes do
  begin
    qrCliente.Edit;
    qrCliente.FieldByName('DataCadastrocliente').AsDateTime := DatePicker1.Date;
    qrCliente.Post;
    CodCliAtual := qrCliente.FieldByName('CodCli').AsInteger;
    AtualizarClientePadrao;
    qrCliente.Close;
    qrCliente.SQL.Clear;
    qrCliente.SQL.Add('SELECT * FROM [LojaNova].[dbo].[Cliente] ORDER BY ISNULL(cliente_padrao, 0) DESC, codcli');
    qrCliente.Open;
    qrCliente.Locate('CodCli', CodCliAtual, []);
    Application.MessageBox('Cliente Cadastrado com Sucesso', 'Cadastro', MB_OK + MB_ICONINFORMATION);
  end;

  PnCancelar.Enabled    := True;
  PnGravar.Enabled      := False;
  PnGravar.Font.Color   := $00333333;
  PnCancelar.Font.Color := 0;
  PnPrimeiro.Font.Color := 0;
  PnAnterior.Font.Color := 0;
  PnProximo.Font.Color  := 0;
  PnUltimo.Font.Color   := 0;
  PnExcluir.Font.Color  := 0;

  PnEditar.Enabled   := True;
  PnExcluir.Enabled  := True;
  PnPrimeiro.Enabled := True;
  PnAnterior.Enabled := True;
  PnProximo.Enabled  := True;
  PnUltimo.Enabled   := True;
  PnSair.Enabled     := True;
end;

procedure TfrmCadastroCliente.PnGravarMouseEnter(Sender: TObject);
begin
  TPanel(Sender).Color      := clMoneyGreen;
  TPanel(Sender).Font.Color := clWhite;
end;

procedure TfrmCadastroCliente.PnLocalizaClick(Sender: TObject);
begin
  Application.CreateForm(TfrmLocalizaCli, frmLocalizaCli);
  frmLocalizaCli.ShowModal;
  frmLocalizaCli.Free;

  if Trim(LocalizaCodigoCli) <> '' then
  begin
    with dmConexoes do
    begin
      qrCliente.Close;
      qrCliente.SQL.Clear;
      qrCliente.SQL.Add('SELECT * FROM [LojaNova].[dbo].[Cliente]');
      qrCliente.SQL.Add('WHERE CODCLI = :pCodigo');
      qrCliente.Parameters.ParamByName('pCodigo').Value := LocalizaCodigoCli;
      qrCliente.Open;
    end;
    LocalizaCodigoCli := '';
  end;

  PnLocaliza.ParentDoubleBuffered := False;
end;

procedure TfrmCadastroCliente.PnLocalizaMouseEnter(Sender: TObject);
begin
  TPanel(Sender).Color      := $00333333;
  TPanel(Sender).Font.Color := clWhite;
end;

procedure TfrmCadastroCliente.PnNovoClick(Sender: TObject);
begin
  GarantirCampoClientePadrao;
  with dmConexoes do
  begin
    qrCliente.Close;
    qrCliente.SQL.Clear;
    qrCliente.SQL.Add('SELECT * FROM [LojaNova].[dbo].[Cliente]');
    qrCliente.Open;
    qrCliente.First;
    qrCliente.Insert;
    if qrCliente.FindField('cliente_padrao') <> nil then
      qrCliente.FieldByName('cliente_padrao').AsBoolean := False;

    PnEditar.Enabled   := not PnEditar.Enabled;
    PnExcluir.Enabled  := not PnExcluir.Enabled;
    PnPrimeiro.Enabled := not PnPrimeiro.Enabled;
    PnAnterior.Enabled := not PnAnterior.Enabled;
    PnProximo.Enabled  := not PnProximo.Enabled;
    PnUltimo.Enabled   := not PnUltimo.Enabled;
    PnSair.Enabled     := not PnSair.Enabled;
    PnGravar.Enabled   := True;
    PnCancelar.Enabled := True;

    PnEditar.Font.Color   := $00333333;
    PnExcluir.Font.Color  := $00333333;
    PnPrimeiro.Font.Color := $00333333;
    PnAnterior.Font.Color := $00333333;
    PnProximo.Font.Color  := $00333333;
    PnUltimo.Font.Color   := $00333333;
    PnSair.Font.Color     := $00333333;
    PnCancelar.Font.Color := 0;
    PnGravar.Font.Color   := 0;

    edtNomeCliente.Enabled := not edtNomeCliente.Enabled;
    edtEndereco.Enabled    := not edtEndereco.Enabled;
    edtTel.Enabled         := not edtTel.Enabled;
    edtNResidente.Enabled  := not edtNResidente.Enabled;
    DatePicker1.Enabled    := not DatePicker1.Enabled;
    chkClientePadrao.Enabled := not chkClientePadrao.Enabled;

    edtNomeCliente.SetFocus;
  end;
end;

procedure TfrmCadastroCliente.PnNovoMouseEnter(Sender: TObject);
begin
  TPanel(Sender).Color      := $00333333;
  TPanel(Sender).Font.Color := clWhite;
end;

procedure TfrmCadastroCliente.PnNovoMouseLeave(Sender: TObject);
begin
  TPanel(Sender).Color      := $00666666;
  TPanel(Sender).Font.Color := 0;
end;

procedure TfrmCadastroCliente.PnPrimeiroClick(Sender: TObject);
begin
  dmConexoes.qrCliente.First;
end;

procedure TfrmCadastroCliente.PnPrimeiroMouseEnter(Sender: TObject);
begin
  TPanel(Sender).Color      := $00333333;
  TPanel(Sender).Font.Color := clWhite;
end;

procedure TfrmCadastroCliente.PnProximoClick(Sender: TObject);
begin
  with dmConexoes.qrCliente do
  begin
    if not Eof then
      Next
    else
      ShowMessage('Ultimo registro!');
  end;
end;

procedure TfrmCadastroCliente.PnProximoMouseEnter(Sender: TObject);
begin
  TPanel(Sender).Color      := $00333333;
  TPanel(Sender).Font.Color := clWhite;
end;

procedure TfrmCadastroCliente.PnProximoMouseLeave(Sender: TObject);
begin
  TPanel(Sender).Color      := $00666666;
  TPanel(Sender).Font.Color := 0;
end;

procedure TfrmCadastroCliente.PnSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmCadastroCliente.PnSairMouseEnter(Sender: TObject);
begin
  TPanel(Sender).Color      := $00333333;
  TPanel(Sender).Font.Color := clWhite;
end;

procedure TfrmCadastroCliente.PnSairMouseLeave(Sender: TObject);
begin
  TPanel(Sender).Color      := $00666666;
  TPanel(Sender).Font.Color := 0;
end;

procedure TfrmCadastroCliente.PnUltimoClick(Sender: TObject);
begin
  dmConexoes.qrCliente.Last;
end;

procedure TfrmCadastroCliente.PnUltimoMouseEnter(Sender: TObject);
begin
  TPanel(Sender).Color      := $00333333;
  TPanel(Sender).Font.Color := clWhite;
end;

procedure TfrmCadastroCliente.PnUltimoMouseLeave(Sender: TObject);
begin
  TPanel(Sender).Color      := $00666666;
  TPanel(Sender).Font.Color := 0;
end;

end.
