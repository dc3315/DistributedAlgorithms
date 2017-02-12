-module(system3).
-export([start/0]).


start() ->
    % Create N processes.
    N = 5,
    Processes = [spawn(process, start, []) || _ <- lists:seq(1, N)],
    % Send each process the system pid, its own token, and the number
    % of other processes.
    [lists:nth(Token, Processes) ! {bindSystem, self(), Token, N} 
    || Token <- lists:seq(1, N)],
    % Then, wait for each process to send their PL addresses.
    PlPIDs = awaitLinks(N, []),
    % Once we have those, interConnect each PL.
    interConnect(PlPIDs),
    % Then invoke task1.
    task1(PlPIDs),
    countTermination(N).


% Get all the PL PIDs to interconnect them all together afterwards.
awaitLinks(0, PlPIDs) -> PlPIDs;
awaitLinks(N, PlPIDs) ->
    receive
        {plPID, PlPID, ProcToken} -> 
            awaitLinks(N - 1, PlPIDs ++ [{ProcToken, PlPID}])
    end.


% Interconnect all PLs by sending the addresses of all PLs.
interConnect(PlPIDs) -> 
    [PlPID ! {interConnectPLs, PlPIDs} || {_, PlPID} <- PlPIDs].
    
    
% Start the execution of task1.
task1(PlPIDs) ->
   MaxMessages = 0,
   Time = 2000, 
   [PlPID ! {message, 0, {task1, start, MaxMessages, Time}} 
   || {_, PlPID} <- PlPIDs].


% Halt all process once all processes have logged their values.
countTermination(0) -> halt();
countTermination(N) -> 
    receive
        done -> countTermination(N - 1)
    end.  
