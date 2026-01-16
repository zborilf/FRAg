package frag.fragSnakes;

import java.util.LinkedList;
import java.util.List;
import java.util.Stack;

import com.sun.tools.javac.util.Pair;

import jason.asSyntax.BodyLiteral;
import jason.asSyntax.Literal;

/* Bindings are a list of interconnection between programs
 * each binding is one such interconnection that
 *    only matching (the same, unifiable) items may be connected
 *    connection cannot cross one another, it means when a[i11] -> a[i21] (action at positions i11 in 1st program
 *    and position i21 in the 2nd program), then
 *    	there cannot be a[i12]-> a[i22] such that if a11>a12 then a12<a22 and vice versa
 */

public class FSBindings {

	private List<FSBinding> PBindings;
	private FSBinding PBiggestBinding=null;
	private FSProgram PProgramA, PProgramB;

	/*
	 * In fact unification of two body literals ...
	 * Supposedly two predicates representing actions
	 * matching (unifiable) when terms are matching at each position
	 * where both are not variables (atoms)
	 */

	public void printBindings() {
		for(FSBinding binding:PBindings) {
			binding.printBinding();
		}
		System.out.println();
	}

	public void addBinding(FSBinding binding) {
		PBindings.add(binding);
	}
	
	public FSBindings revertBindings(){
		FSBindings bindings=new FSBindings(PProgramB,PProgramA,false);
		for(FSBinding bs:PBindings)
			bindings.addBinding(bs.revertBinding());
		return(bindings);
			
	}
	
	private boolean matches(BodyLiteral bl1, BodyLiteral bl2) {

		if(bl1.getType().compareTo(bl2.getType())!=0)
			return(false);
		Literal lf1,lf2;
		lf1=bl1.getLiteralFormula();
		lf2=bl2.getLiteralFormula();
		if(lf1.getFunctor().compareTo(lf2.getFunctor())!=0)
			return(false);
		if(lf1.getArity()!=lf2.getArity())
			return(false);
		for(int i=0;i<lf1.getArity();i++) {
			if(lf1.getTerm(i).isVar())
				continue;
			if(lf2.getTerm(i).isVar())
				continue;
			if(lf1.getTerm(i).toString().compareTo(lf2.getTerm(i).toString())!=0)
				return(false);
		}
		return(true);
	}
	
	
	private boolean matchesInstance(List<BodyLiteral> bl1l, List<BodyLiteral> bl2l) {
		for(int i=0;i<bl1l.size();i++)
			for(int j=0;j<bl2l.size();j++) {
		//		System.out.println("Matchuje "+bl1l.get(i).getLiteralFormula().toString()+
		//				" a "+bl2l.get(j).getLiteralFormula().toString());
				if (matches(bl1l.get(i),bl2l.get(j)))
					return(true);
			}
		return(false);
	}
	
	private int nextMatch(int offset1, int offset2) {
		// for action at position offset1 in PProgramA finds
		// position of matching action in PProgramB starting with position offset 2
		// or returns -1, when there is no such action
		if(offset2>=PProgramB.getSize()) // second plan is over already
			return(-1);
		int of2=offset2;
		while(!matchesInstance(PProgramA.getProgram().get(offset1),PProgramB.getProgram().get(offset2))
					&&(++offset2<PProgramB.getSize()));
		
		if(offset2<PProgramB.getSize())
			return(offset2);
		else
			return(-1);
	}
	

		
	/*
	 *   Making Bindings
	 */
	
	
	
	/*
	 * Novy pristup k make bindings, pres A*
	 */
	

	int getShorterLength() {
		if(PProgramA.getSize()<PProgramB.getSize())
			return(PProgramA.getSize());
			else
				return(PProgramB.getSize());
	}

	int getShorterLength(int offset1, int offset2) {
		int size1=PProgramA.getSize()-offset1;
		int size2=PProgramB.getSize()-offset2;
		if(size1<size2)
			return(size1);
			else
				return(size2);
	}

	
	class FSStack{
		LinkedList<FSBindingElement> _PElements;
		int _PNOBindings;
		int _PMaxPosBinding;
		
		int size() {
			return(_PElements.size());
		}
		
		FSStack makeCopy() {
			FSStack copy=new FSStack();
			for(FSBindingElement el:_PElements)
				copy.put(new FSBindingElement(el.getFirst(),el.getSecond()));
			return(copy);
		}
		
		void printStack() {
			System.out.print("|");
			for(FSBindingElement el:_PElements)
				System.out.print("["+el.getFirst()+","+el.getSecond()+"] ");
			System.out.println("]");
		}
	
