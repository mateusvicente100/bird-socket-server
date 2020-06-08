unit Bird.Socket.Helpers;

interface

uses IdIOHandler, IdGlobal, System.SysUtils, System.JSON;

type
  TIdIOHandlerHelper = class helper for TIdIOHandler
  private
    function GetHandShaked: Boolean;
    function ReadBytes: TArray<byte>;
    procedure Send(const ARawData: TArray<byte>); overload;
    procedure SetHandShaked(const AValue: Boolean);
  public
    property HandShaked: Boolean read GetHandShaked write SetHandShaked;
    function ReadString: string;
    procedure Send(const AMessage: string); overload;
    procedure Send(const ACode: Integer; const AMessage: string); overload;
    procedure Send(const ACode: Integer; const AMessage: string; const AValues: array of const); overload;
    procedure Send(const AJSONObject: TJSONObject; const AOwns: Boolean = True); overload;
    procedure SendFile(const AFile: string); overload;
  end;

implementation

function TIdIOHandlerHelper.GetHandShaked: Boolean;
begin
  Result := Boolean(Self.Tag);
end;

function TIdIOHandlerHelper.ReadBytes: TArray<byte>;
var
  LByte: Byte;
  LBytes: array [0..7] of byte;
  I, LDecodedSize: int64;
  LMask: array [0..3] of byte;
begin
  try
    if ReadByte = $81 then
    begin
      LByte := ReadByte;
      case LByte of
        $FE:
          begin
            LBytes[1] := ReadByte; LBytes[0] := ReadByte;
            LBytes[2] := 0; LBytes[3] := 0; LBytes[4] := 0; LBytes[5] := 0; LBytes[6] := 0; LBytes[7] := 0;
            LDecodedSize := Int64(LBytes);
          end;
        $FF:
          begin
            LBytes[7] := ReadByte; LBytes[6] := ReadByte; LBytes[5] := ReadByte; LBytes[4] := ReadByte;
            LBytes[3] := ReadByte; LBytes[2] := ReadByte; LBytes[1] := ReadByte; LBytes[0] := ReadByte;
            LDecodedSize := Int64(LBytes);
          end;
        else
          LDecodedSize := LByte - 128;
      end;
      LMask[0] := ReadByte; LMask[1] := ReadByte; LMask[2] := ReadByte; LMask[3] := ReadByte;
      if LDecodedSize < 1 then
      begin
        Result := [];
        Exit;
      end;
      SetLength(result, LDecodedSize);
      inherited ReadBytes(TIdBytes(result), LDecodedSize, False);
      for I := 0 to LDecodedSize - 1 do
        Result[I] := Result[I] xor LMask[I mod 4];
    end;
  except
  end;
end;

function TIdIOHandlerHelper.ReadString: string;
begin
  Result := IndyTextEncoding_UTF8.GetString(TIdBytes(ReadBytes));
end;

procedure TIdIOHandlerHelper.Send(const ACode: Integer; const AMessage: string);
begin
  Self.Send(TJSONObject.Create.AddPair('code', TJSONNumber.Create(ACode)).AddPair('message', AMessage));
end;

procedure TIdIOHandlerHelper.Send(const ACode: Integer; const AMessage: string; const AValues: array of const);
begin
  Self.Send(ACode, Format(AMessage, AValues));
end;

procedure TIdIOHandlerHelper.Send(const AJSONObject: TJSONObject; const AOwns: Boolean);
begin
  try
    Self.Send(AJSONObject.ToString);
  finally
    if AOwns then
      AJSONObject.Free;
  end;
end;

procedure TIdIOHandlerHelper.SendFile(const AFile: string);
begin
  WriteFile(AFile, True);
end;

procedure TIdIOHandlerHelper.SetHandShaked(const AValue: Boolean);
begin
  Self.Tag := Ord(AValue);
end;

procedure TIdIOHandlerHelper.Send(const ARawData: TArray<byte>);
var
  LBytes: TArray<Byte>;
begin
  LBytes := [$81];
  if Length(ARawData) <= 125 then
    LBytes := LBytes + [Length(ARawData)]
  else if (Length(ARawData) >= 126) and (Length(ARawData) <= 65535) then
    LBytes := LBytes + [126, (Length(ARawData) shr 8) and 255, Length(ARawData) and 255]
  else
    LBytes := LBytes + [127, (int64(Length(ARawData)) shr 56) and 255, (int64(Length(ARawData)) shr 48) and 255,
      (int64(Length(ARawData)) shr 40) and 255, (int64(Length(ARawData)) shr 32) and 255,
      (Length(ARawData) shr 24) and 255, (Length(ARawData) shr 16) and 255, (Length(ARawData) shr 8) and 255, Length(ARawData) and 255];
  LBytes := LBytes + ARawData;
  try
    Write(TIdBytes(LBytes), Length(LBytes));
  except
  end;
end;

procedure TIdIOHandlerHelper.Send(const AMessage: string);
begin
  Self.Send(TArray<Byte>(IndyTextEncoding_UTF8.GetBytes(AMessage)));
end;

end.

