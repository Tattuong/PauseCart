import 'package:flutter_test/flutter_test.dart';
import 'package:pausecart/core/constants/iap_constants.dart';
import 'package:pausecart/core/services/iap_config_service.dart';
import 'package:pausecart/models/shop_item.dart';

void main() {
  test('PauseCart IAP ids and N307 endpoint', () {
    expect(IapConstants.productPrefix, 'pc');
    expect(IapConstants.remoteConfigUrl,
        'https://api2.blwsmartware.net/N307.json');
    expect(IapConstants.coinPackIds.first, 'pc_pack_1');
    expect(IapConstants.coinPackIds.last, 'pc_pack_10');
    expect(IapConstants.coinPackIds, hasLength(10));
    expect(IapConstants.removeAdsProductId, 'pc_remove_ads');
    expect(IapConstants.proProductId, 'pc_pro');
    expect(IapConstants.allProductIds,
        containsAll([...IapConstants.coinPackIds, 'pc_remove_ads', 'pc_pro']));
    expect(IapConstants.coinsForProduct('pc_pack_5'), 500);
    expect(IapConstants.freeArchiveLimit, 8);
    expect(IapConstants.proArchiveLimit, 99);
  });

  test('disable=1 hides billing only', () {
    final off = IapRemoteConfig.fromJson({'disable': 1, 'name': 'PauseCart'});
    expect(off.billingDisabled, isTrue);
    final on = IapRemoteConfig.fromJson(
        {'disable': 0, 'name': 'PauseCart', 'code': 'FULL_IAP'});
    expect(on.billingDisabled, isFalse);
    expect(on.name, 'PauseCart');
  });

  test('shop catalog extras can be applied and reverted', () {
    expect(
        ShopCatalog.items.where((e) => e.id.startsWith('theme_')), isNotEmpty);
    expect(ShopCatalog.find(ShopCatalog.featPro), isNotNull);
    expect(ShopCatalog.find('remove_ads'), isNotNull);
    expect(ShopCatalog.find(ShopCatalog.featHint), isNotNull);
    expect(ShopCatalog.find(ShopCatalog.featSound), isNotNull);
    expect(ShopCatalog.isDefaultId(ShopCatalog.defaultThemeId), isTrue);
  });
}
