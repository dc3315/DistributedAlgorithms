-module(process).
-export([start/0]).


start() -> 
  receive
    {bindSystem, SystemPID, SelfToken, N} -> 
        next(SystemPID, SelfToken, N)
  end.


next(SystemPID, SelfToken, N) ->
    PlPID = spawn(pl, start, []),
    AppPID = spawn(app, start, []),
    BEBPID = spawn(beb, start, []),
    
    BEBPID ! {bindPLAndApp, AppPID, PlPID},
    PlPID ! {bindBEB, BEBPID, SystemPID},

    AppPID ! {bindBEB, BEBPID, SelfToken, N},
    SystemPID ! {plPID, PlPID, SelfToken}.
