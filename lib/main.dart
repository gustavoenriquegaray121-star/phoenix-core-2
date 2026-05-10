import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:ui' as ui;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Capturar errores en runtime y mostrarlos en pantalla
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };
  
  runZonedGuarded(() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    runApp(const PC2App());
  }, (error, stack) {
    runApp(MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'ERROR:\n\n$error\n\n$stack',
            style: TextStyle(color: Colors.red, fontSize: 10,
              fontFamily: 'monospace'),
          ),
        )),
      ),
    ));
  });
}

class PC2App extends StatelessWidget {
  const PC2App({super.key});
  @override
  Widget build(BuildContext ctx) => MaterialApp(
    title: 'Phoenix Core 2',
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
    home: const CaptainSelectScreen(),
  );
}

const cIce    = Color(0xFF00DDFF);
const cFire   = Color(0xFFFF5500);
const cGold   = Color(0xFFFFD700);
const cRed    = Color(0xFFFF2244);
const cPurple = Color(0xFF9944FF);
const cBg     = Color(0xFF080C18);
const cPanel  = Color(0xFF0D1420);

enum Captain { danny, andy, denise }

class CaptainData {
  final Captain id;
  final String name, fullName, title, ability, abilityDesc, tradeoff, style, emoji;
  final Color color;
  final double damage, speed, hullMax;
  const CaptainData({
    required this.id, required this.name, required this.fullName,
    required this.title, required this.ability, required this.abilityDesc,
    required this.tradeoff, required this.style, required this.emoji,
    required this.color, required this.damage, required this.speed,
    required this.hullMax,
  });
}

const captains = [
  CaptainData(
    id: Captain.danny, name: 'DANNY', fullName: 'Daniel Garay',
    title: 'El Estratega', emoji: '🪖', ability: 'MODO FÉNIX',
    abilityDesc: 'Anticipa el peligro 90ms antes.\nVentana de daño máximo en boss.',
    tradeoff: 'Cadencia lenta — necesita timing perfecto',
    style: 'Lento · Preciso · Devastador', color: cGold,
    damage: 1.8, speed: 0.75, hullMax: 120,
  ),
  CaptainData(
    id: Captain.andy, name: 'ANDY', fullName: 'Andres Garay',
    title: 'El Impulsivo', emoji: '⚡', ability: 'MODO KALMAN',
    abilityDesc: 'Estabiliza la realidad local.\nCadencia x2 en zona de calor.',
    tradeoff: 'Hull baja 2x más rápido — frágil',
    style: 'Rápido · Agresivo · Alto riesgo', color: cIce,
    damage: 1.0, speed: 1.5, hullMax: 70,
  ),
  CaptainData(
    id: Captain.denise, name: 'DENISE', fullName: 'Denise Garay',
    title: 'La Guardiana', emoji: '🛡️', ability: 'WATCH DOG',
    abilityDesc: 'Teletransporte de emergencia\ncuando hull < 15%.',
    tradeoff: 'Menor daño base — solo brilla sobreviviendo',
    style: 'Defensivo · Supervivencia · Control', color: cPurple,
    damage: 0.8, speed: 1.0, hullMax: 150,
  ),
];

class CaptainSelectScreen extends StatefulWidget {
  const CaptainSelectScreen({super.key});
  @override State<CaptainSelectScreen> createState() => _CaptainSelectState();
}

