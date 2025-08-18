import 'package:appwrite/appwrite.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import '../../config/appwrite_config.dart';

class AppWriteClient extends GetxService {
  late final Client client;
  late final Account account;

  static const APPWRITE_ENDPOINT = AppWriteConfig.CURRENT_ENDPOINT;
  static const PROJECT_ID = AppWriteConfig.PROJECT_ID;

  @override
  void onInit() {
    super.onInit();
    client = Client()
      ..setEndpoint(APPWRITE_ENDPOINT)
      ..setProject(PROJECT_ID);
    account = Account(client);
  }
}
