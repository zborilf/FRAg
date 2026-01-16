# This class implements agent and its behavior towards environment
# Could be called "controllable entity" since it is not an agent per se, but a device agent uses to percieve and act
#author David Kanocz
#license GPL

from Cell import *
from Grid import *
from Structure import *
import time

class Agent:
    def __init__(self, name:str, viewrange:int=3, weight_limit:int=10):
        self.name:str = name
        self.env = None
        self.carrying:list = []
        self.beliefs:dict = {}
        self.in_cell:Cell = None
        self.viewrange:int = viewrange
        self.weight_limit:int = weight_limit
        self.currently_carrying_weight:int = 0


    # Sets agent to a cell. If it was registered to a cell already
    #   the previous cell unregisters this agent
    def register_cell(self, cell:Cell) -> None:
        if self.get_location() is not None:
            self.get_location().detach_agent(self)
        self.set_location(cell)


    # Returns a cell in which agent is located
    def get_location(self) -> Cell | None:
        return self.in_cell

    
    # Sets passed cell as the cell agent is in
    def set_location(self, cell:Cell) -> None:
        self.in_cell = cell


    # Physically moves the agent based on provided direction (Grid) or name room (Structure)
    def move_to_cell(self, direction:str) -> int:
        current_cell:Cell = self.get_location()
        new_cell:Cell
        if direction == "left":     
            new_cell = current_cell.get_neighbor("left")
        elif direction == "right":  
            new_cell = current_cell.get_neighbor("right")
        elif direction == "up":
            new_cell = current_cell.get_neighbor("up")
        elif direction == "down":   
            new_cell = current_cell.get_neighbor("down")

        # if cell is NCell (structure and not x,y coordinates)
        if not current_cell.get_neighbor(direction): return 0
        else: new_cell = current_cell.get_neighbor(direction)

        self.register_cell(new_cell)
        new_cell.register_agent(self)
        if self.get_env().get_inner_structure().danger_present == True:
            return -new_cell.danger_rating
        else:
            return -1


    # Returns a pointer to environment where agent is situated in
    def get_env(self):
        return self.env
    

    # This method returns add and delete lists to prolog, moves forward episode
    # Also handles animation if set
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
        return [add, delete]


    # Percept handling method for Grid.
    # Checks if time is over time limit and sets closed
    # Assembles add and delete lists, based on difference between current agent's beliefs and percepts from Grid
    # A debug is available, displaying the add and delete lists
    def percept_g(self, grid: Grid, debug:bool=False):
        # Gets percepts (items, danger, self, and other agents from cells in grid that agent sees)
        percepts:list[Tuple] = grid.get_percepts(self) 
        # Gets static facts that are always known to agent
        static_facts:dict = self.get_env().static_facts
        # In new beliefs we append all observed facts, percepts or anything we want agent to know about
        # This then gets compared to the agent's current belief base
        # Result from this comparison gets appended to add and delete lists which are returned
        new_beliefs:dict[str, list[tuple]] = {}
        for percept in percepts:
            if len(percept) == 4:
                kind, value, x, y = percept
                # "items" are internal for python -> not adding them (they contain py_obj)
                # "item" is 'the same' but is passed to agent and includes more detail about item but not py_obj
                if kind != "items":
                    new_beliefs.setdefault(kind, []).append((value, x, y))
            # All percepts are of length 4, except "item" which is sent to agent
            else: # kind == "item"
                kind, name, value, weight, x, y, uuid = percept
                new_beliefs.setdefault(kind, []).append((name, value, weight, x, y, uuid))

        # static fact that is of type NAME:(x,y)
        for kind, value in static_facts.items():
            if len(value) == 2:
                x,y = value
                new_beliefs.setdefault(kind, []).append((x,y))

        # add carry limit and currently carrying weight as percepts
        new_beliefs["carrying_weight"] = [self.currently_carrying_weight]
        new_beliefs["weight_limit"]    = [self.weight_limit]
        
        add_list = []
        delete_list = []
        
        # Check if time ran out
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
    

    # Percept handling method for Structure.
    # Checks if time is over time limit and sets closed
    # Assembles add and delete lists, based on difference between current agent's beliefs and percepts from Structure
    # A debug is available, displaying the add and delete lists
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

        # add carry limit and currently carrying weight as percepts
        new_beliefs["carrying_weight"] = [self.currently_carrying_weight]
        new_beliefs["weight_limit"]    = [self.weight_limit]

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


    # returns agent's viewrange
    def get_viewrange(self) -> int:
        return self.viewrange


    # sets agent's viewrange
    def set_viewrange(self, new_viewrange:int) -> None:
        self.viewrange = new_viewrange


    # returns a list of items agent is carrying
    def get_carried_items(self) -> list[Item]:
        return self.carrying


    # Called from an item, this method removes item from agent
    def remove_item_carry(self, item:Item) -> None:
        items:list[Item] = self.get_carried_items()
        if item in items:  self.carrying.remove(item)
       

    # Called from an item, this method adds item from agent
    def add_item_carry(self, item:Item) -> None:
        self.carrying.append(item)


    # Attempts to pick item based on provided name 
    # If no name was provided, it tries to pick up AN item
    # If it fails, prints out why
    def pick_item(self, item_name:str="") -> int:
        agent_cell:Cell = self.get_location()

        # IF item name was specified, pick up first instance of that item
        # If no item name was entered, pick up an item in cell
        for item in agent_cell.get_items():
            if item_name != "": # If 
                if item_name == item.get_name():
                    # If agent can carry this item, pick it up
                    if item.get_weight() + self.currently_carrying_weight <= self.weight_limit:
                        # Tell item that he belongs to this agent
                        item.attach_to_agent(self)
                        self.currently_carrying_weight+=item.get_weight()
                        return 1

            # If item name was not provided, pick first item you get
            else:
                # If agent can carry this item, pick it up
                if item.get_weight() + self.currently_carrying_weight <= self.weight_limit:
                    # Tell item that he belongs to this agent
                    item.attach_to_agent(self)
                    self.currently_carrying_weight+=item.get_weight()
                    return 1
                else: # if item was too heavy, try another one
                    continue
        

    # Drops item carried by agent by name of the item
    # If no name of item was provided, agent will simply drop AN item
    # Probably want to override this function for rewards
    def drop_item(self, item_name:str="") -> int:
        print("HUH")
        agent_cell:Cell = self.get_location()
        reward = False

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
        

    # Returns name of agent
    def get_name(self) -> str:
        return self.name


    # Sets environment agent will be acting in
    def set_env(self, env):
        self.env = env


    # Returns environment in which agent is placed
    def return_environment(self):
        return self.env


    # For when it makes more sense to not return an item into the env
    # For example passenger in elevator - we do not care about him once we drop him off
    def destroy_item(self, item:Item):
        items:list[Item] = self.get_carried_items()
        if item in items:  
            self.carrying.remove(item)
            del item


    # Prints item's description to stdout
    def get_item_description(self, item_name:str):
        print("S")
        # helper function printing description
        def print_description(desc: str):
                print("┌" + "─" * 100)
                print(f"| {item_name}: {desc}")
                print("└" + "─" * 100 + "\n")

        for kind, entries in self.beliefs.items():
            # kind has to be item
            if kind != "item": continue
            if isinstance(self.env.get_inner_structure(), Grid):
                for name, _,_,_,_,_ in entries:
                    if name == item_name:
                        description = self.get_env().get_item_description_by_name(name)
                        print_description (description)
                        return
            else:
                for item, value, weight, cell_uid in entries:
                    if item == item_name:
                        description = self.get_env().get_item_description_by_name(item_name)
                        print_description (description)
                        return
        
        for item in self.carrying:
            # kind has to be item
            if item.get_name() == item_name:
                print_description(item.get_description())
                return
        
        # If item not found
        print("NO ITEM MATCHING DESCRIPTION")
        
        
    # return agents beliefs
    def get_beliefs(self) -> list:
        return self.beliefs


    def debug(self, verbose:bool=False):
        print("┌──────────────────────────────────────── Agent Debug Info ────────────────────────────────────────┐")
        print(f"│ Agent's name : {self.name}")
        print(f"│ Cell         : {self.get_location().get_uid()}")
        print(f"│ Episode      : {self.get_env().episode}")

        # — Beliefs —
        if self.beliefs:
            print("│ Beliefs      :")
            for key, value in self.beliefs.items():
                if key == "item_kind": continue
                elif key == "carrying_weight": 
                    print(f"│               - Currently carrying: {value[0]}")
                    continue
                elif key == "weight_limit": 
                    print(f"│               - Carry capacity:     {value[0]}")
                    continue
                print(f"│               - {key}: {len(value)}")
                if key == "danger" and verbose == False: continue
                if key == "carrying": continue
                elif key == "items":
                    if len(value[0]) == 3: # grid
                        for item, x, y in value:
                            print(f"│                   * {item.get_name(),x,y}")
                    else:
                        for item, cell_name in value:
                            print(f"│                   * {item.get_name(),cell_name}")
                else:
                    for val in value:
                        print(f"│                   * {val}")
        else:
            print("│ Beliefs      : None")
        
        
        if self.carrying:
            print(f"│ Carrying     : {len(self.carrying)} item{'s' if len(self.carrying) != 1 else ''}")
            for item in self.carrying:
                print(f"│                   * {item.get_name()} (value={item.get_value()}, weight={item.get_weight()})")
        else:
            print("│ Carrying     : None")

            
        print("└──────────────────────────────────────────────────────────────────────────────────────────────────┘\n")
