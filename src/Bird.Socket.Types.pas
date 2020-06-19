unit Bird.Socket.Types;

interface

uses System.Generics.Collections, IdCustomTCPServer, Bird.Socket.Connection;

type
  THeaders = TDictionary<string, string>;
  TEventListener = reference to procedure(const ABird: TBirdSocketConnection);

{$SCOPEDENUMS ON}
  TEventType = (CONNECT, EXECUTE, DISCONNECT);
{$SCOPEDENUMS OFF}

implementation

end.
