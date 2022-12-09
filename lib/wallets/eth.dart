import 'dart:async';

import 'package:frac/frac.dart';

import 'package:web3dart/web3dart.dart';
import '../wallet.dart';
import 'fractal.dart';

class WalletEth extends WalletFractal {
  late EthereumAddress eth;
  late EtherAmount balance;

  static Map<String, WalletEth> map = {};

  final homeCur = 'USD';

  final amount = Frac<double>(0);
  final value = Frac<String>('');
  final address = Frac<String>('');

  WalletEth._(String address) {
    this.address.value = address;
    init();
  }

  WalletEth.fromMatrixId(String matrixId) {
    fromMatrixId(matrixId);
  }

  fromMatrixId(matrixId) async {
    final m = await CurrencyFractal.fetchInfo(matrixId);
    address.value = m['eth'];
    init();
  }

  init() {
    eth = EthereumAddress.fromHex(address.value);
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
