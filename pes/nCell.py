# This file provides programmer a simple way to create a cell as a part of environment for the 'programmable' environment.
# Zero, one, or more instances of cell can be present in one environment, however, they need to be connected manually via "doors"
# Cells themselves can be organised in structured way called 'structure' (see Structure.py)

#author David Kanócz 2024 - 2025
#license GPL

from Item import Item

class Cell:
    def __init__(self, uid:str, active=True):
        self.uid = uid
        
        # Position if cell is located inside a grid
        self.neighbors = {} 

        self.items = []
        self.agents = []
        self.params = {}
        
        self.active = active

    
    # sets up a connection from one cell to the next
    def set_doorway(self, direction:str, cell) -> None:
        self.neighbors.setdefault(direction, cell)


    # adds item
    def add_item(self, item:Item) -> None:
        self.items.append(item)


    # removes item
    def remove_item(self, item:Item) -> None:
        self.items.remove(item)


    # registers agent with cell
    def register_agent(self, agent) -> None:
        self.agents.append(agent)


    def get_uid(self) -> str:
        return self.uid
    

    def set_uid(self, uid:str) -> None:
        self.uid = uid


    def set_param(self, name_of_param:str, value):
        self.params.update({name_of_param: value})


    def get_items(self) -> list[Item]:
        return self.items


    def has_items(self) -> bool:
        return True if len(self.get_items()) > 0 else False


    def get_neighbor(self, direction:str):
        return self.neighbors.get(direction)
    

    def get_neighbors(self):
        return self.neighbors


    def get_agents(self) -> list:
        return self.agents


    # unregisters agent
    def detach_agent(self, agent) -> None:
        self.agents.remove(agent)

    def debug(self):
        print("┌───────────────────────────── Cell Debug Info ─────────────────────────────┐")
        print(f"│ UID         : {self.uid}")
        print(f"│ Active      : {self.active}")
        
        # Display attached items
        if self.items:
            print("│ Items       :")
            for item in self.items:
                name = getattr(item, "name", str(item))
                print(f"│              - {name}")
        else:
            print("│ Items       : None")
        
        # Display registered agents
        if self.agents:
            print(f"│ Agents      : {len(self.agents)}")
            for agent in self.agents:
                name = getattr(agent, "name", str(agent))
                print(f"│             - {name}")
        else:
            print("│ Agents      : None")

        # Display parameters
        if self.params:
            print(f"│ Parameters  : {len(self.params)}")
            for key, value in self.params.items():
                print(f"│             - {key}: {value}")
        else:
            print("│ Parameters  : None")

        # Display neighbors
        if self.neighbors:
            print("│ Neighbors   :")
            for direction, neighbor in self.neighbors.items():
                print(f"│              - {direction}")
        else:
            print("│ Neighbors   : None")
        
        print("└───────────────────────────────────────────────────────────────────────────┘\n")
