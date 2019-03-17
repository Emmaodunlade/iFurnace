import 'package:connectivity/connectivity.dart';

class Status {
  static Future<bool> isConnected() async{
      var connectivityResult = await (Connectivity().checkConnectivity());
       if (connectivityResult == ConnectivityResult.wifi) {
        return true;
      }
      return false;
  }
}