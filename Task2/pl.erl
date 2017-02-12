-module(pl).
-export([start/0]).


start() -> 
    receive
        {app, AppPID, SystemPID} -> next(AppPID, SystemPID)
    end.

next(AppPID, SystemPID) -> 
    receive
        {interconnect, PLs} -> 
            PlMap = maps:from_list(PLs ++ [{0, SystemPID}]),
            ready(PlMap, AppPID)
    end.

ready(PlMap, AppPID) ->
    receive
        % Just forward to owner using pl_deliver.
        {pl_send, ToID, Message} -> maps:get(ToID, PlMap) ! Message;
        {message, FromID, Message} -> AppPID ! {pl_deliver, FromID, Message}
    end,
    ready(PlMap, AppPID).

