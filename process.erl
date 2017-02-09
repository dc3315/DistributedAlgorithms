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
  io:format("OK!~n"),
  task1Helper(MaxMessages, Processes, #{}, #{}, 0).

task1Helper(MaxMessages, Processes, From, To, CurrentCount) ->
  % if MaxMessage is > CurrentCount:
  % block here.
  % otherwise
  io:format("OK TASK1HELPER~n"),
  receive
    {message, Sender} -> updateMap();
    {timeout} -> halt()
  after
    0 -> broadcast(Processes, MaxMessages, CurrentCount)
  end.

updateMap() -> ok.
broadcast(P, M, C) -> halt().
log() -> ok.
