import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

// ── Audio (audioplayers) ────────────────────────────────────────────────────
// pubspec.yaml necesita:
//   audioplayers: ^5.2.1
// ────────────────────────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (d) => FlutterError.presentError(d);
  runZonedGuarded(() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    runApp(const PC2App());
  }, (e, s) {
    runApp(MaterialApp(home: Scaffold(backgroundColor: Colors.black,
      body: Center(child: Padding(padding: const EdgeInsets.all(20),
        child: Text('ERROR:\n$e\n$s',
          style: const TextStyle(color: Colors.red, fontSize: 9,
            fontFamily: 'monospace')))))));
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
class _SplashState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1500));
    _fade = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.pushReplacement(context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const CaptainSelectScreen(),
          transitionDuration: const Duration(milliseconds: 800),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c)));
    });
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override Widget build(BuildContext ctx) => Scaffold(
    backgroundColor: Colors.black,
    body: FadeTransition(opacity: _fade, child: Stack(fit: StackFit.expand, children: [
      Image.asset('assets/images/splash.png', fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: Colors.black,
          child: const Center(child: Text('PHOENIX CORE II',
            style: TextStyle(color: Color(0xFFFF6600), fontSize: 32,
              fontWeight: FontWeight.bold, fontFamily: 'monospace'))))),
      Container(color: Colors.black.withOpacity(0.35)),
      Positioned(bottom: 60, left: 0, right: 0, child: Column(children: [
        const Text('UCC v7.3 · ALTEA-GARAY',
          style: TextStyle(color: Colors.white38, fontSize: 11,
            fontFamily: 'monospace', letterSpacing: 3)),
        const SizedBox(height: 16),
        SizedBox(width: 40, height: 40,
          child: CircularProgressIndicator(strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(
              const Color(0xFFFF6600).withOpacity(0.7)))),
      ])),
    ])));
}

// ═══════════════════════════════════════════════════════════════════════════
//  DATOS CAPITANES
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
    emoji: '🪖', imagePath: 'assets/images/dany.png',
    ability: 'MODO FÉNIX',
    abilityDesc: 'Anticipa el peligro 90ms antes.\nVentana de daño máximo en boss.\nUn disparo preciso vale por diez.',
    tradeoff: 'Cadencia lenta — necesita timing perfecto',
    color: cGold, damage: 1.8, speed: 0.75, hullMax: 120),
  CaptainData(id: Captain.andy, name: 'ANDY', title: 'El Impulsivo',
    emoji: '⚡', imagePath: 'assets/images/andy.png',
    ability: 'MODO KALMAN',
    abilityDesc: 'Estabiliza la realidad local.\nCadencia x2 en zona de calor.\nEl caos es tu combustible.',
    tradeoff: 'Hull baja 2x más rápido — frágil',
    color: cIce, damage: 1.0, speed: 1.5, hullMax: 70),
  CaptainData(id: Captain.denise, name: 'DENISE', title: 'La Guardiana',
    emoji: '🛡️', imagePath: 'assets/images/denisse.png',
    ability: 'WATCH DOG',
    abilityDesc: 'Teletransporte de emergencia\ncuando hull < 15%.\nNadie la derriba — solo se cansa.',
    tradeoff: 'Menor daño base — solo brilla sobreviviendo',
    color: cPurple, damage: 0.8, speed: 1.0, hullMax: 150),
];

// ═══════════════════════════════════════════════════════════════════════════
//  SELECCIÓN DE CAPITÁN
// ═══════════════════════════════════════════════════════════════════════════
class CaptainSelectScreen extends StatefulWidget {
  const CaptainSelectScreen({super.key});
  @override State<CaptainSelectScreen> createState() => _SelectState();
}
class _SelectState extends State<CaptainSelectScreen> with TickerProviderStateMixin {
  final PageController _page = PageController();
  int _cur = 0;
  late AnimationController _pulse;

