import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:ulist/listRequestCacher.dart';

import 'pocket_base.dart';

final getIt = GetIt.instance;

Future setupServiceLocators() async {
  getIt.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());
  getIt.registerSingletonAsync<PocketBaseController>(
      () async => PocketBaseController());

  getIt.registerSingletonWithDependencies<ListRequestCacher>(
      () => ListRequestCacher(),
      dependsOn: [PocketBaseController]);
}
