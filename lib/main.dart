import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';

// ══════════════════════════════════════════════════════════
// PHOENIX CORE 2 — "No puedes ganarte a ti mismo siendo tú mismo"
// Motor: Flame Engine 1.18
// Gustavo Enrique Garay — ALTEA-GARAY
// ══════════════════════════════════════════════════════════

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PC2App());
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

// ══════════════════════════════════════════════════════════
// COLORES
// ══════════════════════════════════════════════════════════
const cIce     = Color(0xFF00DDFF);
const cFire    = Color(0xFFFF5500);
const cGold    = Color(0xFFFFD700);
const cRed     = Color(0xFFFF2244);
const cPurple  = Color(0xFF9944FF);
const cBg      = Color(0xFF080C18);
const cPanel   = Color(0xFF0D1420);

// ══════════════════════════════════════════════════════════
// CAPITANES — Los 3 hijos de Gustavo
// ══════════════════════════════════════════════════════════
enum Captain { danny, andy, denise }

class CaptainData {
  final Captain id;
  final String name;
  final String fullName;
  final String title;
  final String ability;
  final String abilityDesc;
  final String tradeoff;
  final String style;
  final Color color;
  final String emoji;
  final double damage;      // multiplicador
  final double speed;       // multiplicador
  final double hullMax;     // HP del casco

  const CaptainData({
    required this.id, required this.name, required this.fullName,
    required this.title, required this.ability, required this.abilityDesc,
    required this.tradeoff, required this.style, required this.color,
    required this.emoji, required this.damage, required this.speed,
    required this.hullMax,
  });
}

const captains = [
  CaptainData(
    id: Captain.danny, name: 'DANNY', fullName: 'Daniel Garay',
    title: 'El Estratega', emoji: '🪖',
    ability: 'MODO FÉNIX',
    abilityDesc: 'Anticipa el peligro 90ms antes.\nVentana de daño máximo en boss.',
    tradeoff: 'Cadencia lenta — necesita timing perfecto',
    style: 'Lento · Preciso · Devastador',
    color: cGold,
    damage: 1.8, speed: 0.75, hullMax: 120,
  ),
  CaptainData(
    id: Captain.andy, name: 'ANDY', fullName: 'Andres Garay',
    title: 'El Impulsivo', emoji: '⚡',
    ability: 'MODO KALMAN',
    abilityDesc: 'Estabiliza la realidad local.\nCadencia x2 en zona de calor.',
    tradeoff: 'Hull baja 2x más rápido — frágil',
    style: 'Rápido · Agresivo · Alto riesgo',
    color: cIce,
    damage: 1.0, speed: 1.5, hullMax: 70,
  ),
  CaptainData(
    id: Captain.denise, name: 'DENISE', fullName: 'Denise Garay',
    title: 'La Guardiana', emoji: '🛡️',
    ability: 'WATCH DOG',
    abilityDesc: 'Teletransporte de emergencia\ncuando hull < 15%.',
    tradeoff: 'Menor daño base — solo brilla sobreviviendo',
    style: 'Defensivo · Supervivencia · Control',
    color: cPurple,
    damage: 0.8, speed: 1.0, hullMax: 150,
  ),
];

// ══════════════════════════════════════════════════════════
// PANTALLA DE SELECCIÓN DE CAPITÁN
// ══════════════════════════════════════════════════════════
class CaptainSelectScreen extends StatefulWidget {
  const CaptainSelectScreen({super.key});
  @override State<CaptainSelectScreen> createState() => _CaptainSelectState();
}