		FSBinding stack2Binding(){
			FSBinding binding=new FSBinding();
			for(FSBindingElement el:_PElements)
				if(el.getSecond()>-1)
					binding.add(new FSBindingElement(el.getFirst(),el.getSecond()));
			return(binding);
		}
		
		
		void put(FSBindingElement element){
			_PElements.add(element);
			// bind to x -> -1 is not binded
			if(element.getSecond()>-1)
				_PNOBindings++;
		}
		
		int getNOBinds() {
			return(_PNOBindings);
		}
		
		int getLatestOffset1() {
			// returns position in programB, one after the last binds here
			int last=_PElements.get(0).getFirst();
			for(FSBindingElement el:_PElements)
				if(el.getFirst()>last)
					last=el.getFirst();
			return(last);
		}

		int getLatestOffset2() {
			// returns position in programB, one after the last binds here
			int last=_PElements.get(0).getSecond();
			for(FSBindingElement el:_PElements)
				if(el.getSecond()>last)
					last=el.getSecond();
			return(last);
		}
		
		FSStack(){
			_PMaxPosBinding=0;
			_PNOBindings=0;
			_PElements=new LinkedList<FSBindingElement>();
		}
	}
	
	class FSOpen{
		LinkedList<FSStack> _POpen;
	
		
		int getCost(int bindings, int offset1, int offset2) {
			int expMax=getShorterLength(); // max possible ever for P1 and P2
			int expMaxNow=getShorterLength(offset1, offset2);
			return(expMax-expMaxNow-bindings);
		}
		
		
		int getCost(FSStack stack) {
			return(getCost(stack.getNOBinds(),stack.getLatestOffset1()+1,stack.getLatestOffset2()+1));
		}
		
		boolean isEmpty() {
			return(_POpen.isEmpty());
		}
		
		FSStack getCheapest() {
			if(_POpen.isEmpty())
				return(null);
			int cheapest=0;
			FSStack stack=_POpen.get(0);
			int cheapestValue=getCost(stack);
			for(int i=1;i<_POpen.size();i++) {
				if(((getCost(_POpen.get(i))==cheapestValue)
						&&(_POpen.get(i).getLatestOffset1()>_POpen.get(cheapest).getLatestOffset1()))
					||
						(getCost(_POpen.get(i))<cheapestValue)) {
							cheapestValue=getCost(_POpen.get(i));
							cheapest=i;
				}
			}
			FSStack res=_POpen.get(cheapest);
			return(res);
		}
		
		
		FSStack getAndRemoveCheapest() {
			FSStack res=getCheapest();
			if(res==null)
				return(null);
			_POpen.remove(res);
			return(res);
		}
		
		
		void printStacksAndValues(){
			for(FSStack st:_POpen)
			{
				System.out.print("Stack ");
				st.printStack();
				System.out.println(" val:"+getCost(st));
			}
			return;
		}
		
		void add(FSStack element){
			_POpen.add(element);
		}
		
		
		FSOpen(){
			_POpen=new LinkedList<FSStack>();
		}
	}
		
	
		
	
	FSOpen expandBest(FSOpen open){
		FSStack stack=open.getAndRemoveCheapest();
		int offset1=stack.getLatestOffset1();
		int offset2=stack.getLatestOffset2();
		FSStack newStack=stack.makeCopy();
		newStack.put(new FSBindingElement(offset1+1,-1));
		open.add(newStack);
		do{
			offset2=nextMatch(offset1+1,offset2+1);
			if(offset2>=0) {
					newStack=stack.makeCopy();
					newStack.put(new FSBindingElement(offset1+1,offset2));
					open.add(newStack);                                    
			}		
		}while(offset2>=0);
		return(open);
	}
	
	FSStack makeBindingsAsDo(FSOpen open, int offset, int optimLength){
		System.out.println(PProgramA.getProgram().toString());
		System.out.println(PProgramB.getProgram().toString());
		System.out.println("Optim length = "+optimLength);
		do
			{
//			System.out.println("Best stack in Open value "+open.getCost(open.getCheapest()));
			expandBest(open);
//			open.printStacksAndValues();
//			System.out.println("Best stack in Open value "+open.getCost(open.getCheapest()));
			}
			while((open.getCheapest().getLatestOffset1()+1)<PProgramA.getSize());
		System.out.print("Reseni je ");
		open.getCheapest().printStack();
		return(open.getCheapest());
	}
	
	
	public FSBinding makeMaxBindingAs(){
		if((PProgramA==null)
			|| (PProgramB==null))
			return(null);
		FSStack rstack=new FSStack();
		FSStack stack=new FSStack();
		FSOpen open=new FSOpen();
		stack.put(new FSBindingElement(-1,-1));
		open.add(stack);
		int optimLength=getShorterLength();
		rstack=makeBindingsAsDo(open, 0, optimLength);
		return(rstack.stack2Binding());
	}
	
	
	
	
	
	
	
	

	/*
	 * Provides the longest binding
	 */
	
