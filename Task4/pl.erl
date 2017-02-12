-module(pl).
-export([start/0]).

% Bind the PL link to the corresponding App.
start() -> 
    receive
        {bindBEB, BEBPID, SystemPID, Rel} -> next(BEBPID, SystemPID, Rel)
    end.

% Receive all other PL addresses.
next(BEBPID, SystemPID, Rel) -> 
    receive
        {interConnectPLs, PlMappings} -> 
            PlMap = maps:from_list(PlMappings ++ [{0, SystemPID}]),
            ready(PlMap, BEBPID, Rel)
    end.

% Get ready to transmit / deliver.
ready(PlMap, BEBPID, Rel) ->
    receive
        {pl_send, ToToken, Message} -> 
            N = random:uniform(100),
            if 
                N =< Rel ->
                    maps:get(ToToken, PlMap) ! Message;
                true -> 
                    ready(PlMap, BEBPID, Rel)
            end;
        _Message -> 
            BEBPID ! {pl_deliver, _Message}
    end,
    ready(PlMap, BEBPID, Rel).