class _CaptainSelectState extends State<CaptainSelectScreen>
    with TickerProviderStateMixin {

  int _selected = 0;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulse = Tween(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override void dispose() { _pulseCtrl.dispose(); super.dispose(); }

  @override Widget build(BuildContext ctx) {
    final cap = captains[_selected];
    return Scaffold(
      backgroundColor: cBg,
      body: SafeArea(child: Column(children: [

        // Header
        Padding(padding: const EdgeInsets.all(20), child: Column(children: [
          Text('PHOENIX CORE II', style: TextStyle(
            color: cap.color, fontSize: 22, fontWeight: FontWeight.bold,
            letterSpacing: 4, fontFamily: 'monospace')),
          const SizedBox(height: 4),
          const Text('"No puedes ganarte a ti mismo siendo tú mismo"',
            style: TextStyle(color: Colors.white38, fontSize: 11,
              fontStyle: FontStyle.italic)),
        ])),

        // Selector de capitanes
        SizedBox(height: 80, child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(captains.length, (i) {
            final c = captains[i];
            final sel = i == _selected;
            return GestureDetector(
              onTap: () => setState(() => _selected = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: sel ? 80 : 64,
                height: sel ? 80 : 64,
                decoration: BoxDecoration(
                  color: sel ? c.color.withOpacity(0.2) : cPanel,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: sel ? c.color : Colors.white12,
                    width: sel ? 2.5 : 1),
                ),
                child: Center(child: Text(c.emoji,
                  style: TextStyle(fontSize: sel ? 32 : 26))),
              ),
            );
          }),
        )),

        const SizedBox(height: 20),

        // Panel del capitán seleccionado
        Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (ctx, _) => Transform.scale(
              scale: _selected == 1 ? _pulse.value : 1.0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cPanel,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cap.color.withOpacity(0.4), width: 1.5),
                  boxShadow: [BoxShadow(
                    color: cap.color.withOpacity(0.15),
                    blurRadius: 30, spreadRadius: 5)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre y título
                    Row(children: [
                      Text(cap.emoji, style: const TextStyle(fontSize: 36)),
                      const SizedBox(width: 12),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(cap.name, style: TextStyle(
                          color: cap.color, fontSize: 24,
                          fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                        Text(cap.fullName, style: const TextStyle(
                          color: Colors.white54, fontSize: 12)),
                        Text(cap.title, style: TextStyle(
                          color: cap.color.withOpacity(0.7), fontSize: 13,
                          fontStyle: FontStyle.italic)),
                      ]),
                    ]),

                    const SizedBox(height: 20),
                    _divider(cap.color),
                    const SizedBox(height: 16),

                    // Habilidad
                    _label('HABILIDAD ESPECIAL', cap.color),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cap.color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: cap.color.withOpacity(0.3)),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Text(cap.ability, style: TextStyle(
                          color: cap.color, fontSize: 15,
                          fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                        const SizedBox(height: 4),
                        Text(cap.abilityDesc, style: const TextStyle(
                          color: Colors.white70, fontSize: 12, height: 1.5)),
                      ]),
                    ),

                    const SizedBox(height: 16),

                    // Stats
                    _label('ESTADÍSTICAS', cap.color),
                    const SizedBox(height: 8),
                    _statBar('DAÑO', cap.damage / 1.8, cap.color),
                    _statBar('VELOCIDAD', cap.speed / 1.5, cap.color),
                    _statBar('CASCO', cap.hullMax / 150, cap.color),

                    const SizedBox(height: 12),

                    // Trade-off
                    Row(children: [
                      const Text('⚠ ', style: TextStyle(fontSize: 14)),
                      Expanded(child: Text(cap.tradeoff, style: const TextStyle(
                        color: Colors.orange, fontSize: 11,
                        fontStyle: FontStyle.italic))),
                    ]),

                    const SizedBox(height: 8),
                    Text(cap.style, style: TextStyle(
                      color: cap.color.withOpacity(0.6), fontSize: 11,
                      letterSpacing: 1)),
                  ],
                ),
              ),
            ),
          ),
        )),

        // Botón confirmar
        Padding(
          padding: const EdgeInsets.all(24),
          child: GestureDetector(
            onTap: () => Navigator.pushReplacement(ctx,
              MaterialPageRoute(builder: (_) =>
                PC2GameWrapper(captain: captains[_selected]))),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: cap.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cap.color, width: 2),
                boxShadow: [BoxShadow(
                  color: cap.color.withOpacity(0.3),
                  blurRadius: 20)],
              ),
              child: Center(child: Text(
                'DESPLEGAR — ${cap.name}',
                style: TextStyle(color: cap.color, fontSize: 16,
                  fontWeight: FontWeight.bold, letterSpacing: 3,
                  fontFamily: 'monospace'),
              )),
            ),
          ),
        ),
      ])),
    );
  }

  Widget _divider(Color c) => Container(height: 1,
    decoration: BoxDecoration(gradient: LinearGradient(
      colors: [Colors.transparent, c.withOpacity(0.5), Colors.transparent])));

  Widget _label(String t, Color c) => Text(t, style: TextStyle(
    color: c.withOpacity(0.7), fontSize: 10, letterSpacing: 2,
    fontFamily: 'monospace'));

  Widget _statBar(String label, double val, Color c) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      SizedBox(width: 80, child: Text(label, style: const TextStyle(
        color: Colors.white38, fontSize: 10, fontFamily: 'monospace'))),
      Expanded(child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: LinearProgressIndicator(
          value: val.clamp(0, 1), minHeight: 6,
          backgroundColor: Colors.white10,
          valueColor: AlwaysStoppedAnimation(c)),
      )),
    ]),
  );
}

