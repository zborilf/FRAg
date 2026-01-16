# This file contains class for creating item(s). Item has to belong to one either a specific cell or an agent in order to be used

#author David Kanócz 2024 - 2025
#license GPL

import uuid

class Item:
    def __init__(self, name:str, value:int, weight:int, description:str):
        self.uuid = str(uuid.uuid4())
        self.name = name
        self.value = value
        self.weight = weight
        self.description = description
        self.attached = None
        self.attached_to_agent = False

    def __del__(self):
        ...


    # Attaches item to cell
    # Handles if it was attached to something else previously
    def attach_to_cell(self, cell):
        if self.get_attached_obj():
            agent = self.get_attached_obj()
            agent.remove_item_carry(self)
            
        cell.add_item(self)
        self.attached = cell
        self.attached_to_agent = False

    
    # Attaches item to agent
    # Handles if it was attached to something else previously
    def attach_to_agent(self, agent):
        agent.add_item_carry(self)
        self.attached = agent
        agent.get_location().remove_item(self)
        self.attached_to_agent = True
    

    # returns Agent, Cell or None
    def get_attached_obj(self):
        return self.attached


    #Getters and setters
    def set_weight(self, new_weight:int):
        self.weight = new_weight


    # sets item's value
    def set_value(self, new_value:int):
        self.value = new_value


    # returns item's name
    def get_name(self) -> str:
        return self.name
    

    # returns item's uuid
    def get_uuid(self) -> str:
        return self.uuid


    # returns item's weight
    def get_weight(self) -> int:
        return self.weight


    # returns item's value
    def get_value(self) -> int:
        return self.value
    

    # Method returning a description for when agent performs exampination
    def get_description(self) -> str:
        return self.description
    
    # Debug of cell, printing all relevant info
    def debug(self) -> None:
        print("┌───────────────────────────── Item Debug Info ─────────────────────────────┐")
        print(f"│ UUID        : {self.uuid}")
        print(f"│ Name        : {self.name}")
        print(f"│ Value       : {self.value}")
        print(f"│ Weight      : {self.weight}")
        print(f"│ Description : {self.description}")
        if self.attached is not None:
            if self.attached_to_agent:
                print(f"│ Attached to : Agent ({self.attached})")
            else:
                print(f"│ Attached to : Cell ({self.attached})")
        else:
            print("│ Attached to : None")
        print("└───────────────────────────────────────────────────────────────────────────┘\n")
