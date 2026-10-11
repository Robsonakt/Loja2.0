unit untCadastroEmpresa;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.UITypes, System.JSON, System.Net.HttpClient,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  Data.Win.ADODB,Vcl.Menus, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;


type
  TfrmCadastroEmpresa = class(TForm)
    pnlTopo: TPanel;
    lblTitulo: TLabel;
    pgcPrincipal: TPageControl;
    tabDadosGerais: TTabSheet;
    tabFiscal: TTabSheet;
    grpIdentificacao: TGroupBox;
    lblCodigo: TLabel;
    lblRazaoSocial: TLabel;
    lblNomeFantasia: TLabel;
    lblCNPJ: TLabel;
    lblIE: TLabel;
    lblIM: TLabel;
    lblRegime: TLabel;
    edtCodigo: TEdit;
    edtRazaoSocial: TEdit;
    edtNomeFantasia: TEdit;
    edtCNPJ: TEdit;
    edtIE: TEdit;
    edtIM: TEdit;
    cboRegime: TComboBox;
    chkPrincipal: TCheckBox;
    grpEndereco: TGroupBox;
    lblCEP: TLabel;
    lblLogradouro: TLabel;
    lblNumero: TLabel;
    lblComplemento: TLabel;
    lblBairro: TLabel;
    lblCidade: TLabel;
    lblUF: TLabel;
    edtCEP: TEdit;
    edtLogradouro: TEdit;
    edtNumero: TEdit;
    edtComplemento: TEdit;
    edtBairro: TEdit;
    edtCidade: TEdit;
    edtUF: TEdit;
    grpContato: TGroupBox;
    lblTelefone: TLabel;
    lblCelular: TLabel;
    lblEmail: TLabel;
    lblSite: TLabel;
    lblResponsavel: TLabel;
    lblSituacao: TLabel;
    edtTelefone: TEdit;
    edtCelular: TEdit;
    edtEmail: TEdit;
    edtSite: TEdit;
    edtResponsavel: TEdit;
    cboSituacao: TComboBox;
    grpFiscal: TGroupBox;
    lblCNAE: TLabel;
    lblAtividade: TLabel;
    lblSuframa: TLabel;
    edtCNAE: TEdit;
    edtAtividade: TEdit;
    edtSuframa: TEdit;
    chkEmiteNFCeVenda: TCheckBox;
    chkEmiteNFeVenda: TCheckBox;
    pnlBotoes: TPanel;
    btnNovo: TButton;
    btnEditar: TButton;
    btnGravar: TButton;
    btnCancelar: TButton;
    btnExcluir: TButton;
    btnAnterior: TButton;
    btnProximo: TButton;
    btnLimpar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure btnGravarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnAnteriorClick(Sender: TObject);
    procedure btnProximoClick(Sender: TObject);
    procedure btnLimparClick(Sender: TObject);
    procedure edtCEPExit(Sender: TObject);
    procedure edtCNPJExit(Sender: TObject);
    procedure pgcPrincipalChange(Sender: TObject);
  private
    FModoEdicao: Boolean;
    FCodigoAtual: Integer;
    procedure LimparCampos;
    procedure CarregarDados(ACodigo: Integer);
    procedure CarregarPrimeiraEmpresa;
    procedure NavegarEmpresa(ADirecao: Integer);
    function DocumentoJaCadastrado(const ADocumento: string; out AIdEmpresa: Integer): Boolean;
    procedure HabilitarEdicao(AHabilitar: Boolean);
    procedure AplicarTemaDark;
    function ValidarCampos: Boolean;
    function CNPJValido(ACNPJ: string): Boolean;
    function FormatarCNPJ(ACNPJ: string): string;
    function FormatarCEP(ACEP: string): string;
    function SoNumeros(ATexto: string): string;
    function ProximoCodigo: Integer;
    procedure BuscarEnderecoPorCEP;
  public
    procedure CarregarEmpresa(ACodigo: Integer);
  end;

var
  frmCadastroEmpresa: TfrmCadastroEmpresa;

implementation

uses
  dmconexao, uEmpresaConfig;

{$R *.dfm}

// ============================================================
//  EVENTOS DO FORM
// ============================================================

procedure TfrmCadastroEmpresa.FormCreate(Sender: TObject);
begin
  TEmpresaConfig.GarantirEstrutura(dmConexoes.conRobson);
  FModoEdicao  := False;
  FCodigoAtual := 0;
  AplicarTemaDark;
  LimparCampos;
  CarregarPrimeiraEmpresa;
  HabilitarEdicao(False);
end;

