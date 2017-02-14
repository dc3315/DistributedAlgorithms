% David Cattle (dc3314), Jan Matas (jm6214)
-module(beb).
-export([start/0]).

start() -> 
    receive
        {bindPLAndApp, AppPID, PlPID, N} -> next(AppPID, PlPID, N)
    end.

% Same as for pl, we force fairness by giving the process a chance to 
% deliver messages, despite being flooded by broadcast signals.
next(AppPID, PlPID, N) ->
    receive
        {beb_broadcast, Message} ->
            [PlPID ! {pl_send, ToToken, Message} || ToToken <- lists:seq(1, N)],
            deliver(AppPID, PlPID, N)
    after 0 ->
        deliver(AppPID, PlPID, N)
    end.

deliver(AppPID, PlPID, N) ->
    receive 
        {pl_deliver, Message} -> 
            AppPID ! {beb_deliver, Message},
            next(AppPID, PlPID, N)
    after 0 ->
        next(AppPID, PlPID, N)
    end.

