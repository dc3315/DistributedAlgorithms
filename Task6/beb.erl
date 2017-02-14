-module(beb).
-export([start/0]).

start() ->
    receive
        {bindPLAndApp, RBPID, PlPID} -> next(RBPID, PlPID)
    end.

next(RBPID, PlPID) ->
    receive
        {beb_broadcast, Message} ->
            [PlPID ! {pl_send, ToToken, Message} || ToToken <- lists:seq(1, 5)],
            deliver(RBPID, PlPID)

    after 0 ->
      deliver(RBPID, PlPID)

    end.

deliver(RBPID, PlPID) ->
  receive
      {pl_deliver, Message} ->
          RBPID ! {beb_deliver, Message},
          next(RBPID, PlPID)
      after 0 ->
        next(RBPID, PlPID)
  end.