procedure TfrmCadastroEmpresa.FormDestroy(Sender: TObject);
begin
  // Conexao gerenciada pelo dmConexoes — nada a fazer aqui
end;

procedure TfrmCadastroEmpresa.pgcPrincipalChange(Sender: TObject);
begin
  // Reservado para uso futuro
end;

// ============================================================
//  TEMA DARK
// ============================================================

procedure TfrmCadastroEmpresa.AplicarTemaDark;
const
  COR_FUNDO  = $00302F2E;
  COR_PAINEL = $00292928;
  COR_EDIT   = $002A2A2A;
  COR_TEXTO  = clSilver;

  procedure PrepararFundoAba(ATab: TTabSheet; const ANomePainel: string);
  var
    P: TPanel;
    I: Integer;
    C: TControl;
  begin
    if ATab.FindComponent(ANomePainel) <> nil then
      Exit;

    P := TPanel.Create(ATab);
    P.Name := ANomePainel;
    P.Parent := ATab;
    P.Align := alClient;
    P.BevelOuter := bvNone;
    P.Color := COR_PAINEL;
    P.ParentBackground := False;

    for I := ATab.ControlCount - 1 downto 0 do
    begin
      C := ATab.Controls[I];
      if C <> P then
        C.Parent := P;
    end;

    P.SendToBack;
  end;
  procedure ProcessaControle(ACtrl: TWinControl);
  var
    J: Integer;
  begin
    for J := 0 to ACtrl.ControlCount - 1 do
    begin
      if ACtrl.Controls[J] is TEdit then
        with TEdit(ACtrl.Controls[J]) do
        begin
          Color      := COR_EDIT;
          Font.Color := COR_TEXTO;
        end
      else if ACtrl.Controls[J] is TComboBox then
        with TComboBox(ACtrl.Controls[J]) do
        begin
          Color      := COR_EDIT;
          Font.Color := COR_TEXTO;
        end
      else if ACtrl.Controls[J] is TCheckBox then
        with TCheckBox(ACtrl.Controls[J]) do
        begin
          Color      := COR_PAINEL;
          Font.Color := COR_TEXTO;
        end
      else if ACtrl.Controls[J] is TMemo then
        with TMemo(ACtrl.Controls[J]) do
        begin
          Color      := COR_EDIT;
          Font.Color := COR_TEXTO;
        end
      else if ACtrl.Controls[J] is TGroupBox then
        with TGroupBox(ACtrl.Controls[J]) do
        begin
          Color      := COR_PAINEL;
          Font.Color := COR_TEXTO;
          ProcessaControle(TGroupBox(ACtrl.Controls[J]));
        end
      else if ACtrl.Controls[J] is TTabSheet then
        with TTabSheet(ACtrl.Controls[J]) do
        begin
          Color := COR_FUNDO;
          ProcessaControle(TTabSheet(ACtrl.Controls[J]));
        end
      else if ACtrl.Controls[J] is TWinControl then
        ProcessaControle(TWinControl(ACtrl.Controls[J]));
    end;
  end;

begin
  Self.Color      := COR_FUNDO;
  Self.Font.Color := COR_TEXTO;
  pnlTopo.Color   := COR_PAINEL;
  pnlBotoes.Color := COR_PAINEL;
  PrepararFundoAba(tabDadosGerais, 'pnlFundoEmpresa');
  PrepararFundoAba(tabFiscal, 'pnlFundoFiscal');
  ProcessaControle(Self);
end;

// ============================================================
//  CRUD — usa dmConexoes.qrEmpresa (ADO)
// ============================================================

function TfrmCadastroEmpresa.ProximoCodigo: Integer;
var
  qry: TADOQuery;
begin
  Result := 1;
  qry := TADOQuery.Create(nil);
  try
    qry.Connection := dmConexoes.conRobson;
    qry.SQL.Text   :=
      'SELECT ISNULL(MAX(ID_EMPRESA), 0) + 1 AS PROXIMO FROM EMPRESA';
    qry.Open;
    Result := qry.FieldByName('PROXIMO').AsInteger;
  finally
    qry.Free;
  end;
end;

procedure TfrmCadastroEmpresa.CarregarPrimeiraEmpresa;
var
  Qry: TADOQuery;
begin
  Qry := TADOQuery.Create(nil);
  try
    Qry.Connection := dmConexoes.conRobson;
    Qry.SQL.Text := 'SELECT TOP 1 ID_EMPRESA FROM EMPRESA WHERE ISNULL(NULLIF(LTRIM(RTRIM(RAZAO_SOCIAL)), ''''), NULLIF(LTRIM(RTRIM(NOME_FANTASIA)), '''')) IS NOT NULL ORDER BY ISNULL(PRINCIPAL, 0) DESC, ID_EMPRESA';
    Qry.Open;
    if not Qry.IsEmpty then
      CarregarDados(Qry.FieldByName('ID_EMPRESA').AsInteger);
  finally
    Qry.Free;
  end;
