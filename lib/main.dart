import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (d) => FlutterError.presentError(d);
  runZonedGuarded(() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    runApp(const PC2App());
  }, (e, s) {
    runApp(MaterialApp(home: Scaffold(backgroundColor: Colors.black,
      body: Center(child: Text('ERROR:\n$e',
        style: const TextStyle(color: Colors.red, fontSize: 10,
          fontFamily: 'monospace'))))));
  });
}

class PC2App extends StatelessWidget {
  const PC2App({super.key});
  @override Widget build(BuildContext ctx) => MaterialApp(
    title: 'Phoenix Core 2', debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(), home: const SplashScreen());
}

// ═══════════════════════════════════════════════════════════════════════════
//  COLORES
// ═══════════════════════════════════════════════════════════════════════════
const cIce    = Color(0xFF00DDFF);
const cFire   = Color(0xFFFF5500);
const cGold   = Color(0xFFFFD700);
const cRed    = Color(0xFFFF2244);
const cPurple = Color(0xFF9944FF);
const cBg     = Color(0xFF080C18);
const cPanel  = Color(0xFF0D1420);

// ═══════════════════════════════════════════════════════════════════════════
//  SPLASH
// ═══════════════════════════════════════════════════════════════════════════
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashState();
}
class _SplashState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _f;
  @override void initState() {
    super.initState();
    _c = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1400));
    _f = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _c, curve: Curves.easeIn));
    _c.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.pushReplacement(context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const CaptainSelectScreen(),
          transitionDuration: const Duration(milliseconds: 700),
          transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c)));
    });
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext ctx) => Scaffold(
    backgroundColor: Colors.black,
    body: FadeTransition(opacity: _f,
      child: Stack(fit: StackFit.expand, children: [
        Image.asset('assets/images/splash.png', fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: Colors.black,
            child: const Center(child: Text('PHOENIX CORE II',
              style: TextStyle(color: Color(0xFFFF6600), fontSize: 32,
                fontWeight: FontWeight.bold, fontFamily: 'monospace'))))),
        Container(color: Colors.black.withOpacity(0.38)),
        Positioned(bottom: 55, left: 0, right: 0,
          child: Column(children: [
            const Text('UCC v7.3 · ALTEA-GARAY',
              style: TextStyle(color: Colors.white38, fontSize: 11,
                fontFamily: 'monospace', letterSpacing: 3)),
            const SizedBox(height: 14),
            SizedBox(width: 38, height: 38,
              child: CircularProgressIndicator(strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(
                  const Color(0xFFFF6600).withOpacity(0.75)))),
          ])),
      ])));
}

// ═══════════════════════════════════════════════════════════════════════════
//  DATOS
// ═══════════════════════════════════════════════════════════════════════════
enum Captain { danny, andy, denise }

class CaptainData {
  final Captain id;
  final String name, title, ability, abilityDesc, tradeoff, emoji, imagePath;
  final Color color;
  final double damage, speed, hullMax;
  const CaptainData({required this.id, required this.name, required this.title,
    required this.ability, required this.abilityDesc, required this.tradeoff,
    required this.emoji, required this.imagePath, required this.color,
    required this.damage, required this.speed, required this.hullMax});
}

const captains = [
  CaptainData(id: Captain.danny, name: 'DANNY', title: 'El Estratega',
    emoji: '🪖', imagePath: 'assets/images/dany.png', ability: 'MODO FÉNIX',
    abilityDesc: 'Anticipa el peligro 90ms antes.\nVentana de daño máximo en boss.\nUn disparo preciso vale por diez.',
    tradeoff: 'Cadencia lenta — necesita timing perfecto',
    color: cGold, damage: 1.8, speed: 0.75, hullMax: 120),
  CaptainData(id: Captain.andy, name: 'ANDY', title: 'El Impulsivo',
    emoji: '⚡', imagePath: 'assets/images/andy.png', ability: 'MODO KALMAN',
    abilityDesc: 'Estabiliza la realidad local.\nCadencia x2 en zona de calor.\nEl caos es tu combustible.',
    tradeoff: 'Hull baja 2x más rápido — frágil',
    color: cIce, damage: 1.0, speed: 1.5, hullMax: 70),
  CaptainData(id: Captain.denise, name: 'DENISE', title: 'La Guardiana',
    emoji: '🛡️', imagePath: 'assets/images/denisse.png', ability: 'WATCH DOG',
    abilityDesc: 'Teletransporte de emergencia\ncuando hull < 15%.\nNadie la derriba — solo se cansa.',
    tradeoff: 'Menor daño base — solo brilla sobreviviendo',
    color: cPurple, damage: 0.8, speed: 1.0, hullMax: 150),
];

