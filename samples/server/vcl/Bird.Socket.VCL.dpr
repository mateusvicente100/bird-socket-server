program Bird.Socket.VCL;

uses
  Vcl.Forms,
  Bird.Socket.View in 'src\Bird.Socket.View.pas' {FrmMainMenu},
  Bird.Socket.Consts in '..\..\..\src\Bird.Socket.Consts.pas',
  Bird.Socket.Connection in '..\..\..\src\Bird.Socket.Connection.pas',
  Bird.Socket.Helpers in '..\..\..\src\Bird.Socket.Helpers.pas',
  Bird.Socket in '..\..\..\src\Bird.Socket.pas',
  Bird.Socket.Server in '..\..\..\src\Bird.Socket.Server.pas',
  Bird.Socket.Types in '..\..\..\src\Bird.Socket.Types.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMainMenu, FrmMainMenu);
  Application.Run;
end.
