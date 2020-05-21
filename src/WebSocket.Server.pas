unit WebSocket.Server;

interface

uses IdCustomTCPServer, IdHashSHA, IdSSLOpenSSL, IdContext, IdSSL, IdIOHandler, IdGlobal, IdCoderMIME, System.SysUtils,
  System.Generics.Collections, WebSocket.Server.Helpers, WebSocket.Server.Consts, WebSocket.Server.Types;

type
  TWebSocketServer = class(TIdCustomTCPServer)
  private
    FIdServerIOHandlerSSLOpenSSL: TIdServerIOHandlerSSLOpenSSL;
    FIdHashSHA1: TIdHashSHA1;
    function ParseHeaders(const AValue: string): THeaders;
    function GetEncodedHash(const ASecretKey: string): string;
    function GetSuccessHandShakeMessage(const AHash: string): string;
  protected
    function DoExecute(AContext: TIdContext): Boolean; override;
    procedure DoConnect(AContext: TIdContext); override;
  public
    constructor Create;
    property OnExecute;
    procedure InitSSL(AIdServerIOHandlerSSLOpenSSL: TIdServerIOHandlerSSLOpenSSL);
    destructor Destroy; override;
  end;

implementation

constructor TWebSocketServer.Create;
begin
  inherited Create;
  FIdHashSHA1 := TIdHashSHA1.Create;
  FIdServerIOHandlerSSLOpenSSL := nil;
end;

destructor TWebSocketServer.Destroy;
begin
  FIdHashSHA1.DisposeOf;
  inherited;
end;

procedure TWebSocketServer.DoConnect(AContext: TIdContext);
begin
  if (AContext.Connection.IOHandler is TIdSSLIOHandlerSocketBase) then
    TIdSSLIOHandlerSocketBase(AContext.Connection.IOHandler).PassThrough := False;
  AContext.Connection.IOHandler.HandShaked := False;
  inherited;
end;

function TWebSocketServer.DoExecute(AContext: TIdContext): Boolean;
var
  LBytes: TArray<Byte>;
  LMessage: string;
  LHeaders: THeaders;
begin
  if not AContext.Connection.IOHandler.HandShaked then
  begin
    AContext.Connection.IOHandler.CheckForDataOnSource(TIMEOUT_DATA_ON_SOURCE);
    if not AContext.Connection.IOHandler.InputBufferIsEmpty then
    begin
      try
        AContext.Connection.IOHandler.InputBuffer.ExtractToBytes(TIdBytes(LBytes));
        LMessage := IndyTextEncoding_UTF8.GetString(TIdBytes(LBytes));
      except
      end;
      LHeaders := ParseHeaders(LMessage);
      try
        if LHeaders.ContainsKey(HEADERS_UPGRADE) and LHeaders.ContainsKey(HEADERS_AUTHORIZATION) then
          if LHeaders[HEADERS_UPGRADE].ToLower.Equals(HEADERS_WEBSOCKET) then
          begin
            try
              AContext.Connection.IOHandler.Write(GetSuccessHandShakeMessage(GetEncodedHash(LHeaders[HEADERS_AUTHORIZATION])),
                IndyTextEncoding_UTF8);
            except
            end;
            AContext.Connection.IOHandler.HandShaked := True;
          end;
      finally
        LHeaders.DisposeOf;
      end;
    end;
  end;
  Result := inherited;
end;

function TWebSocketServer.GetEncodedHash(const ASecretKey: string): string;
begin
  Result := TIdEncoderMIME.EncodeBytes(FIdHashSHA1.HashString(ASecretKey + '258EAFA5-E914-47DA-95CA-C5AB0DC85B11'));
end;

function TWebSocketServer.GetSuccessHandShakeMessage(const AHash: string): string;
begin
  Result := Format(
    'HTTP/1.1 101 Switching Protocols'#13#10 +
    'Upgrade: websocket'#13#10 +
    'Connection: Upgrade'#13#10 +
    'Sec-WebSocket-Accept: %s'#13#10#13#10, [AHash]);
end;

procedure TWebSocketServer.InitSSL(AIdServerIOHandlerSSLOpenSSL: TIdServerIOHandlerSSLOpenSSL);
var
  LActiveHandler: Boolean;
begin
  LActiveHandler := Self.Active;
  if LActiveHandler then
    Self.Active := False;
  FIdServerIOHandlerSSLOpenSSL := AIdServerIOHandlerSSLOpenSSL;
  IOHandler := AIdServerIOHandlerSSLOpenSSL;
  if LActiveHandler then
    Self.Active := True;
end;

function TWebSocketServer.ParseHeaders(const AValue: string): THeaders;
const
  HEADER_NAME = 0;
  HEADER_VALUE = 1;
var
  LLines: TArray<string>;
  LLine: string;
  LSplittedLine: TArray<string>;
begin
  Result := THeaders.Create;
  LLines := AValue.Split([#13#10]);
  for LLine in LLines do
  begin
    LSplittedLine := LLine.Split([': ']);
    if (Length(LSplittedLine) > 1) then
      Result.AddOrSetValue(Trim(LSplittedLine[HEADER_NAME]), Trim(LSplittedLine[HEADER_VALUE]));
  end;
end;

end.
