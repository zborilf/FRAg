from Agent import Agent
from EnvironmentUtils import *
from Grid import *
from Structure import *
from Generator import *

# Use this environment if you are working with grids, structures
class ModularEnvironment:
    def __init__(self, name:str, clone:bool):
        self.name:str = name # description/name
        self.clones: list[self:ModularEnvironment] = [] # List of clones of environments
        self.agents: list[Agent] = []       # List of agents situated in the environment as a whole aka in all its subenvironments


        # CAUTION! static_facts right now only works with key: (x,y).
        # If you need structure with a different length, for example key: (something, x, y)
        #   update percept_g or percept_s methods in Agent.py by adding if rules to already existing 'for fact in static_facts:'
        # Alternatively, create a class inheriting from Agent and make a new definition for percept_g with changes
        self.static_facts:dict = {}         # Dictionary of static facts about environment.


        self.dynamic_facts:dict = {         # Dictionary of dynamic facts about the environment
            "items": [],
        }             
        self.clone = clone
        self.inner_structure:Grid|Structure = None
        self.episode:int = 0
        self.closing_time:int # Set to an integer value in. This could go into static facts, if it would be beneficial for agent to know
        self.generators:list[Generator] = []
        
        # If you are using Grid, coordinates are what you want to use
        #   for example "paul": 5,4
        # If you are using Structure, you need to specify what room specific agent needs to spawn in
        #   for example "robot A": "Hall"
        self.agent_spawn_coordinates:dict = {}
       

        # Animations for Structures are with a debug, hence animate_mode is ignored 
        self.animating_agent_name:str = ""  # What agent does the animation, if animation is turned on
        self.animate:bool = False           # If program should animate
        self.animate_mode:str = ""          # Modes available are viewrange, items, agents. Anything else will output structure only
        self.animation_delay:float = 0.5    # Delay to make something like an animation
        

    # Register agent with the environment and vice versa
    def append_agent(self, agent:Agent) -> None:
        self.agents.append(agent)
        agent.set_env(self)
    

    # Returns settings used for animation, or if animation should even be enabled
    def get_animate_settings(self) -> Tuple[str, bool, str, float]:
        return self.animating_agent_name, self.animate, self.animate_mode, self.animation_delay


    # Register environment's clone with the environment  
    def append_clone_env(self, env) -> None:
        self.clones.append(env)


    # Creates and places agent in a cell
    def place_agent(self, agent_name:str, cell:Cell) -> Agent:
        agent:Agent = Agent(agent_name)
        self.append_agent(agent)
        agent.register_cell(cell)
        cell.register_agent(agent)
        return agent


    # Registers object of type Structure with the environment
    def register_structure(self, struct:Structure) -> None:
        self.inner_structure = struct
        struct.attached_to = self


    # Registers object of type Grid with the environment   
    def register_grid(self, grid:Grid) -> None:
        self.inner_structure = grid
        grid.attached_to = self


    # Gets an object that acts as the "physical" environment
    # Either Grid or Structure
    # If none has been set -> None
    def get_inner_structure(self) -> Grid | Structure:
        assert self.inner_structure is not None, "None inner structure found! Expected instance of Grid or Structure"
        return self.inner_structure


    # Registers item with environments list and attaches item to cell
    def add_item_to_env(self, item:Item, cell:Cell) -> None:
        item.attach_to_cell(cell)
        self.dynamic_facts["items"].append((item, cell))


    # Registers generator with environments list
    def add_generator_to_env(self, generator:Generator) -> None:
        self.generators.append(generator)


    # Method is called at the end of each perceive cycle of the last agent
    def run_generators(self) -> None:
        for gen in self.generators:
            gen.check_and_generate(self.episode)


    # This method is for generators that are NOT called automatically each percieve cycle
    def explicit_generate(self, item_name:str, number_of_items:int=1) -> None:
        for gen in self.generators:
            if gen.item_name == item_name:
                gen.schedule_item_gen(self.episode, number_of_items)


    # Return name of this environment
    def get_name(self) -> str:
        return self.name


    # Returns item description for specified item, based on item's name, if item can be found
    def get_item_description_by_name(self, item_name:str) -> Item:
        for item, _ in self.dynamic_facts.get("items", []):
            if item.get_name() == item_name:
                return item.get_description()
        return "No item found ERR"


    # Returns a spawn point for agent based on its name
    def get_agent_spawn(self, agent_name:str):
        return self.agent_spawn_coordinates[agent_name]


    # Return all environment clones
    def get_clones(self) -> list:
        return self.clones
    

    # Return all agent objects
    def get_agents(self) -> list[Agent]:
        return self.agents


    # Return names of all agents
    def get_names_a(self) -> list:
        names = []
        for a in self.get_agents():
            names.append(a.get_name())
        return names

    
    # Find and return agent by its name in the environment
    def get_agent_by_name(self, agent_name:str) -> Agent:
        for agent in self.agents:
            if agent.get_name() == agent_name:
                return agent


    # Query environment for a value of a given fact name
    def get_fact_value(self, key:str):
        if key in self.dynamic_facts():
            return self.dynamic_facts[key]
        elif key in self.static_facts:
            return self.static_facts[key]
        # Key not found in either dictionary
        else:
            return None
        
    # Outputs environment's stuff, verbose parameter prints out also individual subcategories
    #   for example, verbose set to false would print out item: number
    #   but with verbose set to true, it would print out item: number and all individual items
    def debug(self, verbose:bool = False):
        print("┌────────────────── ModularEnvironment Debug Info ──────────────────┐")
        # Basic identity
        print(f"│ Name            : {self.name}")
        print(f"│ Clone flag      : {self.clone}")
        
        # Clones
        clones = getattr(self, 'clones', [])
        if clones:
            print(f"│ Clones          : {len(clones)}")
            for c in clones:
                print(f"│                 - {c.get_name()}")
        else:
            print("│ Clones          : None")
        

        # Agents -----------------------------------------------------------------------
        if self.agents:
            print(f"│ Agents          : {len(self.agents)}")
            for ag in self.agents:
                print(f"│                 - {ag.get_name()}")
        else:
            print("│ Agents          : None")
        

        # Dynamic facts ----------------------------------------------------------------
        if self.dynamic_facts:
            print("│ Dynamic facts   :")
            for fact_name, fact_value in self.dynamic_facts.items():
                # print header then each element underneath with an asterisk (if verbose)
                if isinstance(fact_value, list):
                    if verbose:
                        amount:int = len(fact_value)
                        print(f"│                 - {fact_name}: {amount}")
                        for entry in fact_value:
                            if isinstance(entry, tuple):
                                item, cell = entry
                                print(f"│                     * {item.get_name()} @ {cell.get_uid()}")
                            else:
                                print(f"│                     * {entry}")
                    else:
                        print(f"│                 - {fact_name}")
                else:
                    print(f"│                 - {fact_name}: {fact_value}")
        else:
            print("│ Dynamic facts   : None")
        
        if isinstance(self.get_inner_structure(), Grid): print(f"│ Inner structure : Grid")
        elif isinstance(self.get_inner_structure(), Structure): print(f"│ Inner structure : Structure")
        else:    print("│ Inner structure : None")
        
        print("└───────────────────────────────────────────────────────────────────┘\n")