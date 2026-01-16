

pw(Agent):-
    garden(perceive, Agent, Add_List, Delete_List),
    write(Agent),write(' add:'),writeln(Add_List),
    write(Agent),write(' delete:'),writeln(Delete_List).

g:-
    use_module('garden.pl'),
    writeln("Start test:"),
    garden(add_agent, robot),
    pw(robot),
    garden(act, robot, water, Result2),
    writeln("Reward"),
    writeln(Result2),
    pw(robot),
    writeln("Go down:"),
    garden(act, robot, go(down), Result3),
    pw(robot),
    writeln("Go UP:"),
    garden(act, robot, go(up), Result4),
    pw(robot),
    writeln("Go Right:"),
    garden(act, robot, go(right), Result5),
    pw(robot),
    writeln("Water:"),
    garden(act, robot, water, Result6),
    writeln("Reward"),
    writeln(Result6),
    pw(robot).
