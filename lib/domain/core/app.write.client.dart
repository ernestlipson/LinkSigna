import 'package:appwrite/appwrite.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';

class AppWriteClient extends GetxService {
  late final Client client;
  late final Account account;

  static const APPWRITE_ENDPOINT = "https://Frankfurt.cloud.appwrite.io/v1";
  static const PROJECT_ID = "688258d00034a1e36a9e";

  @override
  void onInit() {
    super.onInit();
    client = Client()
      ..setEndpoint(APPWRITE_ENDPOINT)
      ..setProject(PROJECT_ID);
    account = Account(client);
  }
}
