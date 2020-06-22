unit Bird.Socket.Connection;

interface

uses IdContext, Bird.Socket.Consts, Bird.Socket.Helpers, System.JSON, System.Generics.Collections;

type
  TBirdSocketConnection = class
  private
    FIdContext: TIdContext;
  public
    constructor Create(const AIdContext: TIdContext);
    function WaitMessage: string;
    function IPAdress: string;
    function Id: Integer;
    function CheckForDataOnSource(const ATimeOut: Integer): Boolean;
    function Connected: Boolean;
    procedure Send(const AMessage: string); overload;
    procedure Send(const ACode: Integer; const AMessage: string); overload;
    procedure Send(const ACode: Integer; const AMessage: string; const AValues: array of const); overload;
    procedure Send(const AJSONObject: TJSONObject; const AOwns: Boolean = True); overload;
    procedure SendFile(const AFile: string); overload;
  end;

  TBirds = TList<TBirdSocketConnection>;

implementation

function TBirdSocketConnection.CheckForDataOnSource(const ATimeOut: Integer): Boolean;
begin
  Result := FIdContext.Connection.IOHandler.CheckForDataOnSource(ATimeOut);
end;

function TBirdSocketConnection.Connected: Boolean;
begin
  Result := FIdContext.Connection.Connected;
end;

constructor TBirdSocketConnection.Create(const AIdContext: TIdContext);
begin
  FIdContext := AIdContext;
end;

procedure TBirdSocketConnection.Send(const AMessage: string);
begin
  FIdContext.Connection.IOHandler.Send(AMessage);
end;

procedure TBirdSocketConnection.Send(const ACode: Integer; const AMessage: string);
begin
  FIdContext.Connection.IOHandler.Send(ACode, AMessage);
end;

procedure TBirdSocketConnection.Send(const ACode: Integer; const AMessage: string; const AValues: array of const);
begin
  FIdContext.Connection.IOHandler.Send(ACode, AMessage, AValues);
end;

function TBirdSocketConnection.ID: Integer;
begin
  Result := FIdContext.Binding.ID;
end;

function TBirdSocketConnection.IPAdress: string;
begin
  Result := FIdContext.Connection.Socket.Binding.PeerIP;
end;

procedure TBirdSocketConnection.Send(const AJSONObject: TJSONObject; const AOwns: Boolean);
begin
  FIdContext.Connection.IOHandler.Send(AJSONObject, AOwns);
end;

procedure TBirdSocketConnection.SendFile(const AFile: string);
begin
  FIdContext.Connection.IOHandler.SendFile(AFile);
end;

function TBirdSocketConnection.WaitMessage: string;
begin
  FIdContext.Connection.IOHandler.CheckForDataOnSource(TIMEOUT_DATA_ON_SOURCE);
  Result := FIdContext.Connection.IOHandler.ReadString;
end;

end.
