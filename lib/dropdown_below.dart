library dropdown_below;

import 'dart:math' as math;

import 'package:flutter/material.dart';

const Duration _kDropdownMenuDuration = Duration(milliseconds: 300);

/// *[_kDropdownMenuDuration] which is dropdown button's drop down duration.

const double _kMenuItemHeight = 48.0;

/// *[_kMenuItemHeight] which is dropdown item's default height

const EdgeInsets _kAlignedMenuMargin = EdgeInsets.zero;

/// *[_kAlignedMenuMargin] which is dropdown item's default margin

const EdgeInsetsGeometry _kUnalignedMenuMargin = EdgeInsetsDirectional.only(start: 16.0, end: 24.0);

/// *[_kAlignedMenuMargin] which is dropdown item's default margin for align rule.

class _DropdownMenuPainter extends CustomPainter {
  _DropdownMenuPainter({
    this.itemHeight = _kMenuItemHeight,
    this.color,
    this.elevation,
    this.selectedIndex,
    this.resize,
    Decoration decoration,
  })  : _painter = decoration?.createBoxPainter() ??
            new BoxDecoration(
                    color: Colors.white,
                    borderRadius: new BorderRadius.circular(5),
                    boxShadow: kElevationToShadow[elevation])
                .createBoxPainter(),
        super(repaint: resize);

  final Color color;

  /// *[color] which is dropdown item's background color

  final int elevation;

  /// *[elevation] which is dropdown whole item list's elevation

  final int selectedIndex;

  /// *[selectedIndex] which is selected item's index

  final Animation<double> resize;

  /// *[resize] which is resized animation value

  final BoxPainter _painter;

  /// *[_painter] which is panting value
  ///
  final double itemHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final double selectedItemOffset = selectedIndex * itemHeight + kMaterialListPadding.top;
    final Tween<double> top = new Tween<double>(
      begin: selectedItemOffset.clamp(0.0, size.height - itemHeight),
      end: 0.0,
    );

    final Tween<double> bottom = new Tween<double>(
      begin: (top.begin + itemHeight).clamp(itemHeight, size.height),
      end: size.height,
    );

    final Rect rect = new Rect.fromLTRB(0.0, top.evaluate(resize), size.width, bottom.evaluate(resize));

    _painter.paint(canvas, rect.topLeft, new ImageConfiguration(size: rect.size));
  }

  @override
  bool shouldRepaint(_DropdownMenuPainter oldPainter) {
    return oldPainter.color != color ||
        oldPainter.elevation != elevation ||
        oldPainter.selectedIndex != selectedIndex ||
        oldPainter.resize != resize;
  }
}

class _DropdownScrollBehavior extends ScrollBehavior {
  const _DropdownScrollBehavior();

  @override
  TargetPlatform getPlatform(BuildContext context) => Theme.of(context).platform;

  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) => child;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) => const ClampingScrollPhysics();
}

class _DropdownMenu<T> extends StatefulWidget {
  const _DropdownMenu({
    Key key,
    this.padding,
    this.route,
    this.decoration,
  }) : super(key: key);

  final _DropdownRoute<T> route;
  final Decoration decoration;

  /// flutter's dropdown is same as go to new route.
  /// So *[route] means setting new route

  final EdgeInsets padding;

  /// padding.

  @override
  _DropdownMenuState<T> createState() => new _DropdownMenuState<T>();
}

class _DropdownMenuState<T> extends State<_DropdownMenu<T>> {
  CurvedAnimation _fadeOpacity;
  CurvedAnimation _resize;

