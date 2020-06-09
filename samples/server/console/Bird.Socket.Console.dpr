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
  Bird.Socket in '..\..\..\src\Bird.Socket.pas';

var
  LBirdSocket: TBirdSocket;
begin
  LBirdSocket := TBirdSocket.Create(8080);
  try
    LBirdSocket.AddEventListener(TEventType.CONNECT,
      procedure(const AContext: TIdContext)
      begin
        Writeln('Client connected');
      end);

    LBirdSocket.AddEventListener(TEventType.EXECUTE,
      procedure(const AContext: TIdContext)
      var
        LMessage: string;
      begin
        AContext.Connection.IOHandler.CheckForDataOnSource(TIMEOUT_DATA_ON_SOURCE);
        LMessage := AContext.Connection.IOHandler.ReadString;
        if LMessage.Trim.Equals('ping') then
          AContext.Connection.IOHandler.Send('pong')
        else if LMessage.Trim.IsEmpty then
          AContext.Connection.IOHandler.Send('empty message')
        else
          AContext.Connection.IOHandler.Send(Format('message received: "%s"', [LMessage]));
      end);

    LBirdSocket.AddEventListener(TEventType.DISCONNECT,
      procedure(const AContext: TIdContext)
      begin
        Writeln('Client disconnected');
      end);
    LBirdSocket.Start;
  finally
    LBirdSocket.DisposeOf;
  end;
end.