class _CaptainSelectState extends State<CaptainSelectScreen>
    with TickerProviderStateMixin {
  int _selected = 0;
  late AnimationController _pulse;
  late Animation<double> _anim;

  @override void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }
  @override void dispose() { _pulse.dispose(); super.dispose(); }

  @override Widget build(BuildContext ctx) {
    final cap = captains[_selected];
    return Scaffold(
      backgroundColor: cBg,
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(20,20,20,0), child: Column(children: [
          Text('PHOENIX CORE II', style: TextStyle(color: cap.color,
            fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 4,
            fontFamily: 'monospace')),
          const SizedBox(height: 4),
          const Text('"No puedes ganarte a ti mismo siendo tú mismo"',
            style: TextStyle(color: Colors.white38, fontSize: 10,
              fontStyle: FontStyle.italic)),
        ])),
        const SizedBox(height: 16),
        SizedBox(height: 80, child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final c = captains[i]; final sel = i == _selected;
            return GestureDetector(
              onTap: () => setState(() => _selected = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: sel ? 76 : 60, height: sel ? 76 : 60,
                decoration: BoxDecoration(
                  color: sel ? c.color.withOpacity(0.2) : cPanel,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sel ? c.color : Colors.white12,
                    width: sel ? 2 : 1)),
                child: Center(child: Text(c.emoji,
                  style: TextStyle(fontSize: sel ? 30 : 24)))));
          }))),
        const SizedBox(height: 12),
        Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AnimatedBuilder(animation: _anim, builder: (_, __) =>
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cPanel, borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cap.color.withOpacity(0.35), width: 1.5),
                boxShadow: [BoxShadow(color: cap.color.withOpacity(0.1),
                  blurRadius: 20)]),
              child: SingleChildScrollView(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(cap.emoji, style: const TextStyle(fontSize: 34)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text(cap.name, style: TextStyle(color: cap.color, fontSize: 22,
                      fontWeight: FontWeight.bold, fontFamily: 'monospace')),

                    Text(cap.title, style: TextStyle(
                      color: cap.color.withOpacity(0.7), fontSize: 12,
                      fontStyle: FontStyle.italic)),
                  ])),
                ]),
                const SizedBox(height: 16),
                Container(height: 1, decoration: BoxDecoration(gradient: LinearGradient(
                  colors: [Colors.transparent, cap.color.withOpacity(0.4),
                    Colors.transparent]))),
                const SizedBox(height: 14),
                Text('HABILIDAD ESPECIAL', style: TextStyle(
                  color: cap.color.withOpacity(0.6), fontSize: 9,
                  letterSpacing: 2, fontFamily: 'monospace')),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cap.color.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: cap.color.withOpacity(0.25))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text(cap.ability, style: TextStyle(color: cap.color,
                      fontSize: 14, fontWeight: FontWeight.bold,
                      fontFamily: 'monospace')),
                    const SizedBox(height: 4),
                    Text(cap.abilityDesc, style: const TextStyle(
                      color: Colors.white70, fontSize: 12, height: 1.5)),
                  ])),
                const SizedBox(height: 14),
                Text('ESTADÍSTICAS', style: TextStyle(
                  color: cap.color.withOpacity(0.6), fontSize: 9,
                  letterSpacing: 2, fontFamily: 'monospace')),
                const SizedBox(height: 8),
                ...[['DAÑO', cap.damage/1.8], ['VELOCIDAD', cap.speed/1.5],
                    ['CASCO', cap.hullMax/150]].map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(children: [
                    SizedBox(width: 80, child: Text(s[0] as String,
                      style: const TextStyle(color: Colors.white38, fontSize: 9,
                        fontFamily: 'monospace'))),
                    Expanded(child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: (s[1] as double).clamp(0.0, 1.0), minHeight: 5,
                        backgroundColor: Colors.white10,
                        valueColor: AlwaysStoppedAnimation(cap.color)))),
                  ]))),
                const SizedBox(height: 10),
                Row(children: [
                  const Text('⚠ ', style: TextStyle(fontSize: 13)),
                  Expanded(child: Text(cap.tradeoff, style: const TextStyle(
                    color: Colors.orange, fontSize: 11, fontStyle: FontStyle.italic))),
                ]),
                const SizedBox(height: 6),
                Text(cap.style, style: TextStyle(
                  color: cap.color.withOpacity(0.5), fontSize: 10, letterSpacing: 1)),
              ])),
            )))),
        Padding(padding: const EdgeInsets.all(20),
          child: GestureDetector(
            onTap: () => Navigator.pushReplacement(ctx,
              MaterialPageRoute(builder: (_) =>
                PC2GameScreen(captain: captains[_selected]))),
            child: Container(
              width: double.infinity, height: 56,
              decoration: BoxDecoration(
                color: cap.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cap.color, width: 2),
                boxShadow: [BoxShadow(color: cap.color.withOpacity(0.2),
                  blurRadius: 16)]),
              child: Center(child: Text('DESPLEGAR — ${cap.name}',
                style: TextStyle(color: cap.color, fontSize: 15,
                  fontWeight: FontWeight.bold, letterSpacing: 3,
                  fontFamily: 'monospace')))))),
      ])),
    );
  }
}

class PC2GameScreen extends StatefulWidget {
  final CaptainData captain;
  const PC2GameScreen({super.key, required this.captain});
  @override State<PC2GameScreen> createState() => _PC2GameScreenState();
}

