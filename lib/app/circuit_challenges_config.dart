import '../domain/models/circuit_challenge.dart';

/// (skillId, taskIndex) -> CircuitChallenge. Simülasyonu olan görevler burada tanımlı.
CircuitChallenge? getCircuitChallenge(String skillId, int taskIndex) {
  if (skillId == 'skill-led' && taskIndex == 0) {
    return _ledCircuitChallenge;
  }
  if (skillId == 'skill-akim-gerilim' && taskIndex == 0) {
    return _akimGerilimChallenge;
  }
  if (skillId == 'skill-direnc' && taskIndex == 0) {
    return _direncChallenge;
  }
  return null;
}

/// LED: 5V → Direnç → LED(+) → LED(-) → GND. Tüm noktalar tek devrede olmalı.
final _ledCircuitChallenge = CircuitChallenge(
  id: 'led-1',
  skillId: 'skill-led',
  taskIndex: 0,
  title: 'Işığı Yak!',
  instruction: '5V\'dan GND\'ye kablo bağla: önce direnç, sonra LED. Doğru bağlayınca LED yanar.',
  nodes: [
    CircuitNode(id: 'arduino_5v', label: '5V', x: 0.12, y: 0.28, type: CircuitNodeType.arduinoPin),
    CircuitNode(id: 'arduino_gnd', label: 'GND', x: 0.12, y: 0.62, type: CircuitNodeType.arduinoPin),
    CircuitNode(id: 'r_a', label: 'R', x: 0.36, y: 0.32, type: CircuitNodeType.componentPin),
    CircuitNode(id: 'r_b', label: 'R', x: 0.36, y: 0.58, type: CircuitNodeType.componentPin),
    CircuitNode(id: 'led_plus', label: 'LED +', x: 0.62, y: 0.32, type: CircuitNodeType.componentPin),
    CircuitNode(id: 'led_minus', label: 'LED −', x: 0.62, y: 0.58, type: CircuitNodeType.componentPin),
  ],
  requiredNodeIds: ['arduino_5v', 'arduino_gnd', 'r_a', 'r_b', 'led_plus', 'led_minus'],
);

final _akimGerilimChallenge = CircuitChallenge(
  id: 'ag-1',
  skillId: 'skill-akim-gerilim',
  taskIndex: 0,
  title: '5V\'dan LED\'e elektrik ver',
  instruction: '5V pinini direnç ve LED üzerinden GND\'ye bağla.',
  nodes: _ledCircuitChallenge.nodes,
  requiredNodeIds: _ledCircuitChallenge.requiredNodeIds,
);

final _direncChallenge = CircuitChallenge(
  id: 'dr-1',
  skillId: 'skill-direnc',
  taskIndex: 0,
  title: 'Dirençli LED devresi kur',
  instruction: 'Direnci devreye seri bağla: 5V → Direnç → LED → GND.',
  nodes: _ledCircuitChallenge.nodes,
  requiredNodeIds: _ledCircuitChallenge.requiredNodeIds,
);
