
Aktualni verze 'nejak' funkcni pro MCTS a pro prostredi.

run.bat spousti FRAg pro priklad 'adam' umisneny v experiments/adam/adam
v souboru adam.mas2fp je nastavení systému. Lze mìnit, ideálnì mezi 
1, late a early bindings, nastavit
set_default(bindings, late).
nebo
set_default(bindings, early).
2, nastavenim reasoning politiky, idealne 
set_default(reasoning, random_reasoning).
nebo
set_default(reasoning, mcts_reasoning).
reasoningy lze nastavit i v atributech agentu, ktere jsou jako v seznamech ...
load("adam","examples/adam/adam",1,[(reasoning, mcts_reasoning), (debug, systemdbg)]).

Obecnì klauzule pro definici agentù
load(Jmeno_Agentniho_Typy, Soubor_Agentniho_Programu, Pocet_Agentu, Atributy)
Jmeno agenta obdobne jako v Jasonu, pokud je jen jeden, pak je jmeno stejne 
jako jmeno typu. Pokud vice, prida se za jmeno typu cislo 1 .. Pocet_Agentu
Atributy jsou dvojice (typ_atribut, hodnota).
Typ atributu
  
  reasoning
    Mozne hodnoty podle toho, co je nahrano v core/environments
      simple_reasoning,
      random_reasoning
      robin_reasoning,
      biggest_joint_reasoning
      mcts_reasoning
 
  debug
      systemdbg
      reasoningdbg
      mcstdbg
      mctsdbg_path

