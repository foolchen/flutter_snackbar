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
  final GlobalKey _childKey = GlobalKey();
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
              key: _childKey,
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

  /// 执行动画
  /// [message] 要更新的提示内容
  Future<Null> show([String message]) async {
    if (_textKey != null && _textKey.currentState != null) {
      _textKey.currentState.update(message);
    }
    _prepareAnimation();
    try {
      await _controller.forward().orCancel;
      await _controller.reverse().orCancel;
    } on TickerCanceled {}
  }

  /// 使[SnackBarWidget]消失
  void dismiss() async {
    if (_controller.isDismissed) return;
    try {
      await _controller.reverse();
    } on TickerCanceled {}
  }

  void _prepareAnimation() {
    BuildContext context = _childKey.currentContext;
    Container container = _childKey.currentWidget;
    double height = context.size.height;
    double top = container.margin.resolve(TextDirection.ltr).top;
    double deltaY = height + top;
    (_snackKey.currentWidget as SnackBarAnimation).prepare(deltaY);
  }
}

/// 用于动态构建[Text]，以实现动态改变[SnackBarWidget]中内容的目的
typedef TextBuilder = Text Function(String message);

class SnackBarAnimation extends StatelessWidget {
  final Animation controller;
  final Container child;
  Animation<double> fade;
  Animation<double> translate;

  SnackBarAnimation({Key key, this.controller, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: _buildAnimation,
      animation: controller,
      child: child,
    );
  }

  void prepare(double deltaY) {
    fade = fade ??
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: controller,
            curve: Interval(0.0, 0.3, // 持续时间为总持续时间的30%
                curve: Curves.ease)));
    translate = translate ??
        Tween<double>(begin: -deltaY, end: 0).animate(
            CurvedAnimation(parent: controller, curve: Interval(0.0, 0.15)));
  }

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Transform.translate(
      child: Opacity(child: child, opacity: fade != null ? fade.value : 0),
      offset: Offset(0, translate != null ? translate.value : 0),
    );
  }
}

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
    setState(() {
      _message = message;
    });
  }
}
