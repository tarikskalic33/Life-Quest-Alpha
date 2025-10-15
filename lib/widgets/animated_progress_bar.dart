import 'package:flutter/material.dart';

class AnimatedProgressBar extends StatefulWidget {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double height;
  final Duration duration;
  final bool showGlow;

  const AnimatedProgressBar({
    Key? key,
    required this.progress,
    this.backgroundColor = const Color(0xFF0B1021),
    this.progressColor = const Color(0xFF7C5CFF),
    this.height = 8.0,
    this.duration = const Duration(milliseconds: 1000),
    this.showGlow = true,
  }) : super(key: key);

  @override
  _AnimatedProgressBarState createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.height / 2),
          ),
          child: Stack(
            children: [
              // Progress bar
              FractionallySizedBox(
                widthFactor: _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.progressColor,
                    borderRadius: BorderRadius.circular(widget.height / 2),
                    boxShadow: widget.showGlow
                        ? [
                            BoxShadow(
                              color: widget.progressColor.withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
              // Shimmer effect
              if (widget.showGlow && _progressAnimation.value > 0)
                Positioned.fill(
                  child: FractionallySizedBox(
                    widthFactor: _progressAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(widget.height / 2),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            widget.progressColor.withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class XPProgressBar extends StatelessWidget {
  final int currentXP;
  final int xpForNextLevel;
  final int level;

  const XPProgressBar({
    Key? key,
    required this.currentXP,
    required this.xpForNextLevel,
    required this.level,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final xpForCurrentLevel = _getXPForLevel(level);
    final xpForNext = _getXPForLevel(level + 1);
    final progress = (currentXP - xpForCurrentLevel) / (xpForNext - xpForCurrentLevel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Level $level',
              style: const TextStyle(
                color: Color(0xFFE6E9FF),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${currentXP - xpForCurrentLevel}/${xpForNext - xpForCurrentLevel} XP',
              style: const TextStyle(
                color: Color(0xFF9AA3C7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedProgressBar(
          progress: progress,
          progressColor: const Color(0xFF7C5CFF),
          height: 12,
          showGlow: true,
        ),
      ],
    );
  }

  int _getXPForLevel(int level) {
    // XP required for each level (exponential growth)
    return (level * level * 100);
  }
}

class StatProgressBar extends StatelessWidget {
  final String statName;
  final int statValue;
  final Color color;
  final int maxValue;

  const StatProgressBar({
    Key? key,
    required this.statName,
    required this.statValue,
    required this.color,
    this.maxValue = 100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = (statValue / maxValue).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _capitalizeFirst(statName),
              style: const TextStyle(
                color: Color(0xFF9AA3C7),
                fontSize: 14,
              ),
            ),
            Text(
              '$statValue',
              style: const TextStyle(
                color: Color(0xFFE6E9FF),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        AnimatedProgressBar(
          progress: progress,
          progressColor: color,
          height: 8,
          showGlow: true,
        ),
      ],
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

