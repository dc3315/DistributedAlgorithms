% David Cattle (dc3314), Jan Matas (jm6214)
-module(pl).
-export([start/0]).

% Bind the PL link to the corresponding App.
start() -> 
    receive
        {bindApp, AppPID, SystemPID} -> next(AppPID, SystemPID)
    end.

% Receive all other PL addresses.
next(AppPID, SystemPID) -> 
    receive
        {interConnectPLs, PlMappings} -> 
            PlMap = maps:from_list(PlMappings ++ [{0, SystemPID}]),
            ready(PlMap, AppPID)
    end.

% Scan the queue for any 'pl_send' messages, if there is one,
% send it, then check for any deliveries, then recurse. 
% This ensures that we give the process a chance to deliver messages
% if it is flooded with send messages (from beb broadcasts).
ready(PlMap, AppPID) ->
    receive
        {pl_send, ToToken, Message} -> 
            maps:get(ToToken, PlMap) ! {inter_pl, Message},
            deliver(PlMap, AppPID)
    after 0 ->
        deliver(PlMap, AppPID)
    end.

deliver(PlMap, AppPID) ->
    receive
        {inter_pl, _Message} ->
            AppPID ! {pl_deliver, _Message},
            ready(PlMap, AppPID)
    after 0 ->
        ready(PlMap, AppPID)
    end.


