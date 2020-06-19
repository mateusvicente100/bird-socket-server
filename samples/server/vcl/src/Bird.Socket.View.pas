unit Bird.Socket.View;

interface

uses Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, dxGDIPlusClasses, Vcl.ExtCtrls, Vcl.StdCtrls, Bird.Socket;

type
  TFrmMainMenu = class(TForm)
    Panel7: TPanel;
    imgHeader: TImage;
    imgClose: TImage;
    Panel1: TPanel;
    lblServer: TLabel;
    edtServer: TEdit;
    btnStop: TButton;
    btnStart: TButton;
    ListBoxLog: TListBox;
    procedure imgCloseClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
  private
    FBirdSocket: TBirdSocket;
    procedure HandlerButtons(const AConnected: Boolean);
  end;

var
  FrmMainMenu: TFrmMainMenu;

implementation

{$R *.dfm}

procedure TFrmMainMenu.btnClearClick(Sender: TObject);
begin
  ListBoxLog.Clear;
end;

procedure TFrmMainMenu.btnStartClick(Sender: TObject);
begin
  FBirdSocket.Start;
  HandlerButtons(True);
end;

procedure TFrmMainMenu.btnStopClick(Sender: TObject);
begin
  if FBirdSocket.Active then
    FBirdSocket.Stop;
  HandlerButtons(False);
end;

procedure TFrmMainMenu.FormCreate(Sender: TObject);
begin
  FBirdSocket := TBirdSocket.Create(8080);

  FBirdSocket.AddEventListener(TEventType.CONNECT,
    procedure(const AContext: TBirdSocketContext)
    begin
      ListBoxLog.Items.Add(Format('Client %s connected.', [AContext.IPAdress]));
    end);

  FBirdSocket.AddEventListener(TEventType.EXECUTE,
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
      ListBoxLog.Items.Add(Format('Message received from %s: %s.', [AContext.IPAdress, LMessage]));
    end);

  FBirdSocket.AddEventListener(TEventType.DISCONNECT,
    procedure(const AContext: TBirdSocketContext)
    begin
      ListBoxLog.Items.Add(Format('Client %s disconnected.', [AContext.IPAdress]));
    end);
  HandlerButtons(False);
end;

procedure TFrmMainMenu.FormDestroy(Sender: TObject);
begin
  FBirdSocket.Free;
end;

procedure TFrmMainMenu.HandlerButtons(const AConnected: Boolean);
begin
  btnStop.Enabled := AConnected;
  btnStart.Enabled := not(AConnected);
end;

procedure TFrmMainMenu.imgCloseClick(Sender: TObject);
begin
  Close;
end;

end.
