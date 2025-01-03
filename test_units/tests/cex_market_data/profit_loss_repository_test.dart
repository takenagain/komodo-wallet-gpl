import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
import 'package:web_dex/bloc/cex_market_data/profit_loss/profit_loss_calculator.dart';

import 'transaction_generation.dart';

void main() {
  testProfitLossRepository();
}

void testProfitLossRepository() {
  testNetProfitLossRepository();
  testRealisedProfitLossRepository();
}

void testNetProfitLossRepository() {
  group('getProfitFromTransactions', () {
    late ProfitLossCalculator profitLossRepository;
    late CexRepository cexRepository;
    late double currentBtcPrice;

    setUp(() async {
      // TODO: Implement a mock CexRepository
      cexRepository = BinanceRepository(
        binanceProvider: const BinanceProvider(),
      );
      profitLossRepository = ProfitLossCalculator(
        cexRepository,
      );
      final currentDate = DateTime.now();
      final currentDateMidnight = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
      );
      currentBtcPrice = await cexRepository.getCoinFiatPrice(
        'BTC',
        priceDate: currentDateMidnight,
      );
    });

    test('should return empty list when transactions are empty', () async {
      final result = await profitLossRepository.getProfitFromTransactions(
        [],
        coinId: 'BTC',
        fiatCoinId: 'USD',
      );

      expect(result, isEmpty);
    });

    test('return the unrealised profit/loss for a single transaction',
        () async {
      final transactions = [createBuyTransaction(1.0)];

      final result = await profitLossRepository.getProfitFromTransactions(
        transactions,
        coinId: 'BTC',
        fiatCoinId: 'USD',
      );

      final expectedProfitLoss = (currentBtcPrice * 1.0) - (51288.42 * 1.0);

      expect(result.length, 1);
      expect(result[0].profitLoss, closeTo(expectedProfitLoss, 100));
    });

    test('return profit/loss for a 50% sale', () async {
      final transactions = [
        createBuyTransaction(1.0),
        createSellTransaction(0.5),
      ];

      final result = await profitLossRepository.getProfitFromTransactions(
        transactions,
        coinId: 'BTC',
        fiatCoinId: 'USD',
      );

      final expectedProfitLossT1 = (currentBtcPrice * 1.0) - (51288.42 * 1.0);

      const t2CostBasis = 51288.42 * 0.5;
      const t2SaleProceeds = 63866 * 0.5;
      const t2RealizedProfitLoss = t2SaleProceeds - t2CostBasis;
      final t2UnrealisedProfitLoss = (currentBtcPrice * 0.5) - t2CostBasis;
      final expectedTotalProfitLoss =
          t2UnrealisedProfitLoss + t2RealizedProfitLoss;

      expect(result.length, 2);
      expect(
        result[0].profitLoss,
        closeTo(expectedProfitLossT1, 100),
      );
      expect(
        result[1].profitLoss,
        closeTo(expectedTotalProfitLoss, 100),
      );
    });

    test('should skip transactions with zero amount', () async {
      final transactions = [
        createBuyTransaction(1.0),
        createBuyTransaction(0.0, timeStamp: 1708984800),
        createSellTransaction(0.5),
      ];

      final result = await profitLossRepository.getProfitFromTransactions(
        transactions,
        coinId: 'BTC',
        fiatCoinId: 'USD',
      );

      final expectedProfitLossT1 = (currentBtcPrice * 1.0) - (51288.42 * 1.0);

      const t3LeftoverBalance = 0.5;
      const t3CostBasis = 51288.42 * t3LeftoverBalance;
      const t3SaleProceeds = 63866 * 0.5;
      const t3RealizedProfitLoss = t3SaleProceeds - t3CostBasis;
      final t3CurrentBalancePrice = currentBtcPrice * t3LeftoverBalance;
      final t3UnrealisedProfitLoss = t3CurrentBalancePrice - t3CostBasis;
      final expectedTotalProfitLoss =
          t3UnrealisedProfitLoss + t3RealizedProfitLoss;

      expect(result.length, 2);
      expect(
        result[0].profitLoss,
        closeTo(expectedProfitLossT1, 100),
      );
      expect(
        result[1].profitLoss,
        closeTo(expectedTotalProfitLoss, 100),
      );
    });

    test('should zero same day transfer of balance without fees', () async {
      final transactions = [
        createBuyTransaction(1.0, timeStamp: 1708646400),
        createSellTransaction(1.0, timeStamp: 1708646500),
      ];

      final result = await profitLossRepository.getProfitFromTransactions(
        transactions,
        coinId: 'BTC',
        fiatCoinId: 'USD',
      );

      expect(result.length, 2);
      expect(
        result[1].profitLoss,
        0.0,
      ); // No profit/loss as price is the same
    });
  });
}

void testRealisedProfitLossRepository() {
  group('getProfitFromTransactions', () {
    late ProfitLossCalculator profitLossRepository;
    late CexRepository cexRepository;

    setUp(() async {
      // TODO: Implement a mock CexRepository
      cexRepository = BinanceRepository(
        binanceProvider: const BinanceProvider(),
      );
      profitLossRepository = RealisedProfitLossCalculator(
        cexRepository,
      );
    });

    test('return the unrealised profit/loss for a single transaction',
        () async {
      final transactions = [createBuyTransaction(1.0)];

      final result = await profitLossRepository.getProfitFromTransactions(
        transactions,
        coinId: 'BTC',
        fiatCoinId: 'USD',
      );

      expect(result.length, 1);
      expect(
        result[0].profitLoss,
        0.0,
      );
    });

    test('return profit/loss for a 50% sale', () async {
      final transactions = [
        createBuyTransaction(1.0),
        createSellTransaction(0.5),
      ];

      final result = await profitLossRepository.getProfitFromTransactions(
        transactions,
        coinId: 'BTC',
        fiatCoinId: 'USD',
      );

      const t2CostBasis = 51288.42 * 0.5;
      const t2SaleProceeds = 63866 * 0.5;
      const expectedRealizedProfitLoss = t2SaleProceeds - t2CostBasis;

      expect(result.length, 2);
      expect(
        result[1].profitLoss,
        closeTo(expectedRealizedProfitLoss, 100),
      );
    });

    test('should skip transactions with zero amount', () async {
      final transactions = [
        createBuyTransaction(1.0),
        createBuyTransaction(0.0, timeStamp: 1708984800),
        createSellTransaction(0.5),
      ];

      final result = await profitLossRepository.getProfitFromTransactions(
        transactions,
        coinId: 'BTC',
        fiatCoinId: 'USD',
      );

      const t3LeftoverBalance = 0.5;
      const t3CostBasis = 51288.42 * t3LeftoverBalance;
      const t3SaleProceeds = 63866 * 0.5;
      const t3RealizedProfitLoss = t3SaleProceeds - t3CostBasis;

      expect(result.length, 2);
      expect(
        result[1].profitLoss,
        closeTo(t3RealizedProfitLoss, 100),
      );
    });

    test('should zero same day transfer of balance without fees', () async {
      final transactions = [
        createBuyTransaction(1.0, timeStamp: 1708646400),
        createSellTransaction(1.0, timeStamp: 1708646500),
      ];

      final result = await profitLossRepository.getProfitFromTransactions(
        transactions,
        coinId: 'BTC',
        fiatCoinId: 'USD',
      );

      expect(result.length, 2);
      expect(result[1].profitLoss, 0.0);
    });
  });
}