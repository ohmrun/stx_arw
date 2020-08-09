package stx.arw.lift;

class LiftFun2RToArrowlet{
  inline static public function toArrowlet<Ii,Iii,O>(fn:Ii->Iii->O):Arrowlet<Couple<Ii,Iii>,O,Dynamic>{
    return Arrowlet.fromFun2R(fn);
  }
}