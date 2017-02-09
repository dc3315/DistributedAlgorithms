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
  T ! {bind, self(), TimeOut},
  % Start broadcasting and receiving.
  task1Helper(MaxMessages, Processes, #{}, #{}, 0).

task1Helper(MaxMessages, Processes, From, To, CurrentCount) ->
  % if MaxMessage is > CurrentCount:
  % block here.
  % otherwise
  receive
    {message, Sender} -> updateMap();
    {timeout} -> log()
  after
    0 -> broadcast(Processes, MaxMessages, CurrentCount)
  end.

updateMap() -> ok.
broadcast(P, M, C) -> ok.
log() -> ok.
