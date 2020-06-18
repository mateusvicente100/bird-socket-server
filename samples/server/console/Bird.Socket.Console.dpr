program Bird.Socket.Console;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  IdContext,
  Bird.Socket.Consts in '..\..\..\src\Bird.Socket.Consts.pas',
  Bird.Socket.Helpers in '..\..\..\src\Bird.Socket.Helpers.pas',
  Bird.Socket.Server in '..\..\..\src\Bird.Socket.Server.pas',
  Bird.Socket.Types in '..\..\..\src\Bird.Socket.Types.pas',
  Bird.Socket in '..\..\..\src\Bird.Socket.pas',
  Bird.Socket.Context in '..\..\..\src\Bird.Socket.Context.pas';

var
  LBirdSocket: TBirdSocket;
begin
  LBirdSocket := TBirdSocket.Create(8080);
  try
    LBirdSocket.AddEventListener(TEventType.CONNECT,
      procedure(const AContext: TBirdSocketContext)
      begin
        Writeln('Client connected');
      end);

    LBirdSocket.AddEventListener(TEventType.EXECUTE,
      procedure(const AContext: TBirdSocketContext)
      var
        LMessage: string;
      begin
        LMessage := AContext.WaitMessage;
        if LMessage.Trim.Equals('ping') then
          AContext.Send('pong')
        else if LMessage.Trim.IsEmpty then
          AContext.Send('empty message')
        else
          AContext.Send(Format('message received: "%s"', [LMessage]));
      end);

    LBirdSocket.AddEventListener(TEventType.DISCONNECT,
      procedure(const AContext: TBirdSocketContext)
      begin
        Writeln('Client disconnected');
      end);
    LBirdSocket.Start;
  finally
    LBirdSocket.DisposeOf;
  end;
end.
