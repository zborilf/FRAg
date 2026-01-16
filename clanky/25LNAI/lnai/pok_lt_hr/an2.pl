

:-include("stats.pl").

g:-bagof(L,stats_(L),LO), 
    writeln(LO), 
    suml(LO, A, B, C, D),
    length(LO, LN), 
    writelength(A, LN),
    writelength(B, LN),
    writelength(C, LN),
    writelength(D, LN).

writelength(N, LN):-
    ND is N / LN,
    writeln(ND).


suml([], 0, 0, 0, 0).
suml([L|LT], SA, SB, SC, SD):-
   suml(LT, A2, B2, C2, D2), 
   member(rewards(workerE,A), L),
   member(rewards(workerCE,B), L),
   member(rewards(workerL,C), L),
   member(rewards(workerCL,D), L),
   SA is A+A2,
   SB is B+B2,
   SC is C+C2,
   SD is D+D2.

