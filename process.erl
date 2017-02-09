-module(process).
-export([start/0]).

start() -> 
  receive
    {bind, Processes} -> next(Processes)
  end.

next(Processes) ->
  receive
    {task1, start, MaxMessages, Time} -> task1(MaxMessages, Time, Processes)
  end.

task1(MaxMessages, Time, Processes) -> 
  % Set up a timer to interrupt the process after Time milliseconds.
  T = spawn(timer, start, []),
  T ! {bind, self(), Time},
  % Start broadcasting and receiving.
  % Initialise From and To maps.
  From = maps:from_list([{Process, 0} || Process <- Processes]), 
  To = maps:from_list([{Process, 0} || Process <- Processes]),
  task1Helper(MaxMessages, Processes, From, To, 0).

task1Helper(MaxMessages, Processes, From, To, CurrentCount) ->
  % if MaxMessage is > CurrentCount:
  % block here.
  % otherwise
  receive
    {message, Sender} -> 
      NewFrom = incrementMapValuesFromKeyList(From, [Sender]),
      task1Helper(MaxMessages, Processes, NewFrom, To, CurrentCount);
    {timeout} -> halt()
  after
    0 ->
      [Process ! {message, self()} || Process <- Processes], %broadcast.
      NewTo = incrementMapValuesFromKeyList(To, Processes),
      task1Helper(MaxMessages, Processes, From, NewTo, CurrentCount + 1)
  end.

% All keys are guaranteed to be in the map, therefore maps:get will not fail.
incrementMapValuesFromKeyList(Map, Keys) ->
  maps:from_list([{K, maps:get(K, Map) + 1} || K <- Keys]).

broadcast(P, M, C) -> halt().
log() -> ok.
