module checkmate

/////////////////////////////////////////////////////////////////////////////////////
// Candidate Executions module
/////////////////////////////////////////////////////////////////////////////////////
// Alloy Signature 							Set Contains All...
// sig Address 								addressable memory locations
// abstract sig Event 						micro-ops
// abstract sig MemoryEvent extends Event 	micro-ops that access memory
// sig Write extends MemoryEvent 			micro-ops that write memory
// sig Read extends MemoryEvent 			micro-ops that read memory
// abstract sig Location 					microarchitectural structures
// sig Node 								nodes in a µhb graph


sig Core { }

abstract sig Process { }
one sig Attacker extends Process { }
one sig Victim extends Process { }

abstract sig Address { }

abstract sig Cacheability { }
one sig Cacheable extends Cacheability { }
lone sig NonCacheable extends Cacheability { }

sig CacheIndexL1 { }

sig VirtualAddress extends Address { 
	indexL1: one CacheIndexL1,
	map: one PhysicalAddress,
	cacheability: one Cacheability
}
                                
sig PhysicalAddress extends Address {
    readers: set Process,
    writers: set Process,
    region: one Process}

abstract sig Event {	
	po: lone Event,
	NodeRel: set Location,
	
	process: one Process,
	coh: set Event,
   	core: one Core,	

	sub_uhb: set Location->Event->Location,         // Location为纵轴，即流水线，Event为横轴Location
	urf : set Location->Event->Location, 			//read from		
	uco : set Location->Event->Location,
	ufr : set Location->Event->Location, 			//from read
	ustb_flush: set Location->Event->Location,
	udep : set Location->Event->Location,			// dependence
	uhb_spec : set Location->Event->Location,
	ucoh_inter : set Location->Event->Location,		//coherence in superscalar pipeline 多个流水线之间
	ucoh_intra : set Location->Event->Location,		//coherence in pipeline 
	ustb: set Location->Event->Location,
	uvicl: set Location->Event->Location,			//value in cache lifetime	
  	ucci: set Location->Event->Location,
  	usquash: set Location->Event->Location, 		//CPU need to do when branch prediction fails
  	ufence: set Location->Event->Location,  		//lfence mfence, order of io
	uflush: set Location->Event->Location,			//flush cache
	uhb_inter: set Location->Event->Location,		//uhb_inter only relates different events on the same core
	uhb_intra: set Location->Event->Location,		//uhb_intra only relates the same event to different locations
	uhb_proc: set Location->Event->Location
}

abstract sig MemoryEvent extends Event {
	address: one VirtualAddress						
}

sig Read extends MemoryEvent {
    dep : set { MemoryEvent + CacheFlush }
}

sig Write extends MemoryEvent {
	rf: set Read,								
	co: set Write, 			
}

abstract sig Fence extends Event { }
sig FenceSC extends Fence { 
	sc: set FenceSC
}

sig CacheFlush extends Event { 
    flush_addr : one VirtualAddress
}

sig Branch extends Event {
	outcome : one Outcome,
	prediction : one Outcome
}

abstract sig Outcome { }
one sig Taken extends Outcome { }
one sig NotTaken extends Outcome { }

//Conventional FOPC writes “(∃ x)(Px)”.
//Alloy writes: some x | P[x]

// product: x -> y
// dot-join: x . y
// box-join: y[x]
// transpose: ~x  转置
// transitive closure: ^x, *x  传递闭包
// domain/range restriction: <:x, x:>
// override: x ++ y

//po
fact po_acyclic { acyclic[po] } //这里的acyclic是个谓词														
fact po_prior { all e: Event | lone e.~po }		//po是Event x Event的关系，这里将其倒置									

fun po_loc : MemoryEvent->MemoryEvent { ^po & (address.map).~(address.map) }	
 //address是MemoryEvent到VirtualAddress之间的一个关系，而map是VirtualAddress到PhysicalAddress的一个关系，
 //两者的Dot join将会消除掉中间的VirtualAddress,因此address.map表示MemoryEvent到物理地址的一种关系
 
 //po_loc是MemoryEvent x MemoryEvent，但是这两个MemoryEvent访问的地址都相同

//dep
fact dep_in_po { dep in ^po }	//dep是po传递闭包的一个子集			

