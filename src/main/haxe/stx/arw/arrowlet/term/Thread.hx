package stx.arw.arrowlet.term;

@:using(stx.arw.arrowlet.term.Thread.ThreadLift)
@:provide abstract Thread(Arrowlet<Noise,Noise,Noise>) from Arrowlet<Noise,Noise,Noise>{
  static public var _(default,never) = ThreadLift;
  static public function lift(self:Arrowlet<Noise,Noise,Noise>):Thread{
    return self;
  }
  public function submit(?scheduler):Void{
    this.prepare(
      Noise,
      Terminal.ZERO
    ).submit(
      scheduler
    );
  }
  public inline function crunch(?scheduler):Void{
    this.prepare(
      Noise,
      Terminal.ZERO
    ).crunch(
      scheduler
    );
  }
}
class ThreadLift{
  
}