  @override void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this,
        duration: const Duration(seconds: 2))..repeat(reverse: true);
  }
  @override void dispose() { _pulse.dispose(); _page.dispose(); super.dispose(); }

  void _go(int d) => _page.animateToPage((_cur + d).clamp(0, 2),
    duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);

  @override Widget build(BuildContext ctx) {
    final cap = captains[_cur];
    return Scaffold(backgroundColor: cBg, body: SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(20,20,20,0), child: Column(children: [
        AnimatedBuilder(animation: _pulse, builder: (_, __) =>
          Text('PHOENIX CORE II', style: TextStyle(color: cap.color, fontSize: 22,
            fontWeight: FontWeight.bold, letterSpacing: 4, fontFamily: 'monospace',
            shadows: [Shadow(color: cap.color.withOpacity(0.4 + 0.3 * _pulse.value),
              blurRadius: 12)]))),
        const SizedBox(height: 4),
        const Text('"No puedes ganarte a ti mismo siendo tú mismo"',
          style: TextStyle(color: Colors.white38, fontSize: 10,
            fontStyle: FontStyle.italic)),
      ])),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == _cur ? 18 : 7, height: 7,
          decoration: BoxDecoration(
            color: i == _cur ? cap.color : Colors.white24,
            borderRadius: BorderRadius.circular(4))))),
      const SizedBox(height: 10),
      Expanded(child: PageView.builder(
        controller: _page, itemCount: 3,
        onPageChanged: (i) => setState(() => _cur = i),
        itemBuilder: (_, i) => _CapPage(cap: captains[i]))),
      Padding(padding: const EdgeInsets.fromLTRB(20,0,20,16),
        child: Row(children: [
          _Arrow(icon: Icons.chevron_left_rounded,
            color: _cur > 0 ? cap.color : Colors.white12,
            onTap: _cur > 0 ? () => _go(-1) : null),
          const SizedBox(width: 12),
          Expanded(child: GestureDetector(
            onTap: () => Navigator.pushReplacement(ctx,
              MaterialPageRoute(builder: (_) =>
                PC2GameScreen(captain: captains[_cur]))),
            child: Container(height: 54,
              decoration: BoxDecoration(
                color: cap.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cap.color, width: 2),
                boxShadow: [BoxShadow(color: cap.color.withOpacity(0.25),
                  blurRadius: 16)]),
              child: Center(child: Text('DESPLEGAR — ${captains[_cur].name}',
                style: TextStyle(color: cap.color, fontSize: 14,
                  fontWeight: FontWeight.bold, letterSpacing: 3,
                  fontFamily: 'monospace')))))),
          const SizedBox(width: 12),
          _Arrow(icon: Icons.chevron_right_rounded,
            color: _cur < 2 ? cap.color : Colors.white12,
            onTap: _cur < 2 ? () => _go(1) : null),
        ])),
    ])));
  }
}