  @override
  void initState() {
    super.initState();
    _fadeOpacity = new CurvedAnimation(
      parent: widget.route.animation,
      curve: const Interval(0.0, 0.25),
      reverseCurve: const Interval(0.75, 1.0),
    );
    _resize = new CurvedAnimation(
      parent: widget.route.animation,
      curve: const Interval(0.25, 0.5),
      reverseCurve: const Threshold(0.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    final _DropdownRoute<T> route = widget.route;
    final double unit = 0.5 / (route.items.length + 1.5);
    final List<Widget> children = <Widget>[];
    for (int itemIndex = 0; itemIndex < route.items.length; ++itemIndex) {
      CurvedAnimation opacity;
      if (itemIndex == route.selectedIndex) {
        opacity = new CurvedAnimation(parent: route.animation, curve: const Threshold(0.0));
      } else {
        final double start = (0.5 + (itemIndex + 1) * unit).clamp(0.0, 1.0);
        final double end = (start + 1.5 * unit).clamp(0.0, 1.0);
        opacity = new CurvedAnimation(parent: route.animation, curve: new Interval(start, end));
      }
      children.add(new FadeTransition(
        opacity: opacity,
        child: new InkWell(
          child: new Container(
            color: route.selectedColorIndex == itemIndex ? route.selectedColor : null,
            padding: widget.padding,
            child: route.items[itemIndex],
          ),
          onTap: () => Navigator.pop(
            context,
            new _DropdownRouteResult<T>(route.items[itemIndex].value),
          ),
        ),
      ));
    }

    BorderRadius boarderRadius;

    if (widget.decoration is BoxDecoration) {
      boarderRadius = (widget.decoration as BoxDecoration).borderRadius;
    }

    return new FadeTransition(
      opacity: _fadeOpacity,
      child: new CustomPaint(
        painter: new _DropdownMenuPainter(
            color: Colors.white,
            elevation: 2,
            selectedIndex: route.selectedIndex,
            resize: _resize,
            decoration: widget.decoration,
            itemHeight: widget.route.itemHeight),
        child: ClipRRect(
          borderRadius: boarderRadius ?? BorderRadius.zero,
          child: new Semantics(
            scopesRoute: true,
            namesRoute: true,
            explicitChildNodes: true,
            label: localizations.popupMenuLabel,
            child: new Material(
              type: MaterialType.transparency,
              textStyle: route.style,
              child: new ScrollConfiguration(
                behavior: const _DropdownScrollBehavior(),
                child: new Scrollbar(
                  child: new ListView(
                    controller: widget.route.scrollController,
                    padding: kMaterialListPadding,
                    itemExtent: widget.route.itemHeight,
                    shrinkWrap: true,
                    children: children,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownMenuRouteLayout<T> extends SingleChildLayoutDelegate {
  _DropdownMenuRouteLayout({
    @required this.buttonRect,
    @required this.menuTop,
    @required this.menuHeight,
    @required this.textDirection,
    @required this.itemWidth,
    @required this.itemHeight,
  });

  final double itemHeight;

  final double itemWidth;

  /// dropdown button's each item's width

  final Rect buttonRect;

  /// dropdown button's whole list rect.

  final double menuTop;
  final double menuHeight;
  final TextDirection textDirection;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final double maxHeight = math.max(0.0, constraints.maxHeight - 2 * itemHeight);
    return new BoxConstraints(
      minWidth: itemWidth,
      maxWidth: itemWidth,
      minHeight: 0.0,
      maxHeight: maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    assert(() {
      final Rect container = Offset.zero & size;
      if (container.intersect(buttonRect) == buttonRect) {
        assert(menuTop >= 0.0);
        assert(menuTop + menuHeight <= size.height);
      }
      return true;
    }());
    assert(textDirection != null);
    double left;
    switch (textDirection) {
      case TextDirection.rtl:
        left = buttonRect.right.clamp(0.0, size.width) - childSize.width;
        break;
      case TextDirection.ltr:
        left = buttonRect.left.clamp(0.0, size.width - childSize.width);
        break;
    }
    return new Offset(left + 15, menuTop + 13);
  }

  @override
  bool shouldRelayout(_DropdownMenuRouteLayout<T> oldDelegate) {
    return buttonRect != oldDelegate.buttonRect ||
        menuTop != oldDelegate.menuTop ||
        menuHeight != oldDelegate.menuHeight ||
        textDirection != oldDelegate.textDirection;
  }
}

class _DropdownRouteResult<T> {
  const _DropdownRouteResult(this.result);

  final T result;

  @override
  bool operator ==(dynamic other) {
    if (other is! _DropdownRouteResult<T>) return false;
    final _DropdownRouteResult<T> typedOther = other;
    return result == typedOther.result;
  }

  @override
  int get hashCode => result.hashCode;
}

class _DropdownRoute<T> extends PopupRoute<_DropdownRouteResult<T>> {
  _DropdownRoute({
    this.items,
    this.itemWidth,
    this.itemHeight,
    this.padding,
    this.buttonRect,
    this.selectedIndex,
    this.selectedColor,
    this.selectedColorIndex,
    this.itemDecoration,
    this.elevation = 8,
    this.spacing = 0,
    this.theme,
    @required this.style,
    this.barrierLabel,
  }) : assert(style != null);

  final List<DropdownMenuItem<T>> items;

  /// item's list

  final EdgeInsetsGeometry padding;

  final Rect buttonRect;

  /// buttons rectangle

  final int selectedIndex;

  final Color selectedColor;
  final int selectedColorIndex;
  final double spacing;

  /// selected Index

  final int elevation;
  final ThemeData theme;
  final TextStyle style;

  ScrollController scrollController;

  @override
  Duration get transitionDuration => _kDropdownMenuDuration;

  @override
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => null;

  @override
  final String barrierLabel;

  final double itemWidth;
  final double itemHeight;

  final Decoration itemDecoration;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    assert(debugCheckHasDirectionality(context));
    final double screenHeight = MediaQuery.of(context).size.height;
    final double maxMenuHeight = screenHeight - 2.0 * itemHeight;
    final double preferredMenuHeight = (items.length * itemHeight) + kMaterialListPadding.vertical;
    final double menuHeight = math.min(maxMenuHeight, preferredMenuHeight);

    double buttonTop = buttonRect.top + (spacing ?? 0);

    final double selectedItemOffset = selectedIndex * itemHeight + kMaterialListPadding.top;
    double menuTop = (buttonTop - selectedItemOffset) - (itemHeight - buttonRect.height) / 2.0;
    double topPreferredLimit = itemHeight;
    if (menuTop < topPreferredLimit) menuTop = math.min(buttonTop, topPreferredLimit);
    double bottom = menuTop + menuHeight;
    final double bottomPreferredLimit = screenHeight - itemHeight;
    if (bottom > bottomPreferredLimit) {
      bottom = math.max(buttonTop + itemHeight, bottomPreferredLimit);
      menuTop = bottom - menuHeight;
    }

    if (scrollController == null) {
      double scrollOffset = 0.0;
      if (preferredMenuHeight > maxMenuHeight) scrollOffset = selectedItemOffset - (buttonTop - menuTop);
      scrollController = new ScrollController(initialScrollOffset: scrollOffset);
    }

    final TextDirection textDirection = Directionality.of(context);
    Widget menu = new _DropdownMenu<T>(
      route: this,
      padding: padding.resolve(textDirection),
      decoration: itemDecoration,
    );

    if (theme != null) menu = new Theme(data: theme, child: menu);

    return new MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      removeLeft: true,
      removeRight: true,
      child: new Builder(
        builder: (BuildContext context) {
          return new CustomSingleChildLayout(
            delegate: new _DropdownMenuRouteLayout<T>(
              itemHeight: itemHeight,
              itemWidth: itemWidth,
              buttonRect: buttonRect,
              menuTop: menuTop,
              menuHeight: menuHeight,
              textDirection: textDirection,
            ),
            child: menu,
          );
        },
      ),
    );
  }

  void _dismiss() {
    navigator?.removeRoute(this);
  }
}

class DropdownBelow<T> extends StatefulWidget {
  DropdownBelow({
    Key key,
    @required this.items,
    this.value,
    this.hint,
    this.itemTextstyle,
    this.itemHeight = _kMenuItemHeight,
    this.itemWidth,
    this.itemDecoration,
    this.boxHeight,
    this.boxWidth,
    this.boxPadding,
    this.boxTextstyle,
    this.boxDecoration,
    @required this.onChanged,
    this.elevation = 8,
    this.style,
    this.icon,
    this.isDense = false,
    this.showUnderLine = false,
    this.selectedColor,
    this.spacing,
  })  : assert(value == null || items.where((DropdownMenuItem<T> item) => item.value == value).length == 1),
        assert(itemHeight != null || itemHeight > 0),
        super(key: key);
  final List<DropdownMenuItem<T>> items;

  /// item list

  final T value;

  /// printed value

  final double itemWidth;

  final double itemHeight;

  /// each item width

  final double boxHeight;

  /// whole box height

  final double boxWidth;

  /// whole box padding
  final EdgeInsetsGeometry boxPadding;

  /// whole box decoration
  final Decoration boxDecoration;

  /// default box text style
  final TextStyle boxTextstyle;

  /// default item text style
  final TextStyle itemTextstyle;

  /// whole box decoration
  final Decoration itemDecoration;

  final Widget hint;

  /// default value that printed which has no touch to dropdown widget.
  final ValueChanged<T> onChanged;

  /// click item then, function triggered
  final int elevation;
  final TextStyle style;
  final Widget icon;
  final double spacing;
  final Color selectedColor;
  final bool showUnderLine;

  /// if you use icon this value designate icon size

  final bool isDense;

  @override
  _DropdownBelowState<T> createState() => new _DropdownBelowState<T>();
}

class _DropdownBelowState<T> extends State<DropdownBelow<T>>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  static final Animatable<double> _easeInTween = CurveTween(curve: Curves.easeIn);
  static final Animatable<double> _halfTween = Tween<double>(begin: 0.0, end: -0.5);

  int _selectedIndex;
  _DropdownRoute<T> _dropdownRoute;

  bool _show = false;
  AnimationController _controller;
  Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();
    _updateSelectedIndex();
    _controller = AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _iconTurns = _controller.drive(_halfTween.chain(_easeInTween));
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _removeDropdownRoute();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _removeDropdownRoute();
  }

  void _removeDropdownRoute() {
    _dropdownRoute?._dismiss();
    _dropdownRoute = null;
  }

  @override
  void didUpdateWidget(DropdownBelow<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    assert(widget.value == null ||
        widget.items.where((DropdownMenuItem<T> item) => item.value == widget.value).length == 1);
    _selectedIndex = null;
    for (int itemIndex = 0; itemIndex < widget.items.length; itemIndex++) {
      if (widget.items[itemIndex].value == widget.value) {
        _selectedIndex = itemIndex;
        return;
      }
    }
  }

  TextStyle get _textStyle => widget.style ?? Theme.of(context).textTheme.subtitle1;

  void _handleTap() {
    final RenderBox itemBox = context.findRenderObject();
    final Rect itemRect = itemBox.localToGlobal(Offset.zero) & itemBox.size;
    final TextDirection textDirection = Directionality.of(context);
    final EdgeInsetsGeometry menuMargin =
        ButtonTheme.of(context).alignedDropdown ? _kAlignedMenuMargin : _kUnalignedMenuMargin;

    assert(_dropdownRoute == null);
    _dropdownRoute = new _DropdownRoute<T>(
      selectedColorIndex: _selectedIndex,
      selectedColor: widget.selectedColor,
      itemHeight: widget.itemHeight,
      itemWidth: widget.itemWidth,
      itemDecoration: widget.itemDecoration ?? widget.boxDecoration,
      items: widget.items,
      buttonRect: menuMargin.resolve(textDirection).inflateRect(itemRect),
      padding: widget.boxPadding,
      selectedIndex: -1,
      spacing: widget.spacing,
      elevation: widget.elevation,
      theme: Theme.of(context),
      style: _textStyle,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    );

    toggle(true);

    Navigator.push(context, _dropdownRoute).then<void>((_DropdownRouteResult<T> newValue) {
      _dropdownRoute = null;
      toggle(false);
      if (!mounted || newValue == null) return;
      if (widget.onChanged != null) widget.onChanged(newValue.result);
    });
  }

  void toggle(bool show) {
    _show = show;
    if (_show) {
      _controller.forward();
    } else {
      _controller.reverse().then<void>((void value) {
        if (!mounted) return;
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));

    final List<Widget> items = new List<Widget>.from(widget.items);
    int hintIndex;
    if (widget.hint != null) {
      hintIndex = items.length;
      items.add(new DefaultTextStyle(
        style: widget.itemTextstyle,
        child: new IgnorePointer(
          child: widget.hint,
          ignoringSemantics: false,
        ),
      ));
    }

    Widget result = new DefaultTextStyle(
      style: widget.boxTextstyle,
      child: new Container(
        decoration: widget.boxDecoration ??
            BoxDecoration(
              border: Border.all(color: Color(0XFFececec), width: 2),
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: Colors.white,
            ),
        width: widget.boxWidth,
        padding: widget.boxPadding,
        height: widget.boxHeight,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: new IndexedStack(
                index: _selectedIndex ?? hintIndex,
                alignment: AlignmentDirectional.centerStart,
                children: items,
              ),
            ),
            RotationTransition(
              turns: _iconTurns,
              child: widget.icon ??
                  Container(
                      height: 24,
                      width: 24,
                      child: new Icon(
                        Icons.arrow_drop_down,
                        size: 24,
                        color: Color(0XFFbbbbbb),
                      )),
            ),
          ],
        ),
      ),
    );

    if (widget.showUnderLine) {
      result = new Stack(
        children: <Widget>[
          result,
          new Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0,
            child: new Container(
              height: 0.0,
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFececec), width: 0))),
            ),
          ),
        ],
      );
    }

    return new Semantics(
      button: true,
      child: new GestureDetector(onTap: _handleTap, behavior: HitTestBehavior.opaque, child: result),
    );
  }
}
