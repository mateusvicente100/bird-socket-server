unit Bird.Socket.WebModule;

interface

uses System.SysUtils, System.IOUtils, System.Classes, System.RegularExpressions, Bird.Socket, Bird.Socket.Types, IdContext,
  Bird.Socket.Consts, Bird.Socket.Helpers, Web.HTTPApp;

type
  TBirdSocketWebModule = class(TWebModule)
    procedure WebModuleDestroy(Sender: TObject);
    procedure WebModuleCreate(Sender: TObject);
  private
    FBirdSocket: TBirdSocket;
  end;

var
  WebModuleClass: TComponentClass = TBirdSocketWebModule;

implementation

{$R *.dfm}

procedure TBirdSocketWebModule.WebModuleCreate(Sender: TObject);
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

procedure TBirdSocketWebModule.WebModuleDestroy(Sender: TObject);
begin
  FBirdSocket.DisposeOf;
end;

end.