// ═══════════════════════════════════════════════════════════════════════════
//  SELECCIÓN
// ═══════════════════════════════════════════════════════════════════════════
class CaptainSelectScreen extends StatefulWidget {
  const CaptainSelectScreen({super.key});
  @override State<CaptainSelectScreen> createState() => _SelState();
}
class _SelState extends State<CaptainSelectScreen>
    with TickerProviderStateMixin {
  final PageController _pg = PageController();
  int _cur = 0;
  late AnimationController _pulse;
  @override void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this,
        duration: const Duration(seconds: 2))..repeat(reverse: true);
  }
  @override void dispose() { _pulse.dispose(); _pg.dispose(); super.dispose(); }
  void _go(int d) => _pg.animateToPage((_cur+d).clamp(0,2),
    duration: const Duration(milliseconds: 320), curve: Curves.easeInOut);

  @override Widget build(BuildContext ctx) {
    final cap = captains[_cur];
    return Scaffold(backgroundColor: cBg,
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(20,18,20,0),
          child: Column(children: [
            AnimatedBuilder(animation: _pulse, builder: (_, __) =>
              Text('PHOENIX CORE II', style: TextStyle(color: cap.color,
                fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 4,
                fontFamily: 'monospace', shadows: [Shadow(
                  color: cap.color.withOpacity(0.4+0.3*_pulse.value),
                  blurRadius: 12)]))),
            const SizedBox(height: 4),
            const Text('"No puedes ganarte a ti mismo siendo tú mismo"',
              style: TextStyle(color: Colors.white38, fontSize: 10,
                fontStyle: FontStyle.italic)),
          ])),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i==_cur ? 18 : 7, height: 7,
            decoration: BoxDecoration(
              color: i==_cur ? cap.color : Colors.white24,
              borderRadius: BorderRadius.circular(4))))),
        const SizedBox(height: 8),
        Expanded(child: PageView.builder(
          controller: _pg, itemCount: 3,
          onPageChanged: (i) => setState(() => _cur = i),
          itemBuilder: (_, i) => _CapPage(cap: captains[i]))),
        Padding(padding: const EdgeInsets.fromLTRB(16,0,16,14),
          child: Row(children: [
            _Arr(icon: Icons.chevron_left_rounded,
              color: _cur>0 ? cap.color : Colors.white12,
              onTap: _cur>0 ? ()=>_go(-1) : null),
            const SizedBox(width: 10),
            Expanded(child: GestureDetector(
              onTap: () => Navigator.pushReplacement(ctx,
                MaterialPageRoute(builder: (_) =>
                  GameScreen(captain: captains[_cur]))),
              child: Container(height: 52,
                decoration: BoxDecoration(
                  color: cap.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cap.color, width: 2),
                  boxShadow: [BoxShadow(
                    color: cap.color.withOpacity(0.22), blurRadius: 14)]),
                child: Center(child: Text('DESPLEGAR — ${captains[_cur].name}',
                  style: TextStyle(color: cap.color, fontSize: 14,
                    fontWeight: FontWeight.bold, letterSpacing: 3,
                    fontFamily: 'monospace')))))),
            const SizedBox(width: 10),
            _Arr(icon: Icons.chevron_right_rounded,
              color: _cur<2 ? cap.color : Colors.white12,
              onTap: _cur<2 ? ()=>_go(1) : null),
          ])),
      ])));
  }
}

