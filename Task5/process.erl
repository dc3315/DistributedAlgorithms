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
    PlPID ! {bindBEB, BEBPID, SystemPID, 100},

    AppPID ! {bindBEB, BEBPID, SelfToken, N, SystemPID},
    SystemPID ! {plPID, PlPID, SelfToken}.
%    if 
%        SelfToken == 3 ->
%            timer:kill_after(5);
%        true -> ok
%    end.
