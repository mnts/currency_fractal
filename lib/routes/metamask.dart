import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:webthree/credentials.dart';
import 'package:webthree/crypto.dart';

class MetaMaskRouteF {
  final Map<String, String> nonces = {};

  String generateNonce() {
    final random = Random.secure();
    return List<int>.generate(16, (_) => random.nextInt(256))
        .map((e) => e.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  String fromMessage(
    String message,
    String signature,
  ) {
    final prefixedMessage =
        '\x19Ethereum Signed Message:\n${message.length}$message';
    final messageHash = keccakUtf8(prefixedMessage);

    final sigBytes = hexToBytes(signature);
    final r = bytesToUnsignedInt(sigBytes.sublist(0, 32));
    final s = bytesToUnsignedInt(sigBytes.sublist(32, 64));
    var v = sigBytes[64]; // Convert v to recovery id (0 or 1)

    if (v < 27) {
      v += 27;
    }

    final sig = MsgSignature(r, s, v);
    final publicKey = ecRecover(messageHash, sig);
    final recoveredAddress = EthereumAddress.fromPublicKey(publicKey);
    //isValidSignature(messageHash, ,expectedAddress);
    // Compare the recovered address with the expected address
    return recoveredAddress.hexEip55;
  }

  requestNonce(HttpRequest q) async {
    final payload = await utf8.decodeStream(q);
    final data = jsonDecode(payload);

    final address = data['address'] as String;

    final nonce = generateNonce();
    nonces[address] = nonce;
    //q.reJSON({'nonce': nonce});
  }

  verify(HttpRequest q) async {
    final payload = await utf8.decodeStream(q);
    final data = jsonDecode(payload);

    final address = data['address'] as String;
    final message = data['message'] as String;
    final signature = data['signature'] as String;

    final nonce = nonces[address];

    bool isValid = false;
    if (nonce != null && message.contains(nonce)) {
      try {
        final rAddr = fromMessage(message, signature);
        isValid = rAddr.toLowerCase() == address.toLowerCase();
      } catch (e) {
        print(e);
      }
      nonces.remove(address);
    }

    // Clear the nonce after use
    //q.reJSON({'verified': isValid});
  }
}
