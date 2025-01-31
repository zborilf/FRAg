path(hall, warehouseA, [warehouseA]).
path(construction, warehouseA, [hall, warehouseA]).
path(workshop, warehouseA, [hall, warehouseA]).
path(warehouseB, warehouseA, [workshop, hall, warehouseA]).

path(hall, warehouseB, [warehouseB]).
path(construction, warehouseB, [hall, warehouseB]).
path(workshop, warehouseB, [hall, warehouseB]).
path(warehouseA, warehouseB, [workshop, hall, warehouseB]).

path(construction, hall, [hall]).
path(workshop, hall, [hall]).
path(warehouseA, hall, [workshop, hall]).
path(warehouseB, hall, [workshop, hall]).

path(hall, construction, [construction]).
path(workshop, construction, [hall, construction]).
path(warehouseA, construction, [workshop, hall, construction]).
path(warehouseB, construction, [workshop, hall, construction]).

path(hall, workshop, [warehouseA, workshop]).
path(construction, workshop, [hall, warehouseA, workshop]).
path(warehouseA, workshop, [hall, workshop]).
path(warehouseB, workshop, [hall, workshop]).

warehouses(warehouseA).
warehouses(warehouseB).

!complete_tasks.

+!complete_tasks : carry(_)
    <- !go_to(hall);
       drop;
       go(construction);
       !complete_tasks.
