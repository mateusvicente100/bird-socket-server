program Bird.Socket.Service;

uses
  Vcl.SvcMgr,
  Service in 'src\Service.pas' {BirdSocketService: TService},
  Bird.Socket.Connection in '..\..\..\src\Bird.Socket.Connection.pas',
  Bird.Socket.Consts in '..\..\..\src\Bird.Socket.Consts.pas',
  Bird.Socket.Helpers in '..\..\..\src\Bird.Socket.Helpers.pas',
  Bird.Socket in '..\..\..\src\Bird.Socket.pas',
  Bird.Socket.Server in '..\..\..\src\Bird.Socket.Server.pas',
  Bird.Socket.Types in '..\..\..\src\Bird.Socket.Types.pas';

{$R *.RES}

begin
  if not Application.DelayInitialize or Application.Installing then
    Application.Initialize;
  Application.CreateForm(TBirdSocketService, BirdSocketService);
  Application.Run;
end.
