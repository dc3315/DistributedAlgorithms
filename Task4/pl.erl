% David Cattle (dc3314), Jan Matas (jm6214)
-module(pl).
-export([start/0]).

% Bind the PL link to the corresponding App.
start() ->
    receive
        {bindBEB, BEBPID, SystemPID, Rel} ->
            next(BEBPID, SystemPID, Rel)
    end.

% Receive all other PL addresses.
next(BEBPID, SystemPID, Rel) ->
    receive
        {interConnectPLs, PlMappings} ->
            PlMap = maps:from_list(PlMappings ++ [{0, SystemPID}]),
            ready(PlMap, BEBPID, Rel)
    end.


%% Get ready to transmit / deliver.
% Scan the queue for any 'pl_send' messages, if there is one,
% send it, then check for any deliveries, then recurse.
% This ensures that we give the process a chance to deliver messages
% if it is flooded with send messages (from beb broadcasts).
ready(PlMap, BEBPID, Rel) ->
    receive
        {pl_send, ToToken, Message} ->
            N = rand:uniform(100),
            if
                N =< Rel ->
                    maps:get(ToToken, PlMap) ! {inter_pl, Message};
                true ->
                    ok
            end,
            deliver(PlMap, BEBPID, Rel)
    after 0 ->
        deliver(PlMap, BEBPID, Rel)
    end.

deliver(PlMap, BEBPID, Rel) ->
    receive
        {inter_pl, _Message} ->
            BEBPID ! {pl_deliver, _Message},
            ready(PlMap, BEBPID, Rel)
    after 0 ->
        ready(PlMap, BEBPID, Rel)
    end.
