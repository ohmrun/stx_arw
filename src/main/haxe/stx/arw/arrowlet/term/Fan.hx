package stx.arw.arrowlet.term;

class Fan<I,O,E> extends ArrowletCls<I,Couple<O,O>,E>{
  private var delegate : Arrowlet<I,O,E>;
  public function new(delegate){
    super();
    this.delegate = delegate;
  }
  override public function apply(i:I):Couple<O,O>{
    return this.convention.fold(
      () -> throw E_Arw_IncorrectCallingConvention,
      () -> {
        var result = delegate.apply(i);
        return __.couple(result,result);
      }
    );
  }
  override public function defer(i:I,cont:Terminal<Couple<O,O>,E>):Work{
    return delegate.prepare(
      i,
      cont.joint(
        (o:Outcome<O,Defect<E>>) -> contv.value(o.map(v -> __.couple(v,v))).serve()
      ) 
    );
  }
  override public function get_convention(){
    return this.delegate.convention;
  }
}