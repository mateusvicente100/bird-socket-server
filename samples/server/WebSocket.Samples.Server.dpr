program WebSocket.Samples.Server;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Samples.Server in 'src\Samples.Server.pas',
  WebSocket.Server.Consts in '..\..\src\WebSocket.Server.Consts.pas',
  WebSocket.Server.Helpers in '..\..\src\WebSocket.Server.Helpers.pas',
  WebSocket.Server in '..\..\src\WebSocket.Server.pas',
  WebSocket.Server.Types in '..\..\src\WebSocket.Server.Types.pas';

var
  LWebSocketServerSamples: TWebSocketServerSamples;
begin
  try
    LWebSocketServerSamples := TWebSocketServerSamples.Create;
    try
      Readln;
    finally
      LWebSocketServerSamples.DisposeOf;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
