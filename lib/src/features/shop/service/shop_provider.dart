import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nearbycreds/src/features/shop/service/shop_service.dart';
import 'package:nearbycreds/src/features/shop/model/shop_model.dart';

final shopServiceProvider = Provider<ShopService>((ref) => ShopService());

final allShopsProvider = FutureProvider<List<Shop>>((ref) async {
  final shopService = ref.read(shopServiceProvider);
  return shopService.getAllShops();
});