	public FSBinding getBinding(){
		int longest=0;
		FSBinding maxBinding=new FSBinding();
		if(PBindings==null)
			return(maxBinding);
		for(FSBinding bd:PBindings) {
			if(bd.size()>longest) {
				longest=bd.size();
				maxBinding=bd;
			}
		}
		return(maxBinding);
	}
	
	/*
	 * Recursive making of one set of bindings at level idx1 of the 1st Plan and starting at idx2 of 2nd Plan
	 */
	
	FSBinding makeBinding(Stack<FSBindingElement> stack){
		FSBinding binding=new FSBinding();
		
		// nemuzem stack znicit, jen opsat, proto get namisto pop
		for(int i=0;i<stack.size();i++) 
			binding.add(stack.get(i));
		return(binding);
	}

	
	// returns null, if it cannot make bigger binding than is the actual biggest
	// else returns list of bindings
	
	public LinkedList<FSBinding> makeBindingsR(Stack<FSBindingElement> stack,int idx1, int idx2){
		FSBinding binding;
		if(PProgramA.getSize()==idx1) {
			// end of the first program, lets make binding
			binding=makeBinding(stack);
			if(PBiggestBinding==null)
				PBiggestBinding=binding;
			else
			if(PBiggestBinding.size()<binding.size())
				PBiggestBinding=binding;
			LinkedList<FSBinding> bindings=new LinkedList<FSBinding>();
			bindings.add(binding);
			return(bindings);
		}
		
		// stop recursion, if the biggest binding so far is bigger then size of the stack (prefix of actual bidnding)
		// plus shorter of the remaining programs, it means PProgramA from idx1 and PProgramB from idx2
		// then we cannot make bigger binding than is the actual biggest one

		if(PBiggestBinding!=null) {
			int maxSize=PBiggestBinding.size();
			int remP1=PProgramA.getSize()-idx1+1;
			int remP2=PProgramB.getSize()-idx2+1;
			int rem;
			int ss=stack.size();
			if(remP1<remP2)
				rem=remP1+ss;
			else
				rem=remP2+ss;
			if(maxSize>=rem)
;//				return(null);
		}
		
		LinkedList<FSBinding> bindings1, bindings2;
		bindings1=makeBindingsR(stack,idx1+1,idx2); // nejprve dame skip a predame dal, az se vynorime, zkusime vsechny matche
		
		int idx3;
		while(nextMatch(idx1,idx2)>=idx2) {
			idx3=nextMatch(idx1,idx2);
			stack.push(new FSBindingElement(idx1,idx3));
			bindings2=makeBindingsR(stack,idx1+1,idx3+1); // rekurze pro aktualni match na urovni idx1
			stack.pop();
			if(bindings2!=null)
				for(int i=0;i<bindings2.size();i++)
					bindings1.add(bindings2.get(i));
			idx2=idx3+1;
		}
		return(bindings1);
	}
	

	public LinkedList<FSBinding> makeBindings(){
		if((PProgramA==null)
			|| (PProgramB==null))
			return(null);
		LinkedList<FSBinding>bindings=new LinkedList<FSBinding>();
		Stack<FSBindingElement> stack=new Stack<FSBindingElement>();				
		bindings=makeBindingsR(stack,0,0);
		
		return(bindings);
	}
	

		
	// in the bindings there is no bind for the first action of the plan - the plan is then mandatory
	
	public boolean firstBinded() {
		if(PBindings==null)
			return(false);
		for(FSBinding bnd:PBindings)
			if(!bnd.noFirstBinded()) 
				return(true);
		return(false);
	}
	

	public boolean firstBindedAll() {
		
		return(nextMatch(0,1) > -1);
		
	/*	
		LinkedList<FSBinding> bindings=makeBindings();
		for(FSBinding bnd:bindings)
			if(!bnd.noFirstBinded()) 
				return(true);
		return(false);				*/

	}
	
	
	public boolean firstBinded2First() {
		if(PBindings==null)
			return(false);
		for(FSBinding bnd:PBindings)
			if(!bnd.firstBinded2First()) {
				return(false);
			}
		return(true);
	}
	
	
	public FSBindings(FSProgram programA, FSProgram programB, boolean makeBindings) {
		PProgramA=programA;
		PProgramB=programB;
		if(makeBindings) {
			PBindings=new LinkedList<FSBinding>();
//			PBindings.add(makeMaxBindingAs());
			PBindings=makeBindings();
			FSBinding maxBinding=this.getBinding();    // toto je max proc? Je to serazene?
								// ^ ne, getBinding hleda nejvetsi, s nejvetsim poctem prvku
			PBindings=new LinkedList<FSBinding>();
			PBindings.add(maxBinding);
		}
		else
			PBindings=new LinkedList<FSBinding>();
	}

}


