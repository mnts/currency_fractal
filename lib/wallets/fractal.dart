import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:dio/dio.dart';
import 'package:web3dart/web3dart.dart';

class CurrencyFractal {
  static final ethClient = Web3Client(
    "https://mainnet.infura.io/v3/ae4d5a3cad184487b47f9dac9a50e8a7",
    Client(),
  );

  static Map<String, dynamic> rates = {};
  static const Map<String, String> symbols = {
    'USD': '\$',
    'EUR': '€',
    'BTC': '₿',
  };

  static Future<void> updateRates() async {
    final re = await Dio().get(
      'https://min-api.cryptocompare.com/data/price',
      queryParameters: {
        'fsym': 'ETH',
        'tsyms': 'BTC,USD,EUR',
      },
      options: Options(responseType: ResponseType.json),
    );

    if (re.statusCode == 200) {
      rates = re.data;
      return;
    } else {
      throw Exception('Failed to update rates');
    }
    return;
  }

  static Future<Map<String, dynamic>> fetchInfo(String matrixId) async {
    final mid = matrixId.substring(1).split(':');
    final name = mid[0];
    final server = 'slyverse.com'; //mid[2];
    final url = 'https://$server/users/$name';
    final re = await Dio().get(
      url,
      options: Options(responseType: ResponseType.json),
    );

    if (re.statusCode == 200) {
      final m = re.data;
      return m;
    } else {
      throw Exception('Failed to load $matrixId info');
    }
  }
}
