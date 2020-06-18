program Bird.Socket.VCL;

uses
  Vcl.Forms,
  Bird.Socket.View in 'src\Bird.Socket.View.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
