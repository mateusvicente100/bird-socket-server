unit Bird.Socket;

interface

uses IdContext, Bird.Socket.Server, System.SysUtils, Bird.Socket.Types, Bird.Socket.Connection;

type
  TEventType = Bird.Socket.Types.TEventType;
  TBirdSocketConnection = Bird.Socket.Connection.TBirdSocketConnection;
  TBirdSocket = class(TBirdSocketServer)
  public
    procedure Start; override;
  end;

implementation

procedure TBirdSocket.Start;
var
  LAttach: string;
begin
  try
    if IsConsole then
    begin
      Writeln('The websocket server is runing on port ' + Self.DefaultPort.ToString + sLineBreak);
      Read(LAttach);
    end;
  except
    on E: Exception do
    begin
      if IsConsole then
      begin
        Writeln(E.ClassName, ': ', E.Message);
        Read(LAttach);
      end
      else
        raise E;
    end;
  end;
end;

end.