class _PC2GameScreenState extends State<PC2GameScreen>
    with TickerProviderStateMixin {

  late double hullIntegrity;
  double abilityCharge = 0.0;
  bool abilityActive = false;
  double abilityTimer = 0;
  int score = 0;
  final String currentWorld = 'SECTOR OMEGA-9';
  late AnimationController _loop;
  final _rng = Random();
  final List<_VHDLLineData> _lines = [];
  double _spawnTimer = 0;
  bool _glitch = false;
  double _glitchTimer = 2.0;
  double _prev = 0;

  @override void initState() {
    super.initState();
    hullIntegrity = widget.captain.hullMax / 150.0;
    _loop = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 16))
      ..addListener(_tick)..repeat();
  }
  @override void dispose() { _loop.dispose(); super.dispose(); }

  void _tick() {
    final now = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final dt = _prev == 0 ? 0.016 : (now - _prev).clamp(0.0, 0.05);
    _prev = now;

    if (!abilityActive) abilityCharge = (abilityCharge + dt * 0.06).clamp(0, 1);
    if (abilityActive) {
      abilityTimer -= dt;
      if (abilityTimer <= 0) { abilityActive = false; abilityCharge = 0; }
    }
    _spawnTimer -= dt;
    if (_spawnTimer <= 0) {
      _spawnTimer = 0.1 + _rng.nextDouble() * 0.3;
      _lines.add(_VHDLLineData(
        text: _frags[_rng.nextInt(_frags.length)],
        x: _rng.nextDouble(), speed: 0.06 + _rng.nextDouble() * 0.12,
        isCorrupt: _rng.nextDouble() < 0.2));
    }
    for (final l in _lines) l.y += dt * l.speed;
    _lines.removeWhere((l) => l.y > 1.2);
    _glitchTimer -= dt;
    if (_glitchTimer <= 0) {
      _glitch = !_glitch;
      _glitchTimer = _glitch ? 0.06 + _rng.nextDouble() * 0.15
        : 1.5 + _rng.nextDouble() * 3.0;
    }
    setState(() {});
  }

  static const _frags = [
    'signal t_predicted : t_voltage := 0;',
    'if d3T_raw > JERK_LIMIT then',
    'px_state <= ST_PRE_ARM;',
    'binom_raw := 4*t1 - 6*t2 + 4*t3 - t4;',
    'arm_confirm_cnt <= 0;',
    '-- ALTEA-GARAY v7.3', 'JERK_LIMIT := 512;',
    'CORRUPT_SECTOR_0x4F;', 'OVERRIDE_PROTOCOL_9;',
    'MEMORY_VIOLATION_0xFF;', 'ENTROPY_CASCADE > MAX;',
    'YOU_ARE_NOT_THE_ORIGINAL;', 'PHOENIX_PROTOCOL_REJECTED;',
    'LOG_014: The body kept moving.', 'ERROR: identity_mismatch;',
  ];

  void _activate() {
    if (abilityCharge < 1.0 || abilityActive) return;
    setState(() {
      abilityActive = true;
      abilityTimer = switch(widget.captain.id) {
        Captain.danny => 8.0, Captain.andy => 5.0, Captain.denise => 3.0,
      };
    });
  }

  @override Widget build(BuildContext ctx) {
    final cap = widget.captain;
    final size = MediaQuery.of(ctx).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        CustomPaint(size: size,
          painter: _SkyPainter(lines: _lines, glitch: _glitch)),
        if (_glitch) Container(color: const Color(0x09FF0044)),
        Center(child: CustomPaint(size: const Size(44, 44),
          painter: _CrosshairPainter(color: cap.color))),
        Positioned(top: 48, left: 16, child: _hullBar(cap)),
        Positioned(top: 48, right: 16, child: _abilityBar(cap)),
        Positioned(top: 52, left: 0, right: 0, child: Center(
          child: Text(currentWorld, style: TextStyle(
            color: cap.color.withOpacity(0.4), fontSize: 9,
            fontFamily: 'monospace', letterSpacing: 2)))),
        Positioned(bottom: 32, left: 16, child: Text('SCORE $score',
          style: const TextStyle(color: Colors.white38, fontSize: 11,
            fontFamily: 'monospace'))),
        Positioned(bottom: 20, right: 16, child: GestureDetector(
          onTap: _activate,
          child: Container(width: 68, height: 68,
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: abilityCharge >= 1.0
                ? cap.color.withOpacity(0.2) : Colors.black45,
              border: Border.all(
                color: abilityActive ? Colors.white :
                  abilityCharge >= 1.0 ? cap.color : Colors.white24,
                width: 2)),
            child: Center(child: Text(cap.emoji,
              style: const TextStyle(fontSize: 26)))))),
        if (hullIntegrity < 0.15) Positioned(
          top: size.height * 0.35, left: 0, right: 0,
          child: Center(child: Text('⚠ CASCO CRÍTICO ⚠',
            style: TextStyle(color: cRed.withOpacity(0.9),
              fontSize: 14, fontFamily: 'monospace',
              fontWeight: FontWeight.bold)))),
        Positioned(top: 44, right: 60, child: GestureDetector(
          onTap: () => _pause(ctx),
          child: Container(width: 36, height: 36,
            decoration: BoxDecoration(color: Colors.black38,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24)),
            child: const Icon(Icons.pause, color: Colors.white54, size: 18)))),
      ]));
  }

  Widget _hullBar(CaptainData cap) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('HULL', style: TextStyle(color: cap.color.withOpacity(0.6),
      fontSize: 8, fontFamily: 'monospace')),
    const SizedBox(height: 3),
    SizedBox(width: 110, height: 5, child: ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(value: hullIntegrity.clamp(0.0, 1.0),
        backgroundColor: Colors.white10,
        valueColor: AlwaysStoppedAnimation(hullIntegrity > 0.5 ? cIce :
          hullIntegrity > 0.25 ? cGold : cRed)))),
  ]);

  Widget _abilityBar(CaptainData cap) => Column(
    crossAxisAlignment: CrossAxisAlignment.end, children: [
    Text(cap.ability, style: TextStyle(color: cap.color,
      fontSize: 8, fontFamily: 'monospace')),
    const SizedBox(height: 3),
    SizedBox(width: 80, height: 4, child: ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: LinearProgressIndicator(value: abilityCharge.clamp(0.0, 1.0),
        backgroundColor: Colors.white10,
        valueColor: AlwaysStoppedAnimation(
          abilityActive ? Colors.white : cap.color)))),
  ]);

  void _pause(BuildContext ctx) => showDialog(
    context: ctx, barrierColor: Colors.black54,
    builder: (_) => AlertDialog(
      backgroundColor: cPanel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: widget.captain.color.withOpacity(0.4))),
      title: Text('PAUSA', textAlign: TextAlign.center,
        style: TextStyle(color: widget.captain.color,
          fontFamily: 'monospace', letterSpacing: 3)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx),
          child: Text('CONTINUAR', style: TextStyle(
            color: widget.captain.color, fontFamily: 'monospace'))),
        TextButton(
          onPressed: () => Navigator.pushAndRemoveUntil(ctx,
            MaterialPageRoute(builder: (_) => const CaptainSelectScreen()),
            (_) => false),
          child: const Text('MENÚ', style: TextStyle(
            color: Colors.white38, fontFamily: 'monospace'))),
      ]));
}

