import 'package:flutter/material.dart';
import 'package:ulist/list.dart';
import 'package:ulist/pages/list_page.dart';
import 'package:ulist/pages/dummy_list_page.dart';
import 'package:ulist/utils.dart';

class ListOfListEntryWidget extends StatefulWidget {
  const ListOfListEntryWidget({Key? key, required this.entry})
      : super(key: key);

  final ShoppingList entry;
  @override
  State<ListOfListEntryWidget> createState() => _ListOfListEntryWidget();
}

class _ListOfListEntryWidget extends State<ListOfListEntryWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? animationController;
  Animation<double>? animation;
  Animation<double>? sizeAnimation;
  Animation<RelativeRect>? positionAnimation;

  RenderBox? initialBounds = null;

  final GlobalKey _key = GlobalKey();

  Route listEnterRoute(ShoppingList entry, OverlayEntry? overlayEntry) {
    //  return MaterialPageRoute(
    //      builder: (context) => ListPage(
    //            id: entry.uid,
    //            name: entry.name,
    //          ));
    overlayAnimation?.remove();
    overlayAnimation = null;

    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 0),
      reverseTransitionDuration: Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) => ListPage(
        id: entry.uid,
        name: entry.name,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // no transition
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  Future<void> _goBackAnimation() async {
    try {
      await animationController?.reverse().orCancel;
    } on TickerCanceled {}
  }

  Future<void> _playAnimation() async {
    try {
      await animationController?.forward(from: 0.0).orCancel;
    } on TickerCanceled {}
  }

  Animation<Rect?>? overlayRectAnimation = null;
  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        duration: const Duration(milliseconds: 550), vsync: this);

    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }

  _afterLayout(_) {
    _getPosition();
  }

  _getPosition() async {
    final RenderBox rb = _key.currentContext!.findRenderObject()! as RenderBox;

    setState(() {
      initialBounds = rb;
    });
  }

  void createOverlay() {
    if (overlayAnimation != null) {
      overlayAnimation!.remove();
      overlayAnimation = null;
    }

    overlayRectAnimation = RectTween(
      begin: Rect.fromLTWH(
          initialBounds!.localToGlobal(Offset.zero).dx,
          initialBounds!.localToGlobal(Offset.zero).dy,
          initialBounds!.size.width,
          initialBounds!.size.height),
      end: Rect.fromLTWH(0, 0, MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height),
    ).animate(CurvedAnimation(
      parent: animationController!,
      curve: Curves.easeInOutCubicEmphasized,
    ))
      ..addListener(() {
        setState(() {});
      });
    final fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: animationController!,
      curve: Curves.easeInOutCubicEmphasized,
    ))
      ..addListener(() {
        setState(() {});
      });
    ButtonStyle style = ElevatedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary)
        .copyWith(
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0))));

    overlayAnimation = OverlayEntry(builder: (context) {
      return RelativePositionedTransition(
          size: MediaQuery.of(context).size,
          rect: overlayRectAnimation!,
          child: Container(
            width: initialBounds!.size.width,
            height: initialBounds!.size.height,
            child: Material(
                color: Colors.transparent,
                child: Stack(
                  children: [
                    Material(
                        color: Theme.of(context).colorScheme.surface,
                        type: MaterialType.card,
                        surfaceTintColor:
                            Theme.of(context).colorScheme.surfaceTint,
                        elevation: 2.0,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              pad(Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    (Text(widget.entry.name.toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge)),
                                    Text("last edited: 20/20/20",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall),
                                  ])),
                              Spacer(),
                              IconButton(
                                  onPressed: () => {},
                                  icon: Icon(Icons.person_add)),
                              IconButton(
                                  onPressed: () => {}, icon: Icon(Icons.star)),
                              IconButton(
                                  onPressed: () => {},
                                  icon: Icon(Icons.more_vert))
                            ])),
                    FadeTransition(
                        opacity: fadeAnimation,
                        child: DummyListPage(list: widget.entry)),
                  ],
                )),
          ));
    });
  }

  OverlayEntry? overlayAnimation;
  int currentState = 0;
  @override
  Widget build(BuildContext context) {
    // initialBounds = _key.currentContext?.findRenderObject() as RenderBox;
    ButtonStyle style = ElevatedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary)
        .copyWith(
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0))));

    return Container(
        key: _key,
        child: TextButton(
            onPressed: () {
              createOverlay();
              Overlay.of(context, debugRequiredFor: widget)
                  .insert(overlayAnimation!);
              _playAnimation().then((v) {
                Navigator.push(
                  context,
                  listEnterRoute(widget.entry, overlayAnimation),
                ).then((value) => {});
              });
            },
            style: style,
            child: Row(children: [
              pad(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    (Text(widget.entry.name.toString(),
                        style: Theme.of(context).textTheme.bodyLarge)),
                    Text("last edited: 20/20/20",
                        style: Theme.of(context).textTheme.bodySmall),
                  ])),
              Spacer(),
              IconButton(onPressed: () => {}, icon: Icon(Icons.person_add)),
              IconButton(onPressed: () => {}, icon: Icon(Icons.star)),
              IconButton(onPressed: () => {}, icon: Icon(Icons.more_vert))
            ])));
  }
}