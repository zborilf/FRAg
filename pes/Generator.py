import numpy as np

#author David Kanocz
#license GPL
# This class implements a generator, making dynamic environments possible. Generator should always be used as a class to inherit from
# Each percept cycle, all generators wake up and do their business (checking if they can afford to generate item in the future, and planning)
class Generator():
    def __init__(self, env, in_cell, item_name:str, avg_wait:int, item_limit:int=0, enabled:bool=True, mode:str="exp", on_percept_cycle:bool=True):
        assert in_cell is not None, "'in_cell'in generator was None"
        self.env = env # Structure of type structure or grid
        self.in_cell = in_cell  # Cell generator is attached to
        self.planned_episodes:list[int] = [] # list of planned item generations
        self.avg_wait:int = avg_wait # Avg wait time
        self.item_limit:int = item_limit # How many items with a name specified in 'item_name' can be in cell
        self.item_name:str = item_name # What item count we need to check in cell for generator
        self.enabled:bool = enabled # Generator switch
        self.mode:str = mode # What type of planning to use (exponential, constant and other eventually)
        
        # If generator is designed to work always, each cycle, set following to true.
        # Otherwise set it to false and call schedule_item_gen explicitly in some other method or function
        self.on_percept_cycle:bool = on_percept_cycle 

    # Creates x number of items based on how many items are planned to be created this episode
    # Then tries to schedule new ones
    def check_and_generate(self, current_episode: int) -> None:
        if not self.enabled: return None
        # Select episode whose time has come
        episodes_due = [ep for ep in self.planned_episodes if ep <= current_episode]
        # Keep only episodes will be still relevant in the next loop
        self.planned_episodes = [ep for ep in self.planned_episodes if ep > current_episode]

        # Generate for each due episode
        for _ in episodes_due:
            self.item_create()

        if self.on_percept_cycle == True:
            self.schedule_item_gen(current_episode, self.item_limit) # Try to schedule as many as possible


    # Schedules creation of new items, using exponential distribution
    # Number of items to be scheduled is maximal amount of this item in cell - (items currently in cell + already planned ones)
    def schedule_item_gen(self, current_episode:int, number_of_items:int=1) -> None:
        items = self.in_cell.get_items()

        current_item_count:int = 0
        missing_items:int = 0

        if items != []: current_item_count = sum(1 for itm in items if itm.get_name() == self.item_name)
        current_item_count += len(self.planned_episodes) # We need to account for already planned items 
        missing_items = max(0, self.item_limit - current_item_count)

        # IF we limited number of items created via explicit item generation (method explicit_generate in modenv)
        # we need limit them
        missing_items = min(number_of_items, missing_items)

        for _ in range(missing_items):
            if self.mode == "exp": self.exponential_planning(current_episode)
            elif self.mode == "const": self.constant_planning(current_episode)


    # Plans creation of items with exponential distribution
    def exponential_planning(self, current_episode:int) -> None:
            delay = np.random.exponential(scale=self.avg_wait)
            planned_episode = current_episode + int(round(delay))
            self.planned_episodes.append(planned_episode)

    
    # Plans creation of items with a predetermined delay
    def constant_planning(self, current_episode:int) -> None:
            self.planned_episodes.append(self.avg_wait + current_episode)


    # Each class generator must have an explicit definition for what item it should create
    # Example
    # def item_create(self):
    #    self.env.add_item_to_env(Item("Sponge", 400, 4, "Found in electric anomalies"), self.in_cell)
    def item_create(self):...

    # Enables generator    
    def enable_gen(self) -> None:
        self.enabled = True

    # Disables generator
    def disable_gen(self) -> None:
        self.enabled = False