class _CapPage extends StatelessWidget {
  final CaptainData cap;
  const _CapPage({required this.cap});
  @override Widget build(BuildContext ctx) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    child: Column(children: [
      Expanded(flex: 5, child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cap.color.withOpacity(0.4), width: 2),
          boxShadow: [BoxShadow(color: cap.color.withOpacity(0.14),
            blurRadius: 22)]),
        child: ClipRRect(borderRadius: BorderRadius.circular(18),
          child: Image.asset(cap.imagePath, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: cap.color.withOpacity(0.08),
              child: Center(child: Text(cap.emoji,
                style: const TextStyle(fontSize: 72)))))))),
      Expanded(flex: 4, child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: cPanel,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cap.color.withOpacity(0.28), width: 1.5)),
        child: SingleChildScrollView(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(cap.name, style: TextStyle(color: cap.color, fontSize: 21,
              fontWeight: FontWeight.bold, fontFamily: 'monospace')),
            const SizedBox(width: 8),
            Text('· ${cap.title}', style: TextStyle(
              color: cap.color.withOpacity(0.6), fontSize: 11,
              fontStyle: FontStyle.italic)),
          ]),
          const SizedBox(height: 7),
          Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: cap.color.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cap.color.withOpacity(0.22))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(cap.ability, style: TextStyle(color: cap.color,
                fontSize: 13, fontWeight: FontWeight.bold,
                fontFamily: 'monospace')),
              const SizedBox(height: 3),
              Text(cap.abilityDesc, style: const TextStyle(
                color: Colors.white70, fontSize: 11, height: 1.5)),
            ])),
          const SizedBox(height: 8),
          ...[['DAÑO',cap.damage/1.8],['VELOCIDAD',cap.speed/1.5],
              ['CASCO',cap.hullMax/150]].map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(children: [
              SizedBox(width: 70, child: Text(s[0] as String,
                style: const TextStyle(color: Colors.white38, fontSize: 9,
                  fontFamily: 'monospace'))),
              Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: (s[1] as double).clamp(0.0,1.0), minHeight: 5,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation(cap.color)))),
            ]))),
          const SizedBox(height: 5),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('⚠ ', style: TextStyle(fontSize: 11)),
            Expanded(child: Text(cap.tradeoff, style: const TextStyle(
              color: Colors.orange, fontSize: 11,
              fontStyle: FontStyle.italic))),
          ]),
        ])))),
      const SizedBox(height: 6),
    ]));
}

class _Arr extends StatelessWidget {
  final IconData icon; final Color color; final VoidCallback? onTap;
  const _Arr({required this.icon, required this.color, this.onTap});
  @override Widget build(BuildContext ctx) => GestureDetector(onTap: onTap,
    child: Container(width: 44, height: 52,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5)),
      child: Icon(icon, color: color, size: 26)));
}

// ═══════════════════════════════════════════════════════════════════════════
//  GAME SCREEN — FPS ESTILO DOOM
// ═══════════════════════════════════════════════════════════════════════════
class GameScreen extends StatefulWidget {
  final CaptainData captain;
  const GameScreen({super.key, required this.captain});
  @override State<GameScreen> createState() => _GS();
}

class _GS extends State<GameScreen> with TickerProviderStateMixin {

  // Estado jugador
  late double hull;
  double abilityCharge = 0;
  bool abilityActive = false;
  double abilityTimer = 0;
  int score = 0;

  // Enemigos — cada uno tiene posición en "mundo" -1..1 horizontal, distancia 0..1
  final List<_Mob> _mobs = [];
  double _spawnT = 0;
  int _killed = 0;
  bool _bossSpawned = false;
  _BossData? _boss;

  // Disparo
  double _shootCD = 0;
  double _muzzle = 0; // flash de disparo

  // Daño recibido
  double _hitFlash = 0;

  // Impactos visuales en pantalla
  final List<_Hit> _hits = [];

  // Proyectiles del boss
  final List<_BossProj> _bossProjs = [];

