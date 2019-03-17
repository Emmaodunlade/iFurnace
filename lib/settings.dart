import 'package:flutter/material.dart';
import 'config/data.dart';
import 'package:dio/dio.dart';
class Settings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingsState();
  }
}

class SettingsState extends State<Settings> {
  TextEditingController ipC =TextEditingController();
  TextEditingController hrC =TextEditingController();
  TextEditingController crC =TextEditingController();
  TextEditingController mhC =TextEditingController();
  TextEditingController mcC =TextEditingController();
  TextEditingController htC =TextEditingController();
  bool isSaving = false;
  Dio dio = Dio();
  bool isIP(String ip) {
    RegExp ipTest = RegExp(
        r"^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$");
    if (ipTest.hasMatch(ip)) {
      return true;
    }
    return false;
  }

  void save(){
    setState(() {
      isSaving =true;
    });
    dio.get("http://${ipC.text}/config?hr=${hrC.text}&cr=${crC.text}&mh=${mhC.text}&mc=${mcC.text}&ht=${htC.text}").then((resp){
      Map preset = {
        "ip":ipC.text,
        "hr":hrC.text,
        "cr":crC.text,
        "mh":mhC.text,
        "mc":mcC.text,
        "ht":htC.text,
        "message": resp.data
      };
      Data.set(preset);
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Config updated successfully"),
      ));
    }).catchError((err){
      setState(() {
        isSaving = false;
      });
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("A network error occurred again"),
        action: SnackBarAction(
          label: "RETRY",
          onPressed: (){
            save();
          },
        ),
      ));
    });
  }
  @override
  void initState() {
    super.initState();
    Data.get().then((Map preset) {
      if (preset.keys.length == 0) {
        preset = {
          "ip": "192.168.43.1",
          "hr": '20',
          "cr": '20',
          "mh": '20',
          "mc": '20',
          "ht": '20',
          "message":"NO FAULT"
        };
        ipC.text =preset['ip'];
        hrC.text =preset['ht'];
        crC.text =preset['cr'];
        mhC.text =preset['mh'];
        mcC.text =preset['mc'];
        htC.text =preset['ht'];
        Data.set(preset);
      }else{
        ipC.text =preset['ip'];
        hrC.text =preset['ht'];
        crC.text =preset['cr'];
        mhC.text =preset['mh'];
        mcC.text =preset['mc'];
        htC.text =preset['ht'];
      }
    });
  }

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Edit Settings"),
        bottom: PreferredSize(
          preferredSize: Size(size.width, 5.0),
          child: isSaving ? LinearProgressIndicator() :SizedBox(),
        ),
      ),
      body: Container(
          width: size.width,
          height: size.height,
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            autovalidate: true,
            child: ListView(
              children: <Widget>[
                TextFormField(
                  controller: ipC,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (val) {
                    if (!isIP(val)) {
                      return "Invalid IP Address";
                    }
                  },
                  decoration: InputDecoration(
                      labelText: "Device IP",
                      prefixIcon: Icon(Icons.settings_ethernet)),
                ),
                Divider(),
                Text("CONFIG", textAlign: TextAlign.center,),
                Divider(),
                Row(
                  children: <Widget>[
                    Expanded(
                      
                      child: TextFormField(
                        controller: hrC,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (int.tryParse(v) == null || int.tryParse(v) <= 0) {
                            return "Invalid Value";
                          }
                        },
                        decoration: InputDecoration(labelText: "Heating Rate"),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: crC,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (int.tryParse(v) == null || int.tryParse(v) <= 0) {
                            return "Invalid Value";
                          }
                        },
                        decoration: InputDecoration(labelText: "Cooling Rate"),
                      ),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: mhC,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (int.tryParse(v) == null || int.tryParse(v) <= 0) {
                            return "Invalid Value";
                          }
                        },
                        decoration: InputDecoration(
                            labelText: "Max heating temperature"),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: mcC,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (int.tryParse(v) == null) {
                            return "Invalid Value";
                          }
                        },
                        decoration: InputDecoration(
                            labelText: "Max cooling temperature"),
                      ),
                    )
                  ],
                ),
                TextFormField(
                  controller: htC,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (int.tryParse(v) == null ||int.tryParse(v) <=0) {
                      return "Invalid Value";
                    }
                  },
                  decoration: InputDecoration(labelText: "Holding Time"),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: RaisedButton(
                    child: Text("SAVE"),
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      save();
                    },
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
