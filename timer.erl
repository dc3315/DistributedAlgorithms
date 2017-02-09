-module(timer).
-export([start/0]).

start() -> 
  receive
    {bind, Process, Time} -> next(Process, Time)
  end.

next(Process, Time) ->
  timer:send_after(Time, Process, {timeout}).
