% David Cattle (dc3314), Jan Matas (jm6214)
-module(beb).
-export([start/0]).

start() ->
    receive
        {bindPLAndApp, RBPID, PlPID, N} -> next(RBPID, PlPID, N)
    end.

% Same as for pl, we force fairness by giving the process a chance to 
% deliver messages, despite being flooded by broadcast signals.
next(RBPID, PlPID, N) ->
    receive
        {beb_broadcast, Message} ->
            [PlPID ! {pl_send, ToToken, Message} || ToToken <- lists:seq(1, N)],
            deliver(RBPID, PlPID, N)
    after 0 ->
      deliver(RBPID, PlPID, N)
    end.


deliver(RBPID, PlPID, N) ->
  receive
      {pl_deliver, Message} ->
          RBPID ! {beb_deliver, Message},
          next(RBPID, PlPID, N)
      after 0 ->
        next(RBPID, PlPID, N)
  end.
