import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

import 'package:cullen_utilities/custom_log_printer.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:multilayer_framework/multi_layered_app.dart';
import 'package:sha3/sha3.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/browser.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:web3dart/web3dart.dart';

import 'tools/eth_signTypedData.dart';
import 'ui/dialogs/connect_dialog.dart';

Function(String text)? _buttonTextUpdate;

final dappWalletConnect = DappWalletConnect();
const chainId = 4160;

class SessionStorageImpl extends SessionStorage {
  final _sharedPreferencesInstance = SharedPreferences.getInstance();
  late Future<WalletConnectSession> _walletConnectSession;

  Future<WalletConnectSession> init() async {
    return _sharedPreferencesInstance.then((value) {
      final data = value.getString('dappSession');
      if (data != null) {
        _walletConnectSession = Future(() {
          final walletConnectSession = WalletConnectSession.fromUri(
              clientId: '', clientMeta: PeerMeta(
            name: 'WalletConnect',
            description: 'WalletConnect Developer App',
            url: 'https://walletconnect.org',
            icons: [
              'https://gblobscdn.gitbook.com/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
            ],
          ), uri: data);
          walletConnectSession.accounts = value.getStringList('accounts') ?? [];
          return walletConnectSession;
        });
      }
      return _walletConnectSession;
    });
  }

  @override
  Future<WalletConnectSession?> getSession() {
    return _walletConnectSession;
  }

  @override
  Future removeSession() {
    return _sharedPreferencesInstance.then((value) {
      value.remove('dappSession');
      value.remove('accounts');
    });
  }

  @override
  Future store(WalletConnectSession session) {
    return _sharedPreferencesInstance.then((value) {
      value.setString('dappSession', session.toUri());
      value.setStringList('accounts', session.accounts);
    });
  }
}

class DappWalletConnect {
  final logger = Logger(printer: CustomLogPrinter('DappWalletConnect'));
  final inheritSessionStorage = SessionStorageImpl();
  WalletConnect? _connector;
  SessionStatus? _sessionStatus;
  bool _connected = false;
  String? _uri;
  String? _accountAddress;
  Web3Client? _web3client;
  CredentialsWithKnownAddress? _credentials;

  bool get connected => (_connector?.connected ?? _connected) || _connected;

  WalletConnect? get connector => _connector;

  String? get accountAddress => _accountAddress;

  get uri => _uri;

  DappWalletConnect() {
    inheritSessionStorage.init().then((value) {
      logger.i('Creating WalletConnect: ' + (value.toUri() ?? ''));
      _connector = WalletConnect(
        bridge: 'https://bridge.walletconnect.org',
        session: value,
        sessionStorage: inheritSessionStorage,
        clientId: value.clientId,
        clientMeta: const PeerMeta(
          name: "Cullen's Portfolio",
          description: 'WalletConnect Developer App',
          url: 'https://cullen.ml',
          icons: [
            'https://raw.githubusercontent.com/keyskull/keyskull.github.io/master/assets/images/logo.png'
          ],
        ),
      );
      // _connector.setDefaultProvider(provider);
      _connector!.registerListeners(onConnect: (sessionStatus) {
        _buttonTextUpdate?.call(sessionStatus.accounts[0]);
        _accountAddress = sessionStatus.accounts[0];
        logger.i('session connected');
        logger.i('Account Address: ' + (_accountAddress ?? ''));
        MultiLayeredApp.layerManagement
            .destroyContainer(null, layerName: 'DialogLayer');
        MultiLayeredApp.refresh();
      }, onDisconnect: () {
        logger.i('Session disconnected');
        _buttonTextUpdate?.call('Connect to Wallet');
        _accountAddress = null;
        MultiLayeredApp.refresh();
      });

      if (value != null) {
        _connector?.approveSession(accounts: value.accounts, chainId: chainId);
      }
    });
  }

  // Create a connector

  void disconnect() async {
    await _connector?.killSession().timeout(Duration(microseconds: 500),
        onTimeout: () {
      inheritSessionStorage.removeSession();
      _connector?.session.reset();
      _buttonTextUpdate?.call('Connect to Wallet');
      _accountAddress = null;
      MultiLayeredApp.refresh();
    });
    _connected = false;
  }

  Future<EtherAmount>? getBalance() {
    return _web3client?.getBalance(_credentials!.address);
  }

  void connect() async {
    final eth = window.ethereum;
    if (eth == null) {
      logger.i('MetaMask is not available');
    } else {
      var jsonRPC = JsonRPC(
          'https://data-seed-prebsc-1-s1.binance.org:8545/', http.Client());

      _web3client = Web3Client.custom(jsonRPC);
      _credentials = await eth.requestAccount();
      logger.i('Using ${_credentials!.address}');
      logger.i(
          'Client is listening: ${await _web3client!.isListeningForNetwork()}');

      final encrypted = SHA3(256, KECCAK_PADDING, 256);
      encrypted.update(utf8.encode(message));
      logger.i('Start to sign');
      final signature = await _credentials!.signPersonalMessage(
          Uint8List.fromList(encrypted.digest()),
          chainId: 97);
      logger.i('Signature: $signature');
      _accountAddress = _credentials!.address.toString();
      logger.i('session connected');
      logger.i('Account Address: ' + (_accountAddress ?? ''));

      _connected = true;
      _buttonTextUpdate?.call(_credentials!.address.toString());
      MultiLayeredApp.layerManagement
          .destroyContainer(null, layerName: 'DialogLayer');
      MultiLayeredApp.refresh();

      return;
    }

    await _connector?.createSession(
      onDisplayUri: (uri) {
        logger.i(uri);
        _uri = uri;
        MultiLayeredApp.layerManagement.createContainer(
            ConnectDialog(data: uri),
            layerName: 'DialogLayer');
      },
    );

    // _connector.setDefaultProvider(provider)
  }
}