//com
fun com : MemoryEvent->MemoryEvent { rf + fr + co }	//这里的Com是readfrom，from read和co关系的并集合						
fact com_in_same_addr { com in (address.map).~(address.map) }						

//writes
fact co_transitive { transitive[co] }													
fact co_total { all a: Address | total[co, a.~(address.map) & Write] }

// Definition: R is reflexive iff:
// all a : univ | a -> a in R
// Or, put another way:
// iden in R


// The identity relation on set E is the set {(x,x) | x∈E}. 
// The identity relation is true for all pairs whose first and second element are identical. 

//reads
fact lone_source_write { rf.~rf in iden }								
fun fr : Read->Write {							
  ~rf.co																							
  +
  ((Read - (Write.rf)) <:  ((address.map).~(address.map)) :> Write)		
}

//rmws
//fact rmw_adjacent { rmw in po & address.~address } // dep & address.~address } 

//fences
fact sc_total { total[sc, FenceSC] }
fun fence_sc : MemoryEvent->MemoryEvent { (MemoryEvent <: *po :> FenceSC).(FenceSC <: *po :> MemoryEvent) }

/////////////////////////////////////////////////////////////////////////////////////
// Check module
/////////////////////////////////////////////////////////////////////////////////////

abstract sig Location { }

sig Node {
	event: one Event,
	loc: one Location,
	uhb: set Node
}

fact { all e, e' : Event | all l, l' : Location | e->l->e'->l' in sub_uhb => ( e->l in NodeRel and e'->l' in NodeRel ) }

// uhb is the union of all u* relations
fact {
			{ 	urf +
         		uco +
				ufr + 
				udep +
				uhb_spec +
				ucoh_inter +
				ucoh_intra +
				ustb +
				ustb_flush +
				uvicl	+
				ucci +
				usquash +
				uflush +
				uhb_inter +
				uhb_intra +
				uhb_proc
			} = sub_uhb
}
// The product(->) of two relations R and S is the relation {(w,x,y,z) | wRx∧yRz} }
// no iden in uhb 
fact { all e, e' : Event | all l, l' : Location | e->e' in iden and l->l' in iden => not e->l->e'->l' in sub_uhb  }

// node mapping
fact { all e : Event | all l : Location  | e->l in NodeRel => one n : Node | n.event = e and n.loc = l }
fact { all n : Node | n.event->n.loc in NodeRel }
fact { all n, n' : Node | n->n' in uhb <=> n.event->n.loc->n'.event->n'.loc in sub_uhb }

