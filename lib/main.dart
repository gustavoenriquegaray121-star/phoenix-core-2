import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:ui' as ui;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) => FlutterError.presentError(details);
  runZonedGuarded(() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    runApp(const PC2App());
  }, (error, stack) {
    runApp(MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text('ERROR:\n\n$error\n\n$stack',
            style: const TextStyle(color: Colors.red, fontSize: 10,
              fontFamily: 'monospace')),
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
    home: const SplashScreen(),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
//  SPLASH SCREEN
// ═══════════════════════════════════════════════════════════════════════════
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1500));
    _fade = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _ctrl.forward();
    // Navega a selección después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.pushReplacement(context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const CaptainSelectScreen(),
          transitionDuration: const Duration(milliseconds: 800),
          transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child)));
    });
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override Widget build(BuildContext ctx) => Scaffold(
    backgroundColor: Colors.black,
    body: FadeTransition(
      opacity: _fade,
      child: Stack(fit: StackFit.expand, children: [
        Image.asset('assets/images/splash.png', fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.black,
            child: const Center(child: Text('PHOENIX CORE II',
              style: TextStyle(color: Color(0xFFFF6600), fontSize: 32,
                fontWeight: FontWeight.bold, fontFamily: 'monospace',
                letterSpacing: 4))))),
        // Overlay oscuro sutil
        Container(color: Colors.black.withOpacity(0.35)),
        // Texto inferior
        Positioned(bottom: 60, left: 0, right: 0,
          child: Column(children: [
            const Text('UCC v7.3 · ALTEA-GARAY',
              style: TextStyle(color: Colors.white38, fontSize: 11,
                fontFamily: 'monospace', letterSpacing: 3)),
            const SizedBox(height: 16),
            SizedBox(width: 40, height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(
                  const Color(0xFFFF6600).withOpacity(0.7)))),
          ])),
      ])));
}

// ═══════════════════════════════════════════════════════════════════════════
//  COLORES Y DATOS
// ═══════════════════════════════════════════════════════════════════════════
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
  final String name, fullName, title, ability, abilityDesc, tradeoff, style,
      emoji, imagePath;
  final Color color;
  final double damage, speed, hullMax;
  const CaptainData({
    required this.id, required this.name, required this.fullName,
    required this.title, required this.ability, required this.abilityDesc,
    required this.tradeoff, required this.style, required this.emoji,
    required this.imagePath, required this.color,
    required this.damage, required this.speed, required this.hullMax,
  });
}

const captains = [
  CaptainData(
    id: Captain.danny, name: 'DANNY', fullName: 'Daniel Garay',
    title: 'El Estratega', emoji: '🪖',
    imagePath: 'assets/images/dany.png',
    ability: 'MODO FÉNIX',
    abilityDesc: 'Anticipa el peligro 90ms antes.\nVentana de daño máximo en boss.\nUn disparo preciso vale por diez.',
    tradeoff: 'Cadencia lenta — necesita timing perfecto',
    style: 'Lento · Preciso · Devastador', color: cGold,
    damage: 1.8, speed: 0.75, hullMax: 120,
  ),
  CaptainData(
    id: Captain.andy, name: 'ANDY', fullName: 'Andres Garay',
    title: 'El Impulsivo', emoji: '⚡',
    imagePath: 'assets/images/andy.png',
    ability: 'MODO KALMAN',
    abilityDesc: 'Estabiliza la realidad local.\nCadencia x2 en zona de calor.\nEl caos es tu combustible.',
    tradeoff: 'Hull baja 2x más rápido — frágil',
    style: 'Rápido · Agresivo · Alto riesgo', color: cIce,
    damage: 1.0, speed: 1.5, hullMax: 70,
  ),
  CaptainData(
    id: Captain.denise, name: 'DENISE', fullName: 'Denise Garay',
    title: 'La Guardiana', emoji: '🛡️',
    imagePath: 'assets/images/denisse.png',
    ability: 'WATCH DOG',
    abilityDesc: 'Teletransporte de emergencia\ncuando hull < 15%.\nNadie la derriba — solo se cansa.',
    tradeoff: 'Menor daño base — solo brilla sobreviviendo',
    style: 'Defensivo · Supervivencia · Control', color: cPurple,
    damage: 0.8, speed: 1.0, hullMax: 150,
  ),
];

