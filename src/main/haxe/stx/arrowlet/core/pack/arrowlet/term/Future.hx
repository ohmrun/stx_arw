package stx.arrowlet.core.pack.arrowlet.term;

import tink.core.Future in TinkFuture;

class Future<O,E> extends ArrowletApi<Noise,O,E>{
  var delegate : TinkFuture<O>;
  public function new(delegate:TinkFuture<O>){
    super();
    this.delegate = delegate;
  }
  override private function doApplyII(i:Noise,cont:Terminal<O,E>):Response{
    delegate.handle(
      cont.value
    );
    return cont.serve();
  }
}