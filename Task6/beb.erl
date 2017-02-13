-module(beb).
-export([start/0]).

start() -> 
    receive
        {bindPLAndApp, RBPID, PlPID} -> next(RBPID, PlPID)
    end.

next(RBPID, PlPID) ->
    receive
        {beb_broadcast, Message} ->
%            io:format("Received BEB broadcast: ~p~n", [Message]),
            [PlPID ! {pl_send, ToToken, Message} || ToToken <- lists:seq(1, 5)];
        {pl_deliver, Message} ->
%            io:format("BEB UP! ~p~n", [Message]),
            RBPID ! {beb_deliver, Message}
    end,
    next(RBPID, PlPID).

