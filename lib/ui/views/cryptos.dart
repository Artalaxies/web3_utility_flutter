import 'package:cullen_utilities/custom_log_printer.dart';
import 'package:cullen_utilities/future_builder_handler.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:multilayer_framework/framework.dart';

import '../../dapp_connect.dart';

class Cryptos extends SingleWindowWidget {
  final logger = Logger(printer: CustomLogPrinter('Cryptos'));

  Cryptos({Key? key}) : super(key: key, scrollable: true);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
              Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: MaterialButton(
                        color: dapp.isConnected ? Colors.red : Colors.blue,
                        child: Text(dapp.isConnected
                            ? 'Disconnect your wallet'
                            : 'Connect to Wallet'),
                        onPressed: () {
                          dapp.isConnected ? dapp.disconnect() : dapp.connect();
                        },
                      ))),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  ('Address: ' +
                      (dapp.currentAddress ??
                          'Unconnected to a Cryptos Wallet')),
                  style: Theme.of(context)
                      .textTheme
                      .headline3!
                      .copyWith(color: Colors.blueGrey),
                ),
              )
            ]),
            Text(
              "Cullen's Cryptos Tech",
              style: Theme.of(context).textTheme.headline2,
            ),
            Divider(),
            Text(
              'Balance',
              style: Theme.of(context).textTheme.headline4,
            ),
            const Divider(),
            Row(
              children: [Text(dapp.currentNetwork.chainName)],
            ),
            const Divider(),
            Padding(
                padding: const EdgeInsets.all(20),
                child: Table(
                  border: TableBorder.symmetric(
                      outside: BorderSide.none,
                      inside: BorderSide(
                          color: Theme.of(context).dividerColor, width: 2)),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(children: [
                      Center(child: Text(dapp.currentNetwork.chainName)),
                      Center(child: Text(dapp.currentNetwork.chainName))
                    ]),
                    TableRow(children: [
                      FutureBuilder(
                        future: dapp.getBalance(),
                        builder: futureBuilderHandler<BigInt>(
                          logger: logger,
                          builder: (context, snapshot) {
                            final String amount =
                                (snapshot.data ?? 0).toString();
                            final decimals = amount.length -
                                dapp.currentNetwork.nativeCurrency.decimals;
                            String prefix = '';
                            for (int i = 0;
                                decimals < 0 && i <= decimals.abs();
                                i++) {
                              prefix += '0';
                            }
                            final String amountText = ((prefix + amount)
                                    .split('')
                                  ..insert(decimals.abs() - 1, '.'))
                                .reduce((value, element) => value + element);
                            return Text(amountText +
                                ' ' +
                                dapp.currentNetwork.nativeCurrency.symbol);
                          },
                        ),
                      ),
                      FutureBuilder(
                        future: dapp.getBalance(),
                        builder: futureBuilderHandler<BigInt>(
                          logger: logger,
                          builder: (context, snapshot) {
                            final String amount =
                                (snapshot.data ?? 0).toString();
                            final decimals = amount.length -
                                dapp.currentNetwork.nativeCurrency.decimals;
                            String prefix = '';
                            for (int i = 0;
                                decimals < 0 && i <= decimals.abs();
                                i++) {
                              prefix += '0';
                            }
                            final String amountText = ((prefix + amount)
                                    .split('')
                                  ..insert(decimals.abs() - 1, '.'))
                                .reduce((value, element) => value + element);
                            return Text(amountText +
                                ' ' +
                                dapp.currentNetwork.nativeCurrency.symbol);
                          },
                        ),
                      ),
                    ]),
                    TableRow(children: [
                      FutureBuilder(
                        future: dapp.getBEP20Balance('NT'),
                        builder: futureBuilderHandler<BigInt>(
                          logger: logger,
                          builder: (context, snapshot) {
                            final String amount =
                                (snapshot.data ?? 0).toString();
                            final decimals = amount.length -
                                dapp.currentNetwork.nativeCurrency.decimals;
                            String prefix = '';
                            for (int i = 0;
                                decimals < 0 && i <= decimals.abs();
                                i++) {
                              prefix += '0';
                            }
                            final String amountText = ((prefix + amount)
                                    .split('')
                                  ..insert(decimals.abs() - 1, '.'))
                                .reduce((value, element) => value + element);
                            return Text(amountText + ' ' + 'NT');
                          },
                        ),
                      ),
                      FutureBuilder(
                        future: dapp.getBEP20Balance('NT'),
                        builder: futureBuilderHandler<BigInt>(
                          logger: logger,
                          builder: (context, snapshot) {
                            final String amount =
                                (snapshot.data ?? 0).toString();
                            final decimals = amount.length -
                                dapp.currentNetwork.nativeCurrency.decimals;
                            String prefix = '';
                            for (int i = 0;
                                decimals < 0 && i <= decimals.abs();
                                i++) {
                              prefix += '0';
                            }
                            final String amountText = ((prefix + amount)
                                    .split('')
                                  ..insert(decimals.abs() - 1, '.'))
                                .reduce((value, element) => value + element);
                            return Text(amountText + ' ' + 'NT');
                          },
                        ),
                      ),
                    ])
                  ],
                ))
          ],
        ));
  }
}
