import 'package:flutter/cupertino.dart';
import 'package:multilayer_framework/framework.dart';
import 'package:multilayer_framework/multi_layered_app.dart';

import '../../dapp_connect.dart';

Function(String text)? _buttonTextUpdate;

class DappConnectButtonWidget extends StatefulWidget {
  const DappConnectButtonWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => DappConnectButtonWidgetState();
}

class DappConnectButtonWidgetState extends State<DappConnectButtonWidget> {
  String _buttonText = 'Connect to Wallet';

  buttonTextUpdate(String text) {
    setState(() {
      _buttonText = text;
    });
  }

  @override
  void initState() {
    _buttonText = dapp.currentAddress ?? 'Connect to Wallet';
    _buttonTextUpdate = buttonTextUpdate;

    dapp.registerListener(onAccountsChanged: (account) {
      buttonTextUpdate(account.first);
      MultiLayeredApp.refresh();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) => ActionButtonWidget(
        text: _buttonText,
        onPressed: () {
          if (dapp.isConnected) {
            MultiLayeredApp.changePath('cryptos');
          } else {
            dapp.connect();
          }
        },
      );
}