// ══════════════════════════════════════════════════════════
// WRAPPER — Flame Game dentro de Flutter
// ══════════════════════════════════════════════════════════
class PC2GameWrapper extends StatelessWidget {
  final CaptainData captain;
  const PC2GameWrapper({super.key, required this.captain});

  @override Widget build(BuildContext ctx) {
    final game = PhoenixCore2Game(captain: captain);
    return GameWidget(
      game: game,
      overlayBuilderMap: {
        'hud': (ctx, g) => PC2HUD(game: g as PhoenixCore2Game),
        'pause': (ctx, g) => PC2PauseMenu(game: g as PhoenixCore2Game),
      },
    );
  }
}

// ══════════════════════════════════════════════════════════
// FLAME GAME PRINCIPAL
// ══════════════════════════════════════════════════════════
class PhoenixCore2Game extends FlameGame
    with HasCollisionDetection {

  final CaptainData captain;
  PhoenixCore2Game({required this.captain});

  // Estado del juego
  double hullIntegrity = 1.0;
  double abilityCharge = 0.0;
  bool abilityActive = false;
  double abilityTimer = 0;
  int kills = 0;
  int score = 0;
  String currentWorld = 'SECTOR OMEGA-9';

  // Cielo VHDL
  late VHDLSky _vhdlSky;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Fondo VHDL
    _vhdlSky = VHDLSky(captain: captain);
    add(_vhdlSky);

    // HUD overlay
    overlays.add('hud');

    // Hull inicial según capitán
    hullIntegrity = captain.hullMax / 150.0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Cargar habilidad gradualmente
    if (!abilityActive && abilityCharge < 1.0) {
      abilityCharge = (abilityCharge + dt * 0.08).clamp(0, 1);
    }

    // Timer de habilidad activa
    if (abilityActive) {
      abilityTimer -= dt;
      if (abilityTimer <= 0) {
        abilityActive = false;
        abilityCharge = 0;
      }
    }
  }

  void activateAbility() {
    if (abilityCharge < 1.0 || abilityActive) return;
    abilityActive = true;
    abilityTimer = switch(captain.id) {
      Captain.danny  => 8.0,   // Phoenix Mode 8s
      Captain.andy   => 5.0,   // Kalman Mode 5s
      Captain.denise => 3.0,   // Watch Dog instant
    };
  }

  void takeDamage(double amount) {
    final reduced = amount / (abilityActive && captain.id == Captain.denise ? 2.0 : 1.0);
    hullIntegrity = (hullIntegrity - reduced / captain.hullMax).clamp(0, 1);
    if (hullIntegrity < 0.15 && captain.id == Captain.denise) {
      _triggerWatchDog();
    }
  }

  void _triggerWatchDog() {
    // Teletransporte de emergencia — Denise
    hullIntegrity = (hullIntegrity + 0.3).clamp(0, 1);
    abilityCharge = 0;
  }
}

// ══════════════════════════════════════════════════════════
// CIELO VHDL — El mundo del Doppelganger
// ══════════════════════════════════════════════════════════
class VHDLSky extends Component with HasGameRef<PhoenixCore2Game> {

  final CaptainData captain;
  final _rng = Random();
  final List<_VHDLLine> _lines = [];
  double _spawnTimer = 0;
  double _glitchTimer = 0;
  bool _glitchActive = false;

  VHDLSky({required this.captain});

  // Fragmentos de código VHDL que caen
  static const _vhdlFragments = [
    'signal t_predicted : t_voltage := 0;',
    'if d3T_raw > JERK_LIMIT then',
    'px_state <= ST_PRE_ARM;',
    'binom_raw := 4*t1 - 6*t2 + 4*t3 - t4;',
    'phoenix_suppress <= \'1\';',
    'pre_arm_cnt <= pre_arm_cnt + 1;',
    'ENTITY FiberNode IS PORT(',
    'arm_confirm_cnt <= 0;',
    'cap_energy <= new_cap;',
    'delta_event <= \'1\';',
    '-- ALTEA-GARAY v7.3',
    'JERK_LIMIT := 512;',
    'dead_cnt <= DEAD_TIME_CYC;',
    'ST_SUPPRESSING => NULL;',
    'CORRUPT_SECTOR_0x4F;',    // Líneas corruptas del Doppelganger
    'OVERRIDE_PROTOCOL_9;',
    'MEMORY_VIOLATION_0xFF;',
    'ENTROPY_CASCADE > MAX;',
  ];