class _CapPage extends StatelessWidget {
  final CaptainData cap;
  const _CapPage({required this.cap});
  @override Widget build(BuildContext ctx) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(children: [
      Expanded(flex: 5, child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cap.color.withOpacity(0.4), width: 2),
          boxShadow: [BoxShadow(color: cap.color.withOpacity(0.15), blurRadius: 24)]),
        child: ClipRRect(borderRadius: BorderRadius.circular(18),
          child: Image.asset(cap.imagePath, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: cap.color.withOpacity(0.08),
              child: Center(child: Text(cap.emoji,
                style: const TextStyle(fontSize: 72)))))))),
      Expanded(flex: 4, child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: cPanel,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cap.color.withOpacity(0.3), width: 1.5)),
        child: SingleChildScrollView(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(cap.name, style: TextStyle(color: cap.color, fontSize: 22,
              fontWeight: FontWeight.bold, fontFamily: 'monospace')),
            const SizedBox(width: 10),
            Text('· ${cap.title}', style: TextStyle(
              color: cap.color.withOpacity(0.6), fontSize: 12,
              fontStyle: FontStyle.italic)),
          ]),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: cap.color.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cap.color.withOpacity(0.25))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(cap.ability, style: TextStyle(color: cap.color, fontSize: 13,
                fontWeight: FontWeight.bold, fontFamily: 'monospace')),
              const SizedBox(height: 4),
              Text(cap.abilityDesc, style: const TextStyle(
                color: Colors.white70, fontSize: 11, height: 1.5)),
            ])),
          const SizedBox(height: 10),
          ...[['DAÑO', cap.damage/1.8], ['VELOCIDAD', cap.speed/1.5],
              ['CASCO', cap.hullMax/150]].map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(children: [
              SizedBox(width: 72, child: Text(s[0] as String,
                style: const TextStyle(color: Colors.white38, fontSize: 9,
                  fontFamily: 'monospace'))),
              Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: (s[1] as double).clamp(0.0, 1.0), minHeight: 5,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation(cap.color)))),
            ]))),
          const SizedBox(height: 6),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('⚠ ', style: TextStyle(fontSize: 12)),
            Expanded(child: Text(cap.tradeoff, style: const TextStyle(
              color: Colors.orange, fontSize: 11, fontStyle: FontStyle.italic))),
          ]),
        ])))),
      const SizedBox(height: 8),
    ]));
}

class _Arrow extends StatelessWidget {
  final IconData icon; final Color color; final VoidCallback? onTap;
  const _Arrow({required this.icon, required this.color, this.onTap});
  @override Widget build(BuildContext ctx) => GestureDetector(onTap: onTap,
    child: Container(width: 46, height: 54,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5)),
      child: Icon(icon, color: color, size: 28)));
}

// ═══════════════════════════════════════════════════════════════════════════
//  GAME SCREEN — PRIMERA PERSONA
// ═══════════════════════════════════════════════════════════════════════════
class PC2GameScreen extends StatefulWidget {
  final CaptainData captain;
  const PC2GameScreen({super.key, required this.captain});
  @override State<PC2GameScreen> createState() => _GameState();
}

class _GameState extends State<PC2GameScreen> with TickerProviderStateMixin {

  // ── Estado jugador ───────────────────────────────────────────────────────
  late double hull;
  double abilityCharge = 0.0;
  bool abilityActive = false;
  double abilityTimer = 0;
  int score = 0;

  // ── Mira (posición normalizada) ─────────────────────────────────────────
  Offset _aim = const Offset(0.5, 0.4);

  // ── Balas ────────────────────────────────────────────────────────────────
  final List<_Bullet> _bullets = [];
  double _shootCD = 0;

  // ── Flash de disparo ──────────────────────────────────────────────────────
  double _muzzleFlash = 0;

  // ── Enemigos ─────────────────────────────────────────────────────────────
  final List<_Enemy> _enemies = [];
  double _spawnT = 0;
  int _killed = 0;
  bool _bossSpawned = false;
  _Boss? _boss;

  // ── Explosiones ───────────────────────────────────────────────────────────
  final List<_Expl> _expls = [];

  // ── Daño recibido (screen flash) ─────────────────────────────────────────
  double _hitFlash = 0;