  late AnimationController _loop;
  final _rng = Random();
  double _prev = 0;

  @override void initState() {
    super.initState();
    hull = widget.captain.hullMax / 150.0;
    _loop = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 16))
      ..addListener(_tick)..repeat();
  }
  @override void dispose() { _loop.dispose(); super.dispose(); }

  // ── TICK ──────────────────────────────────────────────────────────────────
  void _tick() {
    final now = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final dt = _prev == 0 ? 0.016 : (now - _prev).clamp(0.0, 0.05);
    _prev = now;

    // Habilidad
    if (!abilityActive) abilityCharge = (abilityCharge + dt*0.055).clamp(0,1);
    if (abilityActive) { abilityTimer -= dt;
      if (abilityTimer <= 0) { abilityActive = false; abilityCharge = 0; } }

    // Disparo CD
    _shootCD = (_shootCD - dt).clamp(-1, 10);

    // Muzzle flash decay
    if (_muzzle > 0) _muzzle = (_muzzle - dt*6).clamp(0,1);
    if (_hitFlash > 0) _hitFlash = (_hitFlash - dt*3).clamp(0,1);

    // Hits decay
    for (final h in _hits) h.life -= dt*2;
    _hits.removeWhere((h) => h.life <= 0);

    // Spawn enemigos
    if (!_bossSpawned) {
      _spawnT -= dt;
      if (_spawnT <= 0 && _killed < 20) {
        _spawnT = 1.8 - (score/5000).clamp(0, 1.0);
        _mobs.add(_Mob(
          // posición horizontal aleatoria en el "mundo" -0.8..0.8
          wx: (_rng.nextDouble() * 1.6) - 0.8,
          dist: 0.02, // empieza lejos (pequeño)
          speed: 0.06 + _rng.nextDouble() * 0.05,
          hp: 2.0, type: _rng.nextInt(3)));
      }
      // Mover enemigos — se acercan (dist crece → se ven más grandes)
      for (final m in _mobs) {
        m.dist += dt * m.speed;
        // Movimiento lateral ondulante
        m.wx += sin(m.dist * 5 + m.phase) * dt * 0.08;
        m.wx = m.wx.clamp(-0.95, 0.95);
        // Si llega muy cerca → daño al jugador
        if (m.dist >= 1.0) {
          hull = (hull - 0.07).clamp(0, 1);
          _hitFlash = 1.0;
          m.dead = true;
        }
      }
      _mobs.removeWhere((m) => m.dead);
      if (_killed >= 20 && !_bossSpawned) {
        _bossSpawned = true;
        _boss = _BossData();
      }
    }

    // Boss
    if (_boss != null && !_boss!.dead) {
      _boss!.t += dt;
      _boss!.wx += sin(_boss!.t * 0.7) * dt * 0.06;
      _boss!.wx = _boss!.wx.clamp(-0.6, 0.6);
      // Boss siempre a dist media-fija, se mueve lateral
      _boss!.atkT -= dt;
      if (_boss!.atkT <= 0) {
        _boss!.atkT = 2.8;
        _bossProjs.add(_BossProj(sx: _boss!.wx));
      }
    }

    // Proyectiles boss
    for (final p in _bossProjs) {
      p.life -= dt * 0.6;
      p.sy += dt * 0.5; // bajan en pantalla
    }
    _bossProjs.removeWhere((p) {
      if (p.life <= 0) return true;
      if (p.sy >= 0.85) { // impacto
        hull = (hull - 0.09).clamp(0, 1);
        _hitFlash = 1.0;
        return true;
      }
      return false;
    });

    setState(() {});
  }

  // ── DISPARO ────────────────────────────────────────────────────────────────
  void _fireAt(double sx, double sy, Size size) {
    if (_shootCD > 0) return;
    final cadMult = (abilityActive && widget.captain.id == Captain.andy)
        ? 0.5 : 1.0;
    _shootCD = 0.22 * cadMult / widget.captain.speed;
    _muzzle = 1.0;

    // Convertir toque a coordenadas de mundo normalizadas
    final normX = (sx / size.width - 0.5) * 2; // -1..1
    final normY = sy / size.height;             // 0..1

    // Verificar impacto en enemigos
    bool hit = false;
    for (final m in _mobs.toList()) {
      // Proyección del enemigo en pantalla
      final screenX = _mobScreenX(m, size);
      final screenY = _mobScreenY(m, size);
      final mobSize = _mobSize(m, size);
      if ((sx - screenX).abs() < mobSize * 0.55 &&
          (sy - screenY).abs() < mobSize * 0.55) {
        m.hp -= widget.captain.damage;
        _hits.add(_Hit(x: sx/size.width, y: sy/size.height));
        hit = true;
        if (m.hp <= 0) {
          m.dead = true; _killed++; score += 100;
        }
        break;
      }
    }

    // Impacto en boss
    if (!hit && _boss != null && !_boss!.dead) {
      final bsx = _bossScreenX(_boss!, size);
      final bsy = _bossScreenY(size);
      final bs = _bossSize(size);
      if ((sx - bsx).abs() < bs * 0.55 && (sy - bsy).abs() < bs * 0.45) {
        _boss!.hp -= widget.captain.damage;
        _hits.add(_Hit(x: sx/size.width, y: sy/size.height));
        score += 10;
        if (_boss!.hp <= 0) {
          _boss!.dead = true; score += 5000;
        }
      }
    }
  }

  // ── Proyección pseudo-3D ────────────────────────────────────────────────
  // dist 0..1 = lejos..cerca
  double _mobScreenX(_Mob m, Size sz) =>
    sz.width/2 + m.wx * sz.width * 0.45 * (0.3 + m.dist * 0.9);

  double _mobScreenY(_Mob m, Size sz) =>
    sz.height * (0.25 + m.dist * 0.35); // sube en pantalla al acercarse

  double _mobSize(_Mob m, Size sz) =>
    (20 + m.dist * 200).clamp(20, 220); // crece mucho al acercarse

  double _bossScreenX(_BossData b, Size sz) =>
    sz.width/2 + b.wx * sz.width * 0.35;

  double _bossScreenY(Size sz) => sz.height * 0.28;

  double _bossSize(Size sz) => sz.width * 0.45;

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override Widget build(BuildContext ctx) {
    final cap = widget.captain;
    final sz = MediaQuery.of(ctx).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (d) => _fireAt(d.localPosition.dx, d.localPosition.dy, sz),
        child: Stack(children: [

          // ── FONDO COMPLETO ───────────────────────────────────────────
          Positioned.fill(child: Image.asset('assets/images/bg_stage1.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF020810)))),

          // Overlay oscuro sutil
          Positioned.fill(child:
            Container(color: Colors.black.withOpacity(0.28))),

          // ── ENEMIGOS (pseudo-3D, se ven más grandes al acercarse) ────
          for (final m in _mobs) ...[
            Positioned(
              left: _mobScreenX(m, sz) - _mobSize(m, sz)/2,
              top:  _mobScreenY(m, sz) - _mobSize(m, sz)/2,
              child: _MobWidget(m: m,
                size: _mobSize(m, sz), capColor: cap.color)),
          ],

          // ── BOSS ─────────────────────────────────────────────────────
          if (_boss != null && !_boss!.dead) ...[
            Positioned(
              left: _bossScreenX(_boss!, sz) - _bossSize(sz)/2,
              top:  _bossScreenY(sz) - _bossSize(sz)*0.4,
              child: _BossWidget2(boss: _boss!, size: _bossSize(sz))),
            // Barra HP boss
            Positioned(top: 90, left: 30, right: 30,
              child: Column(children: [
                const Text('⚠ COMANDANTE ALIENÍGENA',
                  style: TextStyle(color: cRed, fontSize: 9,
                    fontFamily: 'monospace', letterSpacing: 1,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
                const SizedBox(height: 3),
                ClipRRect(borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: (_boss!.hp/50).clamp(0,1), minHeight: 7,
                    backgroundColor: Colors.black38,
                    valueColor: const AlwaysStoppedAnimation(cRed))),
              ])),
          ],

          // Boss muerto
          if (_boss != null && _boss!.dead)
            Center(child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('SECTOR LIMPIO', style: TextStyle(color: cap.color,
                  fontSize: 26, fontFamily: 'monospace',
                  fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('DESCENDIENDO A LA NAVE...',
                  style: TextStyle(color: Colors.white60, fontSize: 13,
                    fontFamily: 'monospace')),
              ]))),

          // ── PROYECTILES BOSS (caen desde arriba) ─────────────────────
          for (final p in _bossProjs)
            Positioned(
              left: sz.width/2 + p.sx * sz.width * 0.35 - 10,
              top: p.sy * sz.height - 10,
              child: Container(width: 20, height: 20,
                decoration: BoxDecoration(color: cFire,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: cFire.withOpacity(0.8),
                    blurRadius: 12, spreadRadius: 2)]))),

          // ── MARCAS DE IMPACTO ─────────────────────────────────────────
          for (final h in _hits)
            Positioned(
              left: h.x * sz.width - 12, top: h.y * sz.height - 12,
              child: Opacity(opacity: h.life,
                child: Container(width: 24, height: 24,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    color: Colors.white.withOpacity(0.3))))),

          // ── MIRA CENTRAL FIJA ─────────────────────────────────────────
          Center(child: CustomPaint(size: const Size(52, 52),
            painter: _Crosshair(color: cap.color, active: abilityActive))),

          // ── ARMA EN PRIMERA PERSONA ───────────────────────────────────
          Positioned(bottom: 0, left: 0, right: 0,
            child: Stack(alignment: Alignment.bottomRight, children: [
              Image.asset('assets/images/weapon_fp.png',
                width: sz.width * 0.75,
                height: sz.height * 0.28,
                fit: BoxFit.contain,
                alignment: Alignment.bottomRight,
                errorBuilder: (_, __, ___) =>
                  CustomPaint(size: Size(sz.width*0.65, sz.height*0.22),
                    painter: _FallbackGun(color: cap.color))),
              // Muzzle flash
              if (_muzzle > 0)
                Positioned(top: 0, right: sz.width * 0.18,
                  child: Container(width: 50, height: 50,
                    decoration: BoxDecoration(shape: BoxShape.circle,
                      color: Colors.white.withOpacity(_muzzle * 0.85),
                      boxShadow: [BoxShadow(
                        color: cap.color.withOpacity(_muzzle),
                        blurRadius: 35, spreadRadius: 12)]))),
            ])),

          // ── HIT FLASH (daño) ──────────────────────────────────────────
          if (_hitFlash > 0)
            Positioned.fill(child: Container(
              color: cRed.withOpacity(_hitFlash * 0.38))),

          // ── HUD ───────────────────────────────────────────────────────
          Positioned(top: 46, left: 14,
            child: _HUD(label: 'HULL', value: hull,
              color: hull > 0.5 ? cIce : hull > 0.25 ? cGold : cRed,
              width: 110)),
          Positioned(top: 46, right: 14,
            child: _HUDRight(label: cap.ability, value: abilityCharge,
              color: abilityActive ? Colors.white : cap.color)),
          Positioned(top: 50, left: 0, right: 0,
            child: Center(child: Text('STAGE 1 · TECHO DE NAVE ALIENÍGENA',
              style: TextStyle(color: Colors.white.withOpacity(0.3),
                fontSize: 8, fontFamily: 'monospace', letterSpacing: 2,
                shadows: const [Shadow(color: Colors.black, blurRadius: 4)])))),

          // Score y bajas
          Positioned(bottom: sz.height*0.30, left: 14,
            child: Text('SCORE ${score.toString().padLeft(6,'0')}',
              style: const TextStyle(color: Colors.white54, fontSize: 11,
                fontFamily: 'monospace',
                shadows: [Shadow(color: Colors.black, blurRadius: 4)]))),
          if (!_bossSpawned)
            Positioned(bottom: sz.height*0.30, right: 14,
              child: Text('BAJAS: $_killed/20',
                style: TextStyle(color: cap.color.withOpacity(0.6),
                  fontSize: 10, fontFamily: 'monospace',
                  shadows: const [Shadow(color: Colors.black,
                    blurRadius: 4)]))),

          // Casco crítico
          if (hull < 0.15)
            Positioned(top: sz.height*0.30, left: 0, right: 0,
              child: Center(child: Text('⚠ CASCO CRÍTICO ⚠',
                style: TextStyle(color: cRed.withOpacity(0.95),
                  fontSize: 16, fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  shadows: const [Shadow(color: Colors.black,
                    blurRadius: 6)])))),

          // Botón habilidad
          Positioned(bottom: sz.height*0.29, right: 14,
            child: GestureDetector(onTap: _activateAbility,
              child: Container(width: 60, height: 60,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  color: abilityCharge >= 1.0
                    ? cap.color.withOpacity(0.25) : Colors.black54,
                  border: Border.all(
                    color: abilityActive ? Colors.white :
                      abilityCharge >= 1.0 ? cap.color : Colors.white24,
                    width: 2)),
                child: Center(child: Text(cap.emoji,
                  style: const TextStyle(fontSize: 22)))))),

          // Pausa
          Positioned(top: 42, right: 58,
            child: GestureDetector(onTap: () => _pause(ctx),
              child: Container(width: 34, height: 34,
                decoration: BoxDecoration(color: Colors.black45,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24)),
                child: const Icon(Icons.pause,
                  color: Colors.white54, size: 16)))),
        ])));
  }

  void _activateAbility() {
    if (abilityCharge < 1.0 || abilityActive) return;
    setState(() {
      abilityActive = true;
      abilityTimer = switch(widget.captain.id) {
        Captain.danny => 8.0, Captain.andy => 5.0, Captain.denise => 3.0,
      };
    });
  }

  void _pause(BuildContext ctx) => showDialog(
    context: ctx, barrierColor: Colors.black54,
    builder: (_) => AlertDialog(
      backgroundColor: cPanel,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),
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

// ── Widgets de enemigo/boss ────────────────────────────────────────────────
class _MobWidget extends StatelessWidget {
  final _Mob m; final double size; final Color capColor;
  const _MobWidget({required this.m, required this.size, required this.capColor});
  @override Widget build(BuildContext ctx) {
    final opacity = (m.hp / 2).clamp(0.25, 1.0);
    return Opacity(opacity: opacity,
      child: SizedBox(width: size, height: size,
        child: Image.asset('assets/images/enemy_type${m.type}.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Container(
            width: size, height: size,
            decoration: BoxDecoration(
              color: [const Color(0xFF44FF88), cRed,
                const Color(0xFFCC8833)][m.type].withOpacity(0.75),
              shape: BoxShape.circle)))));
  }
}

