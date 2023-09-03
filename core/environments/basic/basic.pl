 
%
% 	FragPL, basic environment / ... internal actions
%       Frantisek Zboril jr. 2021 - 2023
%	
%


% environment(basic).			% zde by mely byt standardni akce, komunikace ...

% 	me(agent_name)

action(basic, me, 1).

% 	population(list_of_agents)

action(basic, population, 1).


% 	
%   	FRAg internal actions
%   	

action(basic, send,2).
action(basic, bcast,1). 
action(basic, sendfg,2). 		% sendFrag ?
action(basic, printfg,1).
action(basic, printfg,2).
action(basic, foo,1).		% pro ladeni decision, k nicemu
action(basic, foo,2).		% pro ladeni decision, k nicemu
action(basic, foo,3).		% pro ladeni decision, k nicemu
action(basic, foo,4).		% pro ladeni decision, k nicemu

                
% foo action (= printfg)
  % joint_action(Action_symbol, Arity)

joint_action(basic, silently_, 1).   
joint_action(basic, do, 1).
joint_action(basic, jprintfg, 1).


%
%		Particular actions (defined at the begining of this file)                
%



population(P):-
    bagof(A,agent(A),P).


concatTerm(S1,S2,S):-
    string(S2),
    concat(S1,S2,S).

% S2 is not a String
concatTerm(S1,S2,S):-
    term_string(S2,S2S),
    concat(S1,S2S,S).


printfg(String):-    
    me(Agent),
    concatTerm("+: ~w says > ", String, String2),
    concat(String2, "\n", String3),
    format(atom(String4), String3, [Agent]),
    write(current_output, String4).

  printfg(String, Parameters):-
	format(atom(String2), String, Parameters),
	term_string(String2, String3),
	printfg(String3).



foo(A):-
    format(atom(String),"uff ~w",[A]),
    printfg(String).

foo(A,B):-
    format(atom(String),"uff ~w ~w",[A,B]),
    printfg(String).

foo(A,B,C):-
    format(atom(String),"ufff ~w ~w ~w",[A,B,C]),
    printfg(String).

foo(A,B,C,D):-
    format(atom(String),"ufff ~w ~w ~w ~w",[A,B,C,D]),
    printfg(String).


silently_(_).

me(X):-
    thread_self(X).


sendfg(Receiver,Payload):-
    thread_self(ME),
    printfg("Sending message ~w~n",[Receiver]),
    thread_send_message(Receiver,message(ME,inform,pld(Payload))),
    printfg("Send succeed ~n").

sendfg(_,_):-
    printfg("Send Failed ~w~n").


send(Receiver, Payload):-
    thread_self(Me),
    thread_send_message(Receiver, message(Me, inform, pld(Payload))).


bcast2([],_).

bcast2([H|T], Payload):-
    sendfg(H, Payload),
    bcast2(T, Payload).


  bcast(Payload):-
        bagof(X,agent(X),L),
	bcast2(L, Payload).
		
  bcast(_).


%
% 	Joint actions
%

do(X):-
    printfg(X).


    % joint version of printfg
jprintfg(STRING):-
    printfg(STRING).	


% basic(act, _, Act, true):-
%    is_exclusive_action(basic, Act),
%    Act.

basic(act, _, silently_(printfg( _ )), true).

basic(act, _, silently_(printfg( _, _)), true).

basic(act, _, silently_(jprintfg( _ )), true).

basic(act, _, silently_(format( _)), true).

basic(act, _, silently_(format( _, _)), true).

basic(act, Agent, silently_(Act), Result):-
% neni zde zadna, co opravdu chceme umlcet?
    basic(act, Agent, Act, Result). 

basic(act, _, Act, Result):-
    is_joint_action(basic, Act),
    Act,
    Result is Act.

basic(act, _, Act, true):-
    Act.
	         
basic(act, _, _, fail).


