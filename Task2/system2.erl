-module(system2).
-export([start/0]).


start() ->
    % Create N processes.
    N = 5,
    Processes = [spawn(process, start, []) || _ <- lists:seq(1, N)],
    % Send each process the list of processes, the system pid, and its own id.
    [lists:nth(K, Processes) ! {bind, self(), K, N} || K <- lists:seq(1, N)],
    % Then, wait for each process to send their P2P link addresses.
    PLs = awaitP2PLinks(N, []),
    interconnect(PLs),
    countTermination(N).


% Only interconnect the Perfect links once all of the have been received.
awaitP2PLinks(0, PLs) -> PLs;
awaitP2PLinks(N, PLs) ->
    receive
        {p2pLinkID, PL, ProcID} -> 
            awaitP2PLinks(N - 1, PLs ++ [{ProcID, PL}])
    end.


% Send each perfect link the ids of other links + their corresponding process.
interconnect(PLs) -> 
    [PL ! {interconnect, PLs} || {_, PL} <- PLs],
    timer:sleep(1000),
    task1(PLs).
    

task1(PLs) ->
   MaxMessages = 0,
   Time = 3000, 
   [PL ! {message, 0, {task1, start, MaxMessages, Time}} || {_, PL} <- PLs].


%
%% Halt after all processes have logged their values.
countTermination(0) -> halt();
countTermination(N) -> 
    receive
        done -> countTermination(N - 1)
    end.  