// ═══════════════════════════════════════════════════════════════════════════
//  PANTALLA DE SELECCIÓN
// ═══════════════════════════════════════════════════════════════════════════
class CaptainSelectScreen extends StatefulWidget {
  const CaptainSelectScreen({super.key});
  @override State<CaptainSelectScreen> createState() => _CaptainSelectState();
}

class _CaptainSelectState extends State<CaptainSelectScreen>
    with TickerProviderStateMixin {
  final PageController _page = PageController();
  int _current = 0;
  late AnimationController _pulse;

  @override void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this,
        duration: const Duration(seconds: 2))..repeat(reverse: true);
  }
  @override void dispose() { _pulse.dispose(); _page.dispose(); super.dispose(); }

  void _go(int delta) {
    final next = (_current + delta).clamp(0, captains.length - 1);
    _page.animateToPage(next,
        duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
  }

  @override Widget build(BuildContext ctx) {
    final cap = captains[_current];
    return Scaffold(
      backgroundColor: cBg,
      body: SafeArea(child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(children: [
            AnimatedBuilder(animation: _pulse, builder: (_, __) =>
              Text('PHOENIX CORE II', style: TextStyle(
                color: cap.color, fontSize: 22, fontWeight: FontWeight.bold,
                letterSpacing: 4, fontFamily: 'monospace',
                shadows: [Shadow(color: cap.color.withOpacity(
                  0.4 + 0.3 * _pulse.value), blurRadius: 12)]))),
            const SizedBox(height: 4),
            const Text('"No puedes ganarte a ti mismo siendo tú mismo"',
              style: TextStyle(color: Colors.white38, fontSize: 10,
                fontStyle: FontStyle.italic)),
          ])),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(captains.length, (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == _current ? 18 : 7, height: 7,
            decoration: BoxDecoration(
              color: i == _current ? cap.color : Colors.white24,
              borderRadius: BorderRadius.circular(4))))),
        const SizedBox(height: 10),
        Expanded(child: PageView.builder(
          controller: _page,
          itemCount: captains.length,
          onPageChanged: (i) => setState(() => _current = i),
          itemBuilder: (_, i) => _CaptainPage(cap: captains[i]))),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Row(children: [
            _ArrowBtn(icon: Icons.chevron_left_rounded,
              color: _current > 0 ? cap.color : Colors.white12,
              onTap: _current > 0 ? () => _go(-1) : null),
            const SizedBox(width: 12),
            Expanded(child: GestureDetector(
              onTap: () => Navigator.pushReplacement(ctx,
                MaterialPageRoute(builder: (_) =>
                  PC2GameScreen(captain: captains[_current]))),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: cap.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cap.color, width: 2),
                  boxShadow: [BoxShadow(
                    color: cap.color.withOpacity(0.25), blurRadius: 16)]),
                child: Center(child: Text(
                  'DESPLEGAR — ${captains[_current].name}',
                  style: TextStyle(color: cap.color, fontSize: 14,
                    fontWeight: FontWeight.bold, letterSpacing: 3,
                    fontFamily: 'monospace')))))),
            const SizedBox(width: 12),
            _ArrowBtn(icon: Icons.chevron_right_rounded,
              color: _current < captains.length - 1 ? cap.color : Colors.white12,
              onTap: _current < captains.length - 1 ? () => _go(1) : null),
          ])),
      ])));
  }
}

class _CaptainPage extends StatelessWidget {
  final CaptainData cap;
  const _CaptainPage({required this.cap});

  @override Widget build(BuildContext ctx) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(children: [
      Expanded(flex: 5, child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cap.color.withOpacity(0.4), width: 2),
          boxShadow: [BoxShadow(
            color: cap.color.withOpacity(0.15), blurRadius: 24)]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.asset(cap.imagePath, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: cap.color.withOpacity(0.08),
              child: Center(child: Text(cap.emoji,
                style: const TextStyle(fontSize: 72)))))))),
      Expanded(flex: 4, child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cPanel, borderRadius: BorderRadius.circular(18),
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
            decoration: BoxDecoration(
              color: cap.color.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cap.color.withOpacity(0.25))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(cap.ability, style: TextStyle(color: cap.color,
                fontSize: 13, fontWeight: FontWeight.bold,
                fontFamily: 'monospace')),
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
              color: Colors.orange, fontSize: 11,
              fontStyle: FontStyle.italic))),
          ]),
        ])))),
      const SizedBox(height: 8),
    ]));
}

class _ArrowBtn extends StatelessWidget {
  final IconData icon; final Color color; final VoidCallback? onTap;
  const _ArrowBtn({required this.icon, required this.color, this.onTap});
  @override Widget build(BuildContext ctx) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 46, height: 54,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5)),
      child: Icon(icon, color: color, size: 28)));
}

