
1, Program Execution
2, Program Description
3, Output Description



1, Program Execution

Let the directory where FRAg is located be marked as @FRAg. There should be subdirectories 
@FRAg\core @FRAg\examples @FRAg\doc at least.

. In SWI PROLOG consult @FRAg\core\FRAgPL.pl
. ?-frag('../examples/trater/trader).

Output is in @FRAg\examples\trader\ ... some *.out, filename depends on setting of the trader 
multiagent system in @FRAg\examples\trader\trader.mas2fp


2, Program description

2.1 Agent code (in @FRAg\examples\trader\trader.fap)

This file contains a procedure to run and analyse the examples we presented at the ICAART24 conference.
The program on which we tested the parameters of its execution with early or late binfings involved
a souvenir (card) shop. The shopkeeper sold cards to interested buyer if there were
a matching seller offering the desired card at a price acceptable to the buyer. More details are given 
in the article.

The code of such an agent in AgentSpeak(L) would be as follows:

+!sell : wants(Buyer, CD, MAX_Price)
    <- ?offers(Seller, CD, Price);
       Price<=Max_Price;
       sell(Seller, Buyer, CD, Price);
       !sell.

In FRAg, this program is written in the AgentSpeak(L) dialect suitable for interpretation in PROLOG. 
Specifically, similar code with a few modifications is created as follows
          
plan(ach,
     sell,                        
     [not(closed),buyer(Buyer, CD, Buy_Price)], 
     [
	test(seller(Seller, CD, Sel_Price)),
       	rel(Buy_Price > Sel_Price),
        act(card_shop, sell(Seller, Buyer, CD)),
        act(printfg(
            '~w selling ~w CD ~w for ~w', 
            [Seller, Buyer, CD, Sel_Price])),
        ach(sell)
     ]).

The first change is in the contextual conditions of the plan. Because of the trading termination at some 
point, we use the query not(closed). Atom 'closed' is add to the agent's base of ideas when a deal is closed. 
The agent receives this atom from the environment it is assigned to at initialization. Therefore, also included 
in the code is  a second plan definition for the same 'sell' event, which will tell the agent if the 'closed' 
atom exists in its  base of ideas will terminate.

plan(ach,
     sell,                        
     [closed], [
       act(printfg('It is closed, finish'))]).


2.2 Multiagent system settings (in @FRAg\examples\trader\trader.mas2fp)

The settings for the multi-agent card trading system can be found in the trader.mas2fp file. This extension is used 
by FRAg as the default for metafiles representing a population of agents, binding  them to environments along with 
setting parameters for both types of these elements, which together form the multiagent system.
The code is listed below

% a,
include_environment("/environments/shop/shop.pl").

% b,
set_agents([(control, terminate(timeout, 1000)),
             (bindings, early),
             (reasoning, random_reasoning),
             (environment, card_shop)]).		

% c,
set_environment(card_shop, [(closing, 750), (s_lambda, 0.1), (b_lambda, 0.1), 
                            (b_price,[0.4, 0.2]), (s_price, [0.6, 0.2]),
                            (products, [8, 0.3, 0.1]), 
                    %       (episoding, (real_time, 0.0001)) ]).
                            (episoding, sim_time) ]).

% d,
load("paul","../examples/trader/trader",1,[(debug, systemdbg), (debug, reasoningdbg)]).
load("peter","../examples/trader/trader",1,[(debug, systemdbg), (bindings, late), (debug, reasoningdbg)]).

This code is interpreted by the FRAg system and the following is done:

a,
The environment is loaded from the file @FRAg/core-environments/shop/shop.pl This file is a PROLOG module called card_shop
and the name of this module still represents it in the FRAg system. This environment will simulate everything needed for a 
trading agent and is described later in this text.

b,
Sets the default agent parameters. Each subsequent agent loaded, if these parameters are not predefined in its definition
below, will have them set as specified in the parameter list in the atom set_agents(List_Of_Parameters). 
Specifically, the following is set here:
	The agent terminates after 1000 iterations in the control loop
        The strategy for binding variables during agent execution is 'early'
	The choice of a plan as a means of event processing, intention for execution, and substitutions when multiple
 		substitutions are possible is random (the last choice only makes sense in the case of early bindings).
	Each agent is placed in the card_shop environment
For initial experimentation with this example, we recommend not changing these parameters.

c,
Sets the parameters of the environment, in this case the card_shop environment, to which agents will be deployed. 
What parameters can be set depends on the implementation of the environment and can be different for each environment. 
The following are set here

d,
Two agents will be uploaded (since the second term of the 'load' atom is 1) named Peter and Paul. If the second term 
is greater than one, more agents would be loaded with the prefix Peter or Paul followed by a number from 1 upwards.
The debug statements (as pairs (key, value) ) are set in the list, both system and reasoning progress when interpreting 
the agent, these pairs can be removed and then the listing will be brief and will only contain what the agents send 
to the console for printing. Agent Peter has overridden the setting of working with variables to 'late' and therefore does not 
use the default 'early'


3, /  Output description

