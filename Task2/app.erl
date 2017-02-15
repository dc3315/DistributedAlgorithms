% David Cattle (dc3314), Jan Matas (jm6214)
-module(app).
-export([start/0]).

start() ->
    receive
        {bindPL, PlPID, SelfToken, N, SystemPID} -> 
            task1(PlPID, SelfToken, N, SystemPID)
    end.

    
task1(PlPID, SelfToken, N, SystemPID) -> 
    receive
        % Upon reception of the trigger, start the game.
        {task1, start, MaxMessages, Time} -> 
            timer:send_after(Time, timeout),
            From = maps:from_list([{Token, 0} || Token <- lists:seq(1, N)]), 
            To = maps:from_list([{Token, 0} || Token <- lists:seq(1, N)]),
            if
                % Special case.
                MaxMessages == 0 ->
                    task1Helper(infinity, From, To, 0, PlPID, SelfToken, N, SystemPID);
                true ->
                    task1Helper(MaxMessages, From, To, 0, PlPID, SelfToken, N, SystemPID)
            end
    end.


task1Helper(MaxMessages, From, To, CurrentCount, PlPID, SelfToken, N, SystemPID) -> 
    receive
        timeout ->
                    % Log and exit.
                    Vals = lists:flatten([io_lib:format("{~p,~p} ", 
                    [maps:get(Key, To), maps:get(Key, From)]) || Key <- lists:seq(1, N)]),
                    io:format(io_lib:format("~p: ", [SelfToken]) ++ Vals ++ io_lib:format("~n", [])),
                    SystemPID ! terminate;
        {pl_deliver, {_, FromToken, up}} -> 
                    NewFrom = maps:update(FromToken, maps:get(FromToken, From) + 1, From),
                    task1Helper(MaxMessages, NewFrom, To, CurrentCount, PlPID, SelfToken, N, SystemPID)
    after
        0 ->
            if
                CurrentCount < MaxMessages ->
                    [PlPID ! {pl_send, ToToken, {message, SelfToken, up}} || ToToken <- lists:seq(1,N)],
                    NewTo = incrementMapValuesFromKeyList(To, lists:seq(1, N)),
                    task1Helper(MaxMessages, From, NewTo, CurrentCount + 1, PlPID, SelfToken, N, SystemPID);
                true ->
                    task1Helper(MaxMessages, From, To, CurrentCount, PlPID, SelfToken, N, SystemPID)
            end
    end.


incrementMapValuesFromKeyList(Map, Keys) ->
    maps:from_list([{K, maps:get(K, Map) + 1} || K <- Keys]).   

