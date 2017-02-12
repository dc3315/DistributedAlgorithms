-module(beb).
-export([start/0]).

start() -> 
    receive
        {bindPLAndApp, AppPID, PlPID} -> next(AppPID, PlPID)
    end.

next(AppPID, PlPID) ->
    receive
        terminate -> PlPID ! {pl_send, 0, done};
        {beb_broadcast, Message} ->
            [PlPID ! {pl_send, ToToken, Message} || ToToken <- lists:seq(1, 5)];
        {pl_deliver, {_, From, Message}} -> 
            AppPID ! {beb_deliver, From, Message}
    end,
    next(AppPID, PlPID).

