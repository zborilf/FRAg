package frag.fragSnakes;

public class FSBindingElement {

	private int PIdx1;
	private int PIdx2;
	
	public int getFirst() {
		return(PIdx1);
	}
	
	public int getSecond() {
		return(PIdx2);
	}
	
	public void printBindingElement() {
		System.out.print("["+PIdx1+","+PIdx2+"]");
		return;
	}
	
	public FSBindingElement revertElement() {
		return(new FSBindingElement(PIdx2,PIdx1));
	}
	
	public FSBindingElement(int idx1,int idx2) {
		PIdx1=idx1;
		PIdx2=idx2;
	}
	
}
