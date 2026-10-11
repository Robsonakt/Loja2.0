program ProjetoLoja;

uses
  Vcl.Forms,
  untInicial in 'untInicial.pas' {FormularioPrincipal},
  dmconexao in 'dmconexao.pas' {dmConexoes: TDataModule},
  uFiscalNFeEntradaHelper in 'uFiscalNFeEntradaHelper.pas',
  uFiscalStorage in 'uFiscalStorage.pas',
  untEntradaNotasXML in 'untEntradaNotasXML.pas',
  untConsultaXML in 'untConsultaXML.pas',
  untEmissaoXML in 'untEmissaoXML.pas',
  uEmailSMTP in 'uEmailSMTP.pas',
  uOrcamentoPDF in 'uOrcamentoPDF.pas',
  uEmpresaConfig in 'uEmpresaConfig.pas',
  uAjusteTela in 'uAjusteTela.pas',
  untCadastroProd in 'untCadastroProd.pas' {frmCadastroProdutos},
  untVenda in 'untVenda.pas' {frmCaixaVendas},
  untConsultaVendas in 'untConsultaVendas.pas' {frmConsulta_Venda},
  UntRelatorioVenda in 'UntRelatorioVenda.pas' {frmRelatorioVendas},
  untRelatorioProd in 'untRelatorioProd.pas' {FrmRelatorioProd},
  untCadastroCli in 'untCadastroCli.pas' {frmCadastroCliente},
  untCadastroEmpresa in 'untCadastroEmpresa.pas' {frmCadastroEmpresa},
  untLocalizaCli in 'untLocalizaCli.pas' {frmLocalizaCli},
  untLocalizaProd in 'untLocalizaProd.pas' {frmLocalizaProd},
  untLogUser in 'untLogUser.pas' {frmLogin},
  untCadastroUsuario in 'untCadastroUsuario.pas' {FrmCadastroUsuario},
  untconsultaFiado in 'untconsultaFiado.pas' {consulta_vendas},
  untOrcamento in 'untOrcamento.pas' {Form1},
  UntRelatorioOrcamento in 'UntRelatorioOrcamento.pas' {Form2},
  untConsultaOrcamento in 'untConsultaOrcamento.pas' {ConsultaOrcamento},
  untConsultaFechamento in 'untConsultaFechamento.pas' {frmConsultaFechamento},
  untLicenca in 'untLicenca.pas' {frmLicenca};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  // Reduz automaticamente as janelas que nao cabem em monitores menores
  TAjusteTela.Ativar;
  // As demais telas sao criadas quando abertas (evita instancias duplicadas)
  Application.CreateForm(TFormularioPrincipal, FormularioPrincipal);
  Application.CreateForm(TdmConexoes, dmConexoes);
  Application.Run;
end.
