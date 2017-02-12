-module(process).
-export([start/0]).


start() -> 
  receive
    {bindSystem, Processes} -> next(Processes)
  end.


next(Processes) ->
  receive
    {task1, start, MaxMessages, Time, System, SelfToken} ->
        task1(MaxMessages, Time, Processes, System, SelfToken)
  end.


task1(MaxMessages, Time, Processes, System, SelfToken) -> 
  % Send a timeout after Time ms.
  timer:send_after(Time, timeout),
  % Initialise From and To maps.
  From = maps:from_list([{Process, 0} || Process <- Processes]), 
  To = maps:from_list([{Process, 0} || Process <- Processes]),
  % Start sending/listening.
  if 
    MaxMessages == 0 ->
        task1Helper(infinity, Processes, From, To, 0, System, SelfToken);
    true ->
        task1Helper(MaxMessages, Processes, From, To, 0, System, SelfToken)
  end.


task1Helper(MaxMessages, Processes, From, To, CurrentCount, System, SelfToken) ->
  receive
    timeout ->        
        % Create a formatted string, and print it.
        Vals = lists:flatten([io_lib:format("{~p,~p} ", 
                [maps:get(Key, To), maps:get(Key, From)]) || Key <- Processes]),
        io:format(io_lib:format("~p: ", [SelfToken]) ++ Vals ++ io_lib:format("~n", [])),
        % Notify the system.
        System ! done;
    {message, Sender} ->
        % Update received count.
        NewFrom = maps:update(Sender, maps:get(Sender, From) + 1, From), 
        task1Helper(MaxMessages, Processes, NewFrom, To, CurrentCount, System, SelfToken)
  after
    0 ->
      if 
        % If you can, broadcast.
        CurrentCount < MaxMessages ->
            NewTo = incrementMapValuesFromKeyList(To, Processes),
            [Process ! {message, self()} || Process <- Processes],
            task1Helper(MaxMessages, Processes, From, NewTo, 
                        CurrentCount + 1, System, SelfToken); 
        % Otherwise, just wait for the timeout.
        true ->
            task1Helper(MaxMessages, Processes, From, To, CurrentCount, System, SelfToken)
      end
  end.

 % All keys are guaranteed to be in the map, therefore maps:get will not fail.
incrementMapValuesFromKeyList(Map, Keys) ->
    maps:from_list([{K, maps:get(K, Map) + 1} || K <- Keys]).