  // ── Audio simple con pool ─────────────────────────────────────────────────
  // Usamos método nativo básico — sin dependencia externa
  // Los sonidos se reproducen vía AudioPool si audioplayers está disponible
  // Si no, se ignoran silenciosamente.

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
    _tickAbility(dt);
    _tickBullets(dt);
    _tickEnemies(dt);
    _tickBoss(dt);
    _checkHits();
    _tickExpls(dt);
    if (_muzzleFlash > 0) _muzzleFlash = (_muzzleFlash - dt * 8).clamp(0, 1);
    if (_hitFlash > 0)    _hitFlash    = (_hitFlash    - dt * 4).clamp(0, 1);
    setState(() {});
  }

  void _tickAbility(double dt) {
    if (!abilityActive) abilityCharge = (abilityCharge + dt * 0.055).clamp(0, 1);
    if (abilityActive) {
      abilityTimer -= dt;
      if (abilityTimer <= 0) { abilityActive = false; abilityCharge = 0; }
    }
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

  // ── Disparo ───────────────────────────────────────────────────────────────
  void _shoot(Offset worldPos) {
    if (_shootCD > 0) return;
    final cadMult = (abilityActive && widget.captain.id == Captain.andy) ? 0.5 : 1.0;
    _shootCD = 0.20 * cadMult / widget.captain.speed;
    // Bala desde la mira hacia el punto tocado (en coordenadas de mundo 0..1)
    _bullets.add(_Bullet(x: _aim.dx, y: _aim.dy,
      vx: (worldPos.dx - _aim.dx) * 1.5,
      vy: (worldPos.dy - _aim.dy) * 1.5 - 0.8,
      dmg: widget.captain.damage));
    _muzzleFlash = 1.0;
  }

  void _tickBullets(double dt) {
    _shootCD -= dt;
    for (final b in _bullets) { b.x += b.vx * dt; b.y += b.vy * dt; }
    _bullets.removeWhere((b) => b.y < -0.1 || b.x < 0 || b.x > 1);
  }

  // ── Enemigos ──────────────────────────────────────────────────────────────
  void _tickEnemies(double dt) {
    if (_bossSpawned) return;
    _spawnT -= dt;
    if (_spawnT <= 0 && _killed < 20) {
      _spawnT = 1.5 - (score / 5000).clamp(0, 0.9);
      // Los enemigos aparecen en la mitad superior de la pantalla
      _enemies.add(_Enemy(
        x: 0.1 + _rng.nextDouble() * 0.8,
        y: 0.05 + _rng.nextDouble() * 0.35,
        vy: 0.04 + _rng.nextDouble() * 0.04,
        hp: 2.0, type: _rng.nextInt(3)));
    }
    for (final e in _enemies) {
      e.y += dt * e.vy;
      e.x += sin(e.y * 6 + e.phase) * dt * 0.03;
      e.x = e.x.clamp(0.05, 0.95);
      // Si llega al jugador (zona baja) hace daño
      if (e.y > 0.78) {
        hull = (hull - 0.06).clamp(0, 1);
        _hitFlash = 1.0;
        e.dead = true;
      }
    }
    _enemies.removeWhere((e) => e.dead);
    if (_killed >= 20 && !_bossSpawned) {
      _bossSpawned = true;
      _boss = _Boss(x: 0.5, y: 0.15);
    }
  }

  void _tickBoss(double dt) {
    if (_boss == null || _boss!.dead) return;
    _boss!.t += dt;
    _boss!.x += sin(_boss!.t * 0.9) * dt * 0.08;
    _boss!.x = _boss!.x.clamp(0.15, 0.85);
    _boss!.atkT -= dt;
    if (_boss!.atkT <= 0) {
      _boss!.atkT = 2.5;
      _boss!.projs.add(_Proj(x: _boss!.x, y: _boss!.y + 0.1));
    }
    for (final p in _boss!.projs) p.y += dt * 0.20;
    _boss!.projs.removeWhere((p) {
      if (p.y > 0.80) {
        hull = (hull - 0.09).clamp(0, 1);
        _hitFlash = 1.0;
        return true;
      }
      return p.y > 1.0;
    });
  }

  // ── Colisiones ────────────────────────────────────────────────────────────
  void _checkHits() {
    final remB = <_Bullet>{};
    final remE = <_Enemy>{};
    for (final b in _bullets) {
      for (final e in _enemies) {
        if ((b.x - e.x).abs() < 0.07 && (b.y - e.y).abs() < 0.07) {
          e.hp -= b.dmg; remB.add(b);
          if (e.hp <= 0) {
            e.dead = true; remE.add(e);
            _killed++; score += 100;
            _expls.add(_Expl(x: e.x, y: e.y));
          }
          break;
        }
      }
      if (_boss != null && !_boss!.dead) {
        if ((b.x - _boss!.x).abs() < 0.12 && (b.y - _boss!.y).abs() < 0.10) {
          _boss!.hp -= b.dmg; remB.add(b); score += 10;
          if (_boss!.hp <= 0) {
            _boss!.dead = true; score += 5000;
            _expls.add(_Expl(x: _boss!.x, y: _boss!.y, big: true));
          }
        }
      }
    }
    _bullets.removeWhere(remB.contains);
    _enemies.removeWhere(remE.contains);
  }

  void _tickExpls(double dt) {
    for (final e in _expls) e.life -= dt * (e.big ? 0.35 : 1.0);
    _expls.removeWhere((e) => e.life <= 0);
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override Widget build(BuildContext ctx) {
    final cap = widget.captain;
    final sz = MediaQuery.of(ctx).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (d) {
          final norm = Offset(d.localPosition.dx / sz.width,
            d.localPosition.dy / sz.height);
          _shoot(norm);
        },
        onPanUpdate: (d) => setState(() => _aim = Offset(
          (d.localPosition.dx / sz.width).clamp(0.05, 0.95),
          (d.localPosition.dy / sz.height).clamp(0.05, 0.75))),
        child: Stack(children: [

          // ── FONDO: escenario nave alienígena ──────────────────────────
          Positioned.fill(child: Image.asset('assets/images/bg_stage1.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF020810), Color(0xFF040C08)]))))),

          // Overlay oscuro para legibilidad
          Positioned.fill(child: Container(
            color: Colors.black.withOpacity(0.45))),

          // ── ENEMIGOS (en el escenario, zona superior) ─────────────────
          for (final e in _enemies)
            Positioned(
              left: e.x * sz.width - 32,
              top: e.y * sz.height - 32,
              child: _EnemyWidget(e: e)),

          // ── BOSS ──────────────────────────────────────────────────────
          if (_boss != null && !_boss!.dead) ...[
            Positioned(
              left: _boss!.x * sz.width - 55,
              top: _boss!.y * sz.height - 45,
              child: _BossWidget(boss: _boss!)),
            // Barra HP boss
            Positioned(top: 95, left: 40, right: 40,
              child: Column(children: [
                const Text('⚠ COMANDANTE ALIENÍGENA',
                  style: TextStyle(color: cRed, fontSize: 9,
                    fontFamily: 'monospace', letterSpacing: 1)),
                const SizedBox(height: 3),
                ClipRRect(borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: (_boss!.hp / 50).clamp(0, 1), minHeight: 7,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation(cRed))),
              ])),
            // Proyectiles boss
            for (final p in _boss!.projs)
              Positioned(
                left: p.x * sz.width - 8, top: p.y * sz.height - 8,
                child: Container(width: 16, height: 16,
                  decoration: BoxDecoration(color: cFire,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: cFire.withOpacity(0.8),
                      blurRadius: 10)]))),
          ],

          // Boss muerto
          if (_boss != null && _boss!.dead)
            Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('SECTOR LIMPIO', style: TextStyle(color: cap.color,
                fontSize: 26, fontFamily: 'monospace', fontWeight: FontWeight.bold,
                shadows: [Shadow(color: cap.color.withOpacity(0.9),
                  blurRadius: 24)])),
              const SizedBox(height: 10),
              const Text('DESCENDIENDO A LA NAVE...',
                style: TextStyle(color: Colors.white60, fontSize: 13,
                  fontFamily: 'monospace')),
            ])),

          // ── BALAS VISIBLES ─────────────────────────────────────────────
          for (final b in _bullets)
            Positioned(
              left: b.x * sz.width - 3,
              top: b.y * sz.height - 8,
              child: Container(width: 6, height: 16,
                decoration: BoxDecoration(
                  color: cap.color,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [BoxShadow(color: cap.color.withOpacity(0.8),
                    blurRadius: 8)]))),

          // ── EXPLOSIONES ────────────────────────────────────────────────
          for (final ex in _expls)
            Positioned(
              left: ex.x * sz.width - (ex.big ? 55 : 28),
              top: ex.y * sz.height - (ex.big ? 55 : 28),
              child: CustomPaint(
                size: Size(ex.big ? 110 : 56, ex.big ? 110 : 56),
                painter: _ExplPainter(life: ex.life))),

          // ── MIRA ──────────────────────────────────────────────────────
          Positioned(
            left: _aim.dx * sz.width - 24,
            top: _aim.dy * sz.height - 24,
            child: CustomPaint(size: const Size(48, 48),
              painter: _CrosshairPainter(color: cap.color,
                active: abilityActive))),

          // ── ARMA EN PRIMERA PERSONA (abajo derecha) ───────────────────
          Positioned(
            bottom: -10, right: -20,
            child: Stack(children: [
              // Imagen del arma
              Image.asset('assets/images/weapon_fp.png',
                width: sz.width * 0.72,
                height: sz.height * 0.30,
                fit: BoxFit.contain,
                alignment: Alignment.bottomRight,
                errorBuilder: (_, __, ___) =>
                  CustomPaint(size: Size(sz.width * 0.6, sz.height * 0.25),
                    painter: _FallbackWeapon(color: cap.color))),
              // Flash de disparo
              if (_muzzleFlash > 0)
                Positioned(top: 0, left: sz.width * 0.05,
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(_muzzleFlash * 0.9),
                      boxShadow: [BoxShadow(
                        color: cap.color.withOpacity(_muzzleFlash),
                        blurRadius: 30, spreadRadius: 10)]))),
            ])),

          // ── HIT FLASH (daño recibido) ──────────────────────────────────
          if (_hitFlash > 0)
            Positioned.fill(child: Container(
              color: cRed.withOpacity(_hitFlash * 0.35))),

          // ── HUD SUPERIOR ──────────────────────────────────────────────
          Positioned(top: 48, left: 16, child: _HullBar(cap: cap, hull: hull)),
          Positioned(top: 48, right: 16, child: _AbilityBar(cap: cap,
            charge: abilityCharge, active: abilityActive)),
          Positioned(top: 52, left: 0, right: 0,
            child: Center(child: Text('STAGE 1 · TECHO DE NAVE ALIENÍGENA',
              style: TextStyle(color: cap.color.withOpacity(0.3), fontSize: 8,
                fontFamily: 'monospace', letterSpacing: 2)))),

          // ── SCORE Y BAJAS ─────────────────────────────────────────────
          Positioned(bottom: sz.height * 0.32, left: 16,
            child: Text('SCORE ${score.toString().padLeft(6,'0')}',
              style: const TextStyle(color: Colors.white38, fontSize: 11,
                fontFamily: 'monospace'))),
          if (!_bossSpawned)
            Positioned(bottom: sz.height * 0.32, right: 16,
              child: Text('BAJAS: $_killed/20',
                style: TextStyle(color: cap.color.withOpacity(0.5),
                  fontSize: 10, fontFamily: 'monospace'))),

          // ── CASCO CRÍTICO ─────────────────────────────────────────────
          if (hull < 0.15)
            Positioned(top: sz.height * 0.32, left: 0, right: 0,
              child: Center(child: Text('⚠ CASCO CRÍTICO ⚠',
                style: TextStyle(color: cRed.withOpacity(0.95), fontSize: 15,
                  fontFamily: 'monospace', fontWeight: FontWeight.bold)))),

          // ── BOTÓN HABILIDAD ───────────────────────────────────────────
          Positioned(bottom: sz.height * 0.30, right: 16,
            child: GestureDetector(onTap: _activateAbility,
              child: Container(width: 64, height: 64,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  color: abilityCharge >= 1.0
                    ? cap.color.withOpacity(0.2) : Colors.black54,
                  border: Border.all(
                    color: abilityActive ? Colors.white :
                      abilityCharge >= 1.0 ? cap.color : Colors.white24,
                    width: 2)),
                child: Center(child: Text(cap.emoji,
                  style: const TextStyle(fontSize: 24)))))),

          // ── PAUSA ─────────────────────────────────────────────────────
          Positioned(top: 44, right: 60,
            child: GestureDetector(onTap: () => _pause(ctx),
              child: Container(width: 36, height: 36,
                decoration: BoxDecoration(color: Colors.black45,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24)),
                child: const Icon(Icons.pause, color: Colors.white54, size: 18)))),
        ])));
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

