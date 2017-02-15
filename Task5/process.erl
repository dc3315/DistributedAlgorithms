% David Cattle (dc3314), Jan Matas (jm6214)
-module(process).
-export([start/0]).


start() -> 
  receive
    {bindSystem, SystemPID, SelfToken, N} -> 
        next(SystemPID, SelfToken, N)
  end.


next(SystemPID, SelfToken, N) ->
    PlPID = spawn_link(pl, start, []),
    AppPID = spawn_link(app, start, []),
    BEBPID = spawn_link(beb, start, []),
    BEBPID ! {bindPLAndApp, AppPID, PlPID, N},
    PlPID ! {bindBEB, BEBPID, SystemPID, 100},
    AppPID ! {bindBEB, BEBPID, SelfToken, N, SystemPID},
    SystemPID ! {plPID, PlPID, SelfToken},
    receive
        {task1, start, MaxMessages, Time} -> 
            AppPID ! {task1, start, MaxMessages, Time}
    end,
    if 
        SelfToken == 3 ->
            timer:sleep(12),
            exit(kill);
        true ->
            ok
    end.
