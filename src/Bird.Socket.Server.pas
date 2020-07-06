unit Bird.Socket.Server;

interface

uses IdCustomTCPServer, IdHashSHA, IdSSLOpenSSL, IdContext, IdSSL, IdIOHandler, IdGlobal, IdCoderMIME, System.SysUtils,
  Bird.Socket.Helpers, Bird.Socket.Consts, Bird.Socket.Types, Bird.Socket.Connection, System.Generics.Collections;

type
  TBirdSocketServer = class(TIdCustomTCPServer)
  private
    FIdServerIOHandlerSSLOpenSSL: TIdServerIOHandlerSSLOpenSSL;
    FIdHashSHA1: TIdHashSHA1;
    FOnConnect: TEventListener;
    FOnDisconnect: TEventListener;
    FOnExecute: TEventListener;
    FBirds: TBirds;
    function ParseHeaders(const AValue: string): THeaders;
    function GetEncodedHash(const ASecretKey: string): string;
    function GetSuccessHandShakeMessage(const AHash: string): string;
    function GetBirdFromContext(const AContext: TIdContext): TBirdSocketConnection;
    procedure DoOnConnect(AContext: TIdContext);
    procedure DoOnDisconnect(AContext: TIdContext);
    procedure DoOnExecute(AContext: TIdContext);
  protected
    function DoExecute(ABird: TIdContext): Boolean; override;
    procedure DoConnect(ABird: TIdContext); override;
  public
    constructor Create(const APort: Integer);
    property OnExecute;
    property Birds: TBirds read FBirds;
    procedure InitSSL(AIdServerIOHandlerSSLOpenSSL: TIdServerIOHandlerSSLOpenSSL);
    procedure AddEventListener(const AEventType: TEventType; const AEvent: TEventListener);
    procedure Start; virtual; abstract;
    procedure Stop;
    destructor Destroy; override;
  end;

implementation

procedure TBirdSocketServer.AddEventListener(const AEventType: TEventType; const AEvent: TEventListener);
begin
  case AEventType of
    TEventType.CONNECT:
      FOnConnect := AEvent;
    TEventType.EXECUTE:
      FOnExecute := AEvent;
    TEventType.DISCONNECT:
      FOnDisconnect := AEvent;
  end;
end;

procedure TBirdSocketServer.DoOnConnect(AContext: TIdContext);
begin
  FBirds.Add(TBirdSocketConnection.Create(AContext));
  if Assigned(FOnConnect) then
    FOnConnect(FBirds.Last);
end;

constructor TBirdSocketServer.Create(const APort: Integer);
begin
  inherited Create;
  FBirds := TBirds.Create;
  DefaultPort := APort;
  Active := True;
  FIdHashSHA1 := TIdHashSHA1.Create;
  FIdServerIOHandlerSSLOpenSSL := nil;
  OnConnect := DoOnConnect;
  OnDisconnect := DoOnDisconnect;
  OnExecute := DoOnExecute;
end;

destructor TBirdSocketServer.Destroy;
begin
  Active := False;
  FIdHashSHA1.DisposeOf;
  FBirds.DisposeOf;
  inherited;
end;

procedure TBirdSocketServer.DoOnDisconnect(AContext: TIdContext);
var
  LBird: TBirdSocketConnection;
begin
  LBird := GetBirdFromContext(AContext);
  if Assigned(FOnDisconnect) then
    FOnDisconnect(LBird);
  FBirds.Remove(LBird);
  LBird.Free;
end;

procedure TBirdSocketServer.DoConnect(ABird: TIdContext);
begin
  if (ABird.Connection.IOHandler is TIdSSLIOHandlerSocketBase) then
    TIdSSLIOHandlerSocketBase(ABird.Connection.IOHandler).PassThrough := False;
  ABird.Connection.IOHandler.HandShaked := False;
  inherited;
end;

function TBirdSocketServer.DoExecute(ABird: TIdContext): Boolean;
var
  LBytes: TArray<Byte>;
  LMessage: string;
  LHeaders: THeaders;
begin
  if not ABird.Connection.IOHandler.HandShaked then
  begin
    ABird.Connection.IOHandler.CheckForDataOnSource(TIMEOUT_DATA_ON_SOURCE);
    if not ABird.Connection.IOHandler.InputBufferIsEmpty then
    begin
      try
        ABird.Connection.IOHandler.InputBuffer.ExtractToBytes(TIdBytes(LBytes));
        LMessage := IndyTextEncoding_UTF8.GetString(TIdBytes(LBytes));
      except
      end;
      LHeaders := ParseHeaders(LMessage);
      try
        if LHeaders.ContainsKey(HEADERS_UPGRADE) and LHeaders.ContainsKey(HEADERS_AUTHORIZATION) then
          if LHeaders[HEADERS_UPGRADE].ToLower.Equals(HEADERS_WEBSOCKET) then
          begin
            try
              ABird.Connection.IOHandler.Write(GetSuccessHandShakeMessage(GetEncodedHash(LHeaders[HEADERS_AUTHORIZATION])),
                IndyTextEncoding_UTF8);
            except
            end;
            ABird.Connection.IOHandler.HandShaked := True;
          end;
      finally
        LHeaders.DisposeOf;
      end;
    end;
  end;
  Result := inherited;
end;

procedure TBirdSocketServer.DoOnExecute(AContext: TIdContext);
begin
  if Assigned(FOnExecute) then
    FOnExecute(GetBirdFromContext(AContext));
end;

function TBirdSocketServer.GetBirdFromContext(const AContext: TIdContext): TBirdSocketConnection;
var
  LBird: TBirdSocketConnection;
  LBirds: TList<TBirdSocketConnection>;
begin
  LBirds := FBirds.LockList;
  try
    for LBird in LBirds do
    begin
      if LBird.IsEquals(AContext) then
        Exit(LBird);
    end;
    Result := TBirdSocketConnection.Create(AContext);
  finally
    FBirds.UnLockList
  end;
end;

function TBirdSocketServer.GetEncodedHash(const ASecretKey: string): string;
begin
  Result := TIdEncoderMIME.EncodeBytes(FIdHashSHA1.HashString(ASecretKey + '258EAFA5-E914-47DA-95CA-C5AB0DC85B11'));
end;

function TBirdSocketServer.GetSuccessHandShakeMessage(const AHash: string): string;
begin
  Result := Format(
    'HTTP/1.1 101 Switching Protocols'#13#10 +
    'Upgrade: websocket'#13#10 +
    'Connection: Upgrade'#13#10 +
    'Sec-WebSocket-Accept: %s'#13#10#13#10, [AHash]);
end;

procedure TBirdSocketServer.InitSSL(AIdServerIOHandlerSSLOpenSSL: TIdServerIOHandlerSSLOpenSSL);
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

function TBirdSocketServer.ParseHeaders(const AValue: string): THeaders;
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

procedure TBirdSocketServer.Stop;
begin
  if Self.Active then
    Self.StopListening;
end;

end.
