unit uOrcamentoPDF;

interface

uses
  System.SysUtils,
  Data.DB;

type
  TOrcamentoPDF = class
  public
    class procedure Gerar(const AArquivoPDF, AEmpresaTitulo, ANumero, ACliente, AVendedor, AValidade, AObs: string;
      AQtdItens: Integer; ATotalProdutos, AMaoObra, ATotalGeral: Currency; AItens: TDataSet); static;
  end;

implementation

uses
  System.Classes;

function LimparTextoPDF(const S: string): string;
var
  I: Integer;
  C: Char;
begin
  Result := S;
  Result := StringReplace(Result, 'á', 'a', [rfReplaceAll]);
  Result := StringReplace(Result, 'à', 'a', [rfReplaceAll]);
  Result := StringReplace(Result, 'ã', 'a', [rfReplaceAll]);
  Result := StringReplace(Result, 'â', 'a', [rfReplaceAll]);
  Result := StringReplace(Result, 'é', 'e', [rfReplaceAll]);
  Result := StringReplace(Result, 'ê', 'e', [rfReplaceAll]);
  Result := StringReplace(Result, 'í', 'i', [rfReplaceAll]);
  Result := StringReplace(Result, 'ó', 'o', [rfReplaceAll]);
  Result := StringReplace(Result, 'õ', 'o', [rfReplaceAll]);
  Result := StringReplace(Result, 'ô', 'o', [rfReplaceAll]);
  Result := StringReplace(Result, 'ú', 'u', [rfReplaceAll]);
  Result := StringReplace(Result, 'ç', 'c', [rfReplaceAll]);
  Result := StringReplace(Result, 'Á', 'A', [rfReplaceAll]);
  Result := StringReplace(Result, 'À', 'A', [rfReplaceAll]);
  Result := StringReplace(Result, 'Ã', 'A', [rfReplaceAll]);
  Result := StringReplace(Result, 'Â', 'A', [rfReplaceAll]);
  Result := StringReplace(Result, 'É', 'E', [rfReplaceAll]);
  Result := StringReplace(Result, 'Ê', 'E', [rfReplaceAll]);
  Result := StringReplace(Result, 'Í', 'I', [rfReplaceAll]);
  Result := StringReplace(Result, 'Ó', 'O', [rfReplaceAll]);
  Result := StringReplace(Result, 'Õ', 'O', [rfReplaceAll]);
  Result := StringReplace(Result, 'Ô', 'O', [rfReplaceAll]);
  Result := StringReplace(Result, 'Ú', 'U', [rfReplaceAll]);
  Result := StringReplace(Result, 'Ç', 'C', [rfReplaceAll]);

  for I := Length(Result) downto 1 do
  begin
    C := Result[I];
    if not (Ord(C) in [32..126]) then
      Delete(Result, I, 1);
  end;

  Result := StringReplace(Result, '\', '\\', [rfReplaceAll]);
  Result := StringReplace(Result, '(', '\(', [rfReplaceAll]);
  Result := StringReplace(Result, ')', '\)', [rfReplaceAll]);
end;

function ValorCampo(ADataSet: TDataSet; const ANome1, ANome2: string): string;
var
  F: TField;
begin
  Result := '';
  if ADataSet = nil then
    Exit;
  F := ADataSet.FindField(ANome1);
  if (F = nil) and (ANome2 <> '') then
    F := ADataSet.FindField(ANome2);
  if F <> nil then
    Result := F.AsString;
end;

function MoedaCampo(ADataSet: TDataSet; const ANome1, ANome2: string): Currency;
var
  F: TField;
begin
  Result := 0;
  if ADataSet = nil then
    Exit;
  F := ADataSet.FindField(ANome1);
  if (F = nil) and (ANome2 <> '') then
    F := ADataSet.FindField(ANome2);
  if F <> nil then
    Result := F.AsCurrency;
end;

procedure AddLinha(AStream: TStrings; const Texto: string; X, Y, Tamanho: Integer; Negrito: Boolean = False);
begin
  if Negrito then
    AStream.Add(Format('BT /F2 %d Tf %d %d Td (%s) Tj ET', [Tamanho, X, Y, LimparTextoPDF(Texto)]))
  else
    AStream.Add(Format('BT /F1 %d Tf %d %d Td (%s) Tj ET', [Tamanho, X, Y, LimparTextoPDF(Texto)]));
end;

procedure AddTextoArquivo(AStream: TFileStream; const Texto: AnsiString);
begin
  if Length(Texto) > 0 then
    AStream.WriteBuffer(Texto[1], Length(Texto));
end;

class procedure TOrcamentoPDF.Gerar(const AArquivoPDF, AEmpresaTitulo, ANumero, ACliente, AVendedor, AValidade, AObs: string;
  AQtdItens: Integer; ATotalProdutos, AMaoObra, ATotalGeral: Currency; AItens: TDataSet);
var
  Conteudo: TStringList;
  Objetos: TStringList;
  FS: TFileStream;
  Offsets: array[1..6] of Int64;
  I, Y, Obj: Integer;
  PosInicialXref: Int64;
  OldBookmark: TBookmark;
  Cod, Desc, EmpresaTituloPDF: string;
  Qtd, ValUnit, ValTotal: Currency;
begin
  ForceDirectories(ExtractFilePath(AArquivoPDF));
  if FileExists(AArquivoPDF) then
    DeleteFile(AArquivoPDF);

  Conteudo := TStringList.Create;
  Objetos := TStringList.Create;
  try
    Conteudo.LineBreak := #10;
    EmpresaTituloPDF := Trim(AEmpresaTitulo);
    if EmpresaTituloPDF = '' then
      EmpresaTituloPDF := 'Empresa';
    AddLinha(Conteudo, EmpresaTituloPDF, 40, 812, 13, True);
    AddLinha(Conteudo, 'ORCAMENTO', 40, 790, 18, True);
    AddLinha(Conteudo, ANumero, 420, 792, 10, False);
    AddLinha(Conteudo, 'Cliente: ' + ACliente, 40, 770, 11, False);
    AddLinha(Conteudo, 'Vendedor: ' + AVendedor, 40, 752, 11, False);
    AddLinha(Conteudo, 'Validade: ' + AValidade, 40, 734, 11, False);
    if Trim(AObs) <> '' then
      AddLinha(Conteudo, 'Obs: ' + AObs, 40, 716, 10, False);

    Conteudo.Add('0.5 w 40 695 m 555 695 l S');
    AddLinha(Conteudo, 'Codigo', 40, 678, 9, True);
    AddLinha(Conteudo, 'Descricao', 100, 678, 9, True);
    AddLinha(Conteudo, 'Qtd', 360, 678, 9, True);
    AddLinha(Conteudo, 'Vl. Unit.', 405, 678, 9, True);
    AddLinha(Conteudo, 'Vl. Total', 485, 678, 9, True);
    Conteudo.Add('0.5 w 40 670 m 555 670 l S');

    Y := 653;
    if (AItens <> nil) and AItens.Active and (not AItens.IsEmpty) then
    begin
      AItens.DisableControls;
      OldBookmark := AItens.GetBookmark;
      try
        AItens.First;
        while (not AItens.Eof) and (Y > 120) do
        begin
          Cod := ValorCampo(AItens, 'CodProd', 'CodigoProd');
          Desc := Copy(ValorCampo(AItens, 'Descricao', ''), 1, 42);
          Qtd := MoedaCampo(AItens, 'Quantidade', 'Qtd');
          ValUnit := MoedaCampo(AItens, 'ValorUni', 'ValUnit');
          ValTotal := MoedaCampo(AItens, 'ValorTotal', 'ValTotal');

          AddLinha(Conteudo, Cod, 40, Y, 8, False);
          AddLinha(Conteudo, Desc, 100, Y, 8, False);
          AddLinha(Conteudo, FormatFloat('#,##0.####', Qtd), 360, Y, 8, False);
          AddLinha(Conteudo, 'R$ ' + FormatFloat('#,##0.00', ValUnit), 405, Y, 8, False);
          AddLinha(Conteudo, 'R$ ' + FormatFloat('#,##0.00', ValTotal), 485, Y, 8, False);
          Dec(Y, 16);
          AItens.Next;
        end;
      finally
        if AItens.BookmarkValid(OldBookmark) then
          AItens.GotoBookmark(OldBookmark);
        AItens.FreeBookmark(OldBookmark);
        AItens.EnableControls;
      end;
    end;

    Conteudo.Add('0.5 w 40 112 m 555 112 l S');
    AddLinha(Conteudo, 'Itens: ' + IntToStr(AQtdItens), 40, 92, 10, False);
    AddLinha(Conteudo, 'Produtos: R$ ' + FormatFloat('#,##0.00', ATotalProdutos), 330, 92, 10, False);
    AddLinha(Conteudo, 'Mao de obra: R$ ' + FormatFloat('#,##0.00', AMaoObra), 330, 74, 10, False);
    AddLinha(Conteudo, 'Total: R$ ' + FormatFloat('#,##0.00', ATotalGeral), 330, 52, 12, True);

    Objetos.Add('1 0 obj'#10'<< /Type /Catalog /Pages 2 0 R >>'#10'endobj'#10);
    Objetos.Add('2 0 obj'#10'<< /Type /Pages /Kids [3 0 R] /Count 1 >>'#10'endobj'#10);
    Objetos.Add('3 0 obj'#10'<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 4 0 R /F2 5 0 R >> >> /Contents 6 0 R >>'#10'endobj'#10);
    Objetos.Add('4 0 obj'#10'<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>'#10'endobj'#10);
    Objetos.Add('5 0 obj'#10'<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>'#10'endobj'#10);
    Objetos.Add('6 0 obj'#10'<< /Length ' + IntToStr(Length(AnsiString(Conteudo.Text))) + ' >>'#10'stream'#10 + Conteudo.Text + 'endstream'#10'endobj'#10);

    FS := TFileStream.Create(AArquivoPDF, fmCreate);
    try
      AddTextoArquivo(FS, '%PDF-1.4'#10);
      for I := 1 to Objetos.Count do
      begin
        Offsets[I] := FS.Position;
        AddTextoArquivo(FS, AnsiString(Objetos[I - 1]));
      end;
      PosInicialXref := FS.Position;
      AddTextoArquivo(FS, 'xref'#10'0 7'#10'0000000000 65535 f '#10);
      for Obj := 1 to 6 do
        AddTextoArquivo(FS, AnsiString(Format('%.10d 00000 n '#10, [Offsets[Obj]])));
      AddTextoArquivo(FS, AnsiString('trailer'#10'<< /Size 7 /Root 1 0 R >>'#10'startxref'#10 + IntToStr(PosInicialXref) + #10'%%EOF'));
    finally
      FS.Free;
    end;
  finally
    Conteudo.Free;
    Objetos.Free;
  end;

  if not FileExists(AArquivoPDF) then
    raise Exception.Create('Nao foi possivel gerar o PDF do orcamento.');
end;

end.