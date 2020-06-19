program Bird.Socket.VCL;

uses
  Vcl.Forms,
  Bird.Socket.View in 'src\Bird.Socket.View.pas' {FrmMainMenu};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMainMenu, FrmMainMenu);
  Application.Run;
end.
