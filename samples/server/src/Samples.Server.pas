unit Samples.Server;

interface

uses IdContext, WebSocket.Server, WebSocket.Server.Helpers, WebSocket.Server.Consts, System.SysUtils;

type
  TWebSocketServerSamples = class
  private
    FServer: TWebSocketServer;
    procedure Connect(AContext: TIdContext);
    procedure Disconnect(AContext: TIdContext);
    procedure Execute(AContext: TIdContext);
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

procedure TWebSocketServerSamples.Connect(AContext: TIdContext);
begin
  Writeln('Client connected');
end;

constructor TWebSocketServerSamples.Create;
begin
  FServer := TWebSocketServer.Create;
  FServer.DefaultPort := 8080;
  FServer.OnExecute := Execute;
  FServer.OnConnect := Connect;
  FServer.OnDisconnect := Disconnect;
  FServer.Active := True;
  Writeln('The websocket server is runing on port ' + FServer.DefaultPort.ToString);
end;

destructor TWebSocketServerSamples.Destroy;
begin
  FServer.Active := False;
  FServer.DisposeOf;
  inherited;
end;

procedure TWebSocketServerSamples.Disconnect(AContext: TIdContext);
begin
  Writeln('Client disconnected');
end;

procedure TWebSocketServerSamples.Execute(AContext: TIdContext);
var
  LMessage: string;
begin
  AContext.Connection.IOHandler.CheckForDataOnSource(TIMEOUT_DATA_ON_SOURCE);
  LMessage := AContext.Connection.IOHandler.ReadString;
  if LMessage.Trim.Equals('ping') then
    AContext.Connection.IOHandler.WriteString('pong')
  else if LMessage.Trim.IsEmpty then
    AContext.Connection.IOHandler.WriteString('empty message')
  else
    AContext.Connection.IOHandler.WriteString(Format('message received: "%s"', [LMessage]));
end;

end.
