-module(app).
-export([start/0]).

start() ->
    receive
        {appstart, PL, SelfID, N} -> 
            task1(PL, SelfID, N)
    end.

    
task1(PL, SelfID, N) -> 
    receive
        {pl_deliver, 0, {task1, start, MaxMessages, Time}} -> 
            timer:send_after(Time, {pl_deliver, -1, timeout}),
            From = maps:from_list([{Token, 0} || Token <- lists:seq(1, N)]), 
            To = maps:from_list([{Token, 0} || Token <- lists:seq(1, N)]),
            if 
                MaxMessages == 0 ->
                    task1Helper(infinity, From, To, 0, PL, SelfID, N);
                true ->
                    task1Helper(MaxMessages, From, To, 0, PL, SelfID, N)
            end
    end.


task1Helper(MaxMessages, From, To, CurrentCount, PL, SelfID, N) -> 
    receive
        {pl_deliver, FromToken, Message} -> 
            
            case Message of
                timeout -> 
                    Vals = lists:flatten([io_lib:format("{~p,~p} ", 
                    [maps:get(Key, To), maps:get(Key, From)]) || Key <- lists:seq(1, N)]),
                    io:format(io_lib:format("~p: ", [SelfID]) ++ Vals ++ io_lib:format("~n", [])),
                    PL ! {pl_send, 0, done};
                up -> 
                    NewFrom = maps:update(FromToken, maps:get(FromToken, From) + 1, From),
                    task1Helper(MaxMessages, NewFrom, To, CurrentCount, PL, SelfID, N)
            end
    after
        0 ->
            if
                CurrentCount < MaxMessages ->
                    NewTo = incrementMapValuesFromKeyList(To, lists:seq(1,5)),
                    [PL ! {pl_send, K, {message, SelfID, up}} || K <- lists:seq(1,N)],
                    task1Helper(MaxMessages, From, NewTo, CurrentCount + 1, PL, SelfID, N);
                true ->
                    task1Helper(MaxMessages, From, To, CurrentCount, PL, SelfID, N)
            end
    end.


incrementMapValuesFromKeyList(Map, Keys) ->
    maps:from_list([{K, maps:get(K, Map) + 1} || K <- Keys]).   

