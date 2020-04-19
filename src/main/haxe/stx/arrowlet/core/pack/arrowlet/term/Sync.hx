package stx.arrowlet.core.pack.arrowlet.term;

class Sync<I,O,E> extends ArrowletApi<I,O,E>{
  private var delegate : I->O;
  public function new(delegate){
    super();
    this.delegate = delegate;
  }
  override private function doApplyII(i:I,cont:Terminal<O,E>):Response{
    cont.value(delegate(i));
    return cont.serve();
  }
}