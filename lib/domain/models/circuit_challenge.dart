/// Tek bir bağlantı noktası (Arduino pini, breadboard deliği, eleman bacağı).
class CircuitNode {
  const CircuitNode({
    required this.id,
    required this.label,
    required this.x,
    required this.y,
    this.type = CircuitNodeType.componentPin,
  });

  final String id;
  final String label;
  /// 0–1 arası oran (sol üst köşe referans)
  final double x;
  final double y;
  final CircuitNodeType type;

  CircuitNode copyWith({double? x, double? y}) => CircuitNode(
        id: id,
        label: label,
        x: x ?? this.x,
        y: y ?? this.y,
        type: type,
      );
}

enum CircuitNodeType {
  arduinoPin,
  breadboard,
  componentPin,
}

/// Bir devre görevi: hangi noktaların birbirine bağlı olması gerekiyor.
class CircuitChallenge {
  const CircuitChallenge({
    required this.id,
    required this.skillId,
    required this.taskIndex,
    required this.title,
    required this.instruction,
    required this.nodes,
    required this.requiredNodeIds,
  });

  final String id;
  final String skillId;
  final int taskIndex;
  final String title;
  final String instruction;
  final List<CircuitNode> nodes;
  /// Bu id'lerin hepsi tek bir bağlı bileşende olmalı (devre doğru kurulmuş).
  final List<String> requiredNodeIds;
}
