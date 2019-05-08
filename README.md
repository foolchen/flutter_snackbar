# 说明

使用这个库你可以实现类似于[SnackBar](https://flutter.dev/docs/cookbook/design/snackbars)类似的提示，不同的是`flutter_snackbar`的提示显示在顶部。

效果如下：  
<img src="assets/flutter_snackbar.gif" width="360px" height="720px" align="center"/>

## 示例

```dart
// 创建SnackBarWidget
SnackBarWidget(
    // 绑定GlobalKey，用于调用显示/隐藏方法
    key: _globalKey,
    // 设置动态变化的Text
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
    content: Center(child: Text("这是内容部分")))
```

显示显示SnackBar：

```dart
_globalKey.currentState.show("这是SnackBar count: ${count++}");
```

隐藏SnackBar：

```dart
_globalKey.currentState.dismiss();
```
