# FRAg=PL
Flexibly Reasoning BDI Agent in ProLog
September 2021- January 2024,
v0.10

Progrmammed in SWI Prolog

Interpreter of dialect of AgentSpeak(L) language

Dialect outline (AgentSpeak(L) -> FRAgSpeak):
% Beliefs
%  pred(t1,t2,...tn). -> fact(pred(t1,t2,...tn)).
% Achievement goals
%  !pred(t1,t2,...tn). -> goal(ach, pred(t1,t2...tn), [[]]). 
% Plan 
%  +!pred(t11,t12...):predg1(t21,t22...)&predg2(t31,t32,...) <- 
%           .action(t41,t42...); ?tpred(t51,t52...);
%           !apred(t61.t62...); +addpred(t71,t72...); -delpred(t81,t82...).
%  -> plan(pred(t11,t12...),[predg1(t21,t22...),predg2(t31,t32...)], 
%            [act(action(t41,t42...)),test(pred(t51,t52...)), ach(pred()),
%             add(addpred(t71,t73...),del(delpred(t81,t82,...)]).

Uses Late-Bindings (see [1])

Install and Running 
1, Install SWI Prolog
2, Load FRAg files to working directory
3, Consult FragPL.pl

>mas(file.mas2fp)   , 
% loads example/file.mas2fp metafile (multiagent specification) 


================ mas2fp metafile ================

Clauses organizing the multiagent system.

a, 
b, load(+Agentname, +Filename, +Number, +Attributes)
c,

  attributes: [(key, value)*]
	(bindings, late)
	(bindings, early)	

	(debug, system)   	% some system info
	(debug, reasoning)      % each cycle ... reasoning process                  	
	(debug, mctsdbg)		% mcts trees, outputs ...
	(debug, mctsdbg_path)

	(reasoning, simple_reasoning)		% plan:  intention:  subst:
	(reasoning, random_reasoning) 		% plan:  intention:  subst:
	(reasoning, can_reasoning) 		% plan:  intention:  subst:
	(reasoning, biggest_joint_reasoning)  	% plan:  intention:  subst:
	(reasoning, mcts_reasoning)            	% plan:  intention:  subst:
	% @todo (reasoning, mandatory)        	% plan:  intention:  subst:
	% @todo (reasoning, snakes_reasoning)        	% plan:  intention:  subst:

	% @todo (mcts, [expansions, E])		% E expansions 
	% @todo (mcts, [simulations, S])	% S simulations per expansion


4, output is in exapmples/file.out

Aktuální verze
	Provadi agenta agentSpeak(L)
	Pozdni navazovani promennych v planech (FRAg)
	Reaguje na cil dosazeni, dale na udalosti pridani nebo smazani predstavy
	Umi broadcast a send



[1] Zboril, Vidensky, Koci, Zboril V.: Late Bindings in AgentSpeak(L), ICAART, 2022
[2] Vidensky, Zboril, Koci, Zboril V.: Operational Semantic of an AgentSpeak(L) Interpreter using Late Bindings, ICAART, 2023
[3] Vidensky, Zboril, Beran, Koci, Zboril V.: Comparing Variable Handling Strategies in BDI Agents: Experimental Study, ICAART 2024

