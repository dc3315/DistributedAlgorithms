% David Cattle (dc3314), Jan Matas (jm6214)
-module(beb).
-export([start/0]).

start() -> 
    receive
        {bindPLAndApp, AppPID, PlPID} -> next(AppPID, PlPID)
    end.

next(AppPID, PlPID) ->
    receive
        {beb_broadcast, Message} ->
            [PlPID ! {pl_send, ToToken, Message} || ToToken <- lists:seq(1, 5)],
            deliver(AppPID, PlPID)
    after 0 ->
        deliver(AppPID, PlPID)
    end.

deliver(AppPID, PlPID) ->
    receive 
        {pl_deliver, Message} -> 
            AppPID ! {beb_deliver, Message},
            next(AppPID, PlPID)
    after 0 ->
        next(AppPID, PlPID)
    end.

