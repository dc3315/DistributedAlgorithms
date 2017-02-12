-module(process).
-export([start/0]).


start() -> 
  receive
    {bindSystem, ProcessPIDs} -> next(ProcessPIDs)
  end.


next(ProcessPIDs) ->
  receive
    {task1, start, MaxMessages, Time, SystemPID, SelfToken} ->
        task1(MaxMessages, Time, ProcessPIDs, SystemPID, SelfToken)
  end.


task1(MaxMessages, Time, ProcessPIDs, SystemPID, SelfToken) -> 
  % Send a timeout after Time ms.
  timer:send_after(Time, timeout),
  % Initialise From and To maps.
  From = maps:from_list([{ProcessPID, 0} || ProcessPID <- ProcessPIDs]), 
  To = maps:from_list([{ProcessPID, 0} || ProcessPID <- ProcessPIDs]),
  % Start sending/listening.
  if 
    MaxMessages == 0 ->
        task1Helper(infinity, ProcessPIDs, From, To, 0, SystemPID, SelfToken);
    true ->
        task1Helper(MaxMessages, ProcessPIDs, From, To, 0, SystemPID, SelfToken)
  end.


task1Helper(MaxMessages, ProcessPIDs, From, To, CurrentCount, SystemPID, SelfToken) ->
  receive
    timeout ->        
        % Create a formatted string, and print it.
        Vals = lists:flatten([io_lib:format("{~p,~p} ", 
                [maps:get(Key, To), maps:get(Key, From)]) || Key <- ProcessPIDs]),
        io:format(io_lib:format("~p: ", [SelfToken]) ++ Vals ++ io_lib:format("~n", [])),
        % Notify the system.
        SystemPID ! done;
    {up, SenderPID} ->
        % Update received count.
        NewFrom = maps:update(SenderPID, maps:get(SenderPID, From) + 1, From), 
        task1Helper(MaxMessages, ProcessPIDs, NewFrom, To, CurrentCount, SystemPID, SelfToken)
  after
    0 ->
      if 
        % If you can, broadcast.
        CurrentCount < MaxMessages ->
            NewTo = incrementMapValuesFromKeyList(To, ProcessPIDs),
            [ProcessPID ! {up, self()} || ProcessPID <- ProcessPIDs],
            task1Helper(MaxMessages, ProcessPIDs, From, NewTo, 
                        CurrentCount + 1, SystemPID, SelfToken); 
        % Otherwise, just wait for the timeout.
        true ->
            task1Helper(MaxMessages, ProcessPIDs, From, To, CurrentCount, SystemPID, SelfToken)
      end
  end.

 % All keys are guaranteed to be in the map, therefore maps:get will not fail.
incrementMapValuesFromKeyList(Map, Keys) ->
    maps:from_list([{K, maps:get(K, Map) + 1} || K <- Keys]).
