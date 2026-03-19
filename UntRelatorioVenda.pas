unit UntRelatorioVenda;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, RLReport;

type
  TfrmRelatorioVendas = class(TForm)
    rlr_RelatorioVendas: TRLReport;
    RLBand_Cabecalho: TRLBand;
    RLSystemInfo1: TRLSystemInfo;
    RLLabel_Cabecalho: TRLLabel;
    RLSystemInfo2: TRLSystemInfo;
    RLBand1: TRLBand;
    RLLabel1: TRLLabel;
    RLLabel2: TRLLabel;
    RLLabel5: TRLLabel;
    RLBand2: TRLBand;
    RLDBText1: TRLDBText;
    RLDBText2: TRLDBText;
    RLDBText5: TRLDBText;
    RLSubDetail1: TRLSubDetail;
    RLBand_Sumario: TRLBand;
    RLLabel_TotQtd: TRLLabel;
    RLLabel_QtdVendas: TRLLabel;
    RLLabel_TotValor: TRLLabel;
    RLLabel_ValorTotal: TRLLabel;
  private
    { Private declarations }
  public
    procedure SetTotais(AQtd: Integer; AValor: Currency);
  end;

var
  frmRelatorioVendas: TfrmRelatorioVendas;

implementation

{$R *.dfm}
uses
  untCadastroProd, untVenda, dmconexao, untCadastroUsuario, untLogUser, untConsultaVendas;

procedure TfrmRelatorioVendas.SetTotais(AQtd: Integer; AValor: Currency);
begin
  RLLabel_QtdVendas.Caption := IntToStr(AQtd);
  RLLabel_ValorTotal.Caption := FormatFloat('#,##0.00', AValor);
end;

end.
