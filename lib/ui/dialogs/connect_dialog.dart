import 'package:cullen_utilities/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:multilayer_framework/multi_layered_app.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ConnectDialog extends StatelessWidget {
  final String data;

  const ConnectDialog({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) => AlertDialog(
      title: Wrap(children: [
        Align(
            alignment: Alignment.topRight,
            child: IconButton(
                onPressed: () {
                  MultiLayeredApp.layerManagement
                      .destroyContainer(null, layerName: 'DialogLayer');
                },
                icon: Container(
                    decoration: BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child: Icon(Icons.close)))),
        Text('Connect to your Cryptos Wallet',
            style: Theme.of(context).textTheme.headline3)
      ]),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(40))),
      content: Column(
        children: (!ScreenSize.isDesktop(context)
                ? <Widget>[
                    MaterialButton(
                      color: Theme.of(context).canvasColor,
                      onPressed: () => launchUrlString(data),
                      child: Text(
                        'Connect',
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ),
                    Text(
                      '-- Or --',
                      style: Theme.of(context).textTheme.headline3,
                    ),
                  ]
                : <Widget>[]) +
            <Widget>[
              SizedBox(
                  width: (ScreenSize.getScreenSize).width * 0.6,
                  height: (ScreenSize.getScreenSize).width * 0.6,
                  child: QrImage(
                    backgroundColor: Colors.white,
                    data: data,
                    version: QrVersions.auto,
                    size: (ScreenSize.getScreenSize).width * 0.6,
                  ))
            ],
      ));
}
