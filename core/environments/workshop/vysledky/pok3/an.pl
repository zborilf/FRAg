

:-include("stats.pl").

g:-bagof(L,stats_(L),LO), writeln(LO), suml(LO, A, B), writeln(A), writeln(B).

suml([], 0, 0).
suml([L|LT], O1, CO1):-
    suml(LT, O2, CO2), 
    member(rewards(workerCL,CO3), L),
    member(rewards(workerE,O3), L),
    O1 is O2+O3,
    CO1 is CO2+CO3.