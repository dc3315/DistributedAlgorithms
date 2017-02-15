% David Cattle (dc3314), Jan Matas (jm6214)
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
    AppPID ! {bindPL, PlPID, SelfToken, N, SystemPID},
    PlPID ! {bindApp, AppPID, SystemPID},
    SystemPID ! {plPID, PlPID, SelfToken},
    receive
        {task1, start, MaxMessages, Time} ->
            AppPID ! {task1, start, MaxMessages, Time}
    end.

