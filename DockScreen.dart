import 'package:flutter/material.dart';

// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

// stateless widget are not dynamic widget which will not change or not involving in animation
class MyApp extends StatelessWidget {
  const MyApp({super.key});//

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            //
            items: const [
              Icons.home,
              Icons.calendar_month_rounded,
              Icons.notes_rounded,
              Icons.chrome_reader_mode_rounded,
              Icons.person,
            ],
            // use the builder function to map each icon into a dock icon widget
            builder: (icon) {
              return DockIcon(iconData: icon);
            },
          ),
        ),
      ),
    );
  }
}
// Dock hold any type of items
class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],// items list of items to display
    required this.builder,
  });
  final List<T> items;

  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T> extends State<Dock<T>> {

  // Converts the intitial list of items(widget.items) into mutable list(_items).
  // late final means list will be intiallized only once when state is created
  late final List<T> _items = widget.items.toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Reduces vertical space
        children: [
          SizedBox(
            height: 80, // Controls the vertical space occupied by icons
            child: ReorderableListView(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              // It handles the drag and drop logic means if the items moves forward adjust newIndexand Remove the item from oldIndex
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _items.removeAt(oldIndex);
                  _items.insert(newIndex, item);
                });
              },
              children: _items
                  .map((e) => Padding(
                // map each item into a padding widget,
                // valueKey(e): Provides a unique key for efficient reordering,
                // Uses widget.builder(e) to generate each icon,
                key: ValueKey(e),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: widget.builder(e),
              ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
// Stateful widget is using for handling animation
// Without Stateful widget user are not able to manage the information
class DockIcon extends StatefulWidget {
  final IconData iconData;

  const DockIcon({super.key, required this.iconData});

  @override
  _DockIconState createState() => _DockIconState();
}

class _DockIconState extends State<DockIcon> with SingleTickerProviderStateMixin {
  double _scale = 1.0;//Control the size of icon when hovered
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController( //Manage the animation
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    // Control the bouncing effect
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });
  }
//increases the size (1.2x) when the user hovers over the icon.
  void _onHover(bool hovering) {
    setState(() {
      _scale = hovering ? 1.2 : 1.0;
    });
  }

  // Trigger the bounce animation when clicked
  void _onTap() {
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
        //GestureDetector: Detects click events to trigger animations.
        //Transform.scale(): Scales the icon on hovering with involving bounce effects
      child: GestureDetector(
        onTap: _onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scale * _bounceAnimation.value,
              child: child,
            );
          },
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.blueGrey,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(widget.iconData, color: Colors.white, size: 32),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  // This dispose() method ensures that the animation controller (_controller) is properly cleaned up when the widget is removed from the widget tree.
}
