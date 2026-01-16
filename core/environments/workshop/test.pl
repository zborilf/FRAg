

pw(Agent):-
    workshop(perceive, Agent, Add_List, Delete_List),
    write(Agent),write(' add:'),writeln(Add_List),
    write(Agent),write(' delete:'),writeln(Delete_List).
   

g3(0).


g3(N):-
    pw(adam),
    N2 is N-1,
    g3(N2).

g2(N):-
    use_module('workshop.pl'),
    workshop(add_agent, adam),
    g3(N).

g:-
    use_module('workshop.pl'),
    workshop(add_agent, adam),
    pw(adam).