class _BossWidget2 extends StatelessWidget {
  final _BossData boss; final double size;
  const _BossWidget2({required this.boss, required this.size});
  @override Widget build(BuildContext ctx) => Stack(
    alignment: Alignment.center, children: [
    // Glow
    Container(width: size, height: size*0.8,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(size/2),
        boxShadow: [BoxShadow(color: cRed.withOpacity(0.5),
          blurRadius: 40, spreadRadius: 15)])),
    Image.asset('assets/images/enemy_boss_s1.png',
      width: size, height: size*0.8, fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Container(
        width: size*0.6, height: size*0.6,
        decoration: BoxDecoration(color: cRed.withOpacity(0.85),
          shape: BoxShape.circle))),
  ]);
}

// ── HUD widgets ────────────────────────────────────────────────────────────
class _HUD extends StatelessWidget {
  final String label; final double value;
  final Color color; final double width;
  const _HUD({required this.label, required this.value,
    required this.color, required this.width});
  @override Widget build(BuildContext ctx) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: TextStyle(color: color.withOpacity(0.7),
      fontSize: 8, fontFamily: 'monospace',
      shadows: const [Shadow(color: Colors.black, blurRadius: 4)])),
    const SizedBox(height: 3),
    SizedBox(width: width, height: 6, child: ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(value: value.clamp(0.0,1.0),
        backgroundColor: Colors.black38,
        valueColor: AlwaysStoppedAnimation(color)))),
  ]);
}

