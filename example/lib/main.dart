import 'package:flutter/material.dart';
import 'package:flutter_snackbar/flutter_snackbar.dart';

void main() => runApp(SnackBarApp());

class SnackBarApp extends StatelessWidget {
  GlobalKey<SnackBarWidgetState> _globalKey = GlobalKey();
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(primarySwatch: Colors.blue),
        home: Scaffold(
          appBar: AppBar(
            title: Text("SnackBar"),
            actions: <Widget>[
              InkWell(
                child: Padding(
                  child: Center(
                    child: Text("显示"),
                  ),
                  padding: EdgeInsets.only(left: 10, right: 10),
                ),
                onTap: () {
                  _globalKey.currentState.show("这是SnackBar count: ${count++}");
                },
              ),
              Padding(
                child: InkWell(
                  child: Padding(
                    child: Center(
                      child: Text("隐藏"),
                    ),
                    padding: EdgeInsets.only(left: 10, right: 10),
                  ),
                  onTap: () {
                    _globalKey.currentState.dismiss();
                  },
                ),
                padding: EdgeInsets.only(right: 10),
              )
            ],
          ),
          body: SnackBarWidget(
              // 绑定GlobalKey，用于调用显示/隐藏方法
              key: _globalKey,
              //textBuilder用于动态构建Text，用于显示变化的内容。优先级高于'text'属性
              textBuilder: (String message) {
                return Text(message ?? "",
                    style: TextStyle(color: Colors.white, fontSize: 16.0));
              },
              // 内容不变时使用text属性
              text: Text("内容不变时使用text属性"),
              // 设定背景decoration
              decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  color: Colors.blue.withOpacity(0.8)),
              // 用于显示内容，默认是填充空白区域的
              content: Center(child: Text("这是内容部分"))),
        ));
  }
}
