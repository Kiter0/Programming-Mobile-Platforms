import 'package:flutter/material.dart';

class AnimatedCounter extends StatefulWidget {
  final int initialValue;
  final int maxValue;
  final Duration animationDuration;
  final Color primaryColor;

  const AnimatedCounter({
    super.key,
    this.initialValue = 0,
    this.maxValue = 100,
    this.animationDuration = const Duration(milliseconds: 500),
    this.primaryColor = Colors.blue,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with TickerProviderStateMixin {
  late int _value;

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _value = widget.initialValue;

    _scaleController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );
  }

  void _changeValue(int newValue) {
    if (newValue < 0 || newValue > widget.maxValue) {
      return;
    }

    setState(() {
      _value = newValue;
    });

    _scaleController.forward(from: 0);
  }

  void _increment() {
    if (_value < widget.maxValue) {
      _changeValue(_value + 1);
    }
  }

  void _decrement() {
    if (_value > 0) {
      _changeValue(_value - 1);
    }
  }

  Color get _currentColor {
    if (_value >= widget.maxValue) {
      return Colors.green;
    }

    return widget.primaryColor;
  }

  double get _progress {
    if (widget.maxValue == 0) {
      return 0;
    }

    return _value / widget.maxValue;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Animated Counter',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            AnimatedDefaultTextStyle(
              duration: widget.animationDuration,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: _currentColor,
              ),
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Text(
                  '$_value / ${widget.maxValue}',
                ),
              ),
            ),

            const SizedBox(height: 16),

            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: 0,
                  end: _progress,
                ),
                duration: widget.animationDuration,
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 12,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _currentColor,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CounterButton(
                  icon: Icons.remove,
                  onPressed: _value > 0 ? _decrement : null,
                  color: _currentColor,
                ),

                const SizedBox(width: 20),

                _CounterButton(
                  icon: Icons.add,
                  onPressed:
                      _value < widget.maxValue ? _increment : null,
                  color: _currentColor,
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              _value >= widget.maxValue
                  ? 'Максимальне значення досягнуто!'
                  : 'Змінюйте значення кнопками',
              style: TextStyle(
                color: _currentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;

  const _CounterButton({
    required this.icon,
    required this.onPressed,
    required this.color,
  });

  @override
  State<_CounterButton> createState() => _CounterButtonState();
}

class _CounterButtonState extends State<_CounterButton> {
  bool _pressed = false;

  void _handleTap() {
    if (widget.onPressed == null) {
      return;
    }

    setState(() {
      _pressed = true;
    });

    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        if (mounted) {
          setState(() {
            _pressed = false;
          });
        }
      },
    );

    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedScale(
        scale: _pressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            widget.icon,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}