# Class implementing miconic environment in python
import sys
import os
import numpy as np
import time
from uuid import uuid4

# Add the PES directory to sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../../pes')))

from ModEnv import *
from Structure import *
from Item import *


# Class implementing machines with which agents produce products
# Similar to Generator class
class AssemblyMachine:
    def __init__(self, avg_not_broken:int, avg_broken:int, avg_product_creation:int, available:bool=True, machine_name:str=uuid4()):
        self.planned_change_of_state:int = -1 # list of planned item generations
        self.temporary_working_mask:int = 0 # If machine is working, its status is MASKED by this if its value > 0, for that many ticks
        
        self.avg_not_broken:int = avg_not_broken # Avg machine is in working order
        self.avg_broken:int = avg_broken # Avg time machine is broken
        self.avg_product_creation:int = avg_product_creation # Avg time it takes to produce a product

        self.machine_name:str = machine_name # Name of machine - random UUID if you dont care
        self.available:bool = available # Available if not broken and if it is currently not working on any items


    def check_time_and_update(self, current_episode: int) -> None:
        if self.planned_change_of_state < 0: # beginning is at -1
            if self.available == True: # plan first state change based on init state
                self.exponential_planning(current_episode, self.avg_not_broken)
            else:
                self.constant_planning(current_episode, self.avg_broken)

        # If machine is creating product, subtract 1 from work cycle
        if self.temporary_working_mask > 0:
            self.temporary_working_mask -= 1

        # plan change happening
        if current_episode >= self.planned_change_of_state:
            if self.available == True:
                self.available = False
                self.constant_planning(current_episode, self.avg_broken) # set time after which machine is fixed
            else:
                self.available = True
                self.exponential_planning(current_episode, self.avg_not_broken) # set time after which machine will be working again


    # Returns a boolean value of machine's availability.
    # Machine is available only when it is not broken and not in process of creating product
    def is_machine_available(self) -> bool:
        if self.temporary_working_mask == 0 and self.available == True: return True
        else: return False

    # Plans creation of items with exponential distribution
    def exponential_planning(self, current_episode:int, value:int) -> None:
        delay = np.random.exponential(scale=value)
        planned_episode = current_episode + int(round(delay))
        self.planned_change_of_state = planned_episode 

    
    # Plans creation of items with a predetermined delay
    def constant_planning(self, current_episode:int, value:int) -> None:
        self.planned_episodes = value + current_episode


    # Updates time to mask availability of the machine when creating an item
    def add_work_time(self) -> None:
        self.temporary_working_mask = self.avg_product_creation



class WoodGenerator(Generator):
    def item_create(self):
        self.env.add_item_to_env(Item("Wood", 3, 10, "Wood, needed to construct products"), self.in_cell)

class StoneGenerator(Generator):
    def item_create(self):
        self.env.add_item_to_env(Item("Stone", 5, 10, "Stone, needed to construct products"), self.in_cell)

class ProductGenerator(Generator):
    def item_create(self):
        self.env.add_item_to_env(Item("Product", 30, 10, "Final product"), self.in_cell)



