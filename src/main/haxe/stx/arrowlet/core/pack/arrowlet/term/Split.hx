package stx.arrowlet.core.pack.arrowlet.term;

class Split<I,Oi,Oii,E> extends ArrowletApi<I,Couple<Oi,Oii>,E>{
  var delegate : Arrowlet<Couple<I,I>,Couple<Oi,Oii>,E>;
  
  public function new(lhs,rhs){
    super();
    this.delegate = Arrowlet.lift(new Both(lhs,rhs).asArrowletDef());
  }
  override private function doApplyII(i:I,cont:Terminal<Couple<Oi,Oii>,E>):Response{
    return delegate.applyII(
      __.couple(i,i),
      cont
    );
  }
}