#Análisis del performance para las distintas versiones estables del código (in julia0.3).

--------------------------------------------------
| Parameter |Fixed number of cells| Board as a Deque | Board as a Deque but tracing disks just as it's needed|
|-----------------------------------------------
| Elapsed time* | 0.17 |  0.070 | 0.075|
|
| Memory* | 70 MB  | 28 MB |    22 MB |
|
|Number of events* | 10000 | 4000 | 4000 |
---------------------------------
*Average for  a tmax equal to 1000
