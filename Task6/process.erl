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

    RBPID = spawn(rb, start, []),

    RBPID ! {bind, BEBPID, AppPID},

    BEBPID ! {bindPLAndApp, RBPID, PlPID},
    PlPID ! {bindBEB, BEBPID, SystemPID, 100},

    AppPID ! {bindBEB, RBPID, SelfToken, N, SystemPID},

    SystemPID ! {plPID, PlPID, SelfToken},
    receive
        {task1, start, MaxMessages, Time} -> 
            AppPID ! {task1, start, MaxMessages, Time}
    end.
