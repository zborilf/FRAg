# Documentation of system PES
## Preamble                                                                                           
This document is focused more on programming aspects of this system in comparison with text in the thesis.
Furthermore, this doc is more personable and a bit less formal.
The aim of this documentation is to provide reader a quick guide on how PES works and how testing environments are created.
Last but not least, check official frag github repo for additional updates, since PES will most likely be integrated in definitely changed and hopefully improved version there.
Public repository: https://github.com/VUT-FIT-INTSYS/FRAg/

## Code philosophy
In general, code is focused on readability (more than brevity) and, in general, tries to adhere to calling getters and setters when working with classes.
This, however, comes at a cost. Since naming of variables and functions/methods is not shortened and tries to convey the whole meaning.
This can end up with having lines of code stretched to an amount that is uncomfortable to look at. 
Therehore, if it suits you more, you can skip getters/setters and jump references instead for a more consice look.

# Broad structure of PES
This section covers 3 main parts. Prolog side, Prolog-Python side and Python side -- the PES.
Theoretically, only Prolog-Python and python side is important to you if you only need to quickly develop an environment.

## Getting up to speed -- the bare minimum to create your environment
For prepared "empty" skelets of code see section near the end.
List of classes in PES
ModularEnvironment: main wrapper of whatever simulated environment will exist.
Agent: mainly facilitates execution of actions and percepts of an agent from frag
Generator: used to generate items at runtime
Structure: using nCells. Use this if purely Grid like environment is not suffictient enough due to its limitation of at most 4 connections in each cell.
Grid: typical grid environment. Agents have viewrange in this environment.
Cell: individual cell for Grid class
nCell: individual cell for Structure class
Item: Generic item with properties such as name, value, weight, position, uuid

Creating an environment consists of using classes implemented in PES.
Usually a desirable approach is to make a new class that inherits from ones listed above, if you need a different or added functionality.

Inheritance should used in almost all classes you intend to use (or just redefining methods).
Reasons are the following.
ModularEnvironment: you need to redefine place_agent method, if you use a class inherited from Agent. Also, you need to setup things like:
  1. closing_time:int -- if you do not intend to use it, simply set it to a number > agents' timeout
  2. self.agent_spawn_coordinates:dict -- you MUST define a spawn point for each agent via NAME: LOCATION. This has to be done for ALL agents, otherwise agent will NOT load into the environment.
  3. Animation is disabled by default, so you may want to turn it on
  4. You need to have some method that creates the environment itself, before any agent attempts to load.
Cell: if you use environment where danger is present, you need to redefine the default get_danger_rating, which has stalker environment as an example (would not work in others). 
Generator: since method item_create is only declared and you need to supply the actual item it is supposed to be creating.
Agent: All actions need to be defined. Common actions are already prepared, however you might want to adjust their rewards to specific scenarios. 
       Also, if you need to add a specific percept, modify percept_g or percept_s (depending on if you use Grid or Struct) by simply doing something like new_beliefs["something"] = [something_value]

### Shaping
If you are using Grid, you can sculpt the environment as well by making parts of it unavailable.
The following 5 lines make cells completely unavailable and agent neither sees them OR sees through them
        g.lock_cells(g.select_cells(g.get_cell_by_index(0,0),g.get_cell_by_index(14,0)))
        g.lock_cells(g.select_cells(g.get_cell_by_index(0,19),g.get_cell_by_index(19,19)))
        g.lock_cells(g.select_cells(g.get_cell_by_index(17,17),g.get_cell_by_index(19,19)))
        g.lock_cells(g.select_cells(g.get_cell_by_index(3,1),g.get_cell_by_index(4,1)))
        g.lock_cells(g.get_cell_by_index_list(4,2)) -- expects a list, single cell won't do if not inside a list

These 3 lines add walls. They do not make cell unavailable, just block sight and passage through them
        g.block_way("down", g.select_cells(g.get_cell_by_index(0,3), g.get_cell_by_index(1,3)))
        g.block_way("right", g.select_cells(g.get_cell_by_index(1,0), g.get_cell_by_index(1,1)))
        g.block_way("right", g.get_cell_by_index_list(1,3))

