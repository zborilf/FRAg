% cesty do warehouse, hall, construction


path(hall, warehouse, [warehouse]).
path(construction, warehouse, [hall, warehouse]).
path(workshop, warehouse, [hall, warehouse]).
path(construction, hall, [hall]).
path(workshop, hall, [hall]).
path(warehouse, hall, [workshop, hall]).
path(hall, construction, [construction]).
path(workshop, construction, [hall, construction]).
path(warehouse, construction, [workshop, hall, construction]).


