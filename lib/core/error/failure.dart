import 'package:equatable/equatable.dart';

enum FailureType { network, server, rateLimited, invalidData, unknown }

class Failure extends Equatable {
  const Failure(this.type, {this.cause});

  final FailureType type;
  final Object? cause;

  @override
  List<Object?> get props => [type, cause?.runtimeType, cause?.toString()];
}