IMPORTANT at the end of your sculpting, try to draw your environment at least once.
        g.draw() -- empty will draw out a structure
        If you see any weird stuff, you need to call method cull_paths at the end of your sculpting, which should take care of it.
        Probably should call by default if you ever are making cells unavailable.

## Skeleton files for creating environment SkeletonEnv

### SkeletonEnv.py----------------------------------------------------------------------------------------------------------------
##### Class implementing miconic environment in python
import sys
import os

##### Add the root directory to sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../../pes')))

from ModEnv import *
from Grid import *
from Item import *
from Generator import *

##### Child class of ModularEnvironment class
class NewModEnv(ModularEnvironment):
    def __init__(self, name:str):
        super().__init__(name=name, clone=False)

        self.closing_time = 400
        self.agent_spawn_coordinates = {
            "paul": (7,10),
            "peter":(7,7),
        }

        self.animating_agent_name:str = "paul"
        self.animate:bool = True
        self.animate_mode:str = "viewrange"
        self.animation_delay = 0.5


    # Create a map of Army Warehouses
    def create_skeleton_env(self) -> None:
        # Create a basic grid
        g:Grid = Grid(20, 20, None, False)
        # Very basic shaping - making parts of map inaccessible
        g.lock_cells(g.select_cells(g.get_cell_by_index(0,0),g.get_cell_by_index(14,0)))

        # Adding a wall
        g.block_way("left", g.select_cells(g.get_cell_by_index(9,14), g.get_cell_by_index(9,19)))

        # Cutting off accessible paths to inactive cells
        # This is important!
        g.cull_paths()
        self.register_grid(g)

        self.add_item_to_env(Item("Sparkler", 400, 1, "Found in electric anomalies"),      g.get_cell_by_index(6,1))
        self.add_item_to_env(Item("Ring", 1000, 3, "Found in electric anomalies"),         g.get_cell_by_index(6,6))
        self.add_item_to_env(Item("Binoculars", 10, 1, "A pair of old soviet binoculars"), g.get_cell_by_index(0,3))

        # if you want to add a parameter to cells
        g.add_param("parameter", 15) # Applies this parameter to all cells with 15 as the default value

        # Adjusting parameter to specific areas
        g.mod_param("parameter", 60, g.select_cells(g.get_cell_by_index(10,2), g.get_cell_by_index(13,3)))

##### Creates and registers top-level environment (ModularEnvironment) alongside with subenvironments
def initialize_environment():
    skeleton:SkeletonEnv = SkeletonEnv("skeleton")
    # register the main environment to environment pointer
    register_environment(env_obj=skeleton) 
    skeleton.create_skeleton_env()
    return skeleton

### SkeletonEnv.pl----------------------------------------------------------------------------------------------------------------
:- module(skeleton,[
	  skeleton/2,
	  skeleton/4
    ]).

:- use_module(library(janus)).
:- use_module('../py2pl').

/** <module> Environment bridge for FRAg

This module

@author David Kanocz
@license GPL
*/

/*
    Exported clauses
*/


skeleton(set_attributes, _). % set everything in PES directly


skeleton(add_agent, AgentName):-
    py_call(skeleton:get_environment_by_name("skeleton"), Env),
    py_call(skeleton:situate_agent_modenv_g(AgentName, Env)).


skeleton(perceive, AgentName, Add, Del) :-
    py_call(skeleton:get_environment_by_name("skeleton"), Env),
    py_call(Env:get_agent_by_name(AgentName), Agent),
    py_call(Agent:percept(), [RawAdd, RawDel]), %Agent:percept() can have a boolean parameter, outputting percepts to the terminal
    py2pl:normalize_pairs(RawAdd, Add),
    py2pl:normalize_pairs(RawDel, Del).


