-module(system1).
-export([start/0]).


start() ->
  % Create 5 processes, and for each process, send the list of the PIDS
  % of other processes. Then, ask for task1 to be executed.
  N = 5,
  Processes = [spawn(process, start, []) || _ <- lists:seq(1, N)],
  _ = [X ! {bind, Processes -- [X]} || X <- Processes],
  MaxMessages = 1000,
  TimeOut = 3000,
  [Process ! {task1, start, MaxMessages, TimeOut} || Process <- Processes].
%  erlang:halt(). % Return 0.



  
