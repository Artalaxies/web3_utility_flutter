@JS('WalletConnectProvider')
library wallet_connect_provider;

import 'dart:core';

import 'package:js/js.dart';

@JS('default')
class WalletConnectProviderImpl {
  external WalletConnectProviderImpl(WalletConnectProviderOptionsImpl options);

  external List<String> get accounts;

  external String get chainId;

  external bool get connected;

  external String get rpcUrl;

  external bool get isConnecting;

  external _WalletMetaImpl get walletMeta;

  external int listenerCount([String? eventName]);

  external List<dynamic> listeners(String eventName);

  external removeAllListeners([String? eventName]);

  external updateRpcUrl([int chainId, String? rpcUrl]);
}

@JS()
@anonymous
class WalletConnectProviderOptionsImpl {
  external factory WalletConnectProviderOptionsImpl({
    dynamic infuraId,
    dynamic rpc,
    String? rpcUrl,
    dynamic peerMeta,
    String? bridge,
    bool? qrCode,
    String? network,
    int? chainId,
    int? networkId,
    _QrcodeModalOptionsImpl? qrcodeModalOptions,
  });

  external String? get bridge;

  external int? get chainId;

  external String? get infuraId;

  external String? get network;

  external bool? get qrCode;

  external _QrcodeModalOptionsImpl? get qrcodeModalOptions;

  external dynamic get rpc;
}

@JS()
@anonymous
class _QrcodeModalOptionsImpl {
  external factory _QrcodeModalOptionsImpl({List<String> mobileLinks});

  external List<String> get mobileLinks;
}

@JS()
@anonymous
class _WalletMetaImpl {
  external String get description;

  external List<dynamic> get icons;

  external String get name;

  external String get url;
}
