% David Cattle (dc3314), Jan Matas (jm6214)
-module(system5).
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
    countTermination(N-1). % One less since 3 dies.


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
    MaxMessages = 100,
    Time = 1000,
    [PlPID ! {inter_pl, {task1, start, MaxMessages, Time}} || {_, PlPID} <- PlPIDs].


% Halt all process once all processes have logged their values.
countTermination(0) -> halt();
countTermination(N) ->
    receive
        terminate -> countTermination(N - 1)
    end.
