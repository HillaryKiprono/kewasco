import 'package:get/get.dart';

class SimpleUIController extends GetxController {
  RxBool isObscure = true.obs;
  RxString authenticatedUsername = ''.obs;

  void setAuthenticatedUsername(String username) {
    authenticatedUsername.value = username;
  }

  isObscureActive() {
    isObscure.value = !isObscure.value;
  }
}