// ═══════════════════════════════════════════════════════════════════════════
//  GAME SCREEN — Stage 1
// ═══════════════════════════════════════════════════════════════════════════
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

  Offset _aim = const Offset(0.5, 0.5);
  final List<_Bullet> _bullets = [];
  double _shootCooldown = 0;

  final List<_Enemy> _enemies = [];
  double _enemySpawnTimer = 0;
  int _enemiesKilled = 0;
  bool _bossSpawned = false;
  _Boss? _boss;

  final List<_Explosion> _explosions = [];

  final List<_VHDLLineData> _lines = [];
  double _spawnTimer = 0;
  bool _glitch = false;
  double _glitchTimer = 3.0;

  late AnimationController _loop;
  final _rng = Random();
  double _prev = 0;

  static const _stageName = 'STAGE 1 · TECHO DE NAVE ALIENÍGENA';
  static const _frags = [
    'ALTEA-GARAY v7.3', 'JERK_LIMIT := 512;',
    'YOU_ARE_NOT_THE_ORIGINAL;', 'PHOENIX_PROTOCOL_REJECTED;',
    'ALIEN_CANNON_ONLINE;', 'INTRUDER_ALERT_SECTOR_7;',
    'ERROR: identity_mismatch;', 'HULL_BREACH_DETECTED;',
  ];

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
    _updateBackground(dt);
    _updateAbility(dt);
    _updateShooting(dt);
    _updateEnemies(dt);
    _updateBoss(dt);
    _checkCollisions();
    _updateExplosions(dt);
    setState(() {});
  }

  void _updateBackground(double dt) {
    _spawnTimer -= dt;
    if (_spawnTimer <= 0) {
      _spawnTimer = 0.5 + _rng.nextDouble() * 0.8;
      _lines.add(_VHDLLineData(
        text: _frags[_rng.nextInt(_frags.length)],
        x: _rng.nextDouble(), speed: 0.04 + _rng.nextDouble() * 0.05,
        isCorrupt: _rng.nextDouble() < 0.15));
    }
    for (final l in _lines) l.y += dt * l.speed;
    _lines.removeWhere((l) => l.y > 1.2);
    if (_lines.length > 6) _lines.removeAt(0);
    _glitchTimer -= dt;
    if (_glitchTimer <= 0) {
      _glitch = !_glitch;
      _glitchTimer = _glitch ? 0.05 + _rng.nextDouble() * 0.10
          : 3.0 + _rng.nextDouble() * 5.0;
    }
  }

  void _updateAbility(double dt) {
    if (!abilityActive) abilityCharge = (abilityCharge + dt * 0.06).clamp(0, 1);
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

  void _updateShooting(double dt) {
    _shootCooldown -= dt;
    for (final b in _bullets) b.y -= dt * 0.7;
    _bullets.removeWhere((b) => b.y < -0.05);
  }

  void _shoot(Offset tapNorm) {
    if (_shootCooldown > 0) return;
    final cadMult = (abilityActive && widget.captain.id == Captain.andy)
        ? 0.5 : 1.0;
    _shootCooldown = 0.22 * cadMult / widget.captain.speed;
    _bullets.add(_Bullet(x: 0.5, y: 0.85,
      targetX: tapNorm.dx, targetY: tapNorm.dy,
      damage: widget.captain.damage));
  }

  void _updateEnemies(double dt) {
    if (_bossSpawned) return;
    _enemySpawnTimer -= dt;
    if (_enemySpawnTimer <= 0 && _enemiesKilled < 20) {
      _enemySpawnTimer = 1.4 - (score / 6000).clamp(0, 0.8);
      _enemies.add(_Enemy(
        x: 0.1 + _rng.nextDouble() * 0.8, y: -0.05,
        speed: 0.07 + _rng.nextDouble() * 0.05,
        hp: 2, type: _rng.nextInt(3)));
    }
    for (final e in _enemies) {
      e.y += dt * e.speed;
      e.x += sin(e.y * 7 + e.phase) * dt * 0.035;
      e.x = e.x.clamp(0.05, 0.95);
      if (e.y > 1.0) {
        hullIntegrity = (hullIntegrity - 0.05).clamp(0, 1);
        e.dead = true;
      }
    }
    _enemies.removeWhere((e) => e.dead);
    if (_enemiesKilled >= 20 && !_bossSpawned) {
      _bossSpawned = true;
      _boss = _Boss(x: 0.5, y: 0.15);
    }
  }

  void _updateBoss(double dt) {
    if (_boss == null || _boss!.dead) return;
    _boss!.moveTimer += dt;
    _boss!.x += sin(_boss!.moveTimer * 1.1) * dt * 0.10;
    _boss!.x = _boss!.x.clamp(0.18, 0.82);
    _boss!.attackTimer -= dt;
    if (_boss!.attackTimer <= 0) {
      _boss!.attackTimer = 2.2;
      _boss!.projectiles.add(_BossProjectile(x: _boss!.x, y: _boss!.y + 0.10));
    }
    for (final p in _boss!.projectiles) p.y += dt * 0.22;
    _boss!.projectiles.removeWhere((p) {
      if (p.y > 1.0) return true;
      if (p.y > 0.80 && (p.x - 0.5).abs() < 0.09) {
        hullIntegrity = (hullIntegrity - 0.08).clamp(0, 1);
        return true;
      }
      return false;
    });
  }

  void _checkCollisions() {
    final remB = <_Bullet>{};
    final remE = <_Enemy>{};
    for (final b in _bullets) {
      for (final e in _enemies) {
        if ((b.x - e.x).abs() < 0.07 && (b.y - e.y).abs() < 0.07) {
          e.hp -= b.damage; remB.add(b);
          if (e.hp <= 0) {
            e.dead = true; remE.add(e);
            _enemiesKilled++; score += 100;
            _explosions.add(_Explosion(x: e.x, y: e.y));
          }
          break;
        }
      }
      if (_boss != null && !_boss!.dead) {
        if ((b.x - _boss!.x).abs() < 0.13 && (b.y - _boss!.y).abs() < 0.11) {
          _boss!.hp -= b.damage; remB.add(b); score += 10;
          if (_boss!.hp <= 0) {
            _boss!.dead = true; score += 5000;
            _explosions.add(_Explosion(x: _boss!.x, y: _boss!.y, big: true));
          }
        }
      }
    }
    _bullets.removeWhere(remB.contains);
    _enemies.removeWhere(remE.contains);
  }

  void _updateExplosions(double dt) {
    for (final e in _explosions) e.life -= dt * (e.big ? 0.4 : 1.1);
    _explosions.removeWhere((e) => e.life <= 0);
  }

  @override Widget build(BuildContext ctx) {
    final cap = widget.captain;
    final size = MediaQuery.of(ctx).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (d) {
          final norm = Offset(d.localPosition.dx / size.width,
            d.localPosition.dy / size.height);
          setState(() => _aim = norm);
          _shoot(norm);
        },
        onPanUpdate: (d) => setState(() => _aim = Offset(
          (d.localPosition.dx / size.width).clamp(0, 1),
          (d.localPosition.dy / size.height).clamp(0, 1))),
        child: Stack(children: [

          CustomPaint(size: size,
            painter: _SkyPainter(lines: _lines, glitch: _glitch)),
          if (_glitch) Container(color: const Color(0x09FF0044)),

          // Nave jugador
          Positioned(left: size.width * 0.5 - 20, top: size.height * 0.82,
            child: CustomPaint(size: const Size(40, 36),
              painter: _ShipPainter(color: cap.color, glow: abilityActive))),

          // Proyectiles
          for (final b in _bullets)
            Positioned(left: b.x * size.width - 3, top: b.y * size.height,
              child: Container(width: 6, height: 18,
                decoration: BoxDecoration(color: cap.color,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [BoxShadow(
                    color: cap.color.withOpacity(0.6), blurRadius: 8)]))),

          // Enemigos con imagen real
          for (final e in _enemies)
            Positioned(
              left: e.x * size.width - 28,
              top: e.y * size.height - 28,
              child: Opacity(
                opacity: (e.hp / 2).clamp(0.4, 1.0),
                child: Image.asset(
                  'assets/images/enemy_type${e.type}.png',
                  width: 56, height: 56, fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: [const Color(0xFF44FF88),
                        const Color(0xFFFF3333),
                        const Color(0xFFCC8833)][e.type].withOpacity(0.7),
                      shape: BoxShape.circle))))),

          // Boss con imagen real
          if (_boss != null && !_boss!.dead) ...[
            Positioned(
              left: _boss!.x * size.width - 55,
              top: _boss!.y * size.height - 45,
              child: Stack(alignment: Alignment.center, children: [
                Container(width: 110, height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(55),
                    boxShadow: [BoxShadow(
                      color: cRed.withOpacity(0.5), blurRadius: 30,
                      spreadRadius: 10)])),
                Image.asset('assets/images/enemy_boss_s1.png',
                  width: 110, height: 90, fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => CustomPaint(
                    size: const Size(110, 90),
                    painter: _BossFallback())),
              ])),
            Positioned(top: 100, left: 40, right: 40,
              child: Column(children: [
                const Text('⚠ COMANDANTE ALIENÍGENA',
                  style: TextStyle(color: cRed, fontSize: 9,
                    fontFamily: 'monospace')),
                const SizedBox(height: 3),
                ClipRRect(borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: (_boss!.hp / 50).clamp(0, 1), minHeight: 6,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation(cRed))),
              ])),
            for (final p in _boss!.projectiles)
              Positioned(left: p.x * size.width - 5, top: p.y * size.height,
                child: Container(width: 10, height: 10,
                  decoration: BoxDecoration(color: cFire,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(
                      color: cFire.withOpacity(0.7), blurRadius: 8)]))),
          ],

          // Boss muerto
          if (_boss != null && _boss!.dead)
            Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('SECTOR LIMPIO', style: TextStyle(
                color: cap.color, fontSize: 24, fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: cap.color.withOpacity(0.8),
                  blurRadius: 20)])),
              const SizedBox(height: 8),
              const Text('DESCENDIENDO A LA NAVE...',
                style: TextStyle(color: Colors.white54, fontSize: 12,
                  fontFamily: 'monospace')),
            ])),

          // Explosiones
          for (final ex in _explosions)
            Positioned(
              left: ex.x * size.width - (ex.big ? 50 : 25),
              top: ex.y * size.height - (ex.big ? 50 : 25),
              child: CustomPaint(
                size: Size(ex.big ? 100 : 50, ex.big ? 100 : 50),
                painter: _ExplosionPainter(life: ex.life))),

          // Mira
          Positioned(left: _aim.dx * size.width - 22,
            top: _aim.dy * size.height - 22,
            child: CustomPaint(size: const Size(44, 44),
              painter: _CrosshairPainter(color: cap.color))),

          // HUD
          Positioned(top: 48, left: 16, child: _hullBar(cap)),
          Positioned(top: 48, right: 16, child: _abilityBar(cap)),
          Positioned(top: 52, left: 0, right: 0,
            child: Center(child: Text(_stageName, style: TextStyle(
              color: cap.color.withOpacity(0.35), fontSize: 8,
              fontFamily: 'monospace', letterSpacing: 2)))),
          Positioned(bottom: 32, left: 16,
            child: Text('SCORE ${score.toString().padLeft(6, '0')}',
              style: const TextStyle(color: Colors.white38, fontSize: 11,
                fontFamily: 'monospace'))),
          if (!_bossSpawned)
            Positioned(bottom: 32, right: 16,
              child: Text('BAJAS: $_enemiesKilled/20',
                style: TextStyle(color: cap.color.withOpacity(0.5),
                  fontSize: 10, fontFamily: 'monospace'))),

          // Botón habilidad
          Positioned(bottom: 20, right: 16,
            child: GestureDetector(onTap: _activateAbility,
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

          if (hullIntegrity < 0.15)
            Positioned(top: size.height * 0.35, left: 0, right: 0,
              child: Center(child: Text('⚠ CASCO CRÍTICO ⚠',
                style: TextStyle(color: cRed.withOpacity(0.9),
                  fontSize: 14, fontFamily: 'monospace',
                  fontWeight: FontWeight.bold)))),

          Positioned(top: 44, right: 60,
            child: GestureDetector(onTap: () => _pause(ctx),
              child: Container(width: 36, height: 36,
                decoration: BoxDecoration(color: Colors.black38,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24)),
                child: const Icon(Icons.pause,
                  color: Colors.white54, size: 18)))),
        ])));
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

