-module(app).
-export([start/0]).

start() ->
    receive
        {bindBEB, BEBPID, SelfToken, N} -> 
            task1(BEBPID, SelfToken, N)
    end.

    
task1(BEBPID, SelfToken, N) -> 
    receive
        % Upon reception of the trigger, start the game.
        {beb_deliver, 0, {task1, start, MaxMessages, Time}} -> 
            timer:send_after(Time, {beb_deliver, -1, timeout}),
            From = maps:from_list([{Token, 0} || Token <- lists:seq(1, N)]), 
            To = maps:from_list([{Token, 0} || Token <- lists:seq(1, N)]),
            if
                % Special case.
                MaxMessages == 0 ->
                    task1Helper(infinity, From, To, 0, BEBPID, SelfToken, N);
                true ->
                    task1Helper(MaxMessages, From, To, 0, BEBPID, SelfToken, N)
            end
    end.


task1Helper(MaxMessages, From, To, CurrentCount, BEBPID, SelfToken, N) -> 
    receive
        {beb_deliver, FromToken, Message} ->  
            case Message of
                timeout -> 
                    % Log and exit.
                    Vals = lists:flatten([io_lib:format("{~p,~p} ", 
                    [maps:get(Key, To), maps:get(Key, From)]) || Key <- lists:seq(1, N)]),
                    io:format(io_lib:format("~p: ", [SelfToken]) ++ Vals ++ io_lib:format("~n", [])),
                    BEBPID ! {beb_broadcast, {message, SelfToken, done}};
                up -> 
%                    io:format("Upping!~n"),
                    NewFrom = maps:update(FromToken, maps:get(FromToken, From) + 1, From),
                    task1Helper(MaxMessages, NewFrom, To, CurrentCount, BEBPID, SelfToken, N)
            end
    after
        0 ->
            if
                CurrentCount < MaxMessages ->
                    NewTo = incrementMapValuesFromKeyList(To, lists:seq(1, N)),
                    BEBPID ! {beb_broadcast, {message, SelfToken, up}},
 %                   io:format("Broadcasting!~n"),
                    task1Helper(MaxMessages, From, NewTo, CurrentCount + 1, BEBPID, SelfToken, N);
                true ->
                    task1Helper(MaxMessages, From, To, CurrentCount, BEBPID, SelfToken, N)
            end
    end.


incrementMapValuesFromKeyList(Map, Keys) ->
    maps:from_list([{K, maps:get(K, Map) + 1} || K <- Keys]).   

