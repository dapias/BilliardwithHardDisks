#Análisis del performance para las distintas versiones estables del código (in julia0.3).

--------------------------------------------------
| Parameter |Fixed number of cells| Board as a Deque | Board as a Deque but tracing disks just as it's needed|
|-----------------------------------------------
| Elapsed time* | 0.0062 |  0.0040 | 0.075|
|
| Memory* | 2.5 MB  | 1.7 MB |    22 MB |
|
|Number of events* | 494 | 280 | 4000 |
---------------------------------
*Average for  a tmax equal to 1000
