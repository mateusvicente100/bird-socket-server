program Bird.Socket.Console;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  IdContext,
  Bird.Socket.Consts in '..\..\..\src\Bird.Socket.Consts.pas',
  Bird.Socket.Connection in '..\..\..\src\Bird.Socket.Connection.pas',
  Bird.Socket.Helpers in '..\..\..\src\Bird.Socket.Helpers.pas',
  Bird.Socket in '..\..\..\src\Bird.Socket.pas',
  Bird.Socket.Server in '..\..\..\src\Bird.Socket.Server.pas',
  Bird.Socket.Types in '..\..\..\src\Bird.Socket.Types.pas';

var
  LBirdSocket: TBirdSocket;
begin
  LBirdSocket := TBirdSocket.Create(8080);
  try
    LBirdSocket.AddEventListener(TEventType.CONNECT,
      procedure(const ABird: TBirdSocketConnection)
      begin
        Writeln('Client connected');
      end);

    LBirdSocket.AddEventListener(TEventType.EXECUTE,
      procedure(const ABird: TBirdSocketConnection)
      var
        LMessage: string;
      begin
        LMessage := ABird.WaitMessage;
        if LMessage.Trim.Equals('ping') then
          ABird.Send('pong')
        else if LMessage.Trim.IsEmpty then
          ABird.Send('empty message')
        else
          ABird.Send(Format('message received: "%s"', [LMessage]));
      end);

    LBirdSocket.AddEventListener(TEventType.DISCONNECT,
      procedure(const ABird: TBirdSocketConnection)
      begin
        Writeln('Client disconnected');
      end);
    LBirdSocket.Start;
  finally
    LBirdSocket.DisposeOf;
  end;
end.
