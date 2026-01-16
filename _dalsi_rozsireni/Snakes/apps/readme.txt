
Postup:
	generovani hadu + astar optimum + obsolete hledani snake vysledku
		hjs2.pl
		go(A,B,B,C,D,E).
		A - od ktereho indexu generuji priklad
		B - kolik prikladu
		C - pocet promennych (do 22)
		D - max. delka planu
		E - pocet zameru (do 22)

	vygeneruje priklady do podatresare 'res', mel by existovat, take prida vysledky v souboru results

	prekopirovat do vhodneho adreasere, co bylo vygenerovano pro experimenty je v XXYYZZ adresarich, cisla dle parametru C,D,E
	pocet promennych je ale o jedna mensi nez C, C je max pro rand a nevyskytuje se

	nahrat spustitelne fragy do onoho adresare

	spustit run.bat runb.bat runc.bat

	vytvori soubory 
	fragout, fragoutb, fragoutc, pokud nektery z nich nespadne, pocita se stem prikladu v danem adresari v souborech out1 ... out100
 
	spustit analyzuj.pl v tomto adresari, vytvori cvs.cvs

	naimportovat cvs.cvs do Excelu, oddelovac carka

	seradit podle tretiho sloupce, vyhodit radky, kde je zde hodnota -1 : astar nenasel reseni

	data ve tretim sloupci optimum, odzadu snake, mandatory, first

