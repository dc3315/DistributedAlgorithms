-module(timer).
-export([start/0]).

start() -> 
  receive
    {bind, Process, Time} -> next(Process, Time)
  end.

next(Process, Time) ->
  %io:format("TIMER OK~n"),
  timer:send_after(Time, Process, {timeout}).
