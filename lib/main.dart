import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class ConfettiParticle {
  final Offset position;
  final Color color;
  final double rotation;
  final double size;
  bool fading;

  ConfettiParticle({
    required this.position,
    required this.color,
    required this.rotation,
    required this.size,
    this.fading = false,
  });
}

class ConfettiWidget extends StatefulWidget {
  @override
  _ConfettiWidgetState createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget> {
  final List<ConfettiParticle> _particles = [];
  int _particlesToAdd = 0;
  int _particleIndex = 0;

  @override
  void initState() {
    super.initState();
    _startAddingParticles();
  }

  void _startAddingParticles() {
    Future.delayed(Duration(milliseconds: 10), () {
      _addConfettiParticle();
      if (_particleIndex < 199) {
        setState(() {
          _particleIndex++;
        });
        _startAddingParticles();
      } else {
        setState(() {
          _particlesToAdd = 200;
        });
      }
    });
  }

  void _addConfettiParticle() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final randomX = Random().nextDouble() * screenWidth;
    final randomY = Random().nextDouble() * screenHeight;
    final randomRotation = Random().nextDouble() * 2 * pi;
    final randomSize = Random().nextDouble() * 10 + 5;
    final randomColor =
        Colors.primaries[Random().nextInt(Colors.primaries.length)];

    final particle = ConfettiParticle(
      position: Offset(randomX, randomY),
      color: randomColor,
      rotation: randomRotation,
      size: randomSize,
    );

    setState(() {
      _particles.add(particle);
    });

    Future.delayed(Duration(milliseconds: 1500), () {
      setState(() {
        particle.fading = true;
      });
      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          _particles.remove(particle);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Confetti Example')),
      body: Center(
        child: GestureDetector(
          onTap: () {
            setState(() {
              _particles.clear();
              _particleIndex = 0;
              _startAddingParticles();
            });
          },
          child: CustomPaint(
            painter: ConfettiPainter(_particles),
            size: Size(MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height),
          ),
        ),
      ),
    );
  }
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();

    particles.forEach((particle) {
      if (!particle.fading) {
        paint.color = particle.color;
        canvas.save();
        canvas.translate(particle.position.dx, particle.position.dy);
        canvas.rotate(particle.rotation);
        canvas.drawRect(
            Rect.fromLTWH(-particle.size / 2, -particle.size / 2, particle.size,
                particle.size),
            paint);
        canvas.restore();
      } else {
        final fadingPaint = Paint()
          ..color = Color.alphaBlend(
              particle.color.withOpacity(1 - particle.size / 15),
              Colors.transparent);
        canvas.drawCircle(particle.position, particle.size, fadingPaint);
      }
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Confetti Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ConfettiWidget(),
    );
  }
}
