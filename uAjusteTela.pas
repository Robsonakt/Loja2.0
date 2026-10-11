unit uAjusteTela;

// Ajusta automaticamente o tamanho das janelas em monitores menores
// (ex.: 19" em 1366x768). Se uma janela nao couber na area util da tela,
// ela e reduzida proporcionalmente (controles e fontes) e centralizada.
// Em monitores maiores nada muda.

interface

uses
  System.Classes, Vcl.Forms;

type
  TAjusteTela = class
  private
    class var FInstancia: TAjusteTela;
    procedure ActiveFormChange(Sender: TObject);
  public
    class procedure Ativar;
    class procedure AjustarForm(AForm: TCustomForm);
  end;

implementation

uses
  System.SysUtils, System.Types, System.Math, Vcl.Controls;

const
  MARCA_AJUSTADO = 'AjusteTelaAplicado';
  MARGEM = 8; // folga em pixels em relacao a borda da tela

type
  TFormAcesso = class(TCustomForm);

class procedure TAjusteTela.Ativar;
begin
  if FInstancia = nil then
    FInstancia := TAjusteTela.Create;
  Screen.OnActiveFormChange := FInstancia.ActiveFormChange;
end;

procedure TAjusteTela.ActiveFormChange(Sender: TObject);
begin
  if Screen.ActiveCustomForm <> nil then
    TAjusteTela.AjustarForm(Screen.ActiveCustomForm);
end;

class procedure TAjusteTela.AjustarForm(AForm: TCustomForm);
var
  Area: TRect;
  LargDisp, AltDisp: Integer;
  Fator: Double;
  Marca: TComponent;
begin
  if (AForm = nil) or (csDesigning in AForm.ComponentState) then
    Exit;

  // Ajusta cada janela uma unica vez
  if AForm.FindComponent(MARCA_AJUSTADO) <> nil then
    Exit;
  Marca := TComponent.Create(AForm);
  Marca.Name := MARCA_AJUSTADO;

  // Janelas maximizadas e telas internas dos relatorios (Fortes) nao sao alteradas
  if AForm.WindowState = wsMaximized then
    Exit;
  if AForm.ClassName.StartsWith('TRL') then
    Exit;

  Area := AForm.Monitor.WorkareaRect;
  LargDisp := Area.Width - MARGEM;
  AltDisp  := Area.Height - MARGEM;

  if (AForm.Width <= LargDisp) and (AForm.Height <= AltDisp) then
  begin
    // Cabe na tela: so garante que nao fique para fora
    if AForm.Left + AForm.Width > Area.Right then
      AForm.Left := Max(Area.Left, Area.Right - AForm.Width);
    if AForm.Top + AForm.Height > Area.Bottom then
      AForm.Top := Max(Area.Top, Area.Bottom - AForm.Height);
    Exit;
  end;

  // Nao cabe: reduz proporcionalmente
  Fator := Min(LargDisp / AForm.Width, AltDisp / AForm.Height);
  if Fator < 0.6 then
    Fator := 0.6; // limite para a letra nao ficar ilegivel

  AForm.Constraints.MinWidth  := 0;
  AForm.Constraints.MinHeight := 0;
  TFormAcesso(AForm).ScaleBy(Round(Fator * 1000), 1000);

  // Garante que caiba (bordas e titulo nao sao escalados)
  if AForm.Width > LargDisp then
    AForm.Width := LargDisp;
  if AForm.Height > AltDisp then
    AForm.Height := AltDisp;

  // Se ainda faltar espaco, permite rolar em vez de cortar
  TFormAcesso(AForm).AutoScroll := True;

  // Centraliza na area util
  AForm.Left := Area.Left + (Area.Width - AForm.Width) div 2;
  AForm.Top  := Area.Top + (Area.Height - AForm.Height) div 2;
end;

initialization

finalization
  FreeAndNil(TAjusteTela.FInstancia);

end.
