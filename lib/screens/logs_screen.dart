import 'package:flutter/material.dart';

import '../services/logger.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registros'),
        actions: [
          IconButton(
            onPressed: () => AppLogger.I.clear(),
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Limpar registros',
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: AppLogger.I,
        builder: (_, __) {
          final logs = AppLogger.I.logs.toList().reversed.toList();
          if (logs.isEmpty) {
            return const Center(child: Text('Sem registros ainda. Interaja com o app para ver entradas.'));
          }
          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (_, i) {
              final e = logs[i];
              Color tint;
              switch (e.level) {
                case 'ERROR':
                  tint = Colors.redAccent;
                  break;
                case 'WARN':
                  tint = Colors.orangeAccent;
                  break;
                default:
                  tint = Colors.blueGrey;
              }
              return ListTile(
                dense: true,
                leading: Icon(Icons.bug_report, color: tint),
                title: Text(e.message),
                subtitle: Text('${e.level} • ${e.context ?? '-'} • ${e.time.toLocal()}'),
              );
            },
          );
        },
      ),
    );
  }
}
