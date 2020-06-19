unit Bird.Socket.Context;

interface

uses IdContext, Bird.Socket.Consts, Bird.Socket.Helpers, System.JSON;

type
  TBirdSocketContext = class
  private
    FIdContext: TIdContext;
  public
    constructor Create(const AIdContext: TIdContext);
    function WaitMessage: string;
    function IPAdress: string;
    procedure Send(const AMessage: string); overload;
    procedure Send(const ACode: Integer; const AMessage: string); overload;
    procedure Send(const ACode: Integer; const AMessage: string; const AValues: array of const); overload;
    procedure Send(const AJSONObject: TJSONObject; const AOwns: Boolean = True); overload;
    procedure SendFile(const AFile: string); overload;
  end;

implementation

constructor TBirdSocketContext.Create(const AIdContext: TIdContext);
begin
  FIdContext := AIdContext;
end;

procedure TBirdSocketContext.Send(const AMessage: string);
begin
  FIdContext.Connection.IOHandler.Send(AMessage);
end;

procedure TBirdSocketContext.Send(const ACode: Integer; const AMessage: string);
begin
  FIdContext.Connection.IOHandler.Send(ACode, AMessage);
end;

procedure TBirdSocketContext.Send(const ACode: Integer; const AMessage: string; const AValues: array of const);
begin
  FIdContext.Connection.IOHandler.Send(ACode, AMessage, AValues);
end;

function TBirdSocketContext.IPAdress: string;
begin
  Result := FIdContext.Connection.Socket.Binding.PeerIP;
end;

procedure TBirdSocketContext.Send(const AJSONObject: TJSONObject; const AOwns: Boolean);
begin
  FIdContext.Connection.IOHandler.Send(AJSONObject, AOwns);
end;

procedure TBirdSocketContext.SendFile(const AFile: string);
begin
  FIdContext.Connection.IOHandler.SendFile(AFile);
end;

function TBirdSocketContext.WaitMessage: string;
begin
  FIdContext.Connection.IOHandler.CheckForDataOnSource(TIMEOUT_DATA_ON_SOURCE);
  Result := FIdContext.Connection.IOHandler.ReadString;
end;

end.
