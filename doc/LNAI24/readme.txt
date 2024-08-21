
1, Program Execution
2, Program Description
3, Output Description



1, Program Execution

Let the directory where FRAg is located be marked as @FRAg. There should be subdirectories 
@FRAg\core @FRAg\examples @FRAg\doc at least.

. In SWI PROLOG consult @FRAg\core\FRAgPL.pl
. ?-frag('../examples/worker/worker).

Output is in @FRAg\examples\worker\ ... some *.out, filename depends on setting of the trader 
multiagent system in @FRAg\examples\worker\worker.mas2fp


2, Program description

2.1 Agent code (in @FRAg\examples\trader\trader.fap)

This file contains a procedure to run and analyse the examples we presented at extended paper of
the ICAART24 conference. The program is about robots working at ...
