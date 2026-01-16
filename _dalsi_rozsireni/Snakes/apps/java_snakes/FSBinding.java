package frag.fragSnakes;

import java.util.LinkedList;
import java.util.List;

public class FSBinding {

	List<FSBindingElement> PBinding;
	
	public void printBinding() {
		System.out.print("[ ");
		for(int i=0;i<PBinding.size();i++) {
			PBinding.get(i).printBindingElement();
			System.out.print(" ");
		}
		System.out.print(" ]");
	}
	
	public FSBindingElement get(int i) {
		return(PBinding.get(i));
	}
	
	public void add(FSBindingElement item) {
		PBinding.add(item);
	}
	
	public List<FSBindingElement> getListOfElements(){
		return(PBinding);
	}

	public int size() {
		return(PBinding.size());
	}
	
	public boolean noFirstBinded() {
		for(FSBindingElement be:PBinding)
			if((be.getFirst()==0))   // first action binded to other than another first action
				return(false);
		return(true);
	}

	public boolean firstBinded2First() {
		for(FSBindingElement be:PBinding)
			if((be.getFirst()==0)&&(be.getSecond()==0))   // first action binded to other than another first action
				return(true);
		return(false);		
	}
	
	public FSBinding revertBinding() {
		FSBinding binding=new FSBinding();
		for(int i=0;i<PBinding.size();i++) {
			FSBindingElement el=PBinding.get(i).revertElement();
			binding.add(el);
		}
		return(binding);
	}
	
	public FSBinding(List<FSBindingElement> binding) {
		PBinding=binding;
	}
	
	public FSBinding() {
		PBinding=new LinkedList<FSBindingElement>();
	}
	
}
