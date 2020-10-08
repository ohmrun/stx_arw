package stx.arw;

typedef ProvideDef<O> = ConvertDef<Noise,O>;

@:using(stx.arw.Provide.ProvideLift)
abstract Provide<O>(ProvideDef<O>) from ProvideDef<O> to ProvideDef<O>{
  static public var _(default,never) = ProvideLift;
  public function new(self) this = self;
  static public function lift<O>(self:ProvideDef<O>):Provide<O> return new Provide(self);

  @:from static public function fromFunTerminalWork<O>(fn:Terminal<O,Noise>->Work):Provide<O>{
    return lift(
      Arrowlet.Anon(
        (i:Noise,cont:Terminal<O,Noise>) -> fn(cont)
      )
    );
  }
  @:noUsing static public function pure<O>(v:O):Provide<O>{
    return lift(Arrowlet.pure(v));
  }
  @:from static public function fromFunXR<O>(fn:Void->O):Provide<O>{
    return lift(
      Arrowlet.Anon(
        (i:Noise,cont:Terminal<O,Noise>) -> {
          return cont.value(fn()).serve();
        }
      )
    );
  }
  @:from static public function fromFunXFuture<O>(fn:Void->Future<O>):Provide<O>{
    return lift(
      Arrowlet.Anon(
        (i:Noise,cont:Terminal<O,Noise>) -> {
          return cont.defer(fn.toSlot().map(Success)).serve();
        }
      )
    );
  }
  @:from static public function fromFunFuture<O>(ft:Future<O>):Provide<O>{
    return lift(
      Arrowlet.Anon(
        (i:Noise,cont:Terminal<O,Noise>) -> {
          return cont.defer(ft.map(Success)).serve();
        }
      )
    );
  }
  public function environment(handler:O->Void):Thread{
    return Arrowlet._.environment(
      this,
      Noise,
      (o) -> {
        handler(o);
      },
      (e) -> throw(e)
    );
  }
  static public function bind_fold<T,O>(fn:Convert<Couple<T,O>,O>,arr:Array<T>,seed:O):Provide<O>{
    return arr.lfold(
      (next:T,memo:Provide<O>) -> {
        return memo.convert(
          Convert.fromConvertProvide(
            (o) -> fn.provide(__.couple(next,o))
          )
        );
      },
      Provide.pure(seed)
    );
  }
  @:to public function toArrowlet():Arrowlet<Noise,O,Noise>{
    return this;
  }
  public function prj():ProvideDef<O> return this;
  private var self(get,never):Provide<O>;
  private function get_self():Provide<O> return lift(this);
}

class ProvideLift{
  static public function flat_map<O,Oi>(self:Provide<O>,fn:O->ProvideDef<Oi>):Provide<Oi>{
    return Provide.lift(Arrowlet.FlatMap(self.toArrowlet(),fn));
  }
  static public function and<Oi,Oii>(lhs:ProvideDef<Oi>,rhs:ProvideDef<Oii>):Provide<Couple<Oi,Oii>>{
    return Provide.lift(Arrowlet._.pinch(
      Arrowlet._.both(
        lhs,
        rhs
      )
    ));
  }
  static public function convert<O,Oi>(self:ProvideDef<O>,that:Convert<O,Oi>):Provide<Oi>{
    return Provide.lift(Convert._.then(
      self,
      that
    ));
  }
  static public function prepare<O>(self:ProvideDef<O>,cont:Terminal<O,Noise>):Work{
    return Arrowlet._.prepare(self,Noise,cont);
  }
  static public inline function fudge<O>(self:Provide<O>):O{
    var v = null;
    self.environment(
      (o) -> v = o
    ).crunch();
    return v;
  }
  static public function toProduce<O,E>(self:ProvideDef<O>):Produce<O,E>{
    return Produce.lift(Arrowlet.Then(self,Arrowlet.Sync(__.accept)));
  }
  static public function attempt<O,Oi,E>(self:Provide<O>,that:Attempt<O,Oi,E>):Produce<Oi,E>{
    return toProduce(self).attempt(that);
  }
}