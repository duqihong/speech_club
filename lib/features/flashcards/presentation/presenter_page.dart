import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class PresenterPage extends StatefulWidget {
  final List<String> cards;
  final int initialIndex;

  const PresenterPage({
    super.key,
    required this.cards,
    this.initialIndex = 0,
  });

  @override
  State<PresenterPage> createState() => _PresenterPageState();
}

class _PresenterPageState extends State<PresenterPage> {
  late final PageController _controller;
  int _index = 0;

  bool _dark = true;
  bool _showOverlay = true;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(
      0,
      widget.cards.isEmpty ? 0 : widget.cards.length - 1,
    );
    _controller = PageController(initialPage: _index);

    WakelockPlus.enable();

    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _controller.dispose();

    WakelockPlus.disable();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Presenter')),
        body: const Center(
          child: Text('No cards to present.'),
        ),
      );
    }

    final Color bg = _dark ? Colors.black : Colors.white;
    final Color fg = _dark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _showOverlay = !_showOverlay),
          child: Stack(
            children: <Widget>[
              PageView.builder(
                controller: _controller,
                itemCount: widget.cards.length,
                onPageChanged: (int i) => setState(() => _index = i),
                itemBuilder: (BuildContext context, int i) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Text(
                          widget.cards[i],
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: fg,
                            fontSize: 34,
                            height: 1.25,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (_showOverlay)
                Positioned(
                  left: 12,
                  right: 12,
                  top: 8,
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: fg),
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: 'Back',
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          _dark ? Icons.light_mode : Icons.dark_mode,
                          color: fg,
                        ),
                        onPressed: () => setState(() => _dark = !_dark),
                        tooltip: 'Toggle theme',
                      ),
                    ],
                  ),
                ),
              if (_showOverlay)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 18,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _dark
                            ? Colors.white.withValues(alpha: 0.14)
                            : Colors.black.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${_index + 1} / ${widget.cards.length}',
                        style: TextStyle(
                          color: fg,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
