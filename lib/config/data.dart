import 'package:shared_preferences/shared_preferences.dart';

class Data {
  static Future<Map> get() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List keys = prefs.getKeys().toList();
    Map data = {};
    keys.forEach((key) {
      data[key] = prefs.get(key);
    });
    return data;
  }

  static void set(Map data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List keys = data.keys.toList();
    keys.forEach((key) {
      prefs.setString(key, data[key].toString());
    });
  }

  static void setFault(String fault) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('fault', fault);
  }

  

  static Future<String> getFault() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('fault');
  }
}
