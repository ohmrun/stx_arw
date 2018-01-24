package stx.arrowlet.core.pack;

import stx.arrowlet.core.head.data.Bounce as BounceT;

abstract Bounce<T>(BounceT<T>) from BounceT<T> to BounceT<T>{
  public function new(self){
    this = self;
  }
  public function trampoline():Future<T>{
    var trg = Future.trigger();

    var handler = null;
        handler = function(bounce:Bounce<T>){
          switch(bounce){
            case Call(arw):
              arw(Noise,handler);
            case Done(r):
              trg.trigger(r);
          }
        }
    handler.upply(this);
    
    return trg;
  }
}