// ── Widgets de enemigo y boss ──────────────────────────────────────────────
class _EnemyWidget extends StatelessWidget {
  final _Enemy e;
  const _EnemyWidget({required this.e});
  @override Widget build(BuildContext ctx) {
    final opacity = (e.hp / 2).clamp(0.3, 1.0);
    // Tamaño se agranda conforme baja en pantalla (efecto profundidad)
    final scale = 0.6 + e.y * 0.8;
    final size = (56 * scale).clamp(36.0, 80.0);
    return Opacity(opacity: opacity,
      child: Image.asset('assets/images/enemy_type${e.type}.png',
        width: size, height: size, fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Container(
          width: size, height: size,
          decoration: BoxDecoration(
            color: [const Color(0xFF44FF88), cRed,
              const Color(0xFFCC8833)][e.type].withOpacity(0.7),
            shape: BoxShape.circle))));
  }
}

class _BossWidget extends StatelessWidget {
  final _Boss boss;
  const _BossWidget({required this.boss});
  @override Widget build(BuildContext ctx) => Stack(
    alignment: Alignment.center, children: [
    Container(width: 110, height: 90,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(55),
        boxShadow: [BoxShadow(color: cRed.withOpacity(0.5),
          blurRadius: 30, spreadRadius: 12)])),
    Image.asset('assets/images/enemy_boss_s1.png',
      width: 110, height: 90, fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Container(width: 110, height: 90,
        decoration: BoxDecoration(color: cRed.withOpacity(0.8),
          shape: BoxShape.circle))),
  ]);
}

