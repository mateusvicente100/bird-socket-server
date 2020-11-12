unit Bird.Socket.Connection;

interface

uses IdContext, Bird.Socket.Consts, Bird.Socket.Helpers, System.JSON, System.Generics.Collections, System.SysUtils;

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
    function IsEquals(const AIdContext: TIdContext): Boolean;
    procedure Send(const AMessage: string); overload;
    procedure Send(const ACode: Integer; const AMessage: string); overload;
    procedure Send(const ACode: Integer; const AMessage: string; const AValues: array of const); overload;
    procedure Send(const AJSONObject: TJSONObject; const AOwns: Boolean = True); overload;
    procedure SendFile(const AFile: string); overload;
  end;

  TBirds = class
  private
    FListLocked: Boolean;
    FItems: TList<TBirdSocketConnection>;
  public
    constructor Create;
    property Items: TList<TBirdSocketConnection> read FItems write FItems;
    function LockList: TList<TBirdSocketConnection>;
    function Last: TBirdSocketConnection;
    procedure Add(const ABird: TBirdSocketConnection);
    procedure Remove(const ABird: TBirdSocketConnection);
    procedure UnLockList;
    destructor Destroy; override;
  end;

implementation

function TBirdSocketConnection.CheckForDataOnSource(const ATimeOut: Integer): Boolean;
begin
  if (not Assigned(FIdContext)) or (not Assigned(FIdContext.Connection)) or (not Assigned(FIdContext.Connection.IOHandler)) then
    Exit(False);
  Result := FIdContext.Connection.IOHandler.CheckForDataOnSource(ATimeOut);
end;

function TBirdSocketConnection.Connected: Boolean;
begin
  if (not Assigned(FIdContext)) or (not Assigned(FIdContext.Connection)) then
    Exit(False);
  Result := FIdContext.Connection.Connected;
end;

constructor TBirdSocketConnection.Create(const AIdContext: TIdContext);
begin
  FIdContext := AIdContext;
end;

function TBirdSocketConnection.IsEquals(const AIdContext: TIdContext): Boolean;
begin
  if (not Assigned(FIdContext)) then
    Exit(False);
  Result := (FIdContext = AIdContext);
end;

procedure TBirdSocketConnection.Send(const AMessage: string);
begin
  if Assigned(FIdContext) and Assigned(FIdContext.Connection) and Assigned(FIdContext.Connection.IOHandler) then
    FIdContext.Connection.IOHandler.Send(AMessage);
end;

procedure TBirdSocketConnection.Send(const ACode: Integer; const AMessage: string);
begin
  if Assigned(FIdContext) and Assigned(FIdContext.Connection) and Assigned(FIdContext.Connection.IOHandler) then
    FIdContext.Connection.IOHandler.Send(ACode, AMessage);
end;

procedure TBirdSocketConnection.Send(const ACode: Integer; const AMessage: string; const AValues: array of const);
begin
  if Assigned(FIdContext) and Assigned(FIdContext.Connection) and Assigned(FIdContext.Connection.IOHandler) then
    FIdContext.Connection.IOHandler.Send(ACode, AMessage, AValues);
end;

function TBirdSocketConnection.ID: Integer;
begin
  Result := Integer(@FIdContext);
end;

function TBirdSocketConnection.IPAdress: string;
begin
  if (not Assigned(FIdContext)) or (not Assigned(FIdContext.Connection)) or (not Assigned(FIdContext.Connection.Socket)) or
    (not Assigned(FIdContext.Connection.Socket.Binding)) then
    Exit(EmptyStr);
  Result := FIdContext.Connection.Socket.Binding.PeerIP;
end;

procedure TBirdSocketConnection.Send(const AJSONObject: TJSONObject; const AOwns: Boolean);
begin
  if Assigned(FIdContext) and Assigned(FIdContext.Connection) and Assigned(FIdContext.Connection.IOHandler) then
    FIdContext.Connection.IOHandler.Send(AJSONObject, AOwns);
end;

procedure TBirdSocketConnection.SendFile(const AFile: string);
begin
  if Assigned(FIdContext) and Assigned(FIdContext.Connection) and Assigned(FIdContext.Connection.IOHandler) then
    FIdContext.Connection.IOHandler.SendFile(AFile);
end;

function TBirdSocketConnection.WaitMessage: string;
begin
  if (not Assigned(FIdContext)) or (not Assigned(FIdContext.Connection)) or (not Assigned(FIdContext.Connection.IOHandler)) then
    Exit(EmptyStr);
  FIdContext.Connection.IOHandler.CheckForDataOnSource(TIMEOUT_DATA_ON_SOURCE);
  Result := FIdContext.Connection.IOHandler.ReadString;
end;

procedure TBirds.Add(const ABird: TBirdSocketConnection);
begin
  LockList.Add(ABird);
  UnLockList;
end;

constructor TBirds.Create;
begin
  FItems := TList<TBirdSocketConnection>.Create;
end;

destructor TBirds.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TBirds.Last: TBirdSocketConnection;
begin
  Result := LockList.Last;
  UnLockList;
end;

function TBirds.LockList: TList<TBirdSocketConnection>;
begin
  while FListLocked do
  begin
    Sleep(100);
    Continue;
  end;
  FListLocked := True;
  Result := FItems;
end;

procedure TBirds.Remove(const ABird: TBirdSocketConnection);
begin
  LockList;
  FItems.Remove(ABird);
  UnLockList;
end;

procedure TBirds.UnLockList;
begin
  FListLocked := False;
end;

end.
