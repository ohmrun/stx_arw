package stx.arrowlet.pack;

typedef ReframeDef<I,O,E>               = CascadeDef<I,Couple<O,I>,E>;

@:using(stx.arrowlet.pack.Reframe.ReframeLift)
@:using(stx.arrowlet.core.pack.Arrowlet.ArrowletLift)
@:forward abstract Reframe<I,O,E>(ReframeDef<I,O,E>) from ReframeDef<I,O,E> to ReframeDef<I,O,E>{
  static public var _(default,never) = ReframeLift;

  public function new(self) this = self;

  static public function lift<I,O,E>(wml:ReframeDef<I,O,E>):Reframe<I,O,E> return new Reframe(wml);
  static public function pure<I,O,E>(o:O):Reframe<I,O,E>{
    return lift(Cascade.unit().postfix(
      (oc:Res<I,E>
        ) -> (oc.map(__.couple.bind(o)):Res<Couple<O,I>,E>)
    ));
  }
  
  

  private var self(get,never):Reframe<I,O,E>;
  private function get_self():Reframe<I,O,E> return this;


  @:to public function toCascade():Cascade<I,Couple<O,I>,E>{
    return Cascade.lift(this);
  }
  @:from static public function fromCascade<I,O,E>(self:Cascade<I,Couple<O,I>,E>):Reframe<I,O,E>{
    return lift(self);
  }
}

class ReframeLift{
  static private function lift<I,O,E>(wml:ReframeDef<I,O,E>):Reframe<I,O,E> return new Reframe(wml);
  
  static public function then<I,Oi,Oii,E>(self:Reframe<I,Oi,E>,that:Cascade<Couple<Oi,I>,Oii,E>):Cascade<I,Oii,E>{
    return Cascade.lift(Arrowlet.Then(self,that));
  }
  static public function attempt<I,O,Oi,E>(self:Reframe<I,O,E>,that:Attempt<O,Oi,E>):Reframe<I,Oi,E>{
    var fn = (chk:Res<Couple<Res<Oi,E>,I>,E>) -> (chk.flat_map(
      (tp) -> tp.fst().map(
        (r) -> __.couple(r,tp.snd())
      )
    ):Res<Couple<Oi,I>,E>);
    var arw =  lift(
      self.toCascade().process(
        Process.lift(that.toArrowlet().first())
      ).postfix(fn)
    );
    return arw;
  }
  
  static public function arrange<I,O,Oi,E>(self:Reframe<I,O,E>,that:Arrange<O,I,Oi,E>):Reframe<I,Oi,E>{
    var arw = 
      then(self,Arrange._.toCascade(that))
        .broach()
        .postfix(
          (tp:Couple<Res<I,E>,Res<Oi,E>>) -> {
            return tp.swap().decouple(Res._.zip);
          }
        );
    return Reframe.lift(arw);
  }

  static public function rearrange<I,Ii,O,Oi,E>(self:Reframe<I,O,E>,that:O->Arrange<Ii,I,Oi,E>):Attempt<Couple<Ii,I>,Oi,E>{
    return Attempt.lift(Arrowlet.Anon(
      (ipt:Couple<Ii,I>,contN:Terminal<Res<Oi,E>,Noise>) -> {
        var inner = contN.inner();
            inner.later(
              (chk:Outcome<Res<Couple<O,I>,E>,Noise>) -> switch(chk){
                case Success(Success(tp)) : 
                  inner.after(
                    that(tp.fst()).prepare(__.couple(ipt.fst(),tp.snd()),contN)
                  );
                case Failure(_) :
                      contN.error(Noise);
                case Success(Failure(e)) : 
                      contN.value(__.failure(e));
              }
            );
        contN.after(self.prepare(__.success(ipt.snd()),inner));
        return contN.serve();
      }
    ));
  }

  static public function commander<I,O,E>(self:Reframe<I,O,E>,fN:O->Command<I,E>):Reframe<I,O,E>{
    return lift(Arrowlet.Anon(
      (ipt:Res<I,E>,contN:Terminal<Res<Couple<O,I>,E>,Noise>) -> {
        var inner = contN.inner();
            inner.later(
              (out:Outcome<Res<Couple<O,I>,E>,Noise>) -> switch(out){
                case Success(Success(tp)) : 
                  contN.after(fN(tp.fst()).postfix(
                    (opt) -> opt.fold(
                      (err) -> __.failure(err),
                      ()    -> __.success(tp)
                    )
                  ).prepare(tp.snd(),contN));
                case Success(Failure(e))  : 
                  contN.value(__.failure(e));
                default : 
                  contN.error(Noise);
              }
            );
        contN.after(self.prepare(ipt,inner));
        return contN.serve();
      }
    ));
  }
  static public function evaluation<I,O,E>(self:Reframe<I,O,E>):Cascade<I,O,E>{
    return Cascade.lift(self.postfix(o -> o.map(tp -> tp.fst())));
  }

  static public function execution<I,O,E>(self:Reframe<I,O,E>):Cascade<I,I,E>{
    return Cascade.lift(self.postfix(o -> o.map(tp -> tp.snd())));
  }
}