// ═══════════════════════════════════════════════════════════════════════════
//  MODELOS
// ═══════════════════════════════════════════════════════════════════════════
class _Bullet {
  double x, y; final double targetX, targetY, damage;
  _Bullet({required this.x, required this.y, required this.targetX,
    required this.targetY, required this.damage});
}

class _Enemy {
  double x, y, speed, hp; final int type;
  final double phase = Random().nextDouble() * pi * 2;
  bool dead = false;
  _Enemy({required this.x, required this.y, required this.speed,
    required this.hp, required this.type});
}

class _Boss {
  double x, y, hp = 50, moveTimer = 0, attackTimer = 2.0;
  bool dead = false;
  final List<_BossProjectile> projectiles = [];
  _Boss({required this.x, required this.y});
}

class _BossProjectile {
  double x, y;
  _BossProjectile({required this.x, required this.y});
}

class _Explosion {
  final double x, y; final bool big; double life;
  _Explosion({required this.x, required this.y, this.big = false}) : life = 1.0;
}

// ═══════════════════════════════════════════════════════════════════════════
//  PAINTERS
// ═══════════════════════════════════════════════════════════════════════════
class _VHDLLineData {
  final String text; final double x, speed; final bool isCorrupt; double y;
  _VHDLLineData({required this.text, required this.x, required this.speed,
    required this.isCorrupt}) : y = -0.05;
}