class Robot(Agent):   
    # Attempts to create a product from one wood and one stone item
    def create_product(self) -> int:
        if self.get_location().get_uid() == "Workshop":
            items_in_cell:list[Item] = self.get_location().get_items()
            stone:Item = None
            wood: Item = None

            for item in items_in_cell:
                if item.get_name() == "Stone":
                    stone = item
                    break
            for item in items_in_cell:
                if item.get_name() == "Wood":
                    wood = item
                    break        
            
            if stone is not None and wood is not None:
                items_in_cell.remove(stone)
                items_in_cell.remove(wood)

                for machine in self.get_env().assembly_machines:
                    if machine.is_machine_available() == True:
                        self.get_env().explicit_generate("Product")
                        machine.add_work_time()
                        return 15      
        else: return 0
    

    # for detailed description see Agent
    def drop_item(self, item_name:str="") -> int:
        agent_cell:Cell = self.get_location()
        if agent_cell.get_uid() == "shipment": reward = True

        for item in self.get_carried_items():
            if item_name != "":

                if item.get_name() == item_name:
                    print(item_name, agent_cell.get_uid())
                    if item_name == "Product" and agent_cell.get_uid() == "Shipment":
                        self.currently_carrying_weight-=item.get_weight()
                        self.destroy_item(item)
                        self.get_env().delivered += 1
                        return item.get_value()
                    if item_name in ("Stone", "Wood") and agent_cell.get_uid() == "Workshop":
                        self.currently_carrying_weight-=item.get_weight()
                        item.attach_to_cell(agent_cell)
                        return item.get_value()
                    else:
                        self.currently_carrying_weight-=item.get_weight()
                        item.attach_to_cell(agent_cell)
                        return 0
                else:
                    continue
            # Name of dropped item not specified
            else:
                if item.get_name() == "Product" and agent_cell.get_uid() == "Shipment":
                    self.currently_carrying_weight-=item.get_weight()
                    self.destroy_item(item)
                    self.get_env().delivered += 1
                    return item.get_value()
                if item.get_name in ("Stone", "Wood") and agent_cell.get_uid() == "Workshop":
                    self.currently_carrying_weight-=item.get_weight()
                    item.attach_to_cell(agent_cell)
                    return item.get_value()
                else:
                    self.currently_carrying_weight-=item.get_weight()
                    item.attach_to_cell(agent_cell)
                    return 0
        return -10
    

    # Added percept available_machine
    def percept_s(self, structure: Structure, debug:bool=False):
        # Gets percepts (items, danger, self, and other agents from cells in grid that agent sees)
        percepts:list[Tuple] = structure.get_percepts(self)
        # Gets static facts that are always known to agent
        static_facts:dict = self.get_env().static_facts
        # In new beliefs we append all observed facts, percepts or anything we want agent to know about
        # This then gets compared to the agent's current belief base
        # Result from this comparison gets appended to add and delete lists which are returned
        new_beliefs:dict[str, list[tuple]] = {}

        for percept in percepts:
            if len(percept) == 3:
                kind, value, cell_name = percept
                # "items" are internal for python -> not adding them (they contain py_obj)
                # "item" is 'the same' but is passed to agent and includes more detail about item but not py_obj
                if kind != "items": 
                    new_beliefs.setdefault(kind, []).append((value, cell_name))
            elif len(percept) == 2: # Neighbor
                kind, cell_name = percept
                new_beliefs.setdefault(kind, []).append((cell_name))
            elif len(percept) == 4: # carrying item
                kind, name, value, weight = percept
                new_beliefs.setdefault(kind, []).append((name, value, weight))
            else: # kind == "item"
                kind, name, value, weight, cell_name, uuid = percept
                new_beliefs.setdefault(kind, []).append((name, value, weight, cell_name, uuid))

        # static fact that is of type NAME: cell_name
        for kind, value in static_facts.items():
            if len(value) == 1:
                new_beliefs.setdefault(kind, []).append((value))

        available_machines:int = 0
        machines = self.get_env().assembly_machines
        for machine in machines:
            if machine.is_machine_available() == True: available_machines += 1
        

        # add carry limit and currently carrying weight as percepts
        new_beliefs["carrying_weight"] = [self.currently_carrying_weight]
        new_beliefs["weight_limit"]    = [self.weight_limit]
        new_beliefs["available_machines"] = [available_machines]
        new_beliefs["delivered"] = [self.env.delivered]

        add_list = []
        delete_list = []
        
        # Check if we are over time
        if self.env.episode >= self.env.closing_time:
            add_list.append(("closed", True))

        # find new percepts to add
        for kind, entries in new_beliefs.items():
            for entry in entries:
                if kind not in self.beliefs or entry not in self.beliefs[kind]:
                    # add it to addlist as a new percept
                    add_list.append((kind, entry))
                    # update belief base
                    self.beliefs.setdefault(kind, []).append(entry)
        
        # find old beliefs that no longer appear
        for kind, entries in list(self.beliefs.items()):
            for entry in list(entries):
                if kind not in new_beliefs or entry not in new_beliefs[kind]:
                    delete_list.append((kind, entry))
                    entries.remove(entry)
            # drop empty lists entirely
            if not entries:
                del self.beliefs[kind]

        # (optional) print what changed
        if debug == True:
            if add_list:
                print("Added percepts:")
                for add in add_list:
                    print(add)
            if delete_list:
                print("Removed percepts:")
                for delete in delete_list:
                    print(delete)
        return add_list, delete_list


        # This method returns add and delete lists to prolog, moves forward episode
    
    
    # Added self.env.run_generators()
    def percept(self, debug:bool=False) -> Tuple[list, list]:
        inner:Grid|Structure = self.get_env().get_inner_structure()
        if isinstance(inner, Grid):
            add, delete = self.percept_g(inner, debug)
        else:
            add, delete = self.percept_s(inner, debug)
        
        env = self.get_env()
        agent_name, animate, animate_mode, animation_delay = env.get_animate_settings()
        if animate:
            if isinstance(env.get_inner_structure(), Grid):
                g = env.get_inner_structure()
                if agent_name == self.get_name():
                    if animate_mode   == "viewrange": g.draw("viewrange", g.get_cells_in_radius(self.get_location(), self.get_viewrange()), self.get_location())
                    elif animate_mode == "items": g.draw("items")
                    elif animate_mode == "agents": g.draw("agents")
                    elif animate_mode == "danger": g.draw("danger")
                    else: g.draw()
                    time.sleep(animation_delay)
            else:
                if agent_name == self.get_name():
                    self.debug()
                    time.sleep(animation_delay)

        
        agents:list[Agent] = self.get_env().agents
        # if there’s only one agent, or if this agent is the last one, bump the episode
        if len(agents) == 1 or self is agents[-1]:
            self.env.episode += 1
            self.env.run_generators()
            self.env.run_machines() # NEW
        
        return [add, delete]


