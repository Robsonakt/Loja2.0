unit untCadastroProd;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.WinXPickers, Vcl.StdCtrls, Vcl.Mask,
  Vcl.ExtCtrls, Vcl.DBCtrls;

type
  TfrmCadastroProdutos = class(TForm)
    Panel1: TPanel;
    PnNovo: TPanel;
    PnEditar: TPanel;
    PnCancelar: TPanel;
    PnExcluir: TPanel;
    PnGravar: TPanel;
    PnPrimeiro: TPanel;
    PnAnterior: TPanel;
    PnProximo: TPanel;
    PnUltimo: TPanel;
    PnSair: TPanel;
    PnRelatorio: TPanel;
    PnCentro: TPanel;
    LbCodProd: TLabel;
    Lbdatacadastroproduto: TLabel;
    Lbnomeproduto: TLabel;
    lbQuant: TLabel;
    lbTipo: TLabel;
    lbvalorproduto: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    edtDescricaoProd: TDBEdit;
    edtBarras: TDBEdit;
    edtValorCusto: TDBEdit;
    EdtValorVend: TDBEdit;
    edtQuantProd: TDBEdit;
    edtTipo: TComboBox;
    edtDatacri: TDatePicker;
    edtCodProd: TDBEdit;
    procedure PnNovoMouseLeave(Sender: TObject);
    procedure PnNovoMouseEnter(Sender: TObject);
    procedure PnNovoClick(Sender: TObject);
    procedure PnEditarClick(Sender: TObject);
    procedure PnCancelarClick(Sender: TObject);
    procedure PnExcluirClick(Sender: TObject);
    procedure PnGravarClick(Sender: TObject);
    procedure PnPrimeiroClick(Sender: TObject);
    procedure PnAnteriorClick(Sender: TObject);
    procedure PnProximoClick(Sender: TObject);
    procedure PnUltimoClick(Sender: TObject);
    procedure PnRelatorioClick(Sender: TObject);
    procedure PnSairClick(Sender: TObject);
    procedure FormMouseLeave(Sender: TObject);
    procedure PnCancelarMouseEnter(Sender: TObject);
    procedure PnExcluirMouseEnter(Sender: TObject);
    procedure PnGravarMouseEnter(Sender: TObject);
    procedure PnEditarMouseEnter(Sender: TObject);
    procedure PnEditarMouseLeave(Sender: TObject);
    procedure PnCancelarMouseLeave(Sender: TObject);
    procedure PnExcluirMouseLeave(Sender: TObject);
    procedure PnGravarMouseLeave(Sender: TObject);
    procedure PnPrimeiroMouseEnter(Sender: TObject);
    procedure PnPrimeiroMouseLeave(Sender: TObject);
    procedure PnAnteriorMouseEnter(Sender: TObject);
    procedure PnAnteriorMouseLeave(Sender: TObject);
    procedure PnProximoMouseEnter(Sender: TObject);
    procedure PnProximoMouseLeave(Sender: TObject);
    procedure PnUltimoMouseEnter(Sender: TObject);
    procedure PnUltimoMouseLeave(Sender: TObject);
    procedure PnRelatorioMouseEnter(Sender: TObject);
    procedure PnRelatorioMouseLeave(Sender: TObject);
    procedure PnSairMouseEnter(Sender: TObject);
    procedure PnSairMouseLeave(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCadastroProdutos: TfrmCadastroProdutos;

implementation

{$R *.dfm}

uses dmconexao, untRelatorioProd;

procedure TfrmCadastroProdutos.FormMouseLeave(Sender: TObject);
begin
  TPanel(Sender).Color := $00333333;
  TPanel(sender).Font.Color :=clWhite;
end;

procedure TfrmCadastroProdutos.FormShow(Sender: TObject);
begin
      with dmConexoes do
  begin
    qrEstoque.close;
    qrEstoque.sql.clear;
    qrEstoque.sql.Add('SELECT * FROM [LojaNova].[dbo].[PRODUTOS]');
    qrEstoque.open;
    qrEstoque.First;

  end;

end;

procedure TfrmCadastroProdutos.PnAnteriorClick(Sender: TObject);
begin
     with dmConexoes.qrEstoque do
  begin
    if not Bof then
      Prior // Retrocede para o registro anterior
    else
      ShowMessage('Primeiro registro!');
  end;
end;

procedure TfrmCadastroProdutos.PnAnteriorMouseEnter(Sender: TObject);
begin
   TPanel(sender).Color :=$00333333;
 TPanel(sender).Font.Color :=clWhite;
end;

procedure TfrmCadastroProdutos.PnAnteriorMouseLeave(Sender: TObject);
begin
    Tpanel(sender).Color :=$00666666;
  TPanel(sender).Font.Color :=0;
end;

procedure TfrmCadastroProdutos.PnCancelarClick(Sender: TObject);
begin

  with dmConexoes do
    begin
      qrEstoque.close;
      qrEstoque.sql.clear;
      qrEstoque.sql.Add('SELECT * FROM [LojaNova].[dbo].[ProdutoS]');
      qrEstoque.open;
      qrEstoque.First;

    end;

    begin
       MessageDlg('Cadastro cancelado', mtInformation, [mbOK], 0);
    end;

          PnEditar.Enabled     := true  ;
          PnExcluir.Enabled    := true  ;
          PnPrimeiro.Enabled   := true  ;
          PnAnterior.Enabled   := true  ;
          PnProximo.Enabled    := true  ;
          PnUltimo.Enabled     := true  ;
          PnRelatorio.Enabled  := true  ;
          PnCancelar.Enabled   := true  ;
          PnSair.Enabled       := true  ;
          PnGravar.Enabled     := false ;

          PnEditar.Font.Color      := 0;
          PnExcluir.Font.Color     := 0;
          PnPrimeiro.Font.Color    := 0;
          PnAnterior.Font.Color    := 0;
          PnProximo.Font.Color     := 0;
          PnUltimo.Font.Color      := 0;
          PnSair.Font.Color        := 0;
          PnRelatorio.Font.Color   := 0;
          PnGravar.Font.Color      := $00333333;

          edtDescricaoProd.Enabled := false;
          edtBarras.Enabled        := false;
          edtValorCusto.Enabled    := false;
          EdtValorVend.Enabled     := false;
          edtTipo.Enabled          := false;
          edtQuantProd.Enabled     := false;
          edtDatacri.Enabled       := false;
end;

procedure TfrmCadastroProdutos.PnCancelarMouseEnter(Sender: TObject);
begin
   TPanel(sender).Color :=$00333333;
 TPanel(sender).Font.Color :=clWhite;
end;

procedure TfrmCadastroProdutos.PnCancelarMouseLeave(Sender: TObject);
begin
  Tpanel(sender).Color :=$00666666;
  TPanel(sender).Font.Color :=0;
end;

procedure TfrmCadastroProdutos.PnEditarClick(Sender: TObject);
begin
  // Habilita/Desabilita campos
  edtDescricaoProd.Enabled := true;
  edtBarras.Enabled := true;
  edtQuantProd.Enabled := true;
  edtValorCusto.Enabled := true;
  EdtValorVend.Enabled := true;
  edtTipo.Enabled := true;
  edtDataCri.Enabled := true;

  // Configura botões de ação
  PnGravar.Enabled := true;
  PnCancelar.Enabled := true;
  PnGravar.Font.Color := 0; // Preto
  PnCancelar.Font.Color := 0; // Preto

  // Desabilita PnEditar e configura cores
  PnEditar.Font.Color     := $00333333;
  PnExcluir.Font.Color    := $00333333;
  PnPrimeiro.Font.Color   := $00333333;
  PnAnterior.Font.Color   := $00333333;
  PnProximo.Font.Color    := $00333333;
  PnUltimo.Font.Color     := $00333333;
  PnRelatorio.Font.color  := $00333333; // Depois desabilita

  // Outros componentes (verifique se há lógica faltando aqui)
  PnEditar.Enabled    := false;
  PnExcluir.Enabled   := false;
  PnPrimeiro.Enabled  := false;
  PnAnterior.Enabled  := false;
  PnProximo.Enabled   := false;
  PnUltimo.Enabled    := false;
  PnRelatorio.Enabled := false;
end;

procedure TfrmCadastroProdutos.PnEditarMouseEnter(Sender: TObject);
begin
   TPanel(sender).Color :=$00333333;
 TPanel(sender).Font.Color :=clWhite;
end;

procedure TfrmCadastroProdutos.PnEditarMouseLeave(Sender: TObject);
begin
  Tpanel(sender).Color :=$00666666;
  TPanel(sender).Font.Color :=0;
end;

procedure TfrmCadastroProdutos.PnExcluirClick(Sender: TObject);
begin
   if MessageDlg('Deseja excluir este registro?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    try
      // Exclui o registro atual diretamente
      dmConexoes.qrEstoque.Delete;
      ShowMessage('Registro excluído com sucesso!');
    except
      on E: Exception do
        ShowMessage('Erro ao excluir: ' + E.Message);
    end;
  end;
end;

procedure TfrmCadastroProdutos.PnExcluirMouseEnter(Sender: TObject);
begin
 TPanel(sender).Color :=$00333333;
 TPanel(sender).Font.Color :=clWhite;
end;

procedure TfrmCadastroProdutos.PnExcluirMouseLeave(Sender: TObject);
begin
  Tpanel(sender).Color :=$00666666;
  TPanel(sender).Font.Color :=0;
end;

procedure TfrmCadastroProdutos.PnGravarClick(Sender: TObject);
begin
    application.MessageBox('Deseja gravar o produto ?','Cadastro  ',mb_ok+MB_ICONINFORMATION);
    edtBarras.Enabled := false;
    edtDescricaoProd.Enabled := false;
    edtValorCusto.Enabled := false;
    EdtValorVend.Enabled := false;
    edtQuantProd.Enabled := false;
    edtTipo.Enabled := false;

 with dmConexoes do
  begin

              qrEstoque.FieldByName('tipo').asstring                              := trim(edtTipo.Text);
              qrEstoque.FieldByName('data').AsDateTime                            := edtDatacri.Date;
              qrEstoque.post;

              application.MessageBox('Produto Cadastrado com Sucesso','Cadastro  ',mb_ok+MB_ICONINFORMATION);

end;

  // Configura botões de ação
  PnGravar.Enabled := false;
  PnCancelar.Enabled := true;
  PnGravar.Font.Color := 0; // Preto
  PnCancelar.Font.Color := 0; // Preto
  PnPrimeiro.Font.Color := 0; // Preto
  PnAnterior.Font.Color := 0; // Preto
  PnProximo.Font.Color := 0; // Preto
  PnUltimo.Font.Color := 0; // Preto
  PnRelatorio.Font.Color := 0; // Preto


  // Outros componentes (verifique se há lógica faltando aqui)
  PnEditar.Enabled    := true;
  PnExcluir.Enabled   := true;
  PnPrimeiro.Enabled  := true;
  PnAnterior.Enabled  := true;
  PnProximo.Enabled   := true;
  PnUltimo.Enabled    := true;
  PnRelatorio.Enabled := true;
  PnSair.Enabled      := true;
end;

procedure TfrmCadastroProdutos.PnGravarMouseEnter(Sender: TObject);
begin
  TPanel(sender).Color :=$00333333;
  TPanel(sender).Font.Color :=clWhite;
end;

procedure TfrmCadastroProdutos.PnGravarMouseLeave(Sender: TObject);
begin
  Tpanel(sender).Color :=$00666666;
  TPanel(sender).Font.Color :=0;
end;

procedure TfrmCadastroProdutos.PnNovoClick(Sender: TObject);
begin
      with dmConexoes do
  begin
    qrEstoque.close;
    qrEstoque.sql.clear;
    qrEstoque.sql.Add('SELECT * FROM [LojaNova].[dbo].[PRODUTOS]');
    qrEstoque.open;
    qrEstoque.First;


    qrEstoque.Insert;
  end;


  PnEditar.Enabled      := not PnEditar.Enabled ;
  PnExcluir.Enabled     := not PnExcluir.Enabled ;
  PnPrimeiro.Enabled    := not PnPrimeiro.Enabled ;
  PnAnterior.Enabled    := not PnAnterior.Enabled ;
  PnProximo.Enabled     := not PnProximo.Enabled ;
  PnUltimo.Enabled      := not PnUltimo.Enabled ;
  PnSair.Enabled        := not PnSair.Enabled ;
  PnRelatorio.Enabled   := not PnRelatorio.Enabled ;
  PnGravar.Enabled      := not PnGravar.Enabled ;
  PnCancelar.Enabled    := True;


  PnEditar.Font.Color      := $00333333;
  PnExcluir.Font.Color     := $00333333;
  PnPrimeiro.Font.Color    := $00333333;
  PnAnterior.Font.Color    := $00333333;
  PnProximo.Font.Color     := $00333333;
  PnUltimo.Font.Color      := $00333333;
  PnSair.Font.Color        := $00333333;
  PnRelatorio.Font.Color   := $00333333;
  PnCancelar.Font.Color    :=0;
  PnGravar.Font.Color      :=0;


  edtDescricaoProd.Enabled := not edtDescricaoProd.Enabled ;
  edtBarras.Enabled        := not edtBarras.Enabled ;
  edtQuantProd.Enabled     := not edtQuantProd.Enabled ;
  edtValorCusto.Enabled    := not edtValorCusto.Enabled ;
  EdtValorVend.Enabled     := not EdtValorVend.Enabled ;
  edtTipo.Enabled          := not edtTipo.Enabled ;
  edtDataCri.Enabled       := not edtDataCri.Enabled ;

  begin
    edtBarras.SetFocus;
  end;
end;

procedure TfrmCadastroProdutos.PnNovoMouseEnter(Sender: TObject);
begin
 TPanel(sender).Color :=$00333333;
 TPanel(sender).Font.Color :=clWhite;
end;

procedure TfrmCadastroProdutos.PnNovoMouseLeave(Sender: TObject);
begin
  Tpanel(sender).Color :=$00666666;
  TPanel(sender).Font.Color :=0;
end;

procedure TfrmCadastroProdutos.PnPrimeiroClick(Sender: TObject);
begin
   dmConexoes.qrEstoque.First;
end;

procedure TfrmCadastroProdutos.PnPrimeiroMouseEnter(Sender: TObject);
begin
   TPanel(sender).Color :=$00333333;
 TPanel(sender).Font.Color :=clWhite;

end;

procedure TfrmCadastroProdutos.PnPrimeiroMouseLeave(Sender: TObject);
begin
    Tpanel(sender).Color :=$00666666;
  TPanel(sender).Font.Color :=0;
end;

procedure TfrmCadastroProdutos.PnProximoClick(Sender: TObject);
begin
   with dmConexoes.qrEstoque do
  begin
    if not Eof then
      Next // Move para o próximo registro
    else
      ShowMessage('Último registro!');
  end;
end;

procedure TfrmCadastroProdutos.PnProximoMouseEnter(Sender: TObject);
begin
   TPanel(sender).Color :=$00333333;
 TPanel(sender).Font.Color :=clWhite;
end;

procedure TfrmCadastroProdutos.PnProximoMouseLeave(Sender: TObject);
begin
   Tpanel(sender).Color :=$00666666;
  TPanel(sender).Font.Color :=0;
end;

procedure TfrmCadastroProdutos.PnRelatorioClick(Sender: TObject);
begin
  with dmconexoes do
  begin
   qrEstoque.Close  ;
   qrEstoque.SQL.Clear;
   qrEstoque.SQL.Add('SELECT * FROM [LojaNova].[dbo].[PRODUTOS]');
   qrEstoque.Open;

   FrmRelatorioProd := TFrmRelatorioProd.Create(self);
   FrmRelatorioProd.rlr_RelatorioProdutos.Preview();
  end;
end;

procedure TfrmCadastroProdutos.PnRelatorioMouseEnter(Sender: TObject);
begin
    TPanel(sender).Color :=$00333333;
 TPanel(sender).Font.Color :=clWhite;
end;

procedure TfrmCadastroProdutos.PnRelatorioMouseLeave(Sender: TObject);
begin
    Tpanel(sender).Color :=$00666666;
  TPanel(sender).Font.Color :=0;
end;

procedure TfrmCadastroProdutos.PnSairClick(Sender: TObject);
begin
 close;
end;

procedure TfrmCadastroProdutos.PnSairMouseEnter(Sender: TObject);
begin
  TPanel(sender).Color :=$00333333;
 TPanel(sender).Font.Color :=clWhite;
end;

procedure TfrmCadastroProdutos.PnSairMouseLeave(Sender: TObject);
begin
    Tpanel(sender).Color :=$00666666;
  TPanel(sender).Font.Color :=0;
end;

procedure TfrmCadastroProdutos.PnUltimoClick(Sender: TObject);
begin
   dmConexoes.qrEstoque.Last;
end;

procedure TfrmCadastroProdutos.PnUltimoMouseEnter(Sender: TObject);
begin
   TPanel(sender).Color :=$00333333;
 TPanel(sender).Font.Color :=clWhite;

end;

procedure TfrmCadastroProdutos.PnUltimoMouseLeave(Sender: TObject);
begin
   Tpanel(sender).Color :=$00666666;
  TPanel(sender).Font.Color :=0
end;

end.
