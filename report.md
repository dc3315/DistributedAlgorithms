# 347: Distributed algorithms
# Coursework 1
---
## Task 5 - – Faulty	Process

## Task 6 – Eager	Reliable	Broadcast
We have decided to test the system with multiple sets of parameters to see how
the system behaves under different conditions. We found the results of 3 cases
particularly interesting:
* Limited messages and long timeout
* Limited messages and very short timeout
* Infinite messages

We did not find playing with `process 3` timeout particularly enlightening.
With small values (3ms or less) it just finished without sending any message,
otherwise the number of received messages increased approximately linearly
with the timeout.

### Limited messages and long timeout
After running with `Max_messages = 100` and `Timeout = 3000` we got the
following result:
```
1: {100,100} {100,100} {100,2} {100,100} {100,100}
4: {100,100} {100,100} {100,2} {100,100} {100,100}
5: {100,100} {100,100} {100,2} {100,100} {100,100}
2: {100,100} {100,100} {100,2} {100,100} {100,100}
```
We can see that all processes finish sending `Max_messages` apart from
`process 3`, who is killed earlier. On multiple runs, we see the number of
messages received from `process 3` vary significantly, but it is always the same
across all the correct processes, as we would expect from reliable broadcast.

Increasing the lossiness of the link, we see that the number of successful
receives decreases slowly. On 80%, it seems that we still have more than 99%
confidence that broadcasted messages will be seen by all hosts.
On 50% reliability, hosts report on average 87
receives and on 10% reliability they report on average 15% receives (it should
be noted that we stopped `process 3` from failing when testing the link
reliability, to simplify our next computation.)

We tried to model this mathematically to find the actual probability of a message
reaching a given destination from a given start point:

```
# P(N) is a probability that a link of length N fails

P(1) = (1 - rel)
P(N) = P (N - 1) * rel + ( 1 - rel)

Assuming 5 nodes, there are:
1 path from Start to Dest of Length 1
3 paths from Start to Dest of Length 2
6 paths from Start to Dest of Length 3
6 paths from Start to Dest of Length 4

The probability the message is delivered is then:

1 - P(1) * P(2) ^ 3 * P(3) ^ 6 * P(4) ^ 6

because we need all paths from start to destination fail in order for
destination node never to see a message.
```
Our experimental results seems to more or less follow this model. However,
there is a known weakness that some of the longer paths were already invalidated
by partial successful deliveries on shorter paths. We chose to ignore this,
because we found it impossible to model.

### Limited messages and short timeout
After running with `Max_messages = 100` and `Timeout = 300` we got the
following result:
```
1: {100,64} {100,100} {100,2} {100,54} {100,54}
5: {100,7} {100,100} {100,1} {100,7} {100,7}
2: {100,100} {100,100} {100,2} {100,100} {100,97}
4: {100,10} {100,100} {100,2} {100,10} {100,10}
```
In this case, we can see that there is no agreement in the number of received
messages from `process 3`. This is caused by the fact that we send the timeout
signal so soon that `process 5` simply did not have enough time to process
all rebroadcasts from other processes and therefore have not seen the second
message yet (it is probably in deliver queue of its `PL`, `BEB` or `RB` component and have not
reached `App` component responsible for counting).
The agreement would be reached later on, if we did not timeout the
system. This theory is also supported by observation that none of the processes
had enough time to finish processing all the messages from correct peers.

### Unlimited messages and long timeout
After running with `Max_messages = 0` and `Timeout = 3000` we got the
following result:
```
1: {19106,169} {19106,529} {19106,7} {19106,948} {19106,689}
4: {23431,186} {23431,553} {23431,7} {23431,1080} {23431,852}
5: {23891,120} {23891,455} {23891,6} {23891,642} {23891,267}
2: {36965,91} {36965,407} {36965,6} {36965,473} {36965,149}
```
In this final case, there is again no consensus reached about the number of the
messages received from `process 3`. We attribute this to the fact that the
low level components (`RB`,`BEB`,`PL`) are flooded with infinity messages from
other peers, so even if the timeout is long, they did not have time to process
all the rebroadcasts of messages from `process 3`. We can see even tough
Eager Reliable Broadcast guarantees that all correct processes will _eventually_
get all the messages, it is not always the case that it happens soon enough before
we shut down the system.

When we set the timeout much higher (10s +), we always see that the system
reaches consensus on number of messages received from `process 3`.
