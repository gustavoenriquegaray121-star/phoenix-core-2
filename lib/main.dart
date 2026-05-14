import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'dart:math';

// ═══════════════════════════════════════════════════════════════════════════
//  MAIN
// ═══════════════════════════════════════════════════════════════════════════
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const PC2App());
}

class PC2App extends StatelessWidget {
  const PC2App({super.key});
  @override Widget build(BuildContext ctx) => MaterialApp(
    title: 'Phoenix Core 2',
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
    home: const SplashScreen());
}

// ═══════════════════════════════════════════════════════════════════════════
//  COLORES Y DATOS
// ═══════════════════════════════════════════════════════════════════════════
const cIce    = Color(0xFF00DDFF);
const cGold   = Color(0xFFFFD700);
const cRed    = Color(0xFFFF2244);
const cFire   = Color(0xFFFF5500);
const cPurple = Color(0xFF9944FF);
const cBg     = Color(0xFF080C18);
const cPanel  = Color(0xFF0D1420);

enum CaptainId { danny, andy, denise }

class CaptainData {
  final CaptainId id;
  final String name, title, ability, abilityDesc, tradeoff, emoji, imagePath;
  final Color color;
  final double damage, speed, hullMax;
  const CaptainData({required this.id, required this.name, required this.title,
    required this.ability, required this.abilityDesc, required this.tradeoff,
    required this.emoji, required this.imagePath, required this.color,
    required this.damage, required this.speed, required this.hullMax});
}

const captains = [
  CaptainData(id: CaptainId.danny, name: 'DANNY', title: 'El Estratega',
    emoji: '🪖', imagePath: 'assets/images/dany.png', ability: 'MODO FÉNIX',
    abilityDesc: 'Anticipa el peligro 90ms antes.\nVentana de daño máximo en boss.',
    tradeoff: 'Cadencia lenta — timing perfecto',
    color: cGold, damage: 1.8, speed: 0.75, hullMax: 120),
  CaptainData(id: CaptainId.andy, name: 'ANDY', title: 'El Impulsivo',
    emoji: '⚡', imagePath: 'assets/images/andy.png', ability: 'MODO KALMAN',
    abilityDesc: 'Cadencia x2 en zona de calor.\nEl caos es tu combustible.',
    tradeoff: 'Hull baja 2x más rápido',
    color: cIce, damage: 1.0, speed: 1.5, hullMax: 70),
  CaptainData(id: CaptainId.denise, name: 'DENISE', title: 'La Guardiana',
    emoji: '🛡️', imagePath: 'assets/images/denisse.png', ability: 'WATCH DOG',
    abilityDesc: 'Teletransporte de emergencia\ncuando hull < 15%.',
    tradeoff: 'Menor daño base',
    color: cPurple, damage: 0.8, speed: 1.0, hullMax: 150),
];

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
//  SELECCIÓN DE CAPITÁN
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
              onTap: () {
                final game = PC2Game(captain: captains[_cur]);
                Navigator.pushReplacement(ctx, MaterialPageRoute(
                  builder: (_) => GameWidget(game: game)));
              },
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
//  FLAME GAME — PC2Game
// ═══════════════════════════════════════════════════════════════════════════
class PC2Game extends FlameGame with TapCallbacks, HasCollisionDetection {
  final CaptainData captain;
  PC2Game({required this.captain});

  // Audio
  final _sfxShoot   = AudioPlayer();
  final _sfxHit     = AudioPlayer();
  final _sfxAbility = AudioPlayer();
  final _bgMusic    = AudioPlayer();

  // Estado
  late double hull;
  double abilityCharge = 0;
  bool abilityActive = false;
  double abilityTimer = 0;
  int score = 0;
  int killed = 0;
  bool bossSpawned = false;
  bool bossDead = false;

  // Componentes
  late SpriteComponent _background;
  late SpriteComponent _weapon;
  late _HudComponent _hud;
  late _CrosshairComp _crosshair;

  // Timers
  double _spawnT = 1.5;
  double _shootCD = 0;

  final _rng = Random();

