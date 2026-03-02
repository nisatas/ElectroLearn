import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../app/colors.dart';
import '../../domain/models/circuit_challenge.dart';

/// Devre simülasyonu: JavaScript (HTML5 Canvas) WebView ile çalışır.
/// Konfigürasyon Flutter'dan enjekte edilir; tamamlanınca [CircuitBridge] channel ile Flutter'a bildirilir.
class CircuitSimulatorScreen extends StatefulWidget {
  const CircuitSimulatorScreen({
    super.key,
    required this.challenge,
    required this.onComplete,
  });

  final CircuitChallenge challenge;
  final Future<void> Function() onComplete;

  @override
  State<CircuitSimulatorScreen> createState() => _CircuitSimulatorScreenState();
}

class _CircuitSimulatorScreenState extends State<CircuitSimulatorScreen> {
  bool _success = false;
  late final WebViewController _controller;
  String? _configJson;

  static String _challengeToJson(CircuitChallenge c) {
    final map = <String, dynamic>{
      'nodes': c.nodes.map((n) => {'id': n.id, 'label': n.label, 'x': n.x, 'y': n.y}).toList(),
      'requiredNodeIds': c.requiredNodeIds,
    };
    return jsonEncode(map);
  }

  @override
  void initState() {
    super.initState();
    _configJson = _challengeToJson(widget.challenge);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'CircuitBridge',
        onMessageReceived: (JavaScriptMessage msg) {
          try {
            final data = jsonDecode(msg.message) as Map<String, dynamic>;
            if (data['type'] == 'complete' && mounted) {
              setState(() => _success = true);
            }
          } catch (_) {}
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) async {
            if (_configJson != null) {
              await _controller.runJavaScript(
                'window.__circuitConfig = $_configJson; if (typeof startCircuit === "function") startCircuit();',
              );
            }
          },
        ),
      )
      ..loadFlutterAsset('assets/circuit_simulator/index.html');
  }

  Future<void> _clearWires() async {
    if (_success) return;
    try {
      await _controller.runJavaScript('if (typeof clearWires === "function") clearWires();');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.challenge;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(c.title),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        actions: [
          if (!_success)
            TextButton.icon(
              onPressed: _clearWires,
              icon: const Icon(Icons.delete_outline, size: 20),
              label: const Text('Kabloları kaldır'),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(
                c.instruction,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                    ),
              ),
            ),
            Expanded(
              child: WebViewWidget(controller: _controller),
            ),
            if (_success) ...[
              Container(
                margin: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF58CC02).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF58CC02), width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Color(0xFF58CC02), size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'LED yandı! Devreyi doğru kurdun.',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: FilledButton.icon(
                  onPressed: () async {
                    await widget.onComplete();
                    if (context.mounted) Navigator.of(context).pop(true);
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Görevi tamamla'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF58CC02),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ] else
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'İpucu: İki noktaya sırayla dokunarak kablo bağla.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary.withOpacity(0.7),
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
