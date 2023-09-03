package frag.fragSnakes;

import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Queue;

import frag.FSParameters;
import jason.asSemantics.IntendedMeans;
import jason.asSemantics.Intention;
import jason.asSemantics.Unifier;
import jason.asSyntax.BodyLiteral;
import jason.asSyntax.Plan;

public class FSProgram {
	
	/* program is a list of lists of body literals
	/  it is sequence of action options
	 * [[a11 or a12 ...] ; [a21 or a22 ...] ; ... ]1
	 */
	
	private List<List<BodyLiteral>> PProgram;
	private Intention PIntention;
	

	
	public List<List<BodyLiteral>>getProgram() {
		return(PProgram);
	}
	
	
	public int getSize() {
		return(PProgram.size());
	}
	
	public Intention getIntention() {
		return(PIntention);
	}
	
	void addOption(List<List<BodyLiteral>> program, List<BodyLiteral> actionOption) {
		if(program.size()<FSParameters._maxProgramLength)
			program.add(actionOption);
	}
	
	public FSProgram(Intention intention) {
		PProgram=new LinkedList<List<BodyLiteral>>();
		PIntention=intention;
		IntendedMeans im=null;
		int size=intention.size();
		for(int i=0;i<size;i++) {
		    im=(IntendedMeans)intention.get(i);
			List<BodyLiteral> program=im.getPlan().getBody();
			for(BodyLiteral bl:program) {
				List<BodyLiteral>actionOptions=new LinkedList<BodyLiteral>();
				List<Unifier> context=im.getUnifSet();
				if(context.isEmpty())
					actionOptions.add((BodyLiteral)bl.clone());
				for(Unifier substitution:context) {
					BodyLiteral bl2=(BodyLiteral)bl.clone();
					bl2.getLogicalFormula().apply(substitution);
					actionOptions.add(bl2);
				}
				addOption(PProgram,actionOptions);
			}
		}
	//	System.out.println("Vytvoril jsem program "+PProgram);
	}
	
	public FSProgram(Plan plan, List<Unifier> context) {
		PProgram=new LinkedList<List<BodyLiteral>>();		
		List<BodyLiteral> program=plan.getBody();
		for(BodyLiteral bl:program) {
		List<BodyLiteral>actionOptions=new LinkedList<BodyLiteral>();
		if(context.isEmpty())
			actionOptions.add((BodyLiteral)bl.clone());
		for(Unifier substitution:context) {
			BodyLiteral bl2=(BodyLiteral)bl.clone();
			bl2.getLogicalFormula().apply(substitution);
			actionOptions.add(bl2);
		}
			addOption(PProgram,actionOptions);
		}
	
	
		System.out.println("Vytvoril jsem program "+PProgram);
		
	}
	
}
