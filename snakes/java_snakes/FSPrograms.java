package frag.fragSnakes;

import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Queue;

import jason.asSemantics.IntendedMeans;
import jason.asSemantics.Intention;

public class FSPrograms {

	
	int PNOIntentions;
	FSProgram[] PPrograms;
	FSBindings[][] PBindings;
	int[][] PMaxBindingSize;
	
	// print, just for fun
	
		public void printPrograms() {
			for(FSProgram program:PPrograms)
				System.out.println(">>>>>>>>> : "+program.getProgram().toString());
		}
		
		
		public void printBindings() {
			for(int i=0;i<PNOIntentions;i++)
				for(int j=0;j<PNOIntentions;j++) {
					System.out.println("Bindings /"+i+","+j+"/");
						PBindings[i][j].printBindings();
				}
		}
		
	
	// Pro vsechny zamery JASONa vyrobi odpovidajici programy pro Hadi algoritmus
	
	public void translateIntentions(Queue<Intention> inputIntentions) {
		
		if(inputIntentions==null) {
			PPrograms=null;
			return;
		}
		
		Iterator<Intention> iterator=inputIntentions.iterator();
		
		int index=0;
		while(iterator.hasNext()) {
			Intention intention=(Intention)iterator.next();
			int size=intention.size();
//			for(int j=0;j<size;j++) {
//				IntendedMeans im=(IntendedMeans)intention.get(j);
				PPrograms[index]=(new FSProgram(intention));
//			}
			index++;
		}
		return;
	}
	
	/*
	 * Makes bindings between every pair of programs Pi and Pj, where i!=j
	 */
	
	
	private FSBindings makeBindings(int i, int j) {
		FSBindings bindings=new FSBindings(PPrograms[i],PPrograms[j],true);
		return bindings;
	}
	
	//FSBindings bindings;
	
	private void makeAllBindings() {
		
		for(int i=0;i<PNOIntentions;i++) {
			PBindings[i][i]=null;
			for(int j=0;j<PNOIntentions;j++)
				if(i<j) {
					PBindings[i][j]=makeBindings(i,j);
		//			PBindings[i][j].printBindings();
					PBindings[j][i]=PBindings[i][j].revertBindings();
					
					PMaxBindingSize[i][j]=PBindings[i][j].getBinding().size();
					PMaxBindingSize[j][i]=PMaxBindingSize[i][j]; // it is symetric
				}
			PBindings[i][i]=new FSBindings(PPrograms[i],PPrograms[i],false);
		}
	}
	
	
	public Queue<Intention> getMandatoryIntentions(){
		Queue<Intention> mandatoryIntentions=new LinkedList<Intention>();
		for(int i=0;i<PNOIntentions;i++) {
			boolean binded=false;
			for(int j=0;j<PNOIntentions;j++) {
				if(i!=j)
					if(PBindings[i][j].firstBindedAll())
						binded=true;
			}
			if(!binded) {
				System.out.println("Mandatorni je c "+i+" : "+PPrograms[i]);
				mandatoryIntentions.add(PPrograms[i].getIntention());
			}
		}
		return(mandatoryIntentions);
	}
	
	public Queue<Intention> getSnakeForExecution(int[] permutation){
		Queue<Intention> snake=new LinkedList<Intention>();
		snake.add(PPrograms[permutation[0]].getIntention());
		for(int i=0;i<(permutation.length-1);i++) {
					if(!PBindings[permutation[i]][permutation[i+1]].firstBinded()) {
						return(snake);
					}
					else
						if(PBindings[permutation[i]][permutation[i+1]].firstBinded2First()) {
							snake.add(PPrograms[permutation[i+1]].getIntention());
						}
						else {
							snake.clear();
							snake.add(PPrograms[permutation[i+1]].getIntention());
						}
					}
		return(snake);
	}
	
	
	
	public int getBindingsInSequence(List l) {
		/*int nob=0;
		for(int i=0;i<(l.size()+1);i++) {
			int i1=(int)l.get(i);
			int ii=i+1;
			int i2=(int)l.get(ii);
			FSBindings binding2=PBindings[i1][i2];
			FSBinding binding=bindings.getMaxBinding();
			nob+=binding.size();
			
		}
		return(nob);*/
		return(0);
	}
	
	

	// TEMP, vypise nejvetsi bindingsy pro plany od 1... x
	
	public void printMax() {
		List<Integer> l=new LinkedList<Integer>();
		
		for(int i=0;(i+1)<PNOIntentions;i++) {
			l.add(i);
			FSBindings bindings=PBindings[i][i+1];
			FSBinding be=bindings.getBinding();
			int ii=i+1;
	//		System.out.println("Max mezi "+i+" a "+ii); be.printBindings();
		}
		l.add(PNOIntentions);
		int i=getBindingsInSequence(l);
		System.out.println("Celkem v sekvuenci "+i);
	}
	
	
	/*
	 *  Provides binding between programs Pi and Pj that has the most elements
	 */
	
	public FSBinding getBinding(int i, int j) {
		if(i==j)
			return(null);
		FSBindings bindings=PBindings[i][j];
		return(bindings.getBinding());
	}
	
	// Number of programs
	
	public int getNoPrograms() {
		return(PNOIntentions);
	}
	
	//
	public void filterSnakeBindings(int[] programOrdering){
		FSBindings[][] snakeBindings;
		snakeBindings=new FSBindings[PNOIntentions][PNOIntentions];
		for(int i=0;i<PNOIntentions;i++)
			for(int j=0;j<PNOIntentions;j++)
				snakeBindings[i][j]=new FSBindings(PPrograms[i],PPrograms[j],false);
					
		for(int i=0;i<(programOrdering.length-1);i++) {
			snakeBindings[programOrdering[i]][programOrdering[i+1]]=
				PBindings[programOrdering[i]][programOrdering[i+1]];
			snakeBindings[programOrdering[i+1]][programOrdering[i]]=
					PBindings[programOrdering[i+1]][programOrdering[i]];
		}
		PBindings=snakeBindings;
//		printBindings();
		
	}
	
	
	// number of max bindings between (input) program and (instance) programs
	public int bindingsCount(FSProgram program) {
		int bs=0;
		for(int i=0;i<PNOIntentions;i++)
			bs+=new FSBindings(program,PPrograms[i],true).getBinding().size();
		return(bs);
	}

	public int longestProgramSize() {
		int max=0;
		for(int i=0;i<PNOIntentions;i++) {
			int size=PPrograms[i].getSize();
			if(size>max)
				max=size;
		}
		return(max);
	}
	
	public FSPrograms() {
		PPrograms=null;
	}
	
	
	public FSPrograms(Queue<Intention> inputIntentions) {
		PNOIntentions=inputIntentions.size();		
		PPrograms=new FSProgram[PNOIntentions];
		PBindings=new FSBindings[PNOIntentions][PNOIntentions];
		PMaxBindingSize=new int[PNOIntentions][PNOIntentions];
		translateIntentions(inputIntentions);
		makeAllBindings();
	//	System.out.println("!~!!!!!!!!!!"+PMaxBindingSize.toString());
	}
		
}