// ── HUD widgets ───────────────────────────────────────────────────────────
class _HullBar extends StatelessWidget {
  final CaptainData cap; final double hull;
  const _HullBar({required this.cap, required this.hull});
  @override Widget build(BuildContext ctx) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('HULL', style: TextStyle(color: cap.color.withOpacity(0.6),
      fontSize: 8, fontFamily: 'monospace')),
    const SizedBox(height: 3),
    SizedBox(width: 110, height: 6, child: ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(value: hull.clamp(0.0, 1.0),
        backgroundColor: Colors.white10,
        valueColor: AlwaysStoppedAnimation(
          hull > 0.5 ? cIce : hull > 0.25 ? cGold : cRed)))),
  ]);
}

class _AbilityBar extends StatelessWidget {
  final CaptainData cap; final double charge; final bool active;
  const _AbilityBar({required this.cap, required this.charge,
    required this.active});
  @override Widget build(BuildContext ctx) => Column(
    crossAxisAlignment: CrossAxisAlignment.end, children: [
    Text(cap.ability, style: TextStyle(color: cap.color,
      fontSize: 8, fontFamily: 'monospace')),
    const SizedBox(height: 3),
    SizedBox(width: 80, height: 4, child: ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: LinearProgressIndicator(value: charge.clamp(0.0, 1.0),
        backgroundColor: Colors.white10,
        valueColor: AlwaysStoppedAnimation(
          active ? Colors.white : cap.color)))),
  ]);
}

