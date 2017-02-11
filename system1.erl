-module(system1).
-export([start/0]).


start() ->
    % Create N processes, and for each process, send the list of the PIDS
    % of other processes. Then, ask for task1 to be executed.
    N = 5,
    Processes = [spawn(process, start, []) || _ <- lists:seq(1, N)],
    % Process list is in order.
    _ = [X ! {bind, Processes} || X <- Processes],
    MaxMessages = 0,
    TimeOut = 3000,
    [lists:nth(ID, Processes) ! {task1, start, MaxMessages, TimeOut, self(), ID} 
    || ID <- lists:seq(1, N)],
    countTermination(N).


% Halt after all processes have logged their values.
countTermination(0) -> halt();
countTermination(N) -> 
    receive
        done -> countTermination(N - 1)
    end.  
