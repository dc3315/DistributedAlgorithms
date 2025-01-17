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
    RBPID = spawn_link(rb, start, []),
    RBPID ! {bind, BEBPID, AppPID},
    BEBPID ! {bindPLAndApp, RBPID, PlPID, N},
    PlPID ! {bindBEB, BEBPID, SystemPID, 100},
    AppPID ! {bindBEB, RBPID, SelfToken, N, SystemPID},
    SystemPID ! {plPID, PlPID, SelfToken},
    % Kill process 3.
    if
      SelfToken == 3 ->
        timer:sleep(12),
        exit(kill);
      true ->
        ok
    end.
