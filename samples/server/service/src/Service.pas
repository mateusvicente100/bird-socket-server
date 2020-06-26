unit Service;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs,
  Bird.Socket;

type
  TBirdSocketService = class(TService)
    procedure ServiceCreate(Sender: TObject);
    procedure ServiceDestroy(Sender: TObject);
    procedure ServicePause(Sender: TService; var Paused: Boolean);
    procedure ServiceShutdown(Sender: TService);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServiceExecute(Sender: TService);
  private
    FBirdSocket: TBirdSocket;
  public
    function GetServiceController: TServiceController; override;
  end;

var
  BirdSocketService: TBirdSocketService;

implementation

{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  BirdSocketService.Controller(CtrlCode);
end;

function TBirdSocketService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TBirdSocketService.ServiceCreate(Sender: TObject);
begin
  FBirdSocket := TBirdSocket.Create(8080);

  FBirdSocket.AddEventListener(TEventType.EXECUTE,
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
end;

procedure TBirdSocketService.ServiceDestroy(Sender: TObject);
begin
  FBirdSocket.Stop;
  FBirdSocket.DisposeOf;
end;

procedure TBirdSocketService.ServiceExecute(Sender: TService);
begin
  while not Self.Terminated do
    ServiceThread.ProcessRequests(True);
end;

procedure TBirdSocketService.ServicePause(Sender: TService; var Paused: Boolean);
begin
  FBirdSocket.Stop;
end;

procedure TBirdSocketService.ServiceShutdown(Sender: TService);
begin
  FBirdSocket.Stop;
end;

procedure TBirdSocketService.ServiceStart(Sender: TService; var Started: Boolean);
begin
  FBirdSocket.Start;
end;

procedure TBirdSocketService.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  FBirdSocket.Stop;
end;

end.