  @override
  void update(double dt) {
    // Spawner de líneas VHDL
    _spawnTimer -= dt;
    if (_spawnTimer <= 0) {
      _spawnTimer = 0.3 + _rng.nextDouble() * 0.8;
      _spawnLine();
    }

    // Actualizar líneas
    for (final line in _lines) line.update(dt);
    _lines.removeWhere((l) => l.isDead);

    // Glitch del Doppelganger
    _glitchTimer -= dt;
    if (_glitchTimer <= 0) {
      _glitchActive = !_glitchActive;
      _glitchTimer = _glitchActive ? 0.1 + _rng.nextDouble() * 0.3 : 2.0 + _rng.nextDouble() * 3.0;
    }
  }

  void _spawnLine() {
    final isCorrupt = _rng.nextDouble() < 0.2;
    _lines.add(_VHDLLine(
      text: _vhdlFragments[_rng.nextInt(_vhdlFragments.length)],
      x: _rng.nextDouble() * (gameRef.size.x),
      speed: 40 + _rng.nextDouble() * 80,
      isCorrupt: isCorrupt,
      screenHeight: gameRef.size.y,
    ));
  }

  @override
  void render(Canvas canvas) {
    // Fondo base
    final bgPaint = Paint()..color = const Color(0xFF04080F);
    canvas.drawRect(Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y), bgPaint);

    // Líneas VHDL
    for (final line in _lines) line.render(canvas);

    // Overlay de glitch del Doppelganger
    if (_glitchActive) {
      final glitchPaint = Paint()
        ..color = const Color(0x11FF0044);
      canvas.drawRect(Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y), glitchPaint);
    }
  }
}

class _VHDLLine {
  final String text;
  double x, y;
  final double speed;
  final bool isCorrupt;
  final double screenHeight;
  bool isDead = false;
  double opacity = 1.0;

  _VHDLLine({required this.text, required this.x, required this.speed,
    required this.isCorrupt, required this.screenHeight}) : y = -20;

  void update(double dt) {
    y += speed * dt;
    if (y > screenHeight + 20) isDead = true;
    // Fade out al fondo
    if (y > screenHeight * 0.7) {
      opacity = ((screenHeight - y) / (screenHeight * 0.3)).clamp(0, 1);
    }
  }

  void render(Canvas canvas) {
    final color = isCorrupt
      ? Color.fromARGB((opacity * 180).toInt(), 255, 30, 60)
      : Color.fromARGB((opacity * 120).toInt(), 0, 200, 100);

    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(
        color: color, fontSize: 9, fontFamily: 'monospace',
        letterSpacing: 0.5)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x, y));
  }
}

// ══════════════════════════════════════════════════════════
// HUD PC2 — Primera persona
// ══════════════════════════════════════════════════════════
class PC2HUD extends StatelessWidget {
  final PhoenixCore2Game game;
  const PC2HUD({super.key, required this.game});

  @override Widget build(BuildContext ctx) {
    final cap = game.captain;
    return SafeArea(child: Stack(children: [

      // Hull bar — arriba izquierda
      Positioned(top: 16, left: 16, child: _HullBar(game: game)),

      // Ability charge — arriba derecha
      Positioned(top: 16, right: 16, child: _AbilityIndicator(game: game)),

      // Mundo actual — centro arriba
      Positioned(top: 16, left: 0, right: 0, child: Center(
        child: Text(game.currentWorld, style: TextStyle(
          color: cap.color.withOpacity(0.6), fontSize: 10,
          fontFamily: 'monospace', letterSpacing: 2)),
      )),

      // Score — abajo izquierda
      Positioned(bottom: 30, left: 16, child: Text(
        'SCORE ${game.score}',
        style: const TextStyle(color: Colors.white54, fontSize: 12,
          fontFamily: 'monospace'))),

      // Botón habilidad — abajo derecha
      Positioned(bottom: 20, right: 16, child: _AbilityButton(game: game)),

      // Mira central
      Center(child: _Crosshair(color: cap.color)),

      // Warning hull crítico
      if (game.hullIntegrity < 0.15)
        Center(child: Padding(
          padding: const EdgeInsets.only(top: 200),
          child: Text('⚠ CASCO CRÍTICO ⚠',
            style: TextStyle(color: cRed.withOpacity(0.8),
              fontSize: 14, fontFamily: 'monospace',
              fontWeight: FontWeight.bold)),
        )),
    ]));
  }
}

