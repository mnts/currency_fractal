import 'dart:async';
import 'dart:convert';

import 'package:frac/ref.dart';
import 'package:fractal_socket/index.dart';
import 'package:signed_fractal/fr.dart';
import 'package:signed_fractal/signed_fractal.dart';

class TransactionCtrl<T extends TransactionFractal> extends EventsCtrl<T> {
  TransactionCtrl({
    super.name = 'transaction',
    required super.make,
    required super.extend,
    required super.attributes,
  });

  @override
  final icon = IconF(0xf0b6);
}

class TransactionFractal extends EventFractal with Rewritable {
  static final controller = TransactionCtrl(
    extend: EventFractal.controller,
    attributes: <Attr>[
      Attr(
        name: 'from',
        format: 'TEXT',
        canNull: true,
        isImmutable: true,
      ),
      Attr(
        name: 'thing',
        format: 'TEXT',
        canNull: true,
        isImmutable: true,
        isIndex: true,
      ),
      Attr(
        name: 'amount',
        format: 'REAL',
        canNull: true,
        isImmutable: true,
      ),
      Attr(
        name: 'status',
        format: 'INTEGER',
        def: '0',
      ),
    ],
    make: (d) => switch (d) {
      MP() => TransactionFractal.fromMap(d),
      _ => throw ('wrong'),
    },
  );

  @override
  TransactionCtrl get ctrl => controller;

  FR<UserFractal> from;
  FR<EventFractal>? thing;
  int status;
  double amount;

  _construct() {}

  TransactionFractal({
    required UserFractal from,
    EventFractal? thing,
    required this.amount,
    this.status = 0,
    super.to,
    super.owner,
  })  : from = FR.h(from),
        thing = FR.hn(thing) {
    _construct();
  }

  TransactionFractal.fromMap(MP d)
      : status = d['limit'] ?? 0,
        amount = (d['amount'] ?? 0).toDouble(),
        from = FR(d['from']),
        thing = FR.n(d['thing']),
        super.fromMap(d) {
    _construct();
  }

  @override
  operator [](String key) => switch (key) {
        'from' => from.ref,
        'thing' => thing?.ref,
        'amount' => amount,
        'status' => status,
        _ => super[key] ?? m[key]?.content ?? extend?[key],
      };

  @override
  MP toMap() => {
        ...super.toMap(),
        for (var a in controller.attributes) a.name: this[a.name],
      };

  @override
  onWrite(f) {
    final ok = super.onWrite(f);
    notifyListeners();
    return ok;
  }
}
