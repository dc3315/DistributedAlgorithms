-module(app).
-export([start/0]).

start() ->
    receive
        {appstart, PL, SelfID, N} -> %io:format("Ok app started!~p~n", [SelfID]), 
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
                    task1Helper(infinity, From, To, 0, PL, SelfID);
                true ->
                    task1Helper(MaxMessages, From, To, 0, PL, SelfID)
            end
    end.



task1Helper(MaxMessages, From, To, CurrentCount, PL, SelfID) -> 
    receive
        {pl_deliver, FromToken, Message} -> 
            
            case Message of
                timeout -> 
                    Vals = lists:flatten([io_lib:format("{~p,~p} ", 
                    [maps:get(Key, To), maps:get(Key, From)]) || Key <- lists:seq(1, 5)]),
                    io:format(io_lib:format("~p: ", [SelfID]) ++ Vals ++ io_lib:format("~n", [])),
                    PL ! {pl_send, 0, done};
                up -> 
                    NewFrom = maps:update(FromToken, maps:get(FromToken, From) + 1, From),
                    task1Helper(MaxMessages, NewFrom, To, CurrentCount, PL, SelfID)
            end
    after
        0 ->
            if
                CurrentCount < MaxMessages ->
                    NewTo = incrementMapValuesFromKeyList(To, lists:seq(1,5)),
                    [PL ! {pl_send, K, {message, SelfID, up}} || K <- lists:seq(1,5)],
                    task1Helper(MaxMessages, From, NewTo, CurrentCount + 1, PL, SelfID);
                true ->
                    task1Helper(MaxMessages, From, To, CurrentCount, PL, SelfID)
            end
    end.
%{pl_send, K, {message, SelfID, message}}
%
incrementMapValuesFromKeyList(Map, Keys) ->
    maps:from_list([{K, maps:get(K, Map) + 1} || K <- Keys]).   
%task1Helper(MaxMessages, Processes, From, To, CurrentCount, System, ID) ->
%  receive
%    timeout ->        
%        % Create a formatted string, and print it.
%        Vals = lists:flatten([io_lib:format("{~p,~p} ", 
%                [maps:get(Key, To), maps:get(Key, From)]) || Key <- Processes]),
%        io:format(io_lib:format("~p: ", [ID]) ++ Vals ++ io_lib:format("~n", [])),
%        % Notify the system.
%        System ! done;
%    {message, Sender} ->
%        % Update received count.

%        task1Helper(MaxMessages, Processes, NewFrom, To, CurrentCount, System, ID)
%  after
%    0 ->
%      if 
%        % If you can, broadcast.
%        CurrentCount < MaxMessages ->
%            NewTo = incrementMapValuesFromKeyList(To, Processes),
%            [Process ! {message, self()} || Process <- Processes],
%            task1Helper(MaxMessages, Processes, From, NewTo, 
%                        CurrentCount + 1, System, ID); 
%        % Otherwise, just wait for the timeout.
%        true ->
%            task1Helper(MaxMessages, Processes, From, To, CurrentCount, System, ID)
%      end
%  end.
%
% % All keys are guaranteed to be in the map, therefore maps:get will not fail.

