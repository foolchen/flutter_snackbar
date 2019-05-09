library flutter_snackbar;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// 用于展示类似于Android中SnackBar的提示框
class SnackBarWidget extends StatefulWidget {
  /// 提示框中要显示的内容，提示内容不需要发生变化时使用
  final Text text;

  /// 用于动态构建Text，当需要动态改变SnackBarWidget的内容时使用
  final TextBuilder textBuilder;

  /// 主题内容部分
  final Widget content;

  /// 提示框的内边距
  final EdgeInsets padding;

  /// 提示框的外边距
  final EdgeInsets margin;

  /// 提示框持续时间（从淡入到淡出）
  final Duration duration;

  /// 提示框的包装样式
  final Decoration decoration;

  SnackBarWidget(
      {Key key,
      this.text,
      this.textBuilder,
      this.content,
      this.padding,
      this.margin,
      this.duration,
      this.decoration})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SnackBarWidgetState();
  }
}

class SnackBarWidgetState extends State<SnackBarWidget>
    with TickerProviderStateMixin {
  final GlobalKey _snackKey = GlobalKey();
  GlobalKey<_DynamicTextState> _textKey;

  AnimationController _controller;

  bool get isShowing => _controller.status != AnimationStatus.dismissed;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: widget.duration ?? Duration(milliseconds: 1400), vsync: this);
  }

  @override
  void dispose() {
    // 此时进行资源回收
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.topCenter, // 顶部居中
      fit: StackFit.loose, // 如果child没有指定位置，则采用使用child自身的大小
      children: <Widget>[
        // 使内容部分填充剩余空间
        SizedBox.expand(child: widget.content),
        SnackBarAnimation(
            key: _snackKey,
            controller: _controller,
            child: Container(
              // 如果存在textBuilder，则创建_DynamicText，用来动态更新Text的内容
              // 如果不存在textBuilder，则使用静态的Text
              child: widget.textBuilder != null
                  ? _DynamicText(
                      widget.textBuilder,
                      key: _textKey = GlobalKey(),
                    )
                  : widget.text,
              padding:
                  widget.padding ?? EdgeInsets.fromLTRB(15.0, 10.0, 20.0, 10.0),
              margin: widget.padding ?? EdgeInsets.only(top: 10.0),
              decoration: widget.decoration ??
                  ShapeDecoration(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(30.0))),
                      color: Colors.orange),
            ))
      ],
    );
  }

  /// 显示SnackBar
  /// [message] 要更新的提示内容
  void show([String message]) {
    if (_textKey != null && _textKey.currentState != null) {
      _textKey.currentState.update(message);
    }
    (_snackKey.currentWidget as SnackBarAnimation).playAnimation();
  }

  /// 隐藏SnackBar
  void dismiss() {
    if (_controller.isDismissed) return;
    (_snackKey.currentWidget as SnackBarAnimation).reverseAnimation();
  }
}

/// 用于动态构建[Text]，以实现动态改变[SnackBarWidget]中内容的目的
typedef TextBuilder = Text Function(String message);

class SnackBarAnimation extends StatelessWidget {
  final AnimationController controller;
  final Container child;
  Animation<double> fade;
  Animation<double> translate;

  SnackBarAnimation(
      {@required GlobalKey key, @required this.controller, this.child})
      : assert(key != null), // 由于需要通过BuildContext来获取Widget的高度，此处的key为必须的
        assert(controller != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: _buildAnimation,
      animation: controller,
      child: child,
    );
  }

  // 开始播放动画
  Future<Null> playAnimation() async {
    // 此处通过key去获取Widget的Size属性
    var deltaY = (key as GlobalKey).currentContext.size.height; // 该值为位移动画需要的位移值

    // 如果fade动画不存在，则创建一个新的fade动画
    fade = fade ??
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: controller,
            curve: Interval(0.0, 0.3, // 持续时间为总持续时间的30%
                curve: Curves.ease)));

    translate = translate ??
        Tween<double>(begin: -deltaY, end: 0).animate(CurvedAnimation(
            parent: controller, curve: Interval(0.0, 0.15))); // 前15%的时间用于执行平移动画

    try {
      await controller.forward().orCancel;
      await controller.reverse().orCancel;
    } on TickerCanceled {}
  }

  Future<Null> reverseAnimation() async {
    try {
      await controller.reverse().orCancel;
    } on TickerCanceled {}
  }

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Transform.translate(
      child: Opacity(
          child: child,
          opacity: fade != null
              ? fade.value
              : 0), // 此处使用fade.value不断取值来刷新child的opacity
      offset: Offset(
          0,
          translate != null
              ? translate.value
              : 0), // 此处使用translate.value不断取值来刷新child的偏移量
    );
  }
}

/// 能够动态更新内容的[Text]
class _DynamicText extends StatefulWidget {
  final TextBuilder _textBuilder;
  _DynamicText(this._textBuilder, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DynamicTextState();
  }
}

class _DynamicTextState extends State<_DynamicText> {
  String _message;

  @override
  Widget build(BuildContext context) {
    return widget._textBuilder(_message);
  }

  void update([String message]) {
    if (message == _message) return; // 如果文案相同，则不刷新Text
    setState(() {
      _message = message;
    });
  }
}
