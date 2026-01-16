# This file provides the programmer a simple way to create a structure part of environment for the 'programmable' environment.

#author David Kanócz 2024 - 2025
#license GPL

from nCell import Cell
from Item import Item
from typing import Tuple

#author David Kanocz
#license GPL

class Structure:
    def __init__(self, num_of_cells:int, attached_to, danger_present:bool = False):
        self.attached_to = attached_to
        self.array = [0 for _ in range(num_of_cells)]
        self.danger_present = danger_present

        # Create and add newly created cells to Structure's array
        for index in range(num_of_cells):
            cell:Cell = Cell(index)
            self.array[index] = cell


    # Returns a cell by index -- more useful for Grid
    def get_cell_by_index(self, index) -> Cell:
        return self.array[index]


    # Returns a cell by UID/name f.e. "Hall"
    def get_cell_by_uid(self, uid:str) -> Cell | None:
        for cell in self.array:
            if cell.get_uid() == uid:
                return cell 
        return None

    # For more commented version, see this method in Grid.py    
    def get_percepts(self, agent) -> list:
        cell:Cell = agent.get_location()
        percepts:list[Tuple[str, any, str]] = []
        
        for neighbor in cell.get_neighbors():
            percepts.append(("neighbor", neighbor))
        for item in cell.get_items():
            percepts.append(("items", item, cell.get_uid())) # NOT APPEARING IN AGENTS PERCEPTS - purely for this python env
            percepts.append(("item", item.get_name(), item.get_value(), item.get_weight(), cell.get_uid(), item.get_uuid()))
        for item in agent.get_carried_items():
            percepts.append(("carrying", item.get_name(), item.get_value(), item.get_weight()))
        for seen_agent in cell.get_agents():
            agents_cell:Cell = seen_agent.get_location()
            if agent == seen_agent:
                percepts.append(("self", seen_agent.get_name(), agents_cell.get_uid()))
            else:
                percepts.append(("agent", seen_agent.get_name(), agents_cell.get_uid()))
        return percepts
    

    # Places item in an environment
    def place_item(self, item:Item, cell:Cell):
        item.attach_to_cell(cell)


    # All cells in structure will debug
    def debug(self):
        for cell in self.array:
            cell.debug()