  @override
  Future<void> onLoad() async {
    hull = captain.hullMax / 150.0;

    // Fondo
    final bgSprite = await Sprite.load('bg_stage1.png');
    _background = SpriteComponent(
      sprite: bgSprite,
      size: size,
      position: Vector2.zero(),
      priority: -10);
    add(_background);

    // Arma (primera persona — abajo derecha)
    final wpSprite = await Sprite.load('weapon_fp.png');
    _weapon = SpriteComponent(
      sprite: wpSprite,
      size: Vector2(size.x * 0.72, size.y * 0.30),
      position: Vector2(size.x * 0.28, size.y * 0.72),
      priority: 100);
    add(_weapon);

    // HUD overlay
    _hud = _HudComponent(game: this);
    add(_hud);

    // Mira central
    _crosshair = _CrosshairComp(
      position: size / 2,
      color: captain.color);
    add(_crosshair);

    // Audio fondo
    try {
      await _bgMusic.setReleaseMode(ReleaseMode.loop);
      await _bgMusic.play(AssetSource('audio/fondo_espacial.mp3'),
        volume: 0.4);
    } catch (_) {}
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Habilidad
    if (!abilityActive) {
      abilityCharge = (abilityCharge + dt * 0.055).clamp(0, 1);
    } else {
      abilityTimer -= dt;
      if (abilityTimer <= 0) { abilityActive = false; abilityCharge = 0; }
    }

    // Shoot cooldown
    _shootCD = (_shootCD - dt).clamp(-1, 10);

    // Spawn enemigos
    if (!bossSpawned) {
      _spawnT -= dt;
      if (_spawnT <= 0 && killed < 20) {
        _spawnT = 1.6 - (score / 5000).clamp(0, 1.0);
        _spawnEnemy();
      }
      if (killed >= 20 && !bossSpawned) {
        bossSpawned = true;
        _spawnBoss();
      }
    }
  }

  void _spawnEnemy() {
    final type = _rng.nextInt(3);
    final xPos = size.x * (0.1 + _rng.nextDouble() * 0.8);
    add(_EnemyComp(
      game: this,
      type: type,
      startPos: Vector2(xPos, -80),
      speed: 80 + _rng.nextDouble() * 60,
      hp: 2.0 * captain.damage.clamp(0.5, 2.0)));
  }

  void _spawnBoss() {
    add(_BossComp(game: this, startPos: Vector2(size.x / 2, 80)));
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_shootCD > 0) return;
    final cadMult = (abilityActive && captain.id == CaptainId.andy) ? 0.5 : 1.0;
    _shootCD = 0.22 * cadMult / captain.speed;

    // Sonido disparo
    try { _sfxShoot.play(AssetSource('audio/disparo_laser.mp3'), volume: 0.7); }
    catch (_) {}

    // Flash arma
    _weapon.add(OpacityEffect.to(0.3,
      EffectController(duration: 0.05, reverseDuration: 0.05)));

    // Disparo en la posición tocada
    final tp = event.localPosition;
    add(_BulletComp(
      game: this,
      startPos: Vector2(size.x / 2, size.y * 0.75),
      targetPos: Vector2(tp.x, tp.y),
      damage: captain.damage));
  }

  void onEnemyKilled(Vector2 pos) {
    killed++;
    score += 100;
    add(_ExplosionComp(position: pos, big: false));
    try { _sfxHit.play(AssetSource('audio/golpe_impacto.mp3'), volume: 0.8); }
    catch (_) {}
  }

  void onBossKilled(Vector2 pos) {
    bossDead = true;
    score += 5000;
    add(_ExplosionComp(position: pos, big: true));
  }

  void takeDamage(double amount) {
    hull = (hull - amount).clamp(0, 1);
    // Flash rojo pantalla
    add(_DamageFlash());
  }

  void activateAbility() {
    if (abilityCharge < 1.0 || abilityActive) return;
    abilityActive = true;
    abilityTimer = switch(captain.id) {
      CaptainId.danny => 8.0, CaptainId.andy => 5.0, CaptainId.denise => 3.0,
    };
    try { _sfxAbility.play(AssetSource('audio/activar_habilidad.mp3')); }
    catch (_) {}
  }

  void goToMenu() {
    _bgMusic.stop();
    final context = buildContext;
    if (context != null && context.mounted) {
      Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const CaptainSelectScreen()),
        (_) => false);
    }
  }

  @override
  void onRemove() {
    _bgMusic.stop();
    _bgMusic.dispose();
    _sfxShoot.dispose();
    _sfxHit.dispose();
    _sfxAbility.dispose();
    super.onRemove();
  }

  @override
  Color backgroundColor() => const Color(0xFF020A08);
}

