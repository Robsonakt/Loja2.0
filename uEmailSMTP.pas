unit uEmailSMTP;

interface

uses
  System.SysUtils;

type
  TEmailSMTP = class
  public
    class function EmailValido(const Email: string): Boolean; static;
    class procedure EnviarEmailComAnexo(const Destinatario, Assunto, Corpo, CaminhoAnexo: string); static;
  end;

implementation

uses
  ComObj,
  System.Variants,
  System.IniFiles;

const
  SMTP_HOST = 'smtp.gmail.com';
  SMTP_BUSINESS_NAME = 'BlackSolutions';
  CDO_CONFIG = 'http://schemas.microsoft.com/cdo/configuration/';

// Usuario e senha do SMTP ficam no config.ini (secao [Email]), fora do Git.
function LerConfigEmail(const Chave: string): string;
var
  INI: TIniFile;
begin
  INI := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'config.ini');
  try
    Result := Trim(INI.ReadString('Email', Chave, ''));
  finally
    INI.Free;
  end;
end;

class function TEmailSMTP.EmailValido(const Email: string): Boolean;
var
  PArroba, PPonto: Integer;
  Valor: string;
begin
  Valor := Trim(Email);
  PArroba := Pos('@', Valor);
  PPonto := LastDelimiter('.', Valor);
  Result := (Valor <> '') and (PArroba > 1) and (PPonto > PArroba + 1) and (PPonto < Length(Valor));
end;

class procedure TEmailSMTP.EnviarEmailComAnexo(const Destinatario, Assunto, Corpo, CaminhoAnexo: string);

  procedure EnviarCDO(APorta: Integer; AUsarSSL: Boolean);
  var
    Msg: OleVariant;
    Config: OleVariant;
    Fields: OleVariant;
  begin
    Msg := CreateOleObject('CDO.Message');
    Config := CreateOleObject('CDO.Configuration');
    Fields := Config.Fields;

    Fields.Item[CDO_CONFIG + 'sendusing'] := 2;
    Fields.Item[CDO_CONFIG + 'smtpserver'] := SMTP_HOST;
    Fields.Item[CDO_CONFIG + 'smtpserverport'] := APorta;
    Fields.Item[CDO_CONFIG + 'smtpauthenticate'] := 1;
    Fields.Item[CDO_CONFIG + 'sendusername'] := LerConfigEmail('Usuario');
    Fields.Item[CDO_CONFIG + 'sendpassword'] := LerConfigEmail('Senha');
    Fields.Item[CDO_CONFIG + 'smtpusessl'] := AUsarSSL;
    Fields.Item[CDO_CONFIG + 'smtpconnectiontimeout'] := 60;
    Fields.Update;

    Msg.Configuration := Config;
    Msg.From := '"' + SMTP_BUSINESS_NAME + '" <' + LerConfigEmail('Usuario') + '>';
    Msg.To := Destinatario;
    Msg.Subject := Assunto;
    Msg.TextBody := Corpo;

    if (Trim(CaminhoAnexo) <> '') and FileExists(CaminhoAnexo) then
      Msg.AddAttachment(CaminhoAnexo);

    Msg.Send;
  end;

var
  Erro465: string;
  Erro587: string;
begin
  if (LerConfigEmail('Usuario') = '') or (LerConfigEmail('Senha') = '') then
    raise Exception.Create('Configure a secao [Email] (Usuario e Senha) no config.ini.');

  if not EmailValido(Destinatario) then
    raise Exception.Create('E-mail invalido. Confira o endereco antes de enviar.');

  try
    EnviarCDO(465, True);
    Exit;
  except
    on E: Exception do
      Erro465 := E.Message;
  end;

  try
    EnviarCDO(587, True);
    Exit;
  except
    on E: Exception do
      Erro587 := E.Message;
  end;

  raise Exception.Create('Falha no SMTP Gmail. Porta 465: ' + Erro465 +
    ' | Porta 587: ' + Erro587);
end;

end.