class _HUDRight extends StatelessWidget {
  final String label; final double value; final Color color;
  const _HUDRight({required this.label, required this.value,
    required this.color});
  @override Widget build(BuildContext ctx) => Column(
    crossAxisAlignment: CrossAxisAlignment.end, children: [
    Text(label, style: TextStyle(color: color,
      fontSize: 8, fontFamily: 'monospace',
      shadows: const [Shadow(color: Colors.black, blurRadius: 4)])),
    const SizedBox(height: 3),
    SizedBox(width: 80, height: 5, child: ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: LinearProgressIndicator(value: value.clamp(0.0,1.0),
        backgroundColor: Colors.black38,
        valueColor: AlwaysStoppedAnimation(color)))),
  ]);
}

// ═══════════════════════════════════════════════════════════════════════════
//  MODELOS DE DATOS
// ═══════════════════════════════════════════════════════════════════════════
class _Mob {
  double wx, dist, speed, hp; final int type;
  final double phase = Random().nextDouble() * pi * 2;
  bool dead = false;
  _Mob({required this.wx, required this.dist, required this.speed,
    required this.hp, required this.type});
}

class _BossData {
  double wx = 0, t = 0, atkT = 3.0, hp = 50;
  bool dead = false;
}

class _BossProj {
  double sx, sy; double life = 1.0;
  _BossProj({required this.sx}) : sy = 0.05;
}

