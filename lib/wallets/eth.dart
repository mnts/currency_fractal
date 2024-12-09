/*
import 'dart:async';

import 'package:webthree/webthree.dart';
import '../wallet.dart';
import 'fractal.dart';

class WalletEth extends WalletFractal {
  late EthereumAddress eth;
  late EtherAmount balance;

  static Map<String, WalletEth> map = {};

  final homeCur = 'USD';

  String address = ''; //ref.read(addressProvider.notifier).state;

  WalletEth._(String address) {
    address = address;
    init();
  }

  WalletEth.fromMatrixId(String matrixId) {
    fromMatrixId(matrixId);
  }

  fromMatrixId(matrixId) async {
    final m = await CurrencyFractal.fetchInfo(matrixId);
    address = m['eth'];
    init();
  }

  init() {
    eth = EthereumAddress.fromHex(address);
    updateBalance();
  }

  FutureOr<EtherAmount> updateBalance() async {
    balance = await CurrencyFractal.ethClient.getBalance(eth);
    amount.value = balance.getValueInUnit(EtherUnit.ether);
    updateRate();
    return balance;
  }

  String value = '';

  Future<void> updateRate() async {
    await CurrencyFractal.updateRates();
    final value = (CurrencyFractal.rates[homeCur] ?? 0) * amount.value;
    final symbol = CurrencyFractal.symbols[homeCur];
    this.value =
        '$symbol${value.toStringAsFixed(2)} ${symbol == null ? homeCur : ''}';
    return;
  }

  factory WalletEth(String address) =>
      map.putIfAbsent(address, () => WalletEth._(address));
}

*/