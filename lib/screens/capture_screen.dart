import 'package:flutter/material.dart';

class CaptureScreen extends StatelessWidget {
  const CaptureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recurso indisponível')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'A captura de itens foi substituída pelo chat visual do Alfredo.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/* Arquivo descontinuado: experiência de captura removida em favor do chat visual Alfredo.

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Conteúdo original mantido apenas por referência histórica.

  // Após revisão do usuário, vamos estimar a validade APENAS para os nomes revisados.

      // Deduplicate reviewed items by case-insensitive name, summing quantities
      final Map<String, Map<String, dynamic>> agg = {};
      for (final it in reviewed) {
        final name = (it['name'] as String).trim();
        final qty = (it['quantity'] as num).toInt();
        final key = name.toLowerCase();
        if (agg.containsKey(key)) {
          agg[key]!['quantity'] = (agg[key]!['quantity'] as int) + (qty <= 0 ? 1 : qty);
        } else {
          agg[key] = {
            'name': name,
            'quantity': qty <= 0 ? 1 : qty,
          };
        }
      }
      final deduped = agg.values.toList();

      if (mounted) {
        setState(() {
          _loading = true;
          _loadingLabel = 'Analisando validade…';
        });
      }
      // Estimar validade (dias) para os nomes deduplicados
      final names = deduped.map((e) => (e['name'] as String)).toList();
      Map<String, int> daysByName = {};
      try {
        final expiryData = await service.estimateExpiryForItems(names);
        if (!mounted) return;
        final list = (expiryData['items'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
        for (final e in list) {
          final nm = (e['name']?.toString() ?? '').trim().toLowerCase();
          final dy = (e['days'] is num) ? (e['days'] as num).toInt() : int.tryParse(e['days']?.toString() ?? '') ?? 3;
          if (nm.isNotEmpty) daysByName[nm] = dy;
        }
        logInfo('Expiry estimated for ${daysByName.length}/${names.length} item(s)', context: 'Capture');
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Não foi possível estimar as validades. Usando padrão de 3 dias.')),
          );
        }
        logWarn('Expiry estimation failed: $e', context: 'Capture');
      }

      final now = DateTime.now();
      final created = <GroceryItem>[];
      for (final item in deduped) {
        final n = item['name'] as String;
        final qty = (item['quantity'] as num).toInt();
        final days = daysByName[n.toLowerCase()] ?? 3;
        final expiry = now.add(Duration(days: days));
        created.add(
          GroceryItem(
            id: '${now.microsecondsSinceEpoch}-${n.toLowerCase()}',
            name: n,
            capturedAt: now,
            estimatedExpiry: expiry,
            quantity: qty <= 0 ? 1 : qty,
          ),
        );
      }
      await LocalStorageService.upsertMany(created);
      logInfo('Saved ${created.length} item(s) to storage', context: 'Capture');
      if (!mounted) return;
      // Go straight to the items list replacing the capture screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ItemsScreen()),
      );
    } catch (e) {
      // Unexpected failure: show a snackbar and keep on screen for retry
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Algo deu errado. Tente novamente.')),
        );
      }
      setState(() => _error = e.toString());
      logError('Capture flow error: $e', context: 'Capture');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: AppBar(title: const Text('Capturar')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Builder(builder: (_) {
                  if (kIsWeb) {
                    if (_imageBytes != null) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                      );
                    }
                    if (_webCamLoading) {
                      return const CircularProgressIndicator();
                    }
                    if (_webCamController != null && _webCamController!.value.isInitialized) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: _webCamController!.value.aspectRatio,
                          child: CameraPreview(_webCamController!),
                        ),
                      );
                    }
                    return const Text('Inicializando webcam...');
                  } else {
                    return _imageBytes == null
                        ? const Text('Tire uma foto das suas compras')
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                          );
                  }
                }),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (!kIsWeb) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Tirar foto'),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: FilledButton.icon(
                    onPressed: !_loading ? _process : null,
                    icon: _loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: Text(
                      _loading
                          ? (_loadingLabel.isNotEmpty ? _loadingLabel : 'Processando…')
                          : 'Detectar e revisar',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _pickFromGallery,
                icon: const Icon(Icons.folder_open),
                label: const Text('Enviar imagem (Demo)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
