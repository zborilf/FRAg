# This file provides programmer a simple way to create a cell as a part of environment for the 'programmable' environment.
# Zero, one, or more instances of cell can be present in one environment, however, they need to be connected manually via "doors"
# Cells themselves can be organised in structured way called 'structure' (see Structure.py)
# Cells can also be used manually

#author David Kanócz 2024 - 2025
#license GPL

# For now, only 4 side cells can be created

from Item import Item

class Cell:
    # Feel free to adjust default values to your liking
    def __init__(self, uid:str, active=True):
        self.uid = uid
        
        # default doors / ways of traversal
        self.up = None
        self.down = None
        self.left = None
        self.right = None

        # Position if cell is located inside a grid
        self.x = None
        self.y = None

        self.items = []
        self.agents = []
        self.params = {}

        self.active = active
        self.danger_rating = None # First calculated when needed


    # makes cell unavailable
    def make_unavailable(self) -> None:
        self.active = False

    
    # makes cell available
    def make_available(self) -> None:
        self.active = True


    # manually linking cell to one of cell's side
    # !used mainly for structure
    # theoretically, one could do a "portal" with this in Grid, 
    #   but the viewrange circle from origin wont change,
    #   so no percepts will be available if the final cell is outside of his viewrange circle
    def set_doorway(self, direction:str, cell) -> str|None:
        if direction == "left":
            self.left = cell
        elif direction == "right":
            self.right = cell
        elif direction == "up":
            self.up = cell
        elif direction == "down":
            self.down = cell


    # Adds item to the cell
    def add_item(self, item:Item) -> None:
        self.items.append(item)


    # Removes item from the cell
    def remove_item(self, item:Item) -> None:
        self.items.remove(item)


    # Registers agent with the cell
    def register_agent(self, agent) -> None:
        self.agents.append(agent)


    # sets Cells' x and y coordinates
    def set_coordinates(self, x:int, y:int) -> None:
        # assert >= 0
        self.x = x
        self.y = y


    # Returns cell's x coordinate
    def get_x(self) -> int:
        return self.x
    

    # Returns cell's y coordinate
    def get_y(self) -> int:
        return self.y

    
    # Returns cell's UID
    def get_uid(self) -> str:
        return self.uid
    

    # Sets cell's UID
    def set_uid(self, uid:str) -> None:
        self.uid = uid


    # Sets a cell's parameter to a value
    def set_param(self, name_of_param:str, value):
        self.params.update({name_of_param: value})


    # Returns a list of items located in a cell
    def get_items(self) -> list[Item]:
        return self.items


    # Returns True if cell contains any items
    def has_items(self) -> bool:
        return True if len(self.get_items()) > 0 else False


    # Returns a neighboring cell based on direction
    def get_neighbor(self, direction:str):
        if direction == "left":
            return self.left
        elif direction == "right":
            return self.right
        elif direction == "up":
            return self.up
        elif direction == "down":
            return self.down


    # EACH class of cell that will use danger, needs to make a definition for this method
    # as an example, this is function calculating danger for stalker env
    def get_danger_rating(self) -> int:
        if self.danger_rating is not None:
            return self.danger_rating
        
        anomaly = self.params.get("anomaly_danger", 0)
        mutant = self.params.get("mutant_danger", 0)

        # Compute the weighted sum.
        danger = (anomaly + mutant) / 2

        # Clamp the result to the range 0 to 100.
        danger = max(0, min(100, danger))
        self.danger_rating = int(round(danger))
        return int(round(danger))


    # Returns all agents in the cell
    def get_agents(self) -> list:
        return self.agents


    # Gets a direction of a neighbor based on x,y coordinates
    def get_neighbor_dir(self, target_x:int, target_y:int) -> str|None:
        x:int = self.get_x()
        y:int = self.get_y()

        # Check to make sure self (origin) and target are next to each other
        if abs(target_x - x) > 1 or abs(target_y - y) > 1:
            return None

        if target_x > x:
            if self.get_neighbor("right"):
                return "right"
        elif target_x < x:
            if self.get_neighbor("left"):
                return "left"
        elif target_y > y:
            if self.get_neighbor("down"):
                return "down"
        elif target_y < y:
            if self.get_neighbor("up"):
                return "up"
        return None

    # Detaches agent from this cell
    def detach_agent(self, agent) -> None:
        self.agents.remove(agent)


    def debug(self):
        print("┌───────────────────────────── Cell Debug Info ─────────────────────────────┐")
        print(f"│ UID         : {self.uid}")
        if self.x is not None and self.y is not None:
            print(f"│ Coordinates : (X:{self.x}, Y:{self.y})")
        else:
            print("│ Coordinates : (Not set)")
        print(f"│ Active      : {self.active}")
        
        # Display attached items
        if self.items:
            print("│ Items       :")
            for item in self.items:
                name = getattr(item, "name", str(item))
                print(f"│              - {name}")
        else:
            print("│ Items       : None")
        
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
        up_str    = self.up.get_uid() if self.up else "None"
        down_str  = self.down.get_uid() if self.down else "None"
        left_str  = self.left.get_uid() if self.left else "None"
        right_str = self.right.get_uid() if self.right else "None"
        
        print("│ Neighbors   :")
        print(f"│               Up    : {up_str}")
        print(f"│               Down  : {down_str}")
        print(f"│               Left  : {left_str}")
        print(f"│               Right : {right_str}")
        
        print("└───────────────────────────────────────────────────────────────────────────┘\n")