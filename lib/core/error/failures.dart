abstract class Failure {
  final String message;
  Failure(this.message);
}

class NetworkFailure extends Failure {
  NetworkFailure() : super('Internet baglantisi yok');
}

class NotFoundFailure extends Failure {
  NotFoundFailure() : super('Veri bulunamadi');
}

class UnexpectedFailure extends Failure {
  UnexpectedFailure() : super('Beklenmedik bir hata olustu');
}