end;

procedure TfrmCadastroEmpresa.NavegarEmpresa(ADirecao: Integer);
var
  Qry: TADOQuery;
  Sinal, Ordem: string;
begin
  if FCodigoAtual = 0 then
  begin
    CarregarPrimeiraEmpresa;
    Exit;
  end;

  if ADirecao > 0 then
  begin
    Sinal := '>';
    Ordem := 'ASC';
  end
  else
  begin
    Sinal := '<';
    Ordem := 'DESC';
  end;

  Qry := TADOQuery.Create(nil);
  try
    Qry.Connection := dmConexoes.conRobson;
    Qry.SQL.Text := 'SELECT TOP 1 ID_EMPRESA FROM EMPRESA WHERE ID_EMPRESA ' + Sinal + ' :pID ORDER BY ID_EMPRESA ' + Ordem;
    Qry.Parameters.ParamByName('pID').Value := FCodigoAtual;
    Qry.Open;
    if not Qry.IsEmpty then
    begin
      CarregarDados(Qry.FieldByName('ID_EMPRESA').AsInteger);
      HabilitarEdicao(False);
    end
    else
      MessageDlg('Nao ha outra empresa cadastrada nesta direcao.', mtInformation, [mbOK], 0);
  finally
    Qry.Free;
  end;
end;

procedure TfrmCadastroEmpresa.CarregarDados(ACodigo: Integer);
begin
  try
    dmConexoes.qrEmpresa.Close;
    dmConexoes.qrEmpresa.SQL.Text :=
      'SELECT * FROM EMPRESA WHERE ID_EMPRESA = :pCodigo';
    dmConexoes.qrEmpresa.Parameters.ParamByName('pCodigo').Value := ACodigo;
    dmConexoes.qrEmpresa.Open;

    if dmConexoes.qrEmpresa.IsEmpty then
    begin
      ShowMessage('Empresa nao encontrada.');
      Exit;
    end;

    FCodigoAtual := ACodigo;

    edtCodigo.Text       := dmConexoes.qrEmpresa.FieldByName('ID_EMPRESA').AsString;
    edtRazaoSocial.Text  := dmConexoes.qrEmpresa.FieldByName('RAZAO_SOCIAL').AsString;
    edtNomeFantasia.Text := dmConexoes.qrEmpresa.FieldByName('NOME_FANTASIA').AsString;
    edtCNPJ.Text         := FormatarCNPJ(dmConexoes.qrEmpresa.FieldByName('CNPJ').AsString);
    edtIE.Text           := dmConexoes.qrEmpresa.FieldByName('INSC_ESTADUAL').AsString;
    edtIM.Text           := dmConexoes.qrEmpresa.FieldByName('INSC_MUNICIPAL').AsString;
    edtCEP.Text          := FormatarCEP(dmConexoes.qrEmpresa.FieldByName('CEP').AsString);
    edtLogradouro.Text   := dmConexoes.qrEmpresa.FieldByName('LOGRADOURO').AsString;
    edtNumero.Text       := dmConexoes.qrEmpresa.FieldByName('NUMERO').AsString;
    edtComplemento.Text  := dmConexoes.qrEmpresa.FieldByName('COMPLEMENTO').AsString;
    edtBairro.Text       := dmConexoes.qrEmpresa.FieldByName('BAIRRO').AsString;
    edtCidade.Text       := dmConexoes.qrEmpresa.FieldByName('CIDADE').AsString;
    edtUF.Text           := dmConexoes.qrEmpresa.FieldByName('UF').AsString;
    edtTelefone.Text     := dmConexoes.qrEmpresa.FieldByName('TELEFONE').AsString;
    edtCelular.Text      := dmConexoes.qrEmpresa.FieldByName('CELULAR').AsString;
    edtEmail.Text        := dmConexoes.qrEmpresa.FieldByName('EMAIL').AsString;
    edtSite.Text         := dmConexoes.qrEmpresa.FieldByName('SITE').AsString;
    edtResponsavel.Text  := dmConexoes.qrEmpresa.FieldByName('RESPONSAVEL').AsString;
    edtCNAE.Text         := dmConexoes.qrEmpresa.FieldByName('CNAE').AsString;
    edtAtividade.Text    := dmConexoes.qrEmpresa.FieldByName('ATIVIDADE').AsString;
    edtSuframa.Text      := dmConexoes.qrEmpresa.FieldByName('SUFRAMA').AsString;
    if dmConexoes.qrEmpresa.FindField('EMITE_NFCE_VENDA') <> nil then
      chkEmiteNFCeVenda.Checked := dmConexoes.qrEmpresa.FieldByName('EMITE_NFCE_VENDA').AsBoolean
    else
      chkEmiteNFCeVenda.Checked := False;
    if dmConexoes.qrEmpresa.FindField('EMITE_NFE_VENDA') <> nil then
      chkEmiteNFeVenda.Checked := dmConexoes.qrEmpresa.FieldByName('EMITE_NFE_VENDA').AsBoolean
    else
      chkEmiteNFeVenda.Checked := False;

    cboRegime.ItemIndex   := dmConexoes.qrEmpresa.FieldByName('REGIME_TRIBUTARIO').AsInteger;
    cboSituacao.ItemIndex := dmConexoes.qrEmpresa.FieldByName('SITUACAO').AsInteger;
    if dmConexoes.qrEmpresa.FindField('PRINCIPAL') <> nil then
      chkPrincipal.Checked := dmConexoes.qrEmpresa.FieldByName('PRINCIPAL').AsBoolean
    else
      chkPrincipal.Checked := False;

    HabilitarEdicao(True);
    FModoEdicao := True;

  except
    on E: Exception do
      ShowMessage('Erro ao carregar empresa:' + sLineBreak + E.Message);
  end;