# Child class of ModularEnvironment class
class Assembly(ModularEnvironment):
    def __init__(self, name:str):
        super().__init__(name=name, clone=False)
        self.use_real_time = False

        self.agent_spawn_coordinates:dict = {
            "robot_a": "Workshop",
            "robot_b": "Workshop",
            "robot_c": "Workshop",
            "robot_d": "Workshop"
        }

        self.dynamic_facts:dict = {         # Dictionary of dynamic facts about the environment
            "items": [],
        }          

        # Assembly machines located in workshop.
        # Structure is as follows: 
        # time ticks until broken, time ticks to fix, time ticks to generate product, available [True/False]
        self.assembly_machines = [
            AssemblyMachine(40,10,2, machine_name="A"),
            AssemblyMachine(40,10,2, machine_name="B"),
            AssemblyMachine(40,10,2, machine_name="C")
        ]

        self.delivered = 0
        self.closing_time = 800
        self.animate = True
        self.animating_agent_name = "robot_a"
        self.animation_delay = 0


    def create_structure(self) -> None:
        s:Structure = Structure(5, self)

        # Name individual cells
        s.get_cell_by_index(0).set_uid("Shipment")
        s.get_cell_by_index(1).set_uid("Hall")
        s.get_cell_by_index(2).set_uid("Warehouse_A")
        s.get_cell_by_index(3).set_uid("Workshop")
        s.get_cell_by_index(4).set_uid("Warehouse_B")

        # Connecting cells
        s.get_cell_by_uid("Shipment").set_doorway("Hall", s.get_cell_by_uid("Hall"))
        s.get_cell_by_uid("Hall").set_doorway("Shipment", s.get_cell_by_uid("Shipment"))
        s.get_cell_by_uid("Hall").set_doorway("Warehouse_A", s.get_cell_by_uid("Warehouse_A"))
        s.get_cell_by_uid("Hall").set_doorway("Warehouse_B", s.get_cell_by_uid("Warehouse_B"))
        s.get_cell_by_uid("Warehouse_A").set_doorway("Workshop", s.get_cell_by_uid("Workshop"))
        s.get_cell_by_uid("Warehouse_B").set_doorway("Workshop", s.get_cell_by_uid("Workshop"))
        s.get_cell_by_uid("Workshop").set_doorway("Hall", s.get_cell_by_uid("Hall"))

        # One item of each type on the start
        self.add_item_to_env(Item("Stone", 5, 10, "Stone description"), s.get_cell_by_uid("Warehouse_A"))
        self.add_item_to_env(Item("Wood",  5, 10, "Wood description"),  s.get_cell_by_uid("Warehouse_B"))       

        self.add_generator_to_env(StoneGenerator(self, s.get_cell_by_uid("Warehouse_A"), "Stone", 3, 5, True, "exp"))
        self.add_generator_to_env(WoodGenerator(self, s.get_cell_by_uid("Warehouse_B"), "Wood", 3, 5, True, "exp"))
        self.add_generator_to_env(ProductGenerator(self, s.get_cell_by_uid("Workshop"), "Product", 2, 999, True, "const", False))

        self.register_structure(s)


    def place_agent(self, agent_name:str, cell:Cell) -> Agent:
        agent:Robot = Robot(agent_name)
        self.append_agent(agent)
        agent.register_cell(cell)
        cell.register_agent(agent)
        return agent
    

    # Each tick check if machine is suddenly broken, repaired, or finished creating product
    def run_machines(self) -> None:
        for machine in self.assembly_machines:
            machine.check_time_and_update(self.episode)


# Creates and registers top-level environment (ModularEnvironment) alongside with subenvironments
def initialize_environment():
    assembly:Assembly = Assembly("assembly")
    # register the main environment to environment pointer
    register_environment(env_obj=assembly) 
    assembly.create_structure()
