-module(rb).
-export([start/0]).


start() -> 
    receive
        {bind, BEBPID, AppPID} -> next(BEBPID, AppPID, [], 0)
    end.

next(BEBPID, AppPID, Messages, Count) ->
    receive
        {rb_broadcast, Message} ->
            BEBPID ! {beb_broadcast, {Message, Count}},
            next(BEBPID, AppPID, Messages, Count + 1);
        {beb_deliver, Message} ->
            case lists:member(Message, Messages) of 
                true ->
                    
                    next(BEBPID, AppPID, Messages, Count);
                false ->
%                    io:format("Received RB deliver ~p~n", [Message]),
                    {Body, _} = Message,
                    AppPID ! {rb_deliver, Body},
                    BEBPID ! {beb_broadcast, Message},
                    next(BEBPID, AppPID, Messages ++ [Message], Count)
            end
    end.
    