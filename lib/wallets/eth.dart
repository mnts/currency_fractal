import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:webthree/webthree.dart';
import '../wallet.dart';
import 'fractal.dart';

final amountProvider = StateProvider((ref) => 0.0);
final valueProvider = StateProvider((ref) => '');
final addressProvider = StateProvider((ref) => '');

class WalletEth extends WalletFractal {
  late EthereumAddress eth;
  late EtherAmount balance;

  static Map<String, WalletEth> map = {};

  final homeCur = 'USD';

  set addressState(String value) =>
      ref.read(addressProvider.notifier).state = value;
  String get addressState => ref.read(addressProvider.notifier).state;

  WalletEth._(String address) {
    addressState = address;
    init();
  }

  WalletEth.fromMatrixId(String matrixId) {
    fromMatrixId(matrixId);
  }

  fromMatrixId(matrixId) async {
    final m = await CurrencyFractal.fetchInfo(matrixId);
    addressState = m['eth'];
    init();
  }

  init() {
    eth = EthereumAddress.fromHex(addressState);
    updateBalance();
  }

  FutureOr<EtherAmount> updateBalance() async {
    balance = await CurrencyFractal.ethClient.getBalance(eth);
    amount.value = balance.getValueInUnit(EtherUnit.ether);
    updateRate();
    return balance;
  }

  Future<void> updateRate() async {
    await CurrencyFractal.updateRates();
    final value = (CurrencyFractal.rates[homeCur] ?? 0) * amount.value;
    final symbol = CurrencyFractal.symbols[homeCur];
    this.value.value =
        '$symbol${value.toStringAsFixed(2)} ${symbol == null ? homeCur : ''}';
    return;
  }

  factory WalletEth(String address) =>
      map.putIfAbsent(address, () => WalletEth._(address));
}
