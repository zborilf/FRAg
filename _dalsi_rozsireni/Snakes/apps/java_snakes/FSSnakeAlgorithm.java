package frag.fragSnakes;

import java.util.LinkedList;
import java.util.Queue;

import com.sun.tools.javac.util.List;

import jason.asSemantics.Intention;

public class FSSnakeAlgorithm {

	FSPrograms PPrograms;
	
	/*
	 *  Bindings optimization 
	 *  At this point algorithms search such ordering of intentions I1, I2 ... In that
	 *  sum of max. bindings between I1/I2 ; I2/I3 ... In-1/In is maximal
	 *  Need to do permutations, for this the size of sequence should be limited (to 7 aprox).
	 *  Input - bindings among every pair of the intentions
	 *  Returns a list of bindings, one for each tuple of consequent intentions
	 */

	final static int PMaxLoPermutations=7;
	static boolean PPermutsMade=false;
	static LinkedList<int[]>[] PPermutations;
	int[] PBestPermutation;
	
	static int[] swap(int[] ain, int a, int b){
		Integer e=ain[a];
		ain[a]=ain[b];
		ain[b]=e;
		return(ain);
	}
	
	static boolean containsElement(int n,LinkedList<int[]> l, int[] e) {
		for(int[] le:l){
			for(int i=0;i<n;i++)
				if(e[i]!=le[i])
					break;
				else
					if(i==(n-1))
						return(true);
		}
		return(false);
	}
	
	static boolean reverseIncluded(int n, LinkedList<int[]> l, int[] e) {
		int[] er=new int[n];
		for(int i=0;i<n;i++)
			er[i]=e[n-i-1];
		return(containsElement(n,l,er));
	}
	
	static LinkedList<int[]> 
				permutation(int n,LinkedList<int[]> laout,int[] ain){
		
		if(n==0) {
			int[] nain=new int[ain.length];
			for(int i=0;i<ain.length;i++)
				nain[i]=ain[i];
			if(!reverseIncluded(nain.length,laout,nain))
				laout.add(nain);
		}
		else {
			permutation(n-1,laout,ain);
			for(int i=0;i<n-1;i++) {
				if((n % 2)==0) 
					ain=swap(ain,i,n-1);
				else
					ain=swap(ain,0,n-1);
				permutation(n-1,laout,ain);
			}
		}
		return(laout);
	}
				
	static void printPermutation(int[] perm) {
		for(int i=0;i<perm.length;i++)
			System.out.print(String.valueOf(perm[i]));
	
	}
				
	
	static void printPerms(int n, LinkedList<int[]> ll) {
		for(int[] a:ll) {
			printPermutation(a);
			System.out.println();
		}
		System.out.println();
	}
	
				
	static void createPermutations() {
		if(PPermutsMade)
			return;
		PPermutsMade=true;
		PPermutations=new LinkedList[PMaxLoPermutations+1];
		
		for(int i=2;i <= PMaxLoPermutations; i++) {
			int[] ar=new int[i];
			for(int j=0;j<i;j++)
				ar[j]=j;
			LinkedList<int[]> lout=new LinkedList<int[]>();
			PPermutations[i]=permutation(i,lout,ar);
	//		printPerms(i,lout);
		}
		
	}
				
	public void printBestBindingsStraight(){
	//    PPrograms.printPrograms();; 
	//	  PPrograms.printMax(); 
	}
	
	public Queue<Intention> getMandatoryIfExists(Queue<Intention> inputIntentions){
		
		if(PPrograms.getMandatoryIntentions().isEmpty())
			return(inputIntentions);
			else
				return(PPrograms.getMandatoryIntentions());
	}
	
	
	public Queue<Intention> getSnake(Queue<Intention> inputIntentions) {
	//	Queue<Intention> qi=PPrograms.getMandatoryIntentions();
		if(PBestPermutation==null)
			return(null);
		Queue<Intention> qi=PPrograms.getSnakeForExecution(PBestPermutation);
		
		System.out.println("Snake je ...");
		for(Intention itn:qi)
			System.out.println("MMM:"+itn.toString());
		if(qi.isEmpty())
			return(inputIntentions);
			else
				return(qi);
	}
	
		
	public void filterBestPermutation() {
		int n=PPrograms.getNoPrograms();
		int[] bestPermutation=null;
		int bestValue=0;
		if((n>PMaxLoPermutations)||(n<2))
			return;
		
		for(int[] perm:PPermutations[n]) {
			int value=0;
	
			for(int i=0;i<(n-1);i++)  
				value = value
  						+ PPrograms.getBinding(perm[i], perm[i+1]).size();
					
		//	System.out.print("Value for perm ");
		//	printPermutation(perm);
		//	System.out.println(" is "+value);
			if(value>=bestValue) {
				bestValue=value;
				bestPermutation=perm;
			}
		}
		
		System.out.print("Best permutation ");
		printPermutation(bestPermutation);
		System.out.print("Value="+bestValue);
		System.out.println();
		PBestPermutation=bestPermutation;
		// now only the largest bindings between two successive programs remains (snakes)
		PPrograms.filterSnakeBindings(bestPermutation);
	}
	
	
	public void makeSnakes() {
		createPermutations();
		filterBestPermutation();	
	}
	
	
	public int longestProgram() {
		return(PPrograms.longestProgramSize());	
	}
	
	
	public FSSnakeAlgorithm(Queue<Intention> inputIntentions) {
		PPrograms=new FSPrograms(inputIntentions);
		PBestPermutation=null;
	}	
	
}