skeleton(act, AgentName, some_action, Reward):-
    py_call(skeleton:get_environment_by_name("skeleton"), Env),
    py_call(Env:get_agent_by_name(AgentName), Agent),
    py_call(Agent:some_action, Reward).
    

skeleton(act, AgentName, move_to_cell(Direction), Reward):-
    py_call(skeleton:get_environment_by_name("skeleton"), Env),
    py_call(Env:get_agent_by_name(AgentName), Agent),
    py_call(Agent:move_to_cell(Direction), Reward).


% Initialization
    :-
    prolog_load_context(directory, Dir),
    py_add_lib_dir(Dir),
    py_import(skeleton, []),
    py_call(skeleton:initialize_environment()).


## Contact
If you encounter any error (with the last official version available at https://github.com/VUT-FIT-INTSYS/FRAg/) or would like to expand the system,
feel free to harass me at my personal facebook/instagram, as that is where you can get a hold of me the easiest and is preffered by me anyway.
If I don't get back to you within 2-3 days, I probably will have already seen it and chose to reply 'a little while later.'
In that case, send the message again. Since out of sight is sadly out of mind in my case and 'a little while later' will turn into never, if I don't get a reminder.
Expect email communication to be in the worst case scenario orders of magnitude slower.
Facebook: David Kanócz
Instagram: davidkanocz
Email: xkanoc00@vutbr.cz


                                      :=%#%%                                                        
                                     :*%%%=                                                         
                                 =-:#*@@#*-                                                         
                               :=:-%%%=@#--                                                         
                              =::---+%@%%-#+                                                        
                            ::::::---%%%---*+                                                       
                          =::::::---------++=----=                                                  
                         =::::::----------+-+*==-==                                                 
                        -::-----=--------==-=-=++                                                   
                       --------------=--==+ =                                                       
                     ---===---=----====+*#                                                          
                     :-==---===+*+++++*##%%                                                         
                    :--===-=++++**#****%%%                                                          
                   -:-----+====++*+**#%%%%                                                          
                   :-------===+***###%###                                                           
                   --=+*%@#@@*%%##@%@%%###%                                                         
                  ::*#=*%%%%%@@#+*##%%%%#**%#                                                       
                  :#@#+-::-=+*****#%%%%#*+#%@%                                                      
                  ++:::-----=+++**##%***##@@%%                                                      
                  +%:------==+++***#**%%%@@%#%#+                                                    
                 :-%*--:---=+++*###**%%%%%@%#*###%                                                  
             :--===*%------=++++****#@@@%%#***####%                                                 
            :--==-==*+-----=*****++++%%*###########%                                                
            ----      ---=--=+****+==*########%#####%                                               
           :---=       ---====++=+-==**###############                                              
           ----       :-========+=-=****############**#%                                            
          --=-=    :---========--++*******##%########***#                                           
                  :---==--------==+++*****##%#########***#                                          
                  --===      ----==++*****#################                                         
                 :----         :--==+++****+#*#**##########                                         
                 :---            --======++******#########%%                                        
                :-=-*              -----==++++**#%%%%##%#%%%%%#                                     
               --+=#                 :----===+**#%%%%####%%%@@@@%##                                 
               -=#                     :--++++**##%%%%#%%%%%%%#%###*%%                              
                                       .-==++****#####*##%%%%##**+++++++*##***++++=+                
                                       ---=++*#****#**###%#*++++++==++*++*********++++=             
                                       ---=****#*******+++==========++*++**+************+           
                                       -==+**+++*++++*+++==       ====++++************##**          
                                       -=+*+++****+++===---          ====+++++****########*         
                                       -=+++++**++=====----                ==++++++******+          
                                       -==*+***#*+======-                                           
                                        ==+***###**+===-                                            
                                         -=+*#####*+*+                                              
                                           -+**###++++                                              
                                            ==+*##+==+=                                             
                                             -==+#*+=++=                                            
                                              ==++*+=+++                                            
                                             -=+**+=++                                              
                                            -=+++=++                                                
                                       ----==+++++                                                  
                                      ====+##+                                                      
                                                                