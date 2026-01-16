wants(betty, cd2,60).
wants(betty, cd5,125).
wants(betty, cd4,60).
wants(betty, cd1,90).

has(adam,cd3).
has(adam,cd4).
has(adam,cd5).

price(cd1,100).
price(cd3,80).
price(cd4,110).
price(cd2,110).
price(cd5,130).
price(cd6,70).
price(cd7,110).
price(cd8,130).

!sell.

+!sell<-
			.my_name(ME);
			.println(ME);
			?has(ME,CARD);
			?wants(betty,CARD,OFFERS);
			?price(CARD,PRICE);
			DIF = (PRICE-OFFERS)/PRICE;
			DIF<0.2;
			.println(CARD).


+!sell<-.println(nevysloTo).
