library Bird.Socket.Isapi;

uses
  System.SysUtils,
  System.Classes,
  Web.WebBroker,
  System.Win.ComObj,
  Winapi.ActiveX,
  Web.Win.ISAPIApp,
  Bird.Socket.WebModule in 'src\Bird.Socket.WebModule.pas' {BirdSocketWebModule: TWebModule},
  Bird.Socket.Connection in '..\..\..\src\Bird.Socket.Connection.pas',
  Bird.Socket.Consts in '..\..\..\src\Bird.Socket.Consts.pas',
  Bird.Socket.Helpers in '..\..\..\src\Bird.Socket.Helpers.pas',
  Bird.Socket in '..\..\..\src\Bird.Socket.pas',
  Bird.Socket.Server in '..\..\..\src\Bird.Socket.Server.pas',
  Bird.Socket.Types in '..\..\..\src\Bird.Socket.Types.pas';

{$R *.res}

exports
  GetExtensionVersion,
  HttpExtensionProc,
  TerminateExtension;

begin
  CoInitFlags := COINIT_MULTITHREADED;
  Application.Initialize;
  Application.WebModuleClass := WebModuleClass;
  Application.Run;
end.
