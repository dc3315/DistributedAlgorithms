% David Cattle (dc3314), Jan Matas (jm6214)
-module(system1).
-export([start/0]).


start() ->
    % Create N processes, and for each process, send the list of the PTokenS
    % of other processes. Then, ask for task1 to be executed.
    N = 5,
    ProcessPIDs = [spawn(process, start, []) || _ <- lists:seq(1, N)],
    % Process PID list is in order.
    _ = [X ! {bindSystem, ProcessPIDs} || X <- ProcessPIDs],
    MaxMessages = 0,
    TimeOut = 3000,
    [lists:nth(Token, ProcessPIDs) ! {task1, start, MaxMessages, TimeOut, self(), Token} 
    || Token <- lists:seq(1, N)],
    countTermination(N).


% Halt after all processes have logged their values.
countTermination(0) -> halt();
countTermination(N) -> 
    receive
        done -> countTermination(N - 1)
    end.  