class _Hit {
  double x, y; double life = 1.0;
  _Hit({required this.x, required this.y});
}

// ═══════════════════════════════════════════════════════════════════════════
//  PAINTERS
// ═══════════════════════════════════════════════════════════════════════════
class _Crosshair extends CustomPainter {
  final Color color; final bool active;
  const _Crosshair({required this.color, required this.active});
  @override void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = color.withOpacity(active ? 1.0 : 0.85)
      ..strokeWidth = active ? 2.0 : 1.5;
    final cx = s.width/2, cy = s.height/2;
    // Líneas
    canvas.drawLine(Offset(0, cy), Offset(cx-12, cy), p);
    canvas.drawLine(Offset(cx+12, cy), Offset(s.width, cy), p);
    canvas.drawLine(Offset(cx, 0), Offset(cx, cy-12), p);
    canvas.drawLine(Offset(cx, cy+12), Offset(cx, s.height), p);
    // Círculo
    canvas.drawCircle(Offset(cx, cy), active ? 6 : 4,
      Paint()..color = color.withOpacity(0.9)
        ..style = PaintingStyle.stroke..strokeWidth = 1.5);
    // Punto central
    canvas.drawCircle(Offset(cx, cy), 1.5,
      Paint()..color = color..style = PaintingStyle.fill);
  }
  @override bool shouldRepaint(_) => true;
}

class _FallbackGun extends CustomPainter {
  final Color color;
  const _FallbackGun({required this.color});
  @override void paint(Canvas canvas, Size s) {
    final p = Paint()..color = color.withOpacity(0.55)..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromLTRBR(s.width*0.05, s.height*0.35,
      s.width*0.92, s.height*0.68, const Radius.circular(6)), p);
    canvas.drawRRect(RRect.fromLTRBR(s.width*0.55, s.height*0.22,
      s.width*0.96, s.height*0.42, const Radius.circular(4)), p);
    final gp = Paint()..color = Colors.grey.shade700;
    canvas.drawRRect(RRect.fromLTRBR(s.width*0.15, s.height*0.62,
      s.width*0.42, s.height*1.0, const Radius.circular(10)), gp);
    canvas.drawRRect(RRect.fromLTRBR(s.width*0.5, s.height*0.62,
      s.width*0.72, s.height*1.0, const Radius.circular(10)), gp);
  }
  @override bool shouldRepaint(_) => false;
}