class _VHDLLineData {
  final String text; final double x, speed; final bool isCorrupt; double y;
  _VHDLLineData({required this.text, required this.x,
    required this.speed, required this.isCorrupt}) : y = -0.05;
}

class _SkyPainter extends CustomPainter {
  final List<_VHDLLineData> lines; final bool glitch;
  const _SkyPainter({required this.lines, required this.glitch});
  @override void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0,0,size.width,size.height),
      Paint()..color = const Color(0xFF03060F));
    for (final l in lines) {
      final op = l.y > 0.75 ? ((1-l.y)/0.25).clamp(0.0,1.0) : 1.0;
      final color = l.isCorrupt
        ? Color.fromARGB((op*200).toInt(),255,30,60)
        : Color.fromARGB((op*160).toInt(),0,220,100);
      final pb = ui.ParagraphBuilder(ui.ParagraphStyle(
        textDirection: ui.TextDirection.ltr))
        ..pushStyle(ui.TextStyle(color:color, fontSize:8, fontFamily:'monospace'))
        ..addText(l.text);
      final para = pb.build()..layout(ui.ParagraphConstraints(
        width: size.width*(1-l.x)));
      canvas.drawParagraph(para, Offset(l.x*size.width, l.y*size.height));
    }
  }
  @override bool shouldRepaint(_) => true;
}

class _CrosshairPainter extends CustomPainter {
  final Color color; const _CrosshairPainter({required this.color});
  @override void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color.withOpacity(0.7)..strokeWidth = 1.5;
    final cx = size.width/2, cy = size.height/2;
    canvas.drawLine(Offset(0,cy), Offset(cx-8,cy), p);
    canvas.drawLine(Offset(cx+8,cy), Offset(size.width,cy), p);
    canvas.drawLine(Offset(cx,0), Offset(cx,cy-8), p);
    canvas.drawLine(Offset(cx,cy+8), Offset(cx,size.height), p);
    canvas.drawCircle(Offset(cx,cy), 2, p..style=ui.PaintingStyle.fill);
  }
  @override bool shouldRepaint(_) => false;
}
