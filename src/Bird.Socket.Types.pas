unit Bird.Socket.Types;

interface

uses System.Generics.Collections, IdCustomTCPServer, Bird.Socket.Context;

type
  THeaders = TDictionary<string, string>;
  TEventListener = reference to procedure(const AContext: TBirdSocketContext);

{$SCOPEDENUMS ON}
  TEventType = (CONNECT, EXECUTE, DISCONNECT);
{$SCOPEDENUMS OFF}

implementation

end.