// ═══════════════════════════════════════════════════════════════════════════
//  COMPONENTE ENEMIGO
// ═══════════════════════════════════════════════════════════════════════════
class _EnemyComp extends SpriteComponent with TapCallbacks {
  final PC2Game game;
  final int type;
  final double speed;
  double hp;
  final _rng = Random();
  double _phase;
  double _t = 0;

  _EnemyComp({required this.game, required this.type,
    required Vector2 startPos, required this.speed, required this.hp})
    : _phase = Random().nextDouble() * pi * 2,
      super(position: startPos, size: Vector2(64, 64),
        anchor: Anchor.center, priority: 10);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('enemy_type$type.png');
  }

  @override
  void update(double dt) {
    _t += dt;
    // Baja hacia el jugador
    position.y += speed * dt;
    // Movimiento lateral ondulante
    position.x += sin(_t * 2.5 + _phase) * 40 * dt;
    position.x = position.x.clamp(40, game.size.x - 40);

    // Crece al acercarse (efecto pseudo-3D)
    final progress = (position.y / game.size.y).clamp(0.0, 1.0);
    final s = 48 + progress * 120;
    size = Vector2(s, s);

    // Si llega abajo → daño al jugador
    if (position.y > game.size.y + 40) {
      game.takeDamage(0.07);
      removeFromParent();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    hp -= game.captain.damage;
    // Flash de impacto
    add(OpacityEffect.to(0.2,
      EffectController(duration: 0.06, reverseDuration: 0.06)));
    if (hp <= 0) {
      game.onEnemyKilled(position);
      removeFromParent();
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  COMPONENTE BOSS
// ═══════════════════════════════════════════════════════════════════════════
class _BossComp extends SpriteComponent with TapCallbacks {
  final PC2Game game;
  double hp = 50;
  double _t = 0;
  double _atkT = 3.0;

  _BossComp({required this.game, required Vector2 startPos})
    : super(position: startPos, size: Vector2(160, 130),
        anchor: Anchor.center, priority: 10);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('enemy_boss_s1.png');
    // Glow rojo
    add(OpacityEffect.to(0.7,
      EffectController(duration: 1.0, reverseDuration: 1.0,
        infinite: true, alternate: true)));
  }

  @override
  void update(double dt) {
    _t += dt;
    // Movimiento lateral
    position.x = game.size.x / 2 + sin(_t * 0.8) * game.size.x * 0.28;
    // Ataque
    _atkT -= dt;
    if (_atkT <= 0) {
      _atkT = 2.8;
      game.add(_BossBullet(
        game: game,
        startPos: position.clone()));
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    hp -= game.captain.damage;
    add(OpacityEffect.to(0.2,
      EffectController(duration: 0.07, reverseDuration: 0.07)));
    if (hp <= 0) {
      game.onBossKilled(position);
      removeFromParent();
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  BALA DEL JUGADOR
// ═══════════════════════════════════════════════════════════════════════════
class _BulletComp extends CircleComponent {
  final PC2Game game;
  final Vector2 _vel;

  _BulletComp({required this.game,
    required Vector2 startPos, required Vector2 targetPos,
    required double damage})
    : _vel = (targetPos - startPos).normalized() * 900,
      super(radius: 5, position: startPos.clone(),
        anchor: Anchor.center, priority: 50,
        paint: Paint()..color = game.captain.color);

  @override
  void update(double dt) {
    position += _vel * dt;
    if (position.y < -20 || position.x < -20 ||
        position.x > game.size.x + 20) {
      removeFromParent();
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  BALA DEL BOSS
// ═══════════════════════════════════════════════════════════════════════════
class _BossBullet extends CircleComponent {
  final PC2Game game;

  _BossBullet({required this.game, required Vector2 startPos})
    : super(radius: 10, position: startPos.clone(),
        anchor: Anchor.center, priority: 50,
        paint: Paint()..color = const Color(0xFFFF5500));

  @override
  void update(double dt) {
    position.y += 220 * dt;
    if (position.y > game.size.y * 0.82) {
      game.takeDamage(0.09);
      removeFromParent();
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  EXPLOSIÓN
// ═══════════════════════════════════════════════════════════════════════════
class _ExplosionComp extends CircleComponent {
  final bool big;

  _ExplosionComp({required Vector2 position, required this.big})
    : super(
        radius: big ? 60 : 30,
        position: position,
        anchor: Anchor.center,
        priority: 80,
        paint: Paint()..color = const Color(0xFFFF6600));

  @override
  Future<void> onLoad() async {
    add(OpacityEffect.to(0,
      EffectController(duration: big ? 0.6 : 0.35)));
    add(ScaleEffect.to(Vector2.all(big ? 2.5 : 2.0),
      EffectController(duration: big ? 0.6 : 0.35)));
    Future.delayed(Duration(milliseconds: big ? 650 : 380), () {
      if (isMounted) removeFromParent();
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  FLASH DAÑO
// ═══════════════════════════════════════════════════════════════════════════
class _DamageFlash extends RectangleComponent with HasGameRef<PC2Game> {
  _DamageFlash() : super(priority: 200,
    paint: Paint()..color = const Color(0x66FF2244));

  @override
  Future<void> onLoad() async {
    size = gameRef.size;
    add(OpacityEffect.to(0,
      EffectController(duration: 0.35)));
    Future.delayed(const Duration(milliseconds: 380), () {
      if (isMounted) removeFromParent();
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  MIRA
// ═══════════════════════════════════════════════════════════════════════════
class _CrosshairComp extends PositionComponent {
  final Color color;
  _CrosshairComp({required Vector2 position, required this.color})
    : super(position: position, anchor: Anchor.center,
        size: Vector2(52, 52), priority: 150);

  @override
  void render(Canvas canvas) {
    final p = Paint()
      ..color = color.withOpacity(0.85)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    final cx = size.x / 2, cy = size.y / 2;
    canvas.drawLine(Offset(0, cy), Offset(cx - 10, cy), p);
    canvas.drawLine(Offset(cx + 10, cy), Offset(size.x, cy), p);
    canvas.drawLine(Offset(cx, 0), Offset(cx, cy - 10), p);
    canvas.drawLine(Offset(cx, cy + 10), Offset(cx, size.y), p);
    canvas.drawCircle(Offset(cx, cy), 5,
      Paint()..color = color.withOpacity(0.9)
        ..style = PaintingStyle.stroke..strokeWidth = 1.5);
    canvas.drawCircle(Offset(cx, cy), 1.8,
      Paint()..color = color..style = PaintingStyle.fill);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  HUD OVERLAY
// ═══════════════════════════════════════════════════════════════════════════
class _HudComponent extends Component with HasGameRef<PC2Game> {
  _HudComponent({required PC2Game game}) : super(priority: 300);

  @override
  void render(Canvas canvas) {
    final g = gameRef;
    final sz = g.size;
    final cap = g.captain;

    // ── Hull bar ────────────────────────────────────────────────────────
    _drawBar(canvas, label: 'HULL',
      x: 14, y: 48, w: 110, h: 6,
      value: g.hull,
      color: g.hull > 0.5 ? cIce : g.hull > 0.25 ? cGold : cRed);

    // ── Ability bar ─────────────────────────────────────────────────────
    _drawBarRight(canvas, label: cap.ability,
      x: sz.x - 14, y: 48, w: 90, h: 5,
      value: g.abilityCharge,
      color: g.abilityActive ? Colors.white : cap.color);

    // ── Stage label ─────────────────────────────────────────────────────
    _drawText(canvas, 'STAGE 1 · TECHO DE NAVE ALIENÍGENA',
      sz.x / 2, 54, 9, Colors.white.withOpacity(0.28),
      center: true);

    // ── Score ───────────────────────────────────────────────────────────
    _drawText(canvas,
      'SCORE ${g.score.toString().padLeft(6, '0')}',
      14, sz.y * 0.68, 11, Colors.white54);

    // ── Bajas ───────────────────────────────────────────────────────────
    if (!g.bossSpawned) {
      _drawText(canvas, 'BAJAS: ${g.killed}/20',
        sz.x - 14, sz.y * 0.68, 10, cap.color.withOpacity(0.65),
        right: true);
    }

    // ── Boss HP bar ─────────────────────────────────────────────────────
    if (g.bossSpawned && !g.bossDead) {
      final boss = g.children.whereType<_BossComp>().firstOrNull;
      if (boss != null) {
        _drawText(canvas, '⚠ COMANDANTE ALIENÍGENA',
          sz.x / 2, 88, 9, cRed, center: true);
        _drawBarCenter(canvas, x: sz.x/2, y: 100, w: sz.x - 80, h: 7,
          value: (boss.hp / 50).clamp(0, 1), color: cRed);
      }
    }

    // ── Boss muerto ─────────────────────────────────────────────────────
    if (g.bossDead) {
      _drawText(canvas, 'SECTOR LIMPIO',
        sz.x / 2, sz.y * 0.4, 26, cap.color, center: true);
      _drawText(canvas, 'DESCENDIENDO A LA NAVE...',
        sz.x / 2, sz.y * 0.4 + 36, 13, Colors.white54, center: true);
    }

    // ── Casco crítico ────────────────────────────────────────────────────
    if (g.hull < 0.15) {
      _drawText(canvas, '⚠ CASCO CRÍTICO ⚠',
        sz.x / 2, sz.y * 0.38, 15, cRed, center: true);
    }

    // ── Botón habilidad (visual) ─────────────────────────────────────────
    final btnX = sz.x - 46.0;
    final btnY = sz.y * 0.67;
    final btnPaint = Paint()
      ..color = (g.abilityCharge >= 1.0
        ? cap.color.withOpacity(0.22)
        : Colors.black54);
    canvas.drawCircle(Offset(btnX, btnY), 30, btnPaint);
    canvas.drawCircle(Offset(btnX, btnY), 30,
      Paint()..color = g.abilityActive ? Colors.white :
        g.abilityCharge >= 1.0 ? cap.color : Colors.white24
        ..style = PaintingStyle.stroke..strokeWidth = 2);

    // ── Pause button (visual) ─────────────────────────────────────────
    canvas.drawCircle(Offset(sz.x - 62, 54), 17,
      Paint()..color = Colors.black45);
    canvas.drawCircle(Offset(sz.x - 62, 54), 17,
      Paint()..color = Colors.white24
        ..style = PaintingStyle.stroke..strokeWidth = 1);
  }

  void _drawBar(Canvas c, {required String label, required double x,
    required double y, required double w, required double h,
    required double value, required Color color}) {
    final tp = TextPainter(
      text: TextSpan(text: label,
        style: TextStyle(color: color.withOpacity(0.7), fontSize: 8,
          fontFamily: 'monospace',
          shadows: const [Shadow(color: Colors.black, blurRadius: 4)])),
      textDirection: TextDirection.ltr)..layout();
    tp.paint(c, Offset(x, y - 12));
    c.drawRRect(RRect.fromLTRBR(x, y, x+w, y+h, const Radius.circular(3)),
      Paint()..color = Colors.black38);
    c.drawRRect(RRect.fromLTRBR(x, y, x+w*value.clamp(0,1), y+h,
      const Radius.circular(3)), Paint()..color = color);
  }

  void _drawBarRight(Canvas c, {required String label, required double x,
    required double y, required double w, required double h,
    required double value, required Color color}) {
    final tp = TextPainter(
      text: TextSpan(text: label,
        style: TextStyle(color: color, fontSize: 8, fontFamily: 'monospace',
          shadows: const [Shadow(color: Colors.black, blurRadius: 4)])),
      textDirection: TextDirection.ltr)..layout();
    tp.paint(c, Offset(x - tp.width, y - 12));
    c.drawRRect(RRect.fromLTRBR(x-w, y, x, y+h, const Radius.circular(2)),
      Paint()..color = Colors.black38);
    c.drawRRect(RRect.fromLTRBR(x-w, y, x-w+w*value.clamp(0,1), y+h,
      const Radius.circular(2)), Paint()..color = color);
  }

  void _drawBarCenter(Canvas c, {required double x, required double y,
    required double w, required double h, required double value,
    required Color color}) {
    c.drawRRect(RRect.fromLTRBR(x-w/2, y, x+w/2, y+h,
      const Radius.circular(3)), Paint()..color = Colors.black38);
    c.drawRRect(RRect.fromLTRBR(x-w/2, y, x-w/2+w*value, y+h,
      const Radius.circular(3)), Paint()..color = color);
  }

  void _drawText(Canvas c, String text, double x, double y, double size,
    Color color, {bool center = false, bool right = false}) {
    final tp = TextPainter(
      text: TextSpan(text: text,
        style: TextStyle(color: color, fontSize: size,
          fontFamily: 'monospace', fontWeight: FontWeight.bold,
          shadows: const [Shadow(color: Colors.black, blurRadius: 5)])),
      textDirection: TextDirection.ltr)..layout();
    double dx = x;
    if (center) dx = x - tp.width / 2;
    if (right) dx = x - tp.width;
    tp.paint(c, Offset(dx, y));
  }
}
