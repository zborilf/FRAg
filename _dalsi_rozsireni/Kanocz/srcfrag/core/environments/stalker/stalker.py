# Class implementing miconic environment in python
import sys
import os

# Add the root directory to sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../../pes')))

from ModEnv import *
from Grid import *
from Item import *
from Generator import *
#author David Kanocz
#license GPL

class AnomalyGenerator(Generator):
    def __init__(self, env, in_cell, item_name:str, avg_wait:int, item_limit:int=0, enabled:bool=True):
        super().__init__(env=env, in_cell=in_cell, item_name=item_name, avg_wait=avg_wait, item_limit=item_limit, enabled=enabled)

    def item_create(self):
        self.env.add_item_to_env(Item("Sponge", 400, 4, "Found in electric anomalies"), self.in_cell)


class StalkerAgent(Agent):
    def remove_item_carry(self, item:Item) -> None:
        items:list[Item] = self.get_carried_items()
        if item in items:  self.carrying.remove(item)
        has_binocs:bool = False
        for item in self.get_carried_items():
            if item.get_name() == "Binoculars":
                has_binocs = True
        if has_binocs == False:
            self.set_viewrange(3)


    def add_item_carry(self, item:Item) -> None:
        if item.get_name() == "Binoculars":
            self.set_viewrange(4)
        self.carrying.append(item)

    
    def drop_item(self, item_name:str="") -> int:
        reward:bool = False
        x,y = (self.get_env().static_facts["TRADER"])
        trader_cell:Cell = self.get_env().get_inner_structure().get_cell_by_index(x,y)
        agent_cell:Cell = self.get_location()
        if agent_cell == trader_cell: reward = True

        for item in self.get_carried_items():
            if item_name != "":
                if item_name == item.get_name():
                    # Tell item that he belongs to this agent
                    self.currently_carrying_weight-=item.get_weight()
                    item.attach_to_cell(agent_cell) if reward == False else self.destroy_item(item)
                    return item.get_value() if reward == True else 0

            # Tell item that he belongs to this agent
            else:
                self.currently_carrying_weight-=item.get_weight()
                item.attach_to_cell(agent_cell) if reward == False else self.destroy_item(item)
                return item.get_value() if reward == True else 0
        return -10