// ═══════════════════════════════════════════════════════════════════════════
//  MODELOS
// ═══════════════════════════════════════════════════════════════════════════
class _Bullet {
  double x, y, vx, vy; final double dmg;
  _Bullet({required this.x, required this.y, required this.vx,
    required this.vy, required this.dmg});
}
class _Enemy {
  double x, y, vy, hp; final int type;
  final double phase = Random().nextDouble() * pi * 2;
  bool dead = false;
  _Enemy({required this.x, required this.y, required this.vy,
    required this.hp, required this.type});
}
class _Boss {
  double x, y, hp = 50, t = 0, atkT = 2.5;
  bool dead = false;
  final List<_Proj> projs = [];
  _Boss({required this.x, required this.y});
}
class _Proj { double x, y; _Proj({required this.x, required this.y}); }
class _Expl {
  final double x, y; final bool big; double life;
  _Expl({required this.x, required this.y, this.big = false}) : life = 1.0;
}

// ═══════════════════════════════════════════════════════════════════════════
//  PAINTERS
// ═══════════════════════════════════════════════════════════════════════════
class _CrosshairPainter extends CustomPainter {
  final Color color; final bool active;
  const _CrosshairPainter({required this.color, required this.active});
  @override void paint(Canvas canvas, Size s) {
    final p = Paint()..color = color.withOpacity(active ? 1.0 : 0.8)
      ..strokeWidth = active ? 2.0 : 1.5;
    final cx = s.width/2, cy = s.height/2;
    // Líneas de mira
    canvas.drawLine(Offset(0, cy), Offset(cx-10, cy), p);
    canvas.drawLine(Offset(cx+10, cy), Offset(s.width, cy), p);
    canvas.drawLine(Offset(cx, 0), Offset(cx, cy-10), p);
    canvas.drawLine(Offset(cx, cy+10), Offset(cx, s.height), p);
    // Círculo central
    canvas.drawCircle(Offset(cx, cy), active ? 5 : 3,
      Paint()..color = color.withOpacity(0.9)..style = PaintingStyle.stroke
        ..strokeWidth = 1.5);
    canvas.drawCircle(Offset(cx, cy), 1.5,
      Paint()..color = color..style = PaintingStyle.fill);
  }
  @override bool shouldRepaint(_) => true;
}

