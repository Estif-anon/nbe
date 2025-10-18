part of '../bloc/transaction_bloc.dart';

@immutable
sealed class TransactionEvent {}

class AddTransaction extends TransactionEvent {
  final Transaction transaction;

  AddTransaction({required this.transaction});
}
