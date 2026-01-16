# Class implementing miconic environment in python
import sys
import os
#author David Kanocz
#license GPL
# Add the root directory to sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../../pes')))

from ModEnv import *
from Grid import *
from Item import *


class Lift(Agent):
    def __init__(self, name:str, viewrange:int, weight_limit:int):
        super().__init__(name=name, viewrange=viewrange)
        self.traveled_distance = 0
        self.weight_limit = weight_limit
        self.served = 0


    # adds traveled distance
    def add_traveled_distance(self, latest_traversal:int) -> None:
        self.traveled_distance += latest_traversal


    # gets traveled distance
    def get_traveled_distance(self) -> int:
        return self.traveled_distance


    # sets new served value
    def set_served(self, newly_served:int) -> None:
        self.served += newly_served


    # gets current served value
    def get_served(self) -> int:
        return self.served


    # moves elevator to a floor, for each floor moved, gets negative point
    def travel(self, floor:int) -> int:
        travel_down:bool = True
        distance:int = abs(self.get_location().get_y() - floor)
        self.add_traveled_distance(distance)
        if floor < self.get_location().get_y(): travel_down = False

        for _ in range(distance):
            if travel_down: self.move_to_cell("down")
            else: self.move_to_cell("up")

        return -distance
        


    def onboard(self) -> None:
        for _ in range (len(self.get_location().get_items())):
            self.pick_item()


    def leave_lift(self) -> int:
        reward:int = 0
        current_floor = self.get_location().get_y()
        for passenger in self.get_carried_items():
            if passenger.get_destination() == current_floor:
                self.set_served(1)
                self.currently_carrying_weight -= passenger.get_weight()
                reward += self.get_env().get_inner_structure().get_height()*2 + 1
                self.destroy_item(passenger)
        return reward
    

    def percept_g(self, grid: Grid, debug:bool=False):
        # Gets percepts (items, danger, self, and other agents from cells in grid that agent sees)
        percepts:list[Tuple] = grid.get_percepts(self) 
        # Gets static facts that are always known to agent
        static_facts:dict = self.get_env().static_facts

        new_beliefs:dict[str, list[tuple]] = {}

        for percept in percepts:
            if len(percept) == 4:
                kind, value, x, y = percept
                if kind != "items": # Items are internal for python -> not adding them
                    new_beliefs.setdefault(kind, []).append((value, x, y))
            else:
                kind, name, value, weight, x, y, uuid = percept
                new_beliefs.setdefault(kind, []).append((name, value, weight, x, y, uuid))

        for kind, value in static_facts.items():
            if len(value) == 2:
                x,y = value
                new_beliefs.setdefault(kind, []).append((x,y))

        # add carry limit and currently carrying weight as percepts
        new_beliefs["carrying_weight"]   = [self.currently_carrying_weight]
        new_beliefs["weight_limit"]      = [self.weight_limit]
        new_beliefs["traveled_distance"] = [self.get_traveled_distance()]
        new_beliefs["served"]            = [self.get_served()]

        if len(self.get_env().dynamic_facts["items"]) == self.get_served():
            new_beliefs["all_served"] = [True]

        add_list = []
        delete_list = []
        
        if self.env.episode >= self.env.closing_time:
            add_list.append(("closed", True))

        #find new percepts to add
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
            # if you want to drop empty lists entirely:
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


class Passenger(Item):
    def __init__(self, name:str, value:int, weight:int, description:str):
        super().__init__(name=name, value=value, weight=weight, description=description)

    def get_destination(self) -> int:
        return self.get_value()