class _ExplPainter extends CustomPainter {
  final double life;
  const _ExplPainter({required this.life});
  @override void paint(Canvas canvas, Size s) {
    final cx = s.width/2, cy = s.height/2;
    final r = s.width/2 * (1.2 - life * 0.3);
    for (final c in [cFire, cGold, Colors.white]) {
      canvas.drawCircle(Offset(cx, cy), r,
        Paint()..color = c.withOpacity(life * 0.7)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.5));
    }
  }
  @override bool shouldRepaint(_) => true;
}

class _FallbackWeapon extends CustomPainter {
  final Color color;
  const _FallbackWeapon({required this.color});
  @override void paint(Canvas canvas, Size s) {
    final p = Paint()..color = color.withOpacity(0.6)..style = PaintingStyle.fill;
    // Cuerpo del arma básico
    canvas.drawRRect(RRect.fromLTRBR(s.width*0.1, s.height*0.4,
      s.width*0.9, s.height*0.7, const Radius.circular(6)), p);
    // Cañón
    canvas.drawRRect(RRect.fromLTRBR(s.width*0.6, s.height*0.3,
      s.width*0.95, s.height*0.48, const Radius.circular(4)), p);
    // Manos
    canvas.drawRRect(RRect.fromLTRBR(s.width*0.2, s.height*0.65,
      s.width*0.45, s.height*0.95, const Radius.circular(8)),
      Paint()..color = Colors.grey.shade800);
    canvas.drawRRect(RRect.fromLTRBR(s.width*0.55, s.height*0.65,
      s.width*0.75, s.height*0.95, const Radius.circular(8)),
      Paint()..color = Colors.grey.shade800);
  }
  @override bool shouldRepaint(_) => false;
}
