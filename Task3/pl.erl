% David Cattle (dc3314), Jan Matas (jm6214)
-module(pl).
-export([start/0]).

% Bind the PL link to the corresponding App.
start() -> 
    receive
        {bindBEB, BEBPID, SystemPID} ->    
            next(BEBPID, SystemPID)
    end.

% Receive all other PL addresses.
next(BEBPID, SystemPID) -> 
    receive
        {interConnectPLs, PlMappings} -> 
            PlMap = maps:from_list(PlMappings ++ [{0, SystemPID}]),
            ready(PlMap, BEBPID)
    end.


%% Get ready to transmit / deliver.
% Scan the queue for any 'pl_send' messages, if there is one,
% send it, then check for any deliveries, then recurse. 
% This ensures that we give the process a chance to deliver messages
% if it is flooded with send messages (from beb broadcasts).
ready(PlMap, BEBPID) ->
    receive
        {pl_send, ToToken, Message} -> 
            maps:get(ToToken, PlMap) ! {inter_pl, Message},
            deliver(PlMap, BEBPID)
    after 0 ->
        deliver(PlMap, BEBPID)
    end.


deliver(PlMap, BEBPID) ->
    receive
        {inter_pl, _Message} ->
            BEBPID ! {pl_deliver, _Message},
            ready(PlMap, BEBPID)
    after 0 ->
        ready(PlMap, BEBPID)
    end.

