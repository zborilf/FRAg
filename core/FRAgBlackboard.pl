
%                               
%  	FRAg shared blackboard
%  	Frantisek Zboril jr. 2021 - 2023
%  	   


:-module(fRAgBlackboard,[
			    frag_debug / 1,
			    agent / 1,
			    ready / 1,
			    go / 1
			]
	).



:-dynamic frag_debug / 1.
% agent(Name), agent Name is a part of the mutliagent system
:-dynamic agent /1.				
:-dynamic ready /1.
:-dynamic go / 1.
:-dynamic max_agent_iterations /1.

