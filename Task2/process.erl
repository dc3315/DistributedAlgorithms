-module(process).
-export([start/0]).


start() -> 
  receive
    {bind, SystemPID, SelfID, N} -> 
        next(SystemPID, SelfID, N)
  end.


next(SystemPID, SelfID, N) ->
    PL = spawn(p2p, start, []),
    App = spawn(app, start, []),
    
    App ! {appstart, PL, SelfID, N},
    PL ! {app, App, SystemPID},
    SystemPID ! {p2pLinkID, PL, SelfID}.
