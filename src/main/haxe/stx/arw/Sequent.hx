package stx.arw;

typedef SequentDef<E,S,R> = ArrowletDef<Triple<Option<Err<E>>,R,S>,Triple<Option<Err<E>>,R,S>,Noise>;

abstract Sequent<E,S,R>(SequentDef<E,S,R>) from SequentDef<E,S,R> to SequentDef<E,S,R>{
  public function new(self) this = self;
  static public function lift<E,S,R>(self:SequentDef<E,S,R>):Sequent<E,S,R> return new Sequent(self);


  public function prj():SequentDef<E,S,R> return this;
  private var self(get,never):Sequent<E,S,R>;
  private function get_self():Sequent<E,S,R> return lift(this);
}