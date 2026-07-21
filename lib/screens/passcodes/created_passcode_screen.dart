import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:api_app/models/passcode_creation_result.dart';
import 'package:api_app/models/passcodes_form_data.dart';

class CreatedPasscodeScreen extends StatelessWidget {
  final PasscodeCreationResult result;
  final DateTime startDate;
  final DateTime? endDate;
  final String lockAlias;
  final int passcodeType;

  const CreatedPasscodeScreen({
    super.key,
    required this.result, required this.startDate, this.endDate, required this.lockAlias, required this.passcodeType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [

              const SizedBox(height: 80),

              const Icon(
                Icons.lock_open,
                size: 70,
              ),

              const SizedBox(height: 25),

              Text(
                passcodeType == 4
                    ? 'Código para eliminar registros'
                    : 'Código generado correctamente',
                style: const TextStyle(
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
              const SizedBox(height: 20,),
              if (passcodeType == 4) ...[
                const SizedBox(height: 20),
                const Card(
                  elevation: 2,
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Este código debe introducirse en la cerradura.\n\n'
                      'Al utilizarlo se eliminarán todos los códigos registrados, '
                      'excepto el código administrador.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
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

                        Share.share(buildShareMessage());

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
                    if (passcodeType == 4) {
                      Navigator.pop(context, true);
                    } else {
                      Navigator.pop(context, true);
                      Navigator.pop(context, true);
                    }
                  },
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  String buildShareMessage() {
    if (passcodeType == 4) {
      return [
        'Código para eliminar registros',
        '',
        result.keyboardPwd,
        '',
        'Este código debe introducirse en la cerradura.',
        'Al utilizarlo se eliminarán todos los códigos registrados, excepto el administrador.',
        '',
        'Cerradura:',
        lockAlias,
      ].join('\n');
    }
    final hasEndDate =
        passcodeType != 1 &&
        passcodeType != 2;
    return [
      
      'Muy buen día,',

      'Has recibido el siguiente código de acceso de tipo '
      '${PasscodesFormData.typeNames[passcodeType]?.toLowerCase()}:',
      '',
      result.keyboardPwd,
      '',
      'Válido desde:',
      formatDateTime(startDate),
      'Hasta:',
      hasEndDate
          ? formatDateTime(endDate!)
          : '-',
      'Puedes aperturar la bóveda del vehículo económico:',
      lockAlias,
      'Saludos.',
    ].join('\n');
  }

  String formatDateTime(DateTime date) {
    return '${date.day}/'
        '${date.month}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2,'0')}:'
        '${date.minute.toString().padLeft(2,'0')}';
  }
}