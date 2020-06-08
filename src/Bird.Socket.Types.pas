unit Bird.Socket.Types;

interface

uses System.Generics.Collections, IdContext, IdCustomTCPServer;

type
  THeaders = TDictionary<string, string>;
  TEventListener = reference to procedure(const AContext: TIdContext);

{$SCOPEDENUMS ON}
  TEventType = (CONNECT, EXECUTE, DISCONNECT);
{$SCOPEDENUMS OFF}

implementation

end.
