# This file provides the programmer a simple way to create a grid-like part of environment for the 'programmable' environment.
# Zero, one, or more instances of grid can be present in one environment, however, they need to be connected manually via "doors" (if other parts of environment exist)
# Grid itself is a collection of individual cells (see Cell.py)
# Each of these cells has 4 sides and by default 4 "doors" that allow agents two-way traversal by default
# max size of grid is 999x999 cells

#author David Kanócz 2024 - 2025
#license GPL

from Cell import Cell
from typing import Tuple
import sys # used in draw if you want to clear terminal

class Grid:
    def __init__(self, width: int, height: int, attached_to, danger_present:bool = False):
        self.attached_to = attached_to
        self.width = width    # horizontal dimension
        self.height = height  # vertical dimension
        self.danger_present = danger_present
        
        # matrix indexed as [x][y]
        self.matrix: list[list[Cell]] = [[None for _ in range(height)] for _ in range(width)]
        
        # creating cells
        for x in range(width):
            for y in range(height):
                # Using x and y in the UID
                name: str = f"{x:03d}{y:03d}"
                cell: Cell = Cell(name)
                cell.set_coordinates(x, y)  # Now x is the horizontal coordinate and y is vertical.
                self.matrix[x][y] = cell

        # connecting individual cells to form the grid
        for x in range(width):
            for y in range(height):
                current_cell:Cell = self.matrix[x][y]
                if x > 0:
                    current_cell.set_doorway("left", self.matrix[x - 1][y])
                if x < width - 1:
                    current_cell.set_doorway("right", self.matrix[x + 1][y])
                if y > 0:
                    current_cell.set_doorway("up", self.matrix[x][y - 1])
                if y < height - 1:
                    current_cell.set_doorway("down", self.matrix[x][y + 1])


    # Call this function after sculpting the environment
    def cull_paths(self):
        for x in range(self.width):
            for y in range(self.height):
                cell: Cell = self.matrix[x][y]

                if cell.active is False:
                    cell.up = cell.down = cell.left = cell.right = None
                else:
                    northern: Cell = cell.get_neighbor("up")
                    southern: Cell = cell.get_neighbor("down")
                    eastern: Cell  = cell.get_neighbor("right")
                    western: Cell  = cell.get_neighbor("left")

                    if northern is not None and not northern.active:
                        cell.set_doorway("up", None)

                    if southern is not None and not southern.active:
                        cell.set_doorway("down", None)

                    if eastern is not None and not eastern.active:
                        cell.set_doorway("right", None)

                    if western is not None and not western.active:
                        cell.set_doorway("left", None)


    # creates a wall on one side for each cell provided
    def block_way(self, direction: str, cells: list[Cell]) -> None:
        for cell in cells:
            if direction == "left":
                neighbor = cell.get_neighbor("left")
                if neighbor is not None:
                    neighbor.set_doorway("right", None)
                cell.set_doorway("left", None)
            elif direction == "right":
                neighbor = cell.get_neighbor("right")
                if neighbor is not None:
                    neighbor.set_doorway("left", None)
                cell.set_doorway("right", None)
            elif direction == "up":
                neighbor = cell.get_neighbor("up")
                if neighbor is not None:
                    neighbor.set_doorway("down", None)
                cell.set_doorway("up", None)
            elif direction == "down":
                neighbor = cell.get_neighbor("down")
                if neighbor is not None:
                    neighbor.set_doorway("up", None)
                cell.set_doorway("down", None)


    # For all cells provided, assign a new parameter to them with a default value
    def add_param(self, name_of_param: str, default_value):
        for x in range(self.width):
            for y in range(self.height):
                current_cell: Cell = self.matrix[x][y]
                current_cell.set_param(name_of_param, default_value)


    # For all cells provided, assign a new parameter value to them
    def mod_param(self, name_of_parameter: str, new_value, cells: list[Cell]):
        for cell in cells:
            cell.set_param(name_of_parameter, new_value)


    # Returns a list containing all cells agent sees from his positions
    # Taking into account walls and inactive cells
    # Performs a line of sight check for all cells in radius
    def get_cells_in_radius(self, origin: Cell, radius: int) -> list[Cell]:

        # Performs a line of sight check for a cell
        def LoS_check(origin: Cell, target: Cell) -> bool:
            x0, y0 = origin.get_x(), origin.get_y()
            x1, y1 = target.get_x(), target.get_y()

            greater:int = abs(x0 - x1)
            lesser:int = abs(y0 - y1)
            # Change it around if needed
            if greater < lesser:
                temp = greater
                greater = lesser
                lesser = temp

            # If the line ever crosses in a way that it hits the corner precisely, take note
            # Taking total number of x and y cells and dividing greater with a lesser
            # IF and only if greater % lesser equals zero AND is not a straight line
            # We can conclusively say, it goes straight through a corner
            going_through_corner:bool = True if (greater+1) % (lesser+1) == 0 else False
            going_through_corner = False if abs(x0 - x1) == 0 or abs(y0 - y1) == 0 else going_through_corner
            
            prev_x = prev_y = prev_coord_x = current_coord_x = prev_coord_y = currend_coord_y = None
            
            # Modified algorithm from Eugen Dedu https://dedu.fr/projects/bresenham/
            for x, y in supercover_line(x0, y0, x1, y1):
                # First iteration setup - no moving
                if x == x0 and y == y0:
                    current_coord_x = prev_coord_x = origin.get_x()
                    currend_coord_y = prev_coord_y = origin.get_y()
                    continue

                # Normal operation
                if going_through_corner == False:
                    direction:str|None = origin.get_neighbor_dir(x,y)
                    if direction: origin = origin.get_neighbor(direction)
                    else: return False
                
                # Hitting corners
                else:
                    # Test for wall on path
                    direction: str | None = origin.get_neighbor_dir(x, y)

                    # Normal operation
                    if direction: origin = origin.get_neighbor(direction)

                    # Wall encountered somewhere. Lets take path 1,1 -> 2,1 -> 2,2 as an example
                    # Encountered a wall from 2,1 -> 2,2
                    elif prev_coord_x and abs(x - prev_coord_x) == 1 and abs(y - prev_coord_y) == 1:
                        # try going from 1,1 -> 1,2

                        # First, go cell back
                        back_dir:str = origin.get_neighbor_dir(prev_coord_x, prev_coord_y)
                        origin = origin.get_neighbor(back_dir)

                        # Switch x and y
                        # after we switch them, one coordinate should match
                        # Other coordinate will differ by one
                        # If one coordinate differs by one and the other by 2, we went wrong direction on the other axis
                        new_y = prev_x
                        new_x = prev_y

                        # check if coordinate x OR y is off by 2
                        if abs(new_x - x) > 1: new_x = x
                        if abs(new_y - y) > 1: new_y = y

                        # Try to move different path aka from 1,1 -> 1,2
                        direction: str | None = origin.get_neighbor_dir(new_x, new_y)
                        if direction: origin = origin.get_neighbor(direction)
                        else: return False

                        # Now try 1,2 -> 2,2
                        direction: str | None = origin.get_neighbor_dir(x, y)
                        if direction: origin = origin.get_neighbor(direction)
                        else: return False

                    # Encountered a wall from 1,1 -> 2,1
                    # Try to move in the other axis. If it was NOT a diagonal cross, it will fail in next loop iteration
                    else:
                        current_x = origin.get_x()
                        current_y = origin.get_y()

                        # If x and current x differ, we already tried moving alongside the x axis
                        tried_horizontal:bool = False
                        if x != current_x: tried_horizontal = True

                        # Check if we are in the vicinity of next cell
                        if abs(current_x - x) + abs(current_y - y) > 1:
                            return False

                        if tried_horizontal:
                            # Then we move vertically
                            # To go up, y1 (target y) must have lower value
                            if y1 < current_y: origin = origin.get_neighbor("up")
                            else: origin = origin.get_neighbor("down")
                        else:
                            if x1 > current_x: origin = origin.get_neighbor("right")
                            else: origin = origin.get_neighbor("left")
                            
                        if origin is None: return False

                    prev_x = x
                    prev_y = y

                    prev_coord_x, prev_coord_y = current_coord_x, currend_coord_y
                    current_coord_x, currend_coord_y = origin.get_x(), origin.get_y()
            
            # Final check if we actually got to the target cell
            if origin.get_x() == x1 and origin.get_y() == y1: return True
            else: return False


        # Returns a line, making a clear path from cell A to cell B
        def supercover_line(x0, y0, x1, y1):
            # Returns a path of all cells from x0y0 to x1y1
            dx = x1 - x0
            dy = y1 - y0
            
            # Number of steps vertically and horizontally
            nx = abs(dx)
            ny = abs(dy)

            # Which way to go on axis
            sign_x = 1 if dx > 0 else -1
            sign_y = 1 if dy > 0 else -1

            x, y = x0, y0
            # Return origin cell
            yield x, y

            # driving axis is X
            if nx >= ny:
                # accumulated error term
                err = nx // 2
                for _ in range(nx):
                    x += sign_x
                    err += ny
                    # if we crossed the y‑boundary, also step in y
                    if err >= nx:
                        err -= nx
                        # include both cells on the diagonal crossing
                        yield x, y
                        y += sign_y
                    yield x, y

            # driving axis is Y
            else:
                err = ny // 2
                for _ in range(ny):
                    y += sign_y
                    err += nx
                    if err >= ny:
                        err -= ny
                        yield x, y
                        x += sign_x
                    yield x, y

                    

        visible:list[Cell] = [] # List of visible cells after line of sight test
        row_origin = origin.get_y()
        col_origin = origin.get_x()

        # culling square around origin
        top = max(0, row_origin - radius)
        left = max(0, col_origin - radius)
        right = min(self.width - 1, col_origin + radius)
        bottom = min(self.height - 1, row_origin + radius)
        
        # checking each cell in culled rectangle for visibility
        for row in range(top, bottom + 1):
            for col in range(left, right + 1):
                dr = row - row_origin
                dc = col - col_origin
                # only check cells in circle
                if dr**2 + dc**2 <= radius**2:
                    if self.matrix[col][row].active:
                        if(LoS_check(origin, self.matrix[col][row])):
                            visible.append(self.matrix[col][row])
        
        return visible
    

    # returns a Cell by provided index
    def get_cell_by_index(self, x: int, y: int) -> Cell:
        assert x >= 0 and x < self.width, f"given X is out of range of grid (0 - {self.width - 1}), given X was {x}"
        assert y >= 0 and y < self.height, f"given Y is out of range of grid (0 - {self.height - 1}), given Y was {y}"
        return self.matrix[x][y]


    # returns a list containing one Cell by provided index. Some methods expect a list and not single Cell.
    def get_cell_by_index_list(self, x: int, y: int) -> list[Cell]:
        assert x >= 0 and x < self.width, f"given X is out of range of grid (0 - {self.width - 1}), given X was {x}"
        assert y >= 0 and y < self.height, f"given Y is out of range of grid (0 - {self.height - 1}), given Y was {y}"
        return [self.matrix[x][y]]


    # return a rectangle of cells from two point - corners
    def select_cells(self, cell_upper_left: Cell, cell_lower_right: Cell) -> list[Cell]:
        cells: list[Cell] = []
        x1: int = cell_upper_left.get_x()
        y1: int = cell_upper_left.get_y()
        x2: int = cell_lower_right.get_x()
        y2: int = cell_lower_right.get_y()

        # ensuring that the given rectangle is within bounds and correctly ordered
        assert 0 <= x1 < self.width, "cell_upper_left.x is out of bounds"
        assert 0 <= y1 < self.height, "cell_upper_left.y is out of bounds"
        assert 0 <= x2 < self.width, "cell_lower_right.x is out of bounds"
        assert 0 <= y2 < self.height, "cell_lower_right.y is out of bounds"
        assert x1 <= x2, "Upper left x must be <= lower right x"
        assert y1 <= y2, "Upper left y must be <= lower right y"

        for x in range(x1, x2 + 1):
            for y in range(y1, y2 + 1):
                cells.append(self.matrix[x][y])
        return cells


    # returns percepts from all cells agent sees
    def get_percepts(self, agent) -> list[(str, any, int, int)]:
        cells:list[Cell] = self.get_cells_in_radius(agent.get_location(), agent.get_viewrange())
        percepts:list[Tuple] = []
        for cell in cells:
            if self.danger_present: percepts.append(("danger", cell.get_danger_rating(), cell.get_x(), cell.get_y())) # if danger is present in an environment
            for item in cell.get_items():
                percepts.append(("items", item, cell.get_x(), cell.get_y())) # NOT APPEARING IN AGENTS PERCEPTS - purely for this python env
                # Next one IS appearing in agent's belief. UUID is only to distinguish between different items, so as to not treat multiple items as one
                percepts.append(("item", item.get_name(), item.get_value(), item.get_weight(), cell.get_x(), cell.get_y(), item.get_uuid()))
            for item in agent.get_carried_items():  # Percieving what agent is carrying
                percepts.append(("carrying", item.get_name(), item.get_value(), item.get_weight()))
            for seen_agent in cell.get_agents():
                agents_cell:Cell = seen_agent.get_location()
                if agent == seen_agent: # Percieving agents
                    percepts.append(("self", seen_agent.get_name(), agents_cell.get_x(), agents_cell.get_y()))
                else:
                    percepts.append(("agent", seen_agent.get_name(), agents_cell.get_x(), agents_cell.get_y()))
        return percepts


    # Returns height of the environment
    def get_height(self) -> int:
        return self.height


    # Makes each cell from list of cells accessible
    # Primary function of this method is to make sculpting of environment more convenient
    # Instead of making X number of calls to make_inaccessible, one can utilize this method
    #   to make a single call make_inaccessible and then simly subtract the inaccessible area with this method
    def unlock_cells(self, cells: list[Cell]) -> None:
        for cell in cells:
            cell.make_available()


    # Makes each cell from list of cells inaccessible -> there exists no way into the cell.
    # These cells are marked with an 'X' when drawn
    def lock_cells(self, cells: list[Cell]) -> None:
        for cell in cells:
            assert 0 <= cell.get_x() < self.width, "cell x is out of bounds"
            assert 0 <= cell.get_y() < self.height, "cell y is out of bounds"
            cell.make_unavailable()


    # Debug function, outputting current attributes of Grid object
    def debug(self, detailed:bool = False):
        # Header with grid-level summary info
        header = "┌" + "─" * 60 + " Grid Debug Info " + "─" * 60 + "┐"
        print(header)
        print(f"│ Grid Dimensions        : {self.width}(X) × {self.height}(Y)")
        print(f"│ Total number of cells  : {self.width *self.height}")
        print(f"│ Attached to environment: {self.attached_to}") if self.attached_to is not None else print("│ Not attached to any subenvironment")
        print("└" + "─" * 137 + "┘\n")
        
        # Detailed outputs debug of each cell as well
        if detailed:
            print("Cell Debug Info:")
            for x in range(self.width):
                for y in range(self.height):
                    self.matrix[x][y].debug()


    # Drawing method used to either debug environment or making a visual representation
    def draw(self, overlay:str="", special_cells:list[Cell]=None, agent_cell:Cell=None):
        # ANSI escape code for red, reset etc
        RED = "\033[31m"
        GREEN = "\033[32m"
        BLUE = "\033[34m"
        RESET = "\033[0m"
        cell_width = 3  # content width for each cell - feel free to change (odd numbers work better for centering content)

        # Calculates color based on danger rating. 0 - green; 100 - red
        # By default, the exponent is set to 0.4, making the danger rating colors logarithmic
        def get_color_for_danger(rating: int, exponent: float = 2.0) -> str:
            # Normalize
            base_ratio = rating / 100.0 # 100 is the max value
            ratio = base_ratio ** exponent
            red_val = int(255 * ratio)
            green_val = int(255 * (1 - ratio))
            #\033 terminal formatting
            #38 - set foreground color
            #2  - 24bit color aka (0-255,0-255,0-255)
            return f"\033[38;2;{red_val};{green_val};0m" 

        # Draw grid
        for y in range(self.height):
            # Top border of cells
            line_top = ""
            for x in range(self.width):
                cell = self.matrix[x][y]
                line_top += "+"
                # If there is no neighbor above - draw a red wall
                if cell.get_neighbor("up") is None:
                    line_top += RED + ("-" * cell_width) + RESET
                else:
                    line_top += " " * cell_width
            # Plus signs mark corners
            line_top += "+"
            print(line_top)

            # Left and right borders plus content
            line_mid = ""
            for x in range(self.width):
                cell = self.matrix[x][y]
                # Draw a wall if neighbor is missing
                if cell.get_neighbor("left") is None:
                    line_mid += RED + "|" + RESET
                else:
                    line_mid += " "
                # The cell content: if cell is inactive, show an "X"
                if not cell.active:
                    content = "X".center(cell_width)
                # Else content is depending on which overlay is chosen
                # If no overlay has been chosen or is missing/misspelled -> empty
                else:
                    # Danger displays the perceived danger. Useful at the start to validate initial settings
                    if overlay == "danger":
                        rating = cell.get_danger_rating()
                        color_code = get_color_for_danger(rating, exponent=0.4)
                        content = color_code + "●".center(cell_width) + RESET
                    # Displays only items in an environment as an integer value
                    elif overlay == "items":
                        num_of_items:int = len(cell.get_items())
                        content = GREEN + str(num_of_items).center(cell_width) + RESET if num_of_items > 0 else " " * cell_width
                    # Displays only agents in an environment as an integer value
                    elif overlay == "agents":
                        num_of_items:int = len(cell.get_agents())
                        content = GREEN + str(num_of_items).center(cell_width) + RESET if num_of_items > 0 else " " * cell_width
                    # Displays one selected agent alongside with his viewrange (cells that he currently sees) and all items in the environment
                    # Cells that are visible are marked with green '●'; cell that agent is in is marked with red '●'
                    # If the cell that agent is standing on has an item, the content changes from displaying a red ● to displaying number of items, in that cell, in blue color
                    # If item is located outside of the agent's viewrange, it's displayed red. If it is indide of viewrange, it is displayed green
                    elif overlay == "viewrange":
                        # Agent cell
                        if agent_cell and agent_cell.get_x() == cell.get_x() and agent_cell.get_y() == cell.get_y():
                            content = RED + "●".center(cell_width) + RESET if cell in special_cells else " " * cell_width
                        # Cell in agent's viewrange
                        else:
                            content = GREEN + "●".center(cell_width) + RESET if cell in special_cells else " " * cell_width

                        # If cell contains item(s)
                        num_of_items:int = len(cell.get_items())
                        if num_of_items > 0:
                            # If this cell has an item and also is the cell agent is standing in -> blue int number of items
                            if cell in special_cells and cell.get_x() == agent_cell.get_x() and cell.get_y() == agent_cell.get_y(): content = BLUE + str(num_of_items).center(cell_width) + RESET
                            # If this cell is in viewrange -> green int number of items
                            elif cell in special_cells: content = GREEN + str(num_of_items).center(cell_width) + RESET
                            # If this cell is outside viewrange -> red int number of items
                            else: content = RED + str(num_of_items).center(cell_width) + RESET
                    # Cell content is ignored - useful when checking the structure of an environment
                    else:
                        content = " " * cell_width
                line_mid += content
            # right border
            line_mid += RED + "|" + RESET
            print(line_mid)

        # Draw the bottom border for the last row
        line_bottom = ""
        for x in range(self.width):
            line_bottom += "+"
            line_bottom += RED + ("-" * cell_width) + RESET
        line_bottom += "+"
        print(line_bottom)