class _SkyPainter extends CustomPainter {
  final List<_VHDLLineData> lines; final bool glitch;
  const _SkyPainter({required this.lines, required this.glitch});
  @override void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF020A08));
    for (final l in lines) {
      final op = l.y > 0.75 ? ((1 - l.y) / 0.25).clamp(0.0, 1.0) : 1.0;
      final color = l.isCorrupt
          ? Color.fromARGB((op * 160).toInt(), 255, 30, 60)
          : Color.fromARGB((op * 100).toInt(), 0, 200, 90);
      final pb = ui.ParagraphBuilder(ui.ParagraphStyle(
          textDirection: ui.TextDirection.ltr))
        ..pushStyle(ui.TextStyle(color: color, fontSize: 9,
          fontFamily: 'monospace'))
        ..addText(l.text);
      final para = pb.build()
        ..layout(ui.ParagraphConstraints(width: size.width * (1 - l.x)));
      canvas.drawParagraph(para, Offset(l.x * size.width, l.y * size.height));
    }
  }
  @override bool shouldRepaint(_) => true;
}

class _ShipPainter extends CustomPainter {
  final Color color; final bool glow;
  const _ShipPainter({required this.color, required this.glow});
  @override void paint(Canvas canvas, Size s) {
    if (glow) canvas.drawCircle(Offset(s.width/2, s.height/2), 28,
      Paint()..color = color.withOpacity(0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
    canvas.drawPath(Path()
      ..moveTo(s.width/2, 0)..lineTo(s.width, s.height)
      ..lineTo(s.width/2, s.height*0.72)..lineTo(0, s.height)..close(),
      Paint()..color = color..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(s.width/2, s.height*0.8), 5,
      Paint()..color = Colors.white.withOpacity(0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
  }
  @override bool shouldRepaint(_) => true;
}

class _BossFallback extends CustomPainter {
  @override void paint(Canvas canvas, Size s) {
    canvas.drawCircle(Offset(s.width/2, s.height/2), s.width/2 - 4,
      Paint()..color = cRed.withOpacity(0.8));
    canvas.drawCircle(Offset(s.width/2, s.height/2), 14,
      Paint()..color = Colors.white.withOpacity(0.9)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
  }
  @override bool shouldRepaint(_) => false;
}

class _ExplosionPainter extends CustomPainter {
  final double life;
  const _ExplosionPainter({required this.life});
  @override void paint(Canvas canvas, Size s) {
    final cx = s.width/2, cy = s.height/2;
    final r = s.width/2 * (1 - life * 0.2);
    for (final c in [cFire, cGold, Colors.white]) {
      canvas.drawCircle(Offset(cx, cy), r,
        Paint()..color = c.withOpacity(life * 0.6)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.5));
    }
  }
  @override bool shouldRepaint(_) => true;
}

class _CrosshairPainter extends CustomPainter {
  final Color color;
  const _CrosshairPainter({required this.color});
  @override void paint(Canvas canvas, Size s) {
    final p = Paint()..color = color.withOpacity(0.7)..strokeWidth = 1.5;
    final cx = s.width/2, cy = s.height/2;
    canvas.drawLine(Offset(0, cy), Offset(cx-8, cy), p);
    canvas.drawLine(Offset(cx+8, cy), Offset(s.width, cy), p);
    canvas.drawLine(Offset(cx, 0), Offset(cx, cy-8), p);
    canvas.drawLine(Offset(cx, cy+8), Offset(cx, s.height), p);
    canvas.drawCircle(Offset(cx, cy), 2, p..style = ui.PaintingStyle.fill);
  }
  @override bool shouldRepaint(_) => false;
}
