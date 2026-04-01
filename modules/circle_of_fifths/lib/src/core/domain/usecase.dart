/// Base class for all use cases.
///
/// [Params] is the input parameter type.
/// [Result] is the output result type.
abstract interface class UseCase<Params, Result> {
  /// Executes the use case.
  Result call(Params params);
}

/// Base class for use cases without parameters.
abstract interface class NoParamsUseCase<Result> {
  /// Executes the use case.
  Result call();
}

/// Base class for asynchronous use cases.
abstract interface class AsyncUseCase<Params, Result> {
  /// Executes the use case asynchronously.
  Future<Result> call(Params params);
}

/// Base class for asynchronous use cases without parameters.
abstract interface class NoParamsAsyncUseCase<Result> {
  /// Executes the use case asynchronously.
  Future<Result> call();
}
