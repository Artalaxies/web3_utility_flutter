import '/network_management.dart';
import '/tools/Interop.dart';
import 'package:flutter_web3/flutter_web3.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final dapp = DappConnect();

final Map<String, void Function(ConnectInfo)> onConnectCallBack = {};
final Map<String, void Function(List<String>)> onAccountsChangedCallBack = {};
final Map<String, void Function(int)> onChainChangedCallBack = {};
final Map<String,
        void Function({int? code, String? reason, ProviderRpcError? error})>
    onDisconnectCallBack = {};

class DappConnect {
  final sharedPreferencesInstance = SharedPreferences.getInstance();

  BlockchainNetwork currentNetwork = NetworkManagement.binanceMain;
  Web3Provider? web3wc;
  final wc = WalletConnectProvider.binance();
  String? currentAddress;
  int? currentChain;
  bool wcConnected = false;

  Map<String, Contract> contracts = {};

  DappConnect() {
    sharedPreferencesInstance.then((value) =>
        value.getString('chains') ??
        http.read(Uri.parse('https://chainid.network/chains.json')));
  }

  bool get isConnected => web3wc != null;

  registerListener(
      {void Function(ConnectInfo)? onConnect,
      void Function(List<String>)? onAccountsChanged,
      void Function(int)? onChainChanged}) {
    if (onConnect != null) {
      onConnectCallBack[onConnect.hashCode.toString()] = onConnect;
    }
    if (onAccountsChanged != null) {
      onAccountsChangedCallBack[onAccountsChanged.hashCode.toString()] =
          onAccountsChanged;
    }
    if (onChainChanged != null) {
      onChainChangedCallBack[onChainChanged.hashCode.toString()] =
          onChainChanged;
    }
  }

  connect() async {
    sharedPreferencesInstance.then((storage) {
      storage.getString('chains') ??
          http.read(Uri.parse('https://chainid.network/chains.json')).then(
              (value) => storage.setString(
                  'chains',
                  value.replaceAll('\${INFURA_API_KEY}',
                      'b7a85e51e8424bae85b0be86ebd8eb31')));
      storage.getString('tokens') ??
          http
              .read(Uri.parse('https://netapi.anyswap.net/bridge/v2/info'))
              .then((value) => storage.setString('tokens', value));
    });

    ethereum?.onConnect((connectInfo) =>
        onConnectCallBack.values.forEach((element) => element(connectInfo)));
    ethereum?.onAccountsChanged((accounts) {
      onAccountsChangedCallBack.values.forEach((element) => element(accounts));
      currentAddress = accounts.first;
    });
    ethereum?.onChainChanged((chainId) {
      onChainChangedCallBack.values.forEach((element) => element(chainId));
      currentChain = chainId;
    });
    ethereum?.onDisconnect((error) {
      onDisconnectCallBack.values.forEach((element) => element(error: error));
    });
    wc.onAccountsChanged((accounts) {
      onAccountsChangedCallBack.values.forEach((element) => element(accounts));
      currentAddress = accounts.first;
    });
    wc.onChainChanged((chainId) {
      for (var element in onChainChangedCallBack.values) {
        element(chainId);
      }
      currentChain = chainId;
    });
    wc.onDisconnect((code, reason) {
      for (var element in onDisconnectCallBack.values) {
        element(code: code, reason: reason);
      }
    });

    // currentNetwork = NetworkManagement.binanceTest;
    if (Ethereum.isSupported) {
      await connectProvider();
    } else {
      await connectWC();
    }
  }

  disconnect() async {
    if (wc.connected) {
      await wc.disconnect();
    }
    if (ethereum?.isConnected() ?? false) {
      // ethereum.off(eventName)
    }
    clear();
  }

  connectProvider() async {
    if (Ethereum.isSupported) {
      final accounts = await ethereum!.requestAccount();
      if (accounts.isNotEmpty) {
        currentAddress = accounts.first;
        currentChain = await ethereum!.getChainId();
        await switchChain(currentNetwork);

        web3wc = Web3Provider.fromEthereum(ethereum!);
      }
    }
  }

  connectWC() async {
    await wc.connect();
    if (wc.connected) {
      currentAddress = wc.accounts.first;
      wcConnected = true;
      (wc.impl as WalletConnectProviderImpl)
          .updateRpcUrl(currentNetwork.chainId, currentNetwork.rpcUrls.first);
      web3wc = Web3Provider.fromWalletConnect(wc);
    }
  }

  clear() {
    currentAddress = null;
    currentChain = null;
    wcConnected = false;
    web3wc = null;
  }

  Future<BigInt> getBalance() async {
    return await ((web3wc?.getBalance(currentAddress!)) ??
        Future<BigInt>.value(BigInt.zero));
  }

  Future<BigInt> getBEP20Balance(String symbol) {
    if (currentNetwork.contracts.containsKey(symbol) && web3wc != null) {
      return currentNetwork.contracts[symbol]!(web3wc!)
          .call('balanceOf', [currentAddress!]);
    } else {
      return Future.value(BigInt.zero);
    }
  }

  getLastestBlock() async {
    print(await provider!.getLastestBlock());
    print(await provider!.getLastestBlockWithTransaction());
  }

  testProvider() async {
    final rpcProvider = JsonRpcProvider('https://bsc-dataseed.binance.org/');
    print(rpcProvider);
    print(await rpcProvider.getNetwork());
  }

  switchChain(BlockchainNetwork blockchainNetwork) async {
    await ethereum!.walletSwitchChain(blockchainNetwork.chainId, () async {
      await ethereum!.walletAddChain(
        chainId: blockchainNetwork.chainId,
        chainName: blockchainNetwork.chainName,
        nativeCurrency: blockchainNetwork.nativeCurrency,
        rpcUrls: blockchainNetwork.rpcUrls,
      );
      currentNetwork = blockchainNetwork;
    });
  }
}
