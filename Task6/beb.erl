-module(beb).
-export([start/0]).

start() ->
    receive
        {bindPLAndApp, RBPID, PlPID} -> next(RBPID, PlPID)
    end.

next(RBPID, PlPID) ->
    receive
        {beb_broadcast, Message} ->
            [PlPID ! {pl_send, ToToken, Message} || ToToken <- lists:seq(1, 5)]
    after 0 ->
      ok
    end,
    deliver(RBPID, PlPID).

deliver(RBPID, PlPID) ->
  receive
      {pl_deliver, Message} ->
          RBPID ! {beb_deliver, Message}
      after 0 ->
        ok
  end,
  next(RBPID, PlPID).
