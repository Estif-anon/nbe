part of '../bloc/transaction_bloc.dart';

@immutable
sealed class TransactionState {}

final class TransactionInitial extends TransactionState {}

class TransactionCreated extends TransactionState {
  final Transaction transaction;

  TransactionCreated({required this.transaction});
}
