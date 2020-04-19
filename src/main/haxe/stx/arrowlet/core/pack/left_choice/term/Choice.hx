package stx.arrowlet.core.pack.left_choice.term;

class Choice<I,O,E> extends ArrowletApi<Either<I,I>,Either<O,I>,E>{
  private var delegate : Arrowlet<I,Either<O,I>,E>;
  public function new(delegate){
    super();
    this.delegate = delegate;
	}
	override private function doApplyII(either:Either<I,I>,cont:Terminal<Either<O,I>,E>):Response{
    return switch(either){
      case Left(i)      : Arrowlet.Apply().prepare(__.couple(delegate,i),cont);
      case Right(oii)   : 
        cont.value(Right(oii));
        cont.serve();
    }
  }
}