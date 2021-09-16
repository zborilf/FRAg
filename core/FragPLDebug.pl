%
%   temporal for main loop (prints, debugs etc.)


printListState([]).

printListState([H|T]):-
		write(H),
		write(";"),
		printListState(T).  

printIntentions:-
		bagof(intention(A,B,C,STATUS),intention(A,B,C,STATUS),INTS),
		write(":: INTENTIONS {"),
		printListState(INTS),
		writeln("}").
printIntentions:-
		writeln(":: No intentions").

printGoals:-
		bagof(goal(A,B,C,D),goal(A,B,C,D),GOALS),
		write(":: GOALS {"),
		printListState(GOALS),
		writeln("}").
				printGoals:-
		writeln(":: No goals").


printBeliefs:-  bagof(fact(F),fact(F),FACTS),
		write(":: FACTS {"),
		printListState(FACTS),
		writeln("}").
printBeliefs:-
		writeln(":: No facts").
		
		

printAgentState:-
		loopNumber(LOOP),
		writeln(":: vvvvvvvvvvvvvvvvvvvvvvvvvv"),
		format(":: LOOP ~w~n",[LOOP]),
		printIntentions,
		printGoals,
		printBeliefs,
		writeln(":: ^^^^^^^^^^^^^^^^^^^^^^^^^^"),
		nl.
