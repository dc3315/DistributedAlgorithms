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

% Get ready to transmit / deliver.
ready(PlMap, AppPID) ->
    receive
        {pl_send, ToToken, Message} -> maps:get(ToToken, PlMap) ! Message;
        {_, FromToken, Message} -> AppPID ! {pl_deliver, FromToken, Message}
    end,
    ready(PlMap, AppPID).

