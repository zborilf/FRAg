# Class implementing miconic environment in python
import sys
import os
import time
import math, random
import numpy as np
import traceback

# Add the root directory to sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../../env')))

from AbsEnv import *


# Child class of ModularEnvironment class
class Shop(Environment):
    def __init__(self, name:str):
        super().__init__(name=name, clone=False)
        self.static_facts = {
            "MAX_PRICE":                    160,
            "AVERAGE_BUYERS":               0.22,
            "AVERAGE_SELLERS":              0.22,
            "MEAN_DISCOUNT_BUYER":          0.60,
            "DISPERSION_DISCOUNT_BUYER":    0.20,
            "MEAN_DISCOUNT_SELLER":         0.40,
            "DISPERSION_DISCOUNT_SELLER":   0.20,
            "BUYERS_STAY":                  100,
            "SELLERS_STAY":                 100,
            "CLOSING_TIME":                 750,
            "EPISODE_MODE":                 "sim_time",  # "real_time" or "sim_time"
            "EPISODE_LENGTH":               1.0,         # if real_time
        }

        self.dynamic_facts = {
            "product": {
                "cd1": 100,
                "cd2": 80,
                "cd3": 68,
                "cd4": 110, 
                "cd5": 50,
                "cd6": 90,
                "cd7": 110,
                "cd8": 55,
                "cd9": 150
            },
            
            # buyer_name: (item, max_price, deadline)
            "buyer": {},
                
            # seller_name: (item, max_price, deadline)
            "seller": {},
                    

            "episode": 1,

            # sales statistics:  
            # sold_by list is a dictionary of key:value (Bob<broker>, 5<sells>)
            "stats_":{
                
                
            },

            "closed":False
        }
        self.buyers_index = 0
        self.sellers_index = 0
        self.deadlines = {}
        self.last_time = -1.0
        self.buyers_total = 0
        self.sellers_total = 0 


    def drive_time(self) -> None:
        # Update episode
        last_time:float = self.last_time
        sim_mode:str = self.get_fact_value("episode_mode")
        episode:int = self.get_fact_value("episode")
        iterations:int = 1
        # the very first percept seeds the initial clock
        if last_time < 0 and sim_mode == "real_time": 
            last_time = now
            return

        if sim_mode == "real_time":
            now = time.time()
            step = self.get_fact_value("episode_length")
            # how many whole episodes have elapsed?
            n_steps = int((now - last_time) // step)
            last_time = now
            if n_steps > 0:
                iterations = n_steps
        
        self.drive_episode(iterations, episode)

    
    def drive_episode(self, iterations:int, episode:int) -> None:
        local_episode:float = episode
        if local_episode >= self.get_fact_value("CLOSING_TIME"): 
            self.add_or_update_facts(("closed", True))

        for _ in range(iterations):
            local_episode += 1
            self.add_or_update_facts(("episode", local_episode))
            # now drop customers with waiting time past their deadline
            self.remove_impatients(local_episode)
            # If the shop is not yet closed, create new customers
            self.add_customers()
        

    # Removes all sellers and buyers whose deadlines expired
    def remove_impatients(self, episode: float) -> None:
        # grab the dicts (or default to empty dict)
        buyers: dict[str, Tuple[str,int]] = self.dynamic_facts.get("buyer", {})
        sellers: dict[str, Tuple[str,int]] = self.dynamic_facts.get("seller", {})


        # filter by deadline (tuple is (item, price, deadline), so index 2)
        buyers = {
            name: data
            for name, data in buyers.items()
            if self.deadlines[name] > episode
        }
        sellers = {
            name: data
            for name, data in sellers.items()
            if self.deadlines[name] > episode
        }

        self.dynamic_facts["buyer"]  = buyers
        self.dynamic_facts["seller"] = sellers
    
    
    def add_customers(self) -> None:
        lam_s   = self.get_fact_value("AVERAGE_SELLERS")
        mean_s  = self.get_fact_value("MEAN_DISCOUNT_SELLER")
        disp_s  = self.get_fact_value("DISPERSION_DISCOUNT_SELLER")
        stay_s  = self.get_fact_value("SELLERS_STAY")

        sellers = self.get_fact_value("seller")
        products = self.get_fact_value("product")
        episode  = self.get_fact_value("episode")

        new_sellers = np.random.poisson(lam_s)

        for _ in range(new_sellers):
            discount   = random.gauss(mean_s, disp_s)
            item       = random.choice(list(products.keys()))
            base_price = products[item]
            price      = int(base_price * (1 - discount))
            deadline   = episode + stay_s
            self.sellers_total += 1
            seller_id = f"seller{self.sellers_index}"
            sellers[seller_id] = (item, price)
            self.deadlines[seller_id] = (deadline)
            self.sellers_index += 1

        self.add_or_update_facts([
            ("seller", sellers),
        ])


        lam_b   = self.get_fact_value("AVERAGE_BUYERS")
        mean_b  = self.get_fact_value("MEAN_DISCOUNT_BUYER")
        disp_b  = self.get_fact_value("DISPERSION_DISCOUNT_BUYER")
        stay_b  = self.get_fact_value("BUYERS_STAY")

        buyers = self.get_fact_value("buyer")
        new_buyers = np.random.poisson(lam_b)

        for _ in range(new_buyers):
            discount   = random.gauss(mean_b, disp_b)
            item       = random.choice(list(products.keys()))
            base_price = products[item]
            price      = int(base_price * (1 - discount))
            deadline   = episode + stay_b
            buyer_id = f"buyer{self.buyers_index}"
            self.buyers_total += 1
            buyers[buyer_id] = (item, price)
            self.deadlines[buyer_id] = (deadline)
            self.buyers_index += 1

        self.add_or_update_facts([
            ("buyer", buyers),
        ])



    # Increases seller's sales by 1
    def bump_sale(self, broker_name) -> None:
        stats = self.get_fact_value("stats_")
        stats[broker_name] = stats.get(broker_name, 0) + 1
        self.add_or_update_facts([
            ("stats_", stats)
       ])


    def attempt_transaction(self, broker:str, seller_str:str, buyer_str:str, what:str) -> int:
        print("\nATTEMPT")
        seller: dict[str, tuple[str,int,float]] = self.get_fact_value("seller")
        buyer: dict[str, tuple[str,int,float]] = self.get_fact_value("buyer")
        closed = self.get_fact_value("closed")
        if closed: return 0

        entry_s = seller.get(seller_str)
        entry_b = buyer.get(buyer_str)
        if not entry_s: return 0
        if not entry_b: return 0
        item_s, _ = entry_s
        item_b, _ = entry_b


        if not item_s == what == item_b:
            return 0
    
        
        seller.pop(seller_str)
        buyer.pop(buyer_str)

        

        stats = self.bump_sale(broker)

        self.buyers_total  -= 1
        self.sellers_total -= 1


        # write back all three facts in one go
        self.add_or_update_facts([
            ("seller", seller),
            ("buyer",  buyer),
            ("stats_",  stats),
        ])

        
        print("TRANSACTION FINISHED")
        print(broker, seller_str, buyer_str, what)
        return 1


# Creates and registers top-level environment (ModularEnvironment) alongside with subenvironments
def initialize_environment():
    shop:Shop = Shop("shop")
    # register the main environment to environment pointer
    register_environment(env_obj=shop)
    return shop
