package stx.arw.arrowlet.term;

import tink.core.Future in TinkFuture;

class Fun1Future<I,O,E> extends ArrowletBase<I,O,E>{
  var delegate : I->TinkFuture<O>;
  public function new(delegate:I -> TinkFuture<O>){
    super();
    this.delegate = delegate;
  }
  override public function applyII(i:I,cont:Terminal<O,E>):Work{
    var defer = Future.trigger();
    var handler   = (o:O) ->{
      defer.trigger(Success(o));
    }
    var canceller = delegate(i).handle(
      handler
    );//TODO
    return cont.defer(defer).serve();
  }
}