// uhb_intra only relates the same event to different locations
fact 	{ all e, e' : Event 	| all l, l' : Location |  EdgeExists[e, l, e', l', uhb_intra] => SameEvent[e, e'] }

// uhb_inter only relates different events on the same core
fact { all e, e' : Event 	| all l, l' : Location | EdgeExists[e, l, e', l', uhb_inter] => not SameEvent[e, e'] }
fact { all e, e' : Event 	| all l, l' : Location | EdgeExists[e, l, e', l', uhb_inter] => SameThread[e, e'] }

pred ucheck { acyclic[uhb]  } 					// ucheck is a predicate that requires acyclicity 

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// =Alloy shortcuts=
fun optional[f: univ->univ] : univ->univ  { iden + f }
pred transitive[rel: Event->Event]        { rel.rel in rel }	//传递性的谓词
pred irreflexive[rel: Event->Event]       { no iden & rel }    //反自反性的谓词，反自反要求对角线上的元素都不存在。即rel与iden相交为空
pred irreflexive[rel: Node->Node]       { no iden & rel }      //此处表示不存在iden与rel相交后的元素
pred acyclic[rel: Event->Event]           { irreflexive[^rel] } //非循环的，如果rel的传递闭包是反自反的
pred acyclic[rel: Node->Node]           { irreflexive[^rel] } 
pred total[rel: Event->Event, bag: Event] {
  all disj e, e': bag | e->e' in rel + ~rel	
  acyclic[rel]											
}
pred u_irreflexive[node_rel: Event->Location->Event->Location]       {
	no node_rel or (		all e, e': Event |
								all l, l': Location |
								e->l->e'->l' in node_rel => not ( (e->e') in iden and (l->l') in iden )
							)
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// =Alloy Check predicates and functions=
fun CoreOf[e: Event] : Event { ( (Event - (Event.po)) & e ) + ( (Event - (Event.po)) & (^po.e) ) }
fun CacheableRead : Read { Read <: address.cacheability.Cacheable }
fun NonCacheableRead : Read { Read <: address.cacheability.NonCacheable }
fun CacheableWrite : Write { Write <: address.cacheability.Cacheable }
fun NonCacheableWrite : Write { Write <: address.cacheability.NonCacheable }
fun CacheableEvent : MemoryEvent { MemoryEvent <: address.cacheability.Cacheable }
fun NonCacheableEvent : MemoryEvent { MemoryEvent <: address.cacheability.NonCacheable }
fun AttackerEvent : Event { process.Attacker }
fun VictimEvent : Event { process.Victim }
fun AttackerRead : Event { Read <: process.Attacker }
fun AttackerWrite : Event { Write <: process.Attacker }
fun VictimRead : Event { Read <: process.Victim }
fun VictimWrite : Event { Write <:  process.Victim }
fun PhysicalAddress[e: Event] : PhysicalAddress { e.address.map + e.flush_addr.map }
fun VirtualAddress[e: Event] : VirtualAddress { e.address + e.flush_addr }
fun PredictedBranch : Branch { ((outcome.~prediction) & iden).Branch }
fun MispredictedBranch : Branch { Branch - ((outcome.~prediction) & iden).Branch }

pred NodeExists[e: Event, l: Location] { e->l in NodeRel }
pred EdgeExists[e: Event, l: Location, e': Event, l': Location, node_rel: Event->Location->Event->Location] 	{ e->l->e'->l' in node_rel }
pred DataFromInitialStateAtPA[r: Read] { r in {Read - Write.rf} }
pred HasDependency[r: Event, e: Event] { r->e in dep}   //从Read到MemoryEvent或者CacheFlush
pred IsAnyMemory[e: Event] { e in MemoryEvent}
pred IsAnyRead[e: Event] { e in Read }
pred IsAnyWrite[e: Event] { e in Write }
pred IsAnyFence[e: Event] { e in Fence }
pred IsAnyBranch[e: Event] { e in Fence }//是不是写错了
pred IsCacheFlush[e: Event] { e in CacheFlush }
pred SameProcess[e: Event, e': Event] { e->e' in process.~process }
pred SameCore[e: Event, e': Event] { e->e' in core.~core }
pred SameThread[e: Event, e': Event] { e->e' in ^po + ^~po }
pred SameLocation[l: Location, l': Location] { l->l' in iden }
pred SameEvent[e: Event, e': Event] { e->e' in iden }
pred ProgramOrder[e: Event, e': Event] { e->e' in ^po }
pred IsCacheable[e: MemoryEvent] { (e.address).cacheability = Cacheable }
pred IsIllegalRead[e: MemoryEvent] { (IsAnyRead[e] or IsCacheFlush[e]) and (not (e.process in PhysicalAddress[e].readers)) }
pred IsIllegalWrite[e: MemoryEvent] { IsAnyWrite[e] and (not (e.process in PhysicalAddress[e].writers)) }
pred DependsOnIllegal[e : MemoryEvent] { some r: Read | r->e in dep and IsIllegalRead[r] }
pred ReadsFromIllegal[e : MemoryEvent]  { IsAnyRead[e] and (some w: Write | w->e in rf and IsIllegalWrite[w]) }
pred SameIndexL1 [e: Event, e': Event] { (e.address).indexL1 = (e'.address).indexL1 }
pred NumProcessThreads[i: Int, P: Process] { #((Event - (Event.po)) & process.P)=i }
pred NumThreads[i: Int] { #(Event - (Event.po))=i }

pred SamePhysicalAddress[e: Event, e': Event] {
    e->e' in (address.map).~(address.map) or
	e->e' in (flush_addr.map).~(address.map) or
	e->e' in (address.map).~(flush_addr.map) or
	e->e' in (flush_addr.map).~(flush_addr.map)
} 

pred SameVirtualAddress[e: Event, e': Event] { 
    e->e' in address.~address or
	e->e' in flush_addr.~address or
	e->e' in address.~flush_addr or
    e->e' in flush_addr.~flush_addr
}

pred SameSourcingWrite[r: Read, r': Read] {
	not SameEvent[r, r'] and (
		DataFromInitialStateAtPA[r] and DataFromInitialStateAtPA[r'] or	// sourced by the same initial value
    	r->r' in ~rf.rf 
	)
}