class _HullBar extends StatelessWidget {
  final PhoenixCore2Game game;
  const _HullBar({required this.game});
  @override Widget build(BuildContext ctx) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('HULL', style: TextStyle(
        color: game.captain.color.withOpacity(0.6),
        fontSize: 9, fontFamily: 'monospace')),
      const SizedBox(height: 3),
      SizedBox(width: 120, height: 6,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: game.hullIntegrity,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation(
              game.hullIntegrity > 0.5 ? cIce :
              game.hullIntegrity > 0.25 ? cGold : cRed),
          ))),
    ]);
}

class _AbilityIndicator extends StatelessWidget {
  final PhoenixCore2Game game;
  const _AbilityIndicator({required this.game});
  @override Widget build(BuildContext ctx) => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(game.captain.ability,
        style: TextStyle(color: game.captain.color,
          fontSize: 9, fontFamily: 'monospace')),
      const SizedBox(height: 3),
      SizedBox(width: 80, height: 4,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: game.abilityCharge,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation(
              game.abilityActive ? Colors.white : game.captain.color),
          ))),
    ]);
}

class _AbilityButton extends StatelessWidget {
  final PhoenixCore2Game game;
  const _AbilityButton({required this.game});
  @override Widget build(BuildContext ctx) => GestureDetector(
    onTap: game.activateAbility,
    child: Container(
      width: 64, height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: game.abilityCharge >= 1.0
          ? game.captain.color.withOpacity(0.25) : Colors.black38,
        border: Border.all(
          color: game.abilityActive ? Colors.white :
            game.abilityCharge >= 1.0 ? game.captain.color : Colors.white24,
          width: 2),
      ),
      child: Center(child: Text(game.captain.emoji,
        style: const TextStyle(fontSize: 24))),
    ),
  );
}

class _Crosshair extends StatelessWidget {
  final Color color;
  const _Crosshair({required this.color});
  @override Widget build(BuildContext ctx) => CustomPaint(
    size: const Size(40, 40),
    painter: _CrosshairPainter(color: color),
  );
}

class _CrosshairPainter extends CustomPainter {
  final Color color;
  const _CrosshairPainter({required this.color});
  @override void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color.withOpacity(0.7)..strokeWidth = 1.5;
    final cx = size.width / 2, cy = size.height / 2;
    canvas.drawLine(Offset(0, cy), Offset(cx - 8, cy), p);
    canvas.drawLine(Offset(cx + 8, cy), Offset(size.width, cy), p);
    canvas.drawLine(Offset(cx, 0), Offset(cx, cy - 8), p);
    canvas.drawLine(Offset(cx, cy + 8), Offset(cx, size.height), p);
    canvas.drawCircle(Offset(cx, cy), 2, p..style = PaintingStyle.fill);
  }
  @override bool shouldRepaint(_) => false;
}

// ══════════════════════════════════════════════════════════
// MENÚ DE PAUSA
// ══════════════════════════════════════════════════════════
class PC2PauseMenu extends StatelessWidget {
  final PhoenixCore2Game game;
  const PC2PauseMenu({super.key, required this.game});
  @override Widget build(BuildContext ctx) => Container(
    color: Colors.black54,
    child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text('PAUSA', style: TextStyle(color: game.captain.color,
        fontSize: 28, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
      const SizedBox(height: 30),
      _btn('CONTINUAR', game.captain.color, () => game.overlays.remove('pause')),
      const SizedBox(height: 12),
      _btn('MENÚ PRINCIPAL', Colors.white38, () =>
        Navigator.pushReplacement(ctx, MaterialPageRoute(
          builder: (_) => const CaptainSelectScreen()))),
    ])),
  );

  Widget _btn(String t, Color c, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 200, height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c), color: c.withOpacity(0.1)),
      child: Center(child: Text(t, style: TextStyle(
        color: c, fontSize: 13, fontFamily: 'monospace')))));
}
