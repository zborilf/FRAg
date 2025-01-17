

%   shared data among threads (agents etc.)
:-use_module('FRAgSync').


:-thread_local next_step /1.

next_step(1).


ag( _ ):- next_step(200).

ag(Agent):-
   S is random(1),
   B is S / 10,
   sleep(B),
   next_step(Step),
%   format("Krok agenta ~w je ~w~n",[Agent, Step]),
   thread_wait(fa_sync:b_step(Step), [alias(Agent)]),
   retract(next_step( _ )),
   Step2 is Step+1,
   assert(next_step( Step2)),
   format("Ahoj, zdavi ~w, step ~w ~n",[Agent, Step]),
   fa_sync:agent_salutes(Agent),
   ag(Agent).

ai(Agent):-
   assert(next_step(1)),
   ag(Agent).

g:- 
   sync_add_agent(hana),
   sync_add_agent(franta),
   sync_add_agent(tereza),
   sync_add_agent(patrik),
   sync_agents_ready,
   thread_create(ai(hana), Thread1, [alias(hana)]),
   thread_create(ai(franta), Thread2, [alias(franta)]),
   thread_create(ai(patrik), Thread3, [alias(patrik)]),
   thread_create(ai(tereza), Thread4, [alias(tereza)]).


