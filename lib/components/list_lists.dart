import 'package:flutter/material.dart';
import 'package:cutelist/components/list_lists_entry.dart';
import 'package:cutelist/list.dart';
import 'package:cutelist/pages/list_page.dart';
import 'package:cutelist/utils.dart';

class ListOfListWidget extends StatefulWidget {
  ListOfListWidget(
      {Key key = const Key("null"), required this.lists, this.onSelectOverride})
      : super(key: key);

  final List<ShoppingList> lists;

  ShopListClickCallback? onSelectOverride;
  @override
  State<ListOfListWidget> createState() => _ListOfListWidget();
}

class _ListOfListWidget extends State<ListOfListWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? animationController;
  Animation? animation;
  Animation? sizeAnimation;

  GlobalKey _key = GlobalKey();

  Route listEnterRoute(ShoppingList entry) {
    if (_key.currentContext == null ||
        _key.currentContext!.findRenderObject() == null) {
      return MaterialPageRoute(
          builder: (context) => ListPage(
                id: entry.uid,
                name: entry.name,
                tags: ["tag", "tag2"],
              ));
    }
    final RenderObject fabRenderBox = _key.currentContext!.findRenderObject()!;

    Rect bound = fabRenderBox.paintBounds;
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => ListPage(
        id: entry.uid,
        name: entry.name,
        tags: ["tag", "tag2"],
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var curve = Curves.easeInOutCubic;
        var curveTween = CurveTween(curve: curve);
        final offsetAnimation = animation.drive(curveTween);

        return ScaleTransition(
          scale: offsetAnimation,
          child: child,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    animation = Tween(begin: 0, end: 60).animate(animationController!)
      ..addListener(() {
        setState(() {});
      });
    sizeAnimation = Tween(begin: 0, end: 1).animate(CurvedAnimation(
        parent: animationController!, curve: Curves.fastOutSlowIn))
      ..addListener(() {
        setState(() {});
      });
  }

  int currentState = 0;
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (var i = 0; i < widget.lists.length; i++) {
      children.add(pad(
        ListOfListEntryWidget(
            entry: widget.lists[i],
            key: Key("$i"),
            onSelectOverride: widget.onSelectOverride),
      ));
    }
    return Column(children: children);
  }
}

Widget listListWidget(BuildContext context, AsyncSnapshot snapshot,
    ShopListClickCallback? onSelectOverride) {
  if (snapshot.hasData || snapshot.hasError) {
    return ListOfListWidget(
        lists: snapshot.data, onSelectOverride: onSelectOverride);
  } else {
    var children = [
      Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        pad(CircularProgressIndicator()),
        pad(Text("Loading")),
        pad(Text("Getting user lists..."))
      ]))
    ];

    return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: children));
  }
}
