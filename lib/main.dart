import 'package:flutter/material.dart';
import 'settings.dart';
import './config/connectivity.dart';
import './config/data.dart';
import 'package:dio/dio.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iFurnace',
      theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.deepOrange[900],
          accentColor: Colors.cyan),
      home: MyHomePage(title: 'iFurnace'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isSaving = false;
  Dio dio = Dio();
  Map state = {
    "connected": false,
    "powered": false,
    "message": "NO FAULTS"
  };
  void checkConnection() async{
    bool status =  await Status.isConnected();
    setState(() {
      state["connected"] =status;
    });

    await Future.delayed(Duration(seconds: 5));
    checkConnection();
  }

  void getFault() async{
    String fault =await Data.getFault();
    setState(() {
      state["message"] =fault;
    });
  }

  void power() async{
    Map data  =await Data.get();
     if (data.keys.length == 0) {
        data = {
          "ip": "192.168.43.1",
          "hr": '20',
          "cr": '20',
          "mh": '20',
          "mc": '20',
          "ht": '20',
          "message":"NO FAULT"
        };
        Data.set(data);
      }
    String val;
    if(state['powered'] ){
      val = '0';
    }else{
      val = '1';
    }
    String ip =data['ip'];
    setState(() {
      isSaving = true;
    });
    dio.get("http://${ip}?power=${val}").then((resp){
      setState(() {
        state['message'] = resp.data == "" ? resp.data : "NO FAULT";
        state['powered'] = !state['powered'];
        isSaving = false;
      });
    }).catchError((err){
      setState(() {
      isSaving = false;
    });
       _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("A network error occurred again"),
        action: SnackBarAction(
          label: "RETRY",
          onPressed: (){
            power();
          },
        ),
      ));
    });

  }


  @override 
  void initState(){
    super.initState();
    checkConnection();
  }
  @override
  void dispose(){
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
       key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0.0,
        title: Text(widget.title),
         bottom: PreferredSize(
          preferredSize: Size(size.width, 5.0),
          child: isSaving ? LinearProgressIndicator() :SizedBox(),
        ),
      ),
      body: Container(
        width: size.width,
        height: size.height,
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Card(
                child: Container(
                    height: size.height * 0.4,
                    width: size.width,
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          top: 5.0,
                          right: 5.0,
                          child: Icon(Icons.wifi, color: state["connected"] ? Colors.green : Colors.red),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Center(
                              child: Text(
                                state["message"],
                                style: TextStyle(fontSize: 36.0),
                              ),
                            ),
                          ],
                        )
                      ],
                    )),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 20.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      key: Key("ftb"),
                      color: state["powered"] ? Theme.of(context).primaryColor : Colors.white54,
                      icon: Icon(Icons.power_settings_new),
                      onPressed: () {
                        power();
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => Settings()));
        },
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'Edit Settings',
        child: Icon(
          Icons.settings_remote,
          color: Colors.white,
        ),
      ),
    );
  }
}
