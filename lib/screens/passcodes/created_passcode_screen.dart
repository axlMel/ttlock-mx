import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'package:api_app/models/passcode_creation_result.dart';

class CreatedPasscodeScreen extends StatelessWidget {
  final PasscodeCreationResult result;

  const CreatedPasscodeScreen({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Código generado'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [

              const SizedBox(height: 30),

              const Icon(
                Icons.lock_open,
                size: 70,
              ),

              const SizedBox(height: 25),

              const Text(
                'Código generado correctamente',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    children: [

                      const Text(
                        'Código',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height:15),

                      Text(
                        result.keyboardPwd,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height:30),

              Row(
                children: [

                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.copy),
                      label: const Text(
                        'Copiar',
                      ),
                      onPressed: () async {

                        await Clipboard.setData(
                          ClipboardData(
                            text: result.keyboardPwd,
                          ),
                        );

                        if(!context.mounted) return;

                        ScaffoldMessenger.of(context)
                        .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Código copiado'
                            ),
                          ),
                        );

                      },
                    ),
                  ),

                  const SizedBox(width:15),

                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.share),
                      label: const Text(
                        'Compartir',
                      ),
                      onPressed: () {

                        Share.share(
                          'Tu código de acceso es: ${result.keyboardPwd}',
                        );

                      },
                    ),
                  ),

                ],
              ),

              const SizedBox(height:35),

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton.icon(
                  icon: const Icon(Icons.list),

                  label: const Text(
                    'Volver al listado',
                  ),

                  onPressed: () {

                    Navigator.pop(context, true);

                    Navigator.pop(context, true);

                  },
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}