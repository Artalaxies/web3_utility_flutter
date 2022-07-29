import 'package:flutter_web3/flutter_web3.dart';

import 'abi/BEP20.dart';

class BlockchainNetwork {
  final CurrencyParams nativeCurrency;
  final List<String> rpcUrls;
  final String chainName;
  final int chainId;
  Map<String, Contract Function(Web3Provider)> contracts = Map();

  BlockchainNetwork(
      {required this.nativeCurrency,
      required this.rpcUrls,
      required this.chainName,
      required this.chainId});
}

class NetworkManagement {
  static final Map<String, BlockchainNetwork> networks = {
    'Ethereum MainNet': BlockchainNetwork(
        chainName: 'Ethereum MainNet',
        chainId: 1,
        nativeCurrency:
            CurrencyParams(name: 'Ethereum', symbol: 'ETH', decimals: 18),
        rpcUrls: [
          'https://mainnet.infura.io/v3/b7a85e51e8424bae85b0be86ebd8eb31',
          'http://localhost:8545'
        ]),
    'Binance TestNet': BlockchainNetwork(
        chainName: 'Binance Testnet',
        chainId: 97,
        nativeCurrency:
            CurrencyParams(name: 'Binance Coin', symbol: 'BNB', decimals: 18),
        rpcUrls: ['https://data-seed-prebsc-1-s1.binance.org:8545/'])
      ..contracts['NT'] = (web3wc) => Contract.fromProvider(
          '0xfbcf80ed90856af0d6d9655f746331763efdb22c',
          Interface(BEP20).format(FormatTypes.json),
          web3wc),
    'Binance MainNet': BlockchainNetwork(
        chainId: 56,
        chainName: 'Binance Mainnet',
        nativeCurrency:
            CurrencyParams(name: 'Binance Coin', symbol: 'BNB', decimals: 18),
        rpcUrls: ['https://bsc-dataseed.binance.org/'])
      ..contracts['NT'] = (web3wc) => Contract.fromProvider(
          '0xfbcf80ed90856af0d6d9655f746331763efdb22c',
          Interface(BEP20).format(FormatTypes.json),
          web3wc)
  };

  static BlockchainNetwork get ethereumMain => networks['Ethereum MainNet']!;

  static BlockchainNetwork get binanceMain => networks['Binance MainNet']!;

  static BlockchainNetwork get binanceTest => networks['Binance TestNet']!;
}