# Child class of ModularEnvironment class
class STALKER(ModularEnvironment):
    def __init__(self, name:str):
        super().__init__(name=name, clone=False)

        self.closing_time = 400
        
        self.static_facts = {
            "TRADER": (10,15)
        }

        self.agent_spawn_coordinates = {
            "paul": (7,7),
            "peter":(7,7),
        }

        self.animating_agent_name:str = "paul"
        self.animate:bool = True
        self.animate_mode:str = "viewrange"
        self.animation_delay = 0.5


    # Create a map of Army Warehouses
    def create_army_warehouses(self) -> None:
        # Create a basic grid
        g:Grid = Grid(20, 20, None, True)
        # Very basic shaping - making parts of map inaccessible
        g.lock_cells(g.select_cells(g.get_cell_by_index(0,0),g.get_cell_by_index(14,0)))
        g.lock_cells(g.select_cells(g.get_cell_by_index(0,19),g.get_cell_by_index(19,19)))
        g.lock_cells(g.select_cells(g.get_cell_by_index(17,17),g.get_cell_by_index(19,19)))
        g.lock_cells(g.select_cells(g.get_cell_by_index(3,1),g.get_cell_by_index(4,1)))
        g.lock_cells(g.get_cell_by_index_list(4,2))


        # Adding a perimeter wall around Freedom military base
        g.block_way("left", g.select_cells(g.get_cell_by_index(9,14), g.get_cell_by_index(9,19)))
        g.block_way("right", g.select_cells(g.get_cell_by_index(16,14), g.get_cell_by_index(16,19)))
        g.block_way("up", g.select_cells(g.get_cell_by_index(9,14), g.get_cell_by_index(12,14)))
        g.block_way("up", g.select_cells(g.get_cell_by_index(14,14), g.get_cell_by_index(16,14)))

        # Adding a walls around mercenary checkpoint
        g.block_way("down", g.select_cells(g.get_cell_by_index(0,3), g.get_cell_by_index(1,3)))
        g.block_way("right", g.select_cells(g.get_cell_by_index(1,0), g.get_cell_by_index(1,1)))
        g.block_way("right", g.get_cell_by_index_list(1,3))

        # Cutting off accessible paths to inactive cells
        # This is important!
        g.cull_paths()

        # Adding parameters to the environment
        # Let danger be a scale from 0 to 100
        g.add_param("anomaly_danger", 5)
        # IF we model mutants as a static chance and not as a different type of agent
        g.add_param("mutant_danger", 15)

        # Adjusting mutant danger to specific areas
        g.mod_param("mutant_danger", 60, g.select_cells(g.get_cell_by_index(10,2), g.get_cell_by_index(13,3)))
        g.mod_param("mutant_danger", 70, g.select_cells(g.get_cell_by_index(2,6), g.get_cell_by_index(6,10)))
        g.mod_param("mutant_danger", 25, g.select_cells(g.get_cell_by_index(15,9), g.get_cell_by_index(17,12)))
        g.mod_param("mutant_danger", 60, g.select_cells(g.get_cell_by_index(10,2), g.get_cell_by_index(13,3)))
        g.mod_param("mutant_danger", 0, g.select_cells(g.get_cell_by_index(9,14), g.get_cell_by_index(16,19)))
        g.mod_param("mutant_danger", 70, g.select_cells(g.get_cell_by_index(3,17), g.get_cell_by_index(4,18)))
        g.mod_param("mutant_danger", 30, g.select_cells(g.get_cell_by_index(5,16), g.get_cell_by_index(7,18)))
        g.mod_param("mutant_danger", 40, g.select_cells(g.get_cell_by_index(0,6), g.get_cell_by_index(1,10)))

        # Adjusting anomaly danger to anomalous zones
        g.mod_param("anomaly_danger", 90, g.select_cells(g.get_cell_by_index(5,1), g.get_cell_by_index(7,1)))
        g.mod_param("anomaly_danger", 100, g.select_cells(g.get_cell_by_index(10,2), g.get_cell_by_index(13,3)))
        g.mod_param("anomaly_danger", 80, g.select_cells(g.get_cell_by_index(5,6), g.get_cell_by_index(6,6)))
        g.mod_param("anomaly_danger", 60, g.select_cells(g.get_cell_by_index(15,9), g.get_cell_by_index(17,12)))
        g.mod_param("anomaly_danger", 2, g.select_cells(g.get_cell_by_index(9,14), g.get_cell_by_index(16,19)))
        g.mod_param("anomaly_danger", 40, g.select_cells(g.get_cell_by_index(3,16), g.get_cell_by_index(4,16)))
        g.mod_param("anomaly_danger", 80, g.select_cells(g.get_cell_by_index(5,17), g.get_cell_by_index(7,18)))

        self.register_grid(g)

        # Populating the map with artefacts
        self.add_item_to_env(Item("Ring", 1000, 3, "A very small artefact of electric origin consisting of two ring-shaped materials of organic nature. When the ring spins, it never stops spinning, defying the first law of thermodynamics."), g.get_cell_by_index(6,1))
        self.add_item_to_env(Item("Ball", 300, 5, "A spherical artefact formed in electrical anomalies under unknown conditions. Very bouncy."), g.get_cell_by_index(7,9))
        self.add_item_to_env(Item("Jellyfish", 600, 1, "A gravitational artefact able to shield the body from physical impacts by altering the gravitational field around the user."),   g.get_cell_by_index(3,16))
        self.add_item_to_env(Item("Wrenched", 300, 4, "This bizarrely shaped artefact appears in places with increased gravitational activity. Although it appears almost organic, it is actually more to that of coral."),    g.get_cell_by_index(6,18))
        self.add_item_to_env(Item("Sponge", 400, 4, "Commonly under debate among the Ecologists is whether this artefact is an advanced life form with self-awareness inherited from once living creatures within the zone."),      g.get_cell_by_index(16,11))
        self.add_item_to_env(Item("Fireball", 1000, 5, "A formation of thermal nature formed under extreme temperatures. Surprisingly cold to the touch, it effectively absorbs heat from its vicinity."), g.get_cell_by_index(6,6))
        self.add_item_to_env(Item("Bracelet", 500, 3, "Formed from common species of bryophyte plants under high exposure to radioactive and chemical anomalies."), g.get_cell_by_index(17,12))

        self.add_item_to_env(Item("Binoculars", 10, 1, "A pair of old soviet binoculars"), g.get_cell_by_index(0,3))
        self.add_item_to_env(Item("Binoculars", 10, 1, "A pair of old soviet binoculars"), g.get_cell_by_index(4,11))
        self.add_item_to_env(Item("Binoculars", 10, 1, "A pair of old soviet binoculars"), g.get_cell_by_index(12,16))
        self.add_item_to_env(Item("Binoculars", 10, 1, "A pair of old soviet binoculars"), g.get_cell_by_index(4,9))

        #self.add_generator_to_env(AnomalyGenerator(self, g.get_cell_by_index(16,11), "Sponge", 4, 5))


    # placing custom agent
    def place_agent(self, agent_name:str, cell:Cell) -> Agent:
        agent:StalkerAgent = StalkerAgent(agent_name)
        self.append_agent(agent)
        agent.register_cell(cell)
        cell.register_agent(agent)
        return agent

# Creates and registers top-level environment (ModularEnvironment) alongside with subenvironments
def initialize_environment():
    stalker:STALKER = STALKER("stalker")
    # register the main environment to environment pointer
    register_environment(env_obj=stalker) 
    stalker.create_army_warehouses()
    return stalker

    
    #agent.percept(stalker.get_inner_structure(), True)



    
