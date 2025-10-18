import 'package:nbe/libs.dart';

part '../states/transaction_event.dart';
part '../states/transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc() : super(TransactionInitial()) {
    on<AddTransaction>(
      (event, emit) {
        emit(TransactionCreated(transaction: event.transaction));
      },
    );
  }
}
