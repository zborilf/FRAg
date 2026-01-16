
:- use_module('FRAgPL.pl').


/*
 TEMP
*/


t1:-     
    fRAgAgentInterface:add_environment_library("environments/miconic10/miconic10.pl"),
    fRAgAgentInterface:situate_agent(franta, miconic10),

    fRAgAgentInterface:agent_acts(franta, miconic10, go(f7), _),
% 	agent_perceives(franta, A, D),
%	writeln(A),
%	writeln(D),                     .
                                

%    situate_agent(pavel, miconic10, mklon),
    fRAgAgentInterface:virtualize_agent(franta, pavel),

    fRAgAgentInterface:agent_acts(pavel, miconic10, go(f6), _),
    fRAgAgentInterface:agent_acts(pavel, miconic10, go(f7), _),
    fRAgAgentInterface:agent_perceives(pavel, A4, D4),
    writeln(atedpavel),
    writeln(A4),
    writeln(D4),
    fRAgAgentInterface:agent_acts(franta, miconic10, go(f2), _),
    fRAgAgentInterface:agent_perceives(franta, A2, D2),
    writeln(A2),
    writeln(D2),
    fRAgAgentInterface:agent_acts(franta, miconic10, go(f3), _),
    fRAgAgentInterface:agent_acts(franta, miconic10, go(f4), _),
    fRAgAgentInterface:agent_acts(franta, miconic10, go(f6), _),
    fRAgAgentInterface:agent_acts(franta, miconic10, go(f7), _),
    fRAgAgentInterface:agent_perceives(franta, A3, D3),
    writeln(A3),
    writeln(D3),
    fRAgAgentInterface:remove_clone(miconic10, pavel).

             
md:-
    use_module(library(pldoc/doc_library)),
 %   doc_load_library,
    doc_save('FragPL.pl',[format(html), recursive(true), doc_root(doc)]).




pw(Agent):-
    agent_perceives(Agent, Add_List, Delete_List),
    write(Agent),write(' add:'),writeln(Add_List),
    write(Agent),write(' delete:'),writeln(Delete_List).



t2:-
    use_module('FRAgAgentInterface.pl'),
    add_environment_library('environments/shop/shop.pl'),
    add_environment_library('environments/counter/counter.pl'),
    situate_agent(adam, card_shop),
  
    situate_agent(adam, simple_counter),
    situate_agent(hana, card_shop),
    situate_agent(hana, simple_counter),
    pw(adam),
    pw(hana),
    agent_acts(adam, card_shop, sell(adam, vera, cd3), Result),

    virtualize_agents(adam, [vera, lenka, jindrich]),


    agent_acts(vera, card_shop, sell(adam, vera, cd8), Result2),
    save_instance_state(card_shop, vera, save1), 

    agent_acts(lenka, card_shop, sell(adam, vera, cd1), Result3),
    agent_acts(hana, card_shop, sell(adam, vera, cd6), Result4),
    agent_acts(jindrich, card_shop, sell(vera, jindrich, cd8), _),
    agent_acts(vera, simple_counter, add(7), _),
    agent_acts(vera, simple_counter, increase, _),
    save_instance_state(simple_counter, vera, save2),

    agent_acts(jindrich, simple_counter, add(-10), _),
    load_instance_state(simple_counter, vera, save2),
    agent_acts(lenka, simple_counter, decrease, _),

    pw(adam),
    pw(hana),
    pw(vera),
    pw(jindrich),
    reset_clone(card_shop, vera),
    reset_clone(simple_counter, vera),
    agent_acts(jindrich, simple_counter, decrease, _),
    pw(vera),
    pw(jindrich),
    remove_instance_state(card_shop, vera, save1),
%    remove_instance_state(simple_counter, vera, save2),
    remove_clone(card_shop, vera).

% testing miconic10


t3:-
    use_module('FRAgAgentInterface.pl'),
    add_environment_library('environments/shop/shop.pl'),
    add_environment_library('environments/counter/counter.pl'),
    situate_agent(adam, card_shop),
    situate_agent(adam, simple_counter),
    virtualize_agents(adam, [beta, cyril, dan]),
    agent_acts(beta, simple_counter, add(5), _),
    agent_acts(dan, card_shop, sell(adam, vera, cd6), _),
    save_all_instances_state(cyril, zaloha),
    agent_acts(cyril, card_shop, sell(adam, franta, cd1), _),
    agent_acts(dan, simple_counter, increase, _),
    pw(dan),  
    load_all_instances_state(dan, zaloha),
    remove_all_instances_state(beta, zaloha),
    pw(dan),
    pw(beta),
    pw(adam).

t4:-
    use_module('FRAgAgentInterface.pl'),
    add_environment_library('environments/miconic/miconic.pl'),

    situate_agent(portyr, miconic10),
    virtualize_agents(portyr, [ghost_portyr]),
 
    agent_acts(portyr, miconic10, go(f7), _),
    agent_acts(ghost_portyr, miconic10, go(f3), _),
    agent_acts(ghost_portyr, miconic10, go(f6), _),
    agent_acts(ghost_portyr, miconic10, go(f1), _),
    pw(portyr),
    pw(ghost_portyr),
    reset_clone(miconic10, ghost_portyr),
    pw(ghost_portyr).

