package stx.arrowlet.core.pack.arrowlet.term;

import tink.core.Future in TinkFuture;

class Fun1Future<I,O,E> extends ArrowletApi<I,O,E>{
  var delegate : I->TinkFuture<O>;
  public function new(delegate:I -> TinkFuture<O>){
    super();
    this.delegate = delegate;
  }
  override private function doApplyII(i:I,cont:Terminal<O,E>):Response{
    var handler   = (o:O) ->{
      cont.value(o);
    }
    var canceller = delegate(i).handle(
      handler
    );//TODO
    return cont.serve();
  }
}