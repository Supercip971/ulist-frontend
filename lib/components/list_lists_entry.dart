import 'package:flutter/material.dart';
import 'package:ulist/components/list_properties.dart';
import 'package:ulist/list.dart';
import 'package:ulist/pages/list_page.dart';
import 'package:ulist/pages/dummy_list_page.dart';
import 'package:ulist/utils.dart';

typedef ShopListClickCallback = bool Function(
    BuildContext ctx, ShoppingList entry);

class ListOfListEntryWidget extends StatefulWidget {
  ListOfListEntryWidget({Key? key, required this.entry, this.onSelectOverride})
      : super(key: key);

  ShopListClickCallback? onSelectOverride;
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
      reverseTransitionDuration: Duration(milliseconds: 0),
      pageBuilder: (context, animation, secondaryAnimation) => ListPage(
		tags: entry.tags,
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
      await animationController?.reverse(from: 1.0);
    } on TickerCanceled {}
  }

  Future<void> _playAnimation() async {
    try {
      await animationController?.forward(from: 0.0);
    } on TickerCanceled {}
  }

  Animation<Rect?>? overlayRectAnimation = null;
  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        duration: const Duration(milliseconds: 550),
        reverseDuration: const Duration(milliseconds: 550),
        vsync: this);

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
      reverseCurve: Curves.easeInOutCubicEmphasized.flipped,
    ))
      ..addListener(() {
        setState(() {});
      });
    final fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: animationController!,
      curve: Curves.easeInOutCubicEmphasized,
      reverseCurve: Curves.easeInOutCubicEmphasized.flipped,
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
                borderRadius: BorderRadius.circular(12.0),
                color: Colors.transparent,
                child: Stack(
                  children: [
                    Material(
                        child: TextButton(
                            onPressed: () {},
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  pad(
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          (Text(widget.entry.name.toString(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge)),
                                          Text("last edited: 20/20/20",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall),
                                        ]),
                                  ),
                                  Spacer(),

                                  // force it to stay in the top
                                  pady(Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ListPropertiesBar(entry: widget.entry),
                                    ],
                                  ))
                                ]))),
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
              if (widget.onSelectOverride != null) {
                widget.onSelectOverride!(context, widget.entry);
                return;
              }

              createOverlay();
              Overlay.of(context, debugRequiredFor: widget)
                  .insert(overlayAnimation!);
              _playAnimation().then((v) {
                Navigator.push(
                  context,
                  listEnterRoute(widget.entry, overlayAnimation),
                ).then((value) {
                  createOverlay();
                  Overlay.of(context, debugRequiredFor: widget)
                      .insert(overlayAnimation!);
                  _goBackAnimation().then((value) {
                    overlayAnimation?.remove();
                    overlayAnimation = null;
                  });
                });
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
              (ListPropertiesBar(entry: widget.entry))
            ])));
  }
}