end;

procedure TfrmCadastroEmpresa.btnEditarClick(Sender: TObject);
begin
  if FCodigoAtual = 0 then
    CarregarPrimeiraEmpresa;

  if FCodigoAtual = 0 then
  begin
    MessageDlg('Nenhuma empresa cadastrada para editar. Clique em Novo para cadastrar.', mtInformation, [mbOK], 0);
    Exit;
  end;

  HabilitarEdicao(True);
  FModoEdicao := True;
  edtRazaoSocial.SetFocus;
end;

function TfrmCadastroEmpresa.DocumentoJaCadastrado(const ADocumento: string; out AIdEmpresa: Integer): Boolean;
var
  Qry: TADOQuery;
begin
  Result := False;
  AIdEmpresa := 0;
  if Trim(ADocumento) = '' then
    Exit;

  Qry := TADOQuery.Create(nil);
  try
    Qry.Connection := dmConexoes.conRobson;
    Qry.SQL.Text := 'SELECT TOP 1 ID_EMPRESA FROM EMPRESA WHERE CNPJ = :pCNPJ AND ID_EMPRESA <> :pID';
    Qry.Parameters.ParamByName('pCNPJ').Value := ADocumento;
    Qry.Parameters.ParamByName('pID').Value := FCodigoAtual;
    Qry.Open;
    Result := not Qry.IsEmpty;
    if Result then
      AIdEmpresa := Qry.FieldByName('ID_EMPRESA').AsInteger;
  finally
    Qry.Free;
  end;
end;

procedure TfrmCadastroEmpresa.btnGravarClick(Sender: TObject);
var
  sSQL: string;
  IdExistente: Integer;
begin
  if not ValidarCampos then Exit;

  if DocumentoJaCadastrado(SoNumeros(edtCNPJ.Text), IdExistente) then
  begin
    MessageDlg('Este CPF/CNPJ ja esta cadastrado. O cadastro existente sera carregado para edicao.', mtInformation, [mbOK], 0);
    CarregarDados(IdExistente);
    HabilitarEdicao(True);
    Exit;
  end;

  try
    if FCodigoAtual = 0 then
    begin
      FCodigoAtual := ProximoCodigo;
      sSQL :=
        'INSERT INTO EMPRESA (' +
        '  ID_EMPRESA, RAZAO_SOCIAL, NOME_FANTASIA, CNPJ,' +
        '  INSC_ESTADUAL, INSC_MUNICIPAL, REGIME_TRIBUTARIO,' +
        '  CEP, LOGRADOURO, NUMERO, COMPLEMENTO, BAIRRO, CIDADE, UF,' +
        '  TELEFONE, CELULAR, EMAIL, SITE,' +
        '  RESPONSAVEL, CNAE, ATIVIDADE, SUFRAMA, SITUACAO, PRINCIPAL, EMITE_NFCE_VENDA, EMITE_NFE_VENDA' +
        ') VALUES (' +
        '  :pID, :pRazao, :pFantasia, :pCNPJ,' +
        '  :pIE, :pIM, :pRegime,' +
        '  :pCEP, :pLogr, :pNum, :pCompl, :pBairro, :pCidade, :pUF,' +
        '  :pTel, :pCel, :pEmail, :pSite,' +
        '  :pResp, :pCNAE, :pAtiv, :pSuframa, :pSit, :pPrincipal, :pEmiteNFCeVenda, :pEmiteNFeVenda' +
        ')';
    end
    else
    begin
      sSQL :=
        'UPDATE EMPRESA SET'                         +
        '  RAZAO_SOCIAL      = :pRazao,'             +
        '  NOME_FANTASIA     = :pFantasia,'           +
        '  CNPJ              = :pCNPJ,'               +
        '  INSC_ESTADUAL     = :pIE,'                 +
        '  INSC_MUNICIPAL    = :pIM,'                 +
        '  REGIME_TRIBUTARIO = :pRegime,'             +
        '  CEP               = :pCEP,'                +
        '  LOGRADOURO        = :pLogr,'               +
        '  NUMERO            = :pNum,'                +
        '  COMPLEMENTO       = :pCompl,'              +
        '  BAIRRO            = :pBairro,'             +
        '  CIDADE            = :pCidade,'             +
        '  UF                = :pUF,'                 +
        '  TELEFONE          = :pTel,'                +
        '  CELULAR           = :pCel,'                +
        '  EMAIL             = :pEmail,'              +
        '  SITE              = :pSite,'               +
        '  RESPONSAVEL       = :pResp,'               +
        '  CNAE              = :pCNAE,'               +
        '  ATIVIDADE         = :pAtiv,'               +
        '  SUFRAMA           = :pSuframa,'            +
        '  SITUACAO          = :pSit,'                 +
        '  PRINCIPAL         = :pPrincipal,'           +
        '  EMITE_NFCE_VENDA  = :pEmiteNFCeVenda,'     +
        '  EMITE_NFE_VENDA = :pEmiteNFeVenda' +
        ' WHERE ID_EMPRESA = :pID';
    end;

    dmConexoes.qrEmpresa.Close;
    dmConexoes.qrEmpresa.SQL.Text := sSQL;

    dmConexoes.qrEmpresa.Parameters.ParamByName('pID').Value       := FCodigoAtual;
    dmConexoes.qrEmpresa.Parameters.ParamByName('pRazao').Value    := Trim(edtRazaoSocial.Text);
    dmConexoes.qrEmpresa.Parameters.ParamByName('pFantasia').Value := Trim(edtNomeFantasia.Text);
    dmConexoes.qrEmpresa.Parameters.ParamByName('pCNPJ').Value     := SoNumeros(edtCNPJ.Text);
    dmConexoes.qrEmpresa.Parameters.ParamByName('pIE').Value       := Trim(edtIE.Text);
    dmConexoes.qrEmpresa.Parameters.ParamByName('pIM').Value       := Trim(edtIM.Text);
    dmConexoes.qrEmpresa.Parameters.ParamByName('pRegime').Value   := cboRegime.ItemIndex;
    dmConexoes.qrEmpresa.Parameters.ParamByName('pCEP').Value      := SoNumeros(edtCEP.Text);
    dmConexoes.qrEmpresa.Parameters.ParamByName('pLogr').Value     := Trim(edtLogradouro.Text);
    dmConexoes.qrEmpresa.Parameters.ParamByName('pNum').Value      := Trim(edtNumero.Text);
    dmConexoes.qrEmpresa.Parameters.ParamByName('pCompl').Value    := Trim(edtComplemento.Text);
    dmConexoes.qrEmpresa.Parameters.ParamByName('pBairro').Value   := Trim(edtBairro.Text);
    dmConexoes.qrEmpresa.Parameters.ParamByName('pCidade').Value   := Trim(edtCidade.Text);
    dmConexoes.qrEmpresa.Parameters.ParamByName('pUF').Value       := Trim(edtUF.Text);
    dmConexoes.qrEmpresa.Parameters.ParamByName('pTel').Value      := SoNumeros(edtTelefone.Text);
    dmConexoes.qrEmpresa.Parameters.ParamByName('pCel').Value      := SoNumeros(edtCelular.Text);
    dmConexoes.qrEmpresa.Parameters.ParamByName('pEmail').Value    := Trim(edtEmail.Text);
    dmConexoes.qrEmpresa.Parameters.ParamByName('pSite').Value     := Trim(edtSite.Text);
    dmConexoes.qrEmpresa.Parameters.ParamByName('pResp').Value     := Trim(edtResponsavel.Text);
    dmConexoes.qrEmpresa.Parameters.ParamByName('pCNAE').Value     := Trim(edtCNAE.Text);
    dmConexoes.qrEmpresa.Parameters.ParamByName('pAtiv').Value     := Trim(edtAtividade.Text);
    dmConexoes.qrEmpresa.Parameters.ParamByName('pSuframa').Value  := Trim(edtSuframa.Text);
    dmConexoes.qrEmpresa.Parameters.ParamByName('pSit').Value      := cboSituacao.ItemIndex;
    dmConexoes.qrEmpresa.Parameters.ParamByName('pPrincipal').Value := chkPrincipal.Checked;
    dmConexoes.qrEmpresa.Parameters.ParamByName('pEmiteNFCeVenda').Value := chkEmiteNFCeVenda.Checked;
    dmConexoes.qrEmpresa.Parameters.ParamByName('pEmiteNFeVenda').Value := chkEmiteNFeVenda.Checked;

    if chkPrincipal.Checked then
    begin
      dmConexoes.qrComando.Close;
      dmConexoes.qrComando.SQL.Text := 'UPDATE EMPRESA SET PRINCIPAL = 0 WHERE ID_EMPRESA <> :pID';
      dmConexoes.qrComando.Parameters.ParamByName('pID').Value := FCodigoAtual;
      dmConexoes.qrComando.ExecSQL;
    end;

    dmConexoes.qrEmpresa.ExecSQL;

    edtCodigo.Text := IntToStr(FCodigoAtual);
    FModoEdicao    := False;
    HabilitarEdicao(False);
    ShowMessage('Empresa gravada com sucesso!');

  except
    on E: Exception do
      ShowMessage('Erro ao gravar empresa:' + sLineBreak + E.Message);
  end;
end;

procedure TfrmCadastroEmpresa.btnExcluirClick(Sender: TObject);
begin
  if FCodigoAtual = 0 then
  begin
    ShowMessage('Nenhuma empresa selecionada para exclusao.');
    Exit;
  end;

  if MessageDlg('Confirma a exclusao desta empresa?',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;

  try
    dmConexoes.qrEmpresa.Close;
    dmConexoes.qrEmpresa.SQL.Text :=
      'DELETE FROM EMPRESA WHERE ID_EMPRESA = :pCodigo';
    dmConexoes.qrEmpresa.Parameters.ParamByName('pCodigo').Value := FCodigoAtual;
    dmConexoes.qrEmpresa.ExecSQL;

    ShowMessage('Empresa excluida com sucesso!');
    LimparCampos;
    HabilitarEdicao(False);
    FModoEdicao  := False;
    FCodigoAtual := 0;

  except
    on E: Exception do
      ShowMessage('Erro ao excluir empresa:' + sLineBreak + E.Message);
  end;
end;

procedure TfrmCadastroEmpresa.btnNovoClick(Sender: TObject);
begin
  LimparCampos;
  HabilitarEdicao(True);
  FModoEdicao  := False;
  FCodigoAtual := 0;
  edtRazaoSocial.SetFocus;
end;

procedure TfrmCadastroEmpresa.btnCancelarClick(Sender: TObject);
begin
  if FCodigoAtual > 0 then
    CarregarDados(FCodigoAtual)
  else
    LimparCampos;

  HabilitarEdicao(False);
  FModoEdicao := False;
end;

procedure TfrmCadastroEmpresa.btnAnteriorClick(Sender: TObject);
begin
  NavegarEmpresa(-1);
end;

procedure TfrmCadastroEmpresa.btnProximoClick(Sender: TObject);
begin
  NavegarEmpresa(1);
end;

procedure TfrmCadastroEmpresa.btnLimparClick(Sender: TObject);
begin
  if MessageDlg('Deseja limpar todos os campos?',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    LimparCampos;
end;

// ============================================================
//  VALIDACOES E HELPERS
// ============================================================

function TfrmCadastroEmpresa.ValidarCampos: Boolean;
begin
  Result := False;

  if Trim(edtRazaoSocial.Text) = '' then
  begin
    ShowMessage('Razao Social e obrigatoria.');
    edtRazaoSocial.SetFocus;
    Exit;
  end;

  if SoNumeros(edtCNPJ.Text) = '' then
  begin
    ShowMessage('CPF/CNPJ e obrigatorio.');
    edtCNPJ.SetFocus;
    Exit;
  end;

  if (Length(SoNumeros(edtCNPJ.Text)) = 14) and (not CNPJValido(SoNumeros(edtCNPJ.Text))) then
  begin
    ShowMessage('CNPJ invalido. Verifique o numero informado.');
    edtCNPJ.SetFocus;
    Exit;
  end;

  if not (Length(SoNumeros(edtCNPJ.Text)) in [11, 14]) then
  begin
    ShowMessage('Informe CPF com 11 digitos ou CNPJ com 14 digitos.');
    edtCNPJ.SetFocus;
    Exit;
  end;

  Result := True;
end;

function TfrmCadastroEmpresa.CNPJValido(ACNPJ: string): Boolean;
var
  I, Soma, Resto, Dig1, Dig2: Integer;
  Peso1: array[1..12] of Integer;
  Peso2: array[1..12] of Integer;
begin
  Result := False;
  if Length(ACNPJ) <> 14 then Exit;

  // Rejeita sequencias invalidas (ex: 00000000000000)
  if ACNPJ = StringOfChar(ACNPJ[1], 14) then Exit;

  // Pesos do 1o digito verificador
  Peso1[1]  := 5; Peso1[2]  := 4; Peso1[3]  := 3; Peso1[4]  := 2;
  Peso1[5]  := 9; Peso1[6]  := 8; Peso1[7]  := 7; Peso1[8]  := 6;
  Peso1[9]  := 5; Peso1[10] := 4; Peso1[11] := 3; Peso1[12] := 2;

  Soma := 0;
  for I := 1 to 12 do
    Soma := Soma + StrToInt(ACNPJ[I]) * Peso1[I];
  Resto := Soma mod 11;
  if Resto < 2 then Dig1 := 0 else Dig1 := 11 - Resto;

  // Pesos do 2o digito verificador
  Peso2[1]  := 6; Peso2[2]  := 5; Peso2[3]  := 4; Peso2[4]  := 3;
  Peso2[5]  := 2; Peso2[6]  := 9; Peso2[7]  := 8; Peso2[8]  := 7;
  Peso2[9]  := 6; Peso2[10] := 5; Peso2[11] := 4; Peso2[12] := 3;

  Soma := 0;
  for I := 1 to 12 do
    Soma := Soma + StrToInt(ACNPJ[I]) * Peso2[I];
  Soma  := Soma + Dig1 * 2;
  Resto := Soma mod 11;
  if Resto < 2 then Dig2 := 0 else Dig2 := 11 - Resto;

  Result := (StrToInt(ACNPJ[13]) = Dig1) and
            (StrToInt(ACNPJ[14]) = Dig2);
end;

function TfrmCadastroEmpresa.SoNumeros(ATexto: string): string;
var
  C: Char;
begin
  Result := '';
  for C in ATexto do
    if CharInSet(C, ['0'..'9']) then
      Result := Result + C;
end;

function TfrmCadastroEmpresa.FormatarCNPJ(ACNPJ: string): string;
var
  N: string;
begin
  N := SoNumeros(ACNPJ);
  if Length(N) = 11 then
    Result := Copy(N,1,3) + '.' + Copy(N,4,3) + '.' + Copy(N,7,3) + '-' + Copy(N,10,2)
  else if Length(N) = 14 then
    Result := Copy(N,1,2) + '.' + Copy(N,3,3) + '.' + Copy(N,6,3) + '/' +
              Copy(N,9,4) + '-' + Copy(N,13,2)
  else
    Result := ACNPJ;
end;
function TfrmCadastroEmpresa.FormatarCEP(ACEP: string): string;
var
  N: string;
begin
  N := SoNumeros(ACEP);
  if Length(N) = 8 then
    Result := Copy(N,1,5) + '-' + Copy(N,6,3)
  else
    Result := ACEP;
end;

procedure TfrmCadastroEmpresa.BuscarEnderecoPorCEP;
var
  Http: THTTPClient;
  Resp: IHTTPResponse;
  JsonValue: TJSONValue;
  JsonObj: TJSONObject;
  CEP, Conteudo: string;

  function ValorJSON(const ANome: string): string;
  var
    V: TJSONValue;
  begin
    Result := '';
    V := JsonObj.GetValue(ANome);
    if V <> nil then
      Result := Trim(V.Value);
  end;

begin
  CEP := SoNumeros(edtCEP.Text);
  if Length(CEP) <> 8 then
    Exit;

  Http := THTTPClient.Create;
  try
    try
      Http.ConnectionTimeout := 5000;
      Http.ResponseTimeout := 5000;
      Resp := Http.Get('https://viacep.com.br/ws/' + CEP + '/json/');
      if Resp.StatusCode <> 200 then
        Exit;

      Conteudo := Resp.ContentAsString(TEncoding.UTF8);
      JsonValue := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(Conteudo), 0);
      try
        if not (JsonValue is TJSONObject) then
          Exit;

        JsonObj := TJSONObject(JsonValue);
        if SameText(ValorJSON('erro'), 'true') then
        begin
          MessageDlg('CEP nao encontrado.', mtWarning, [mbOK], 0);
          Exit;
        end;

        edtLogradouro.Text := ValorJSON('logradouro');
        edtBairro.Text := ValorJSON('bairro');
        edtCidade.Text := ValorJSON('localidade');
        edtUF.Text := ValorJSON('uf');

        if edtLogradouro.Text <> '' then
          edtNumero.SetFocus;
      finally
        JsonValue.Free;
      end;
    except
      on E: Exception do
        MessageDlg('Nao foi possivel consultar o CEP.' + sLineBreak + E.Message, mtWarning, [mbOK], 0);
    end;
  finally
    Http.Free;
  end;
end;

procedure TfrmCadastroEmpresa.edtCEPExit(Sender: TObject);
begin
  edtCEP.Text := FormatarCEP(edtCEP.Text);
  BuscarEnderecoPorCEP;
end;

procedure TfrmCadastroEmpresa.edtCNPJExit(Sender: TObject);
begin
  edtCNPJ.Text := FormatarCNPJ(edtCNPJ.Text);
end;

procedure TfrmCadastroEmpresa.LimparCampos;
begin
  edtCodigo.Text       := '';
  edtRazaoSocial.Text  := '';
  edtNomeFantasia.Text := '';
  edtCNPJ.Text         := '';
  edtIE.Text           := '';
  edtIM.Text           := '';
  edtCEP.Text          := '';
  edtLogradouro.Text   := '';
  edtNumero.Text       := '';
  edtComplemento.Text  := '';
  edtBairro.Text       := '';
  edtCidade.Text       := '';
  edtUF.Text           := '';
  edtTelefone.Text     := '';
  edtCelular.Text      := '';
  edtEmail.Text        := '';
  edtSite.Text         := '';
  edtCNAE.Text         := '';
  edtAtividade.Text    := '';
  edtSuframa.Text      := '';
  chkEmiteNFCeVenda.Checked := False;
  chkEmiteNFeVenda.Checked := False;
  cboRegime.ItemIndex   := 0;
  cboSituacao.ItemIndex := 0;
  chkPrincipal.Checked := False;
  FCodigoAtual := 0;
end;

procedure TfrmCadastroEmpresa.HabilitarEdicao(AHabilitar: Boolean);
begin
  edtRazaoSocial.ReadOnly  := not AHabilitar;
  edtNomeFantasia.ReadOnly := not AHabilitar;
  edtCNPJ.ReadOnly         := not AHabilitar;
  edtIE.ReadOnly           := not AHabilitar;
  edtIM.ReadOnly           := not AHabilitar;
  edtCEP.ReadOnly          := not AHabilitar;
  edtLogradouro.ReadOnly   := not AHabilitar;
  edtNumero.ReadOnly       := not AHabilitar;
  edtComplemento.ReadOnly  := not AHabilitar;
  edtBairro.ReadOnly       := not AHabilitar;
  edtCidade.ReadOnly       := not AHabilitar;
  edtUF.ReadOnly           := not AHabilitar;
  edtTelefone.ReadOnly     := not AHabilitar;
  edtCelular.ReadOnly      := not AHabilitar;
  edtEmail.ReadOnly        := not AHabilitar;
  edtSite.ReadOnly         := not AHabilitar;
  edtResponsavel.ReadOnly  := not AHabilitar;
  edtCNAE.ReadOnly         := not AHabilitar;
  edtAtividade.ReadOnly    := not AHabilitar;
  edtSuframa.ReadOnly      := not AHabilitar;
  chkEmiteNFCeVenda.Enabled := AHabilitar;
  chkEmiteNFeVenda.Enabled := AHabilitar;

  cboRegime.Enabled    := AHabilitar;
  cboSituacao.Enabled  := AHabilitar;
  chkPrincipal.Enabled := AHabilitar;

  btnAnterior.Enabled := not AHabilitar;
  btnProximo.Enabled  := not AHabilitar;
  btnEditar.Enabled   := (not AHabilitar) and (FCodigoAtual > 0);
  btnGravar.Enabled   := AHabilitar;
  btnExcluir.Enabled  := AHabilitar and (FCodigoAtual > 0);
  btnLimpar.Enabled   := AHabilitar;
  btnCancelar.Enabled := AHabilitar;
end;

// ============================================================
//  METODO PUBLICO
// ============================================================

procedure TfrmCadastroEmpresa.CarregarEmpresa(ACodigo: Integer);
begin
  CarregarDados(ACodigo);
end;

end.
