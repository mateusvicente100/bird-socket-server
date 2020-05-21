unit WebSocket.Server.Helpers;

interface

uses IdIOHandler, IdGlobal;

type
  TIdIOHandlerHelper = class helper for TIdIOHandler
  private
    function GetHandShaked: Boolean;
    function ReadBytes: TArray<byte>;
    procedure WriteBytes(RawData: TArray<byte>);
    procedure SetHandShaked(const AValue: Boolean);
  public
    property HandShaked: Boolean read GetHandShaked write SetHandShaked;
    function ReadString: string;
    procedure WriteString(const AValue: string);
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

procedure TIdIOHandlerHelper.SetHandShaked(const AValue: Boolean);
begin
  Self.Tag := Ord(AValue);
end;

procedure TIdIOHandlerHelper.WriteBytes(RawData: TArray<byte>);
var
  LBytes: TArray<Byte>;
begin
  LBytes := [$81];
  if Length(RawData) <= 125 then
    LBytes := LBytes + [Length(RawData)]
  else if (Length(RawData) >= 126) and (Length(RawData) <= 65535) then
    LBytes := LBytes + [126, (Length(RawData) shr 8) and 255, Length(RawData) and 255]
  else
    LBytes := LBytes + [127, (int64(Length(RawData)) shr 56) and 255, (int64(Length(RawData)) shr 48) and 255,
      (int64(Length(RawData)) shr 40) and 255, (int64(Length(RawData)) shr 32) and 255,
      (Length(RawData) shr 24) and 255, (Length(RawData) shr 16) and 255, (Length(RawData) shr 8) and 255, Length(RawData) and 255];
  LBytes := LBytes + RawData;
  try
    Write(TIdBytes(LBytes), Length(LBytes));
  except
  end;
end;

procedure TIdIOHandlerHelper.WriteString(const AValue: string);
begin
  WriteBytes(TArray<Byte>(IndyTextEncoding_UTF8.GetBytes(AValue)));
end;

end.
