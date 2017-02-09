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
  % Initialise From map.
  From = maps:from_list([{Process, 0} || Process <- Processes]), 
  To = maps:from_list([{Process, 0} || Process <- Processes]),
  task1Helper(MaxMessages, Processes, From, To, 0).

task1Helper(MaxMessages, Processes, From, To, CurrentCount) ->
  % if MaxMessage is > CurrentCount:
  % block here.
  % otherwise
  %io:format("OK TASK1HELPER~n"),
  receive
    {message, Sender} -> ok;
      %NewFrom = incrementMappedValue(From, Sender),
      %task1Helper(MaxMessages, Processes, NewFrom, To, CurrentCount);
    {timeout} -> halt()
  after
    0 -> halt() %broadcast(Processes, MaxMessages, CurrentCount)
      %NewTo = [ Process ! {message, self()} || Process <- Processes ]

  end.

broadcast(P, M, C) -> halt().
log() -> ok.