# Child class of ModularEnvironment class
class Miconic(ModularEnvironment):
    def __init__(self, name:str):
        super().__init__(name=name, clone=False)

        self.agent_spawn_coordinates:dict = {
            "lift": (0,0)
        }
        self.closing_time = 100
        self.animating_agent_name:str = "lift" #What agent does the animation, if animation is turned on
        self.animate:bool = True
        self.animate_mode:str = "viewrange"
        self.animation_delay = 0.1

    def place_agent(self, agent_name:str, cell:Cell) -> Lift:
        agent:Lift = Lift(agent_name, self.get_inner_structure().get_height(), 200)
        self.append_agent(agent)
        agent.set_env(self)
        inner:Grid = self.inner_structure
        agent.register_cell(cell)
        assert inner is not None, f"Neither structure or grid are set!"
        if isinstance(inner, Grid):
            target_cell = inner.get_cell_by_index(cell.get_x(), cell.get_y())
            target_cell.register_agent(agent)
        return agent


    def create_lift(self) -> None:
        # Create an elevator
        g:Grid = Grid(1,20,self)
        self.register_grid(g)


    def populate_cells(self) -> None:
        g:Grid = self.get_inner_structure()

        self.add_item_to_env(Passenger("Alice",   5,  62, "waiting"), g.get_cell_by_index(0, 0))
        self.add_item_to_env(Passenger("Bob",     5,  78, "waiting"), g.get_cell_by_index(0, 0))
        self.add_item_to_env(Passenger("Carol",   5,  85, "waiting"), g.get_cell_by_index(0, 0))
        self.add_item_to_env(Passenger("David",   5,  59, "waiting"), g.get_cell_by_index(0, 0))
        self.add_item_to_env(Passenger("Eve",     5,  71, "waiting"), g.get_cell_by_index(0, 0))
        self.add_item_to_env(Passenger("Frank",   5,  90, "waiting"), g.get_cell_by_index(0, 0))
        self.add_item_to_env(Passenger("Grace",   5,  66, "waiting"), g.get_cell_by_index(0, 0))
        self.add_item_to_env(Passenger("Heidi",   5,  73, "waiting"), g.get_cell_by_index(0, 0))

        # group 2: origin (0,0) → floor 10
        self.add_item_to_env(Passenger("Ivan",    10, 82, "waiting"), g.get_cell_by_index(0, 0))
        self.add_item_to_env(Passenger("Judy",    10, 67, "waiting"), g.get_cell_by_index(0, 0))
        self.add_item_to_env(Passenger("Karl",    10, 79, "waiting"), g.get_cell_by_index(0, 0))
        self.add_item_to_env(Passenger("Laura",   10, 58, "waiting"), g.get_cell_by_index(0, 0))
        self.add_item_to_env(Passenger("Mallory", 10, 88, "waiting"), g.get_cell_by_index(0, 0))
        self.add_item_to_env(Passenger("Neil",    10, 60, "waiting"), g.get_cell_by_index(0, 0))

        # group 3: origin (0,1) → floor 15
        self.add_item_to_env(Passenger("Olivia",  15, 69, "waiting"), g.get_cell_by_index(0, 1))
        self.add_item_to_env(Passenger("Peggy",   15, 83, "waiting"), g.get_cell_by_index(0, 1))
        self.add_item_to_env(Passenger("Quentin", 15, 75, "waiting"), g.get_cell_by_index(0, 1))
        self.add_item_to_env(Passenger("Rupert",  15, 92, "waiting"), g.get_cell_by_index(0, 1))

        # group 4: origin (0,2) → floor 3
        self.add_item_to_env(Passenger("Sybil",    3, 61, "waiting"), g.get_cell_by_index(0, 2))
        self.add_item_to_env(Passenger("Trudy",    3, 84, "waiting"), g.get_cell_by_index(0, 2))
        self.add_item_to_env(Passenger("Uma",      3, 70, "waiting"), g.get_cell_by_index(0, 2))

        # outcasts: various origins & floors
        self.add_item_to_env(Passenger("Victor",   1, 77, "waiting"), g.get_cell_by_index(0, 3))
        self.add_item_to_env(Passenger("Wendy",   19, 58, "waiting"), g.get_cell_by_index(0, 4))
        self.add_item_to_env(Passenger("Xavier",   7, 93, "waiting"), g.get_cell_by_index(0, 5))
        self.add_item_to_env(Passenger("Yvonne",  12, 64, "waiting"), g.get_cell_by_index(0, 6))
        self.add_item_to_env(Passenger("Simon",    3, 92, "waiting"), g.get_cell_by_index(0, 7))

        #g.draw()



# Creates and registers top-level environment (ModularEnvironment) alongside with subenvironments
def initialize_environment():
    miconic:Miconic = Miconic("miconic")
    # register the main environment to environment pointer
    register_environment(env_obj=miconic)
    miconic.create_lift()
    miconic.populate_cells()
