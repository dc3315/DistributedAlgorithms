% David Cattle (dc3314), Jan Matas (jm6214)
-module(pl).
-export([start/0]).

% Bind the PL link to the corresponding App.
start() -> 
    receive
        {bindBEB, BEBPID, SystemPID} -> next(BEBPID, SystemPID)
    end.

% Receive all other PL addresses.
next(BEBPID, SystemPID) -> 
    receive
        {interConnectPLs, PlMappings} -> 
            PlMap = maps:from_list(PlMappings ++ [{0, SystemPID}]),
            ready(PlMap, BEBPID)
    end.

% Get ready to transmit / deliver.
ready(PlMap, BEBPID) ->
    receive
        {pl_send, ToToken, Message} -> 
            maps:get(ToToken, PlMap) ! Message;
        _Message -> 
            BEBPID ! {pl_deliver, _Message}
    end,
    ready(PlMap, BEBPID).

