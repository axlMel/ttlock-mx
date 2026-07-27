import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:api_app/models/qrcodes/qrcode_creation_result.dart';
import 'package:api_app/models/qrcodes/qrcode_form_data.dart';
import 'package:api_app/models/ekey.dart';

class CreatedQrcodeScreen extends StatelessWidget {
  final QrcodeCreationResult result;
  final DateTime startDate;
  final DateTime? endDate;
  final EKey keyData;
  final int qrcodeType;

  const CreatedQrcodeScreen({
    super.key,
    required this.result, required this.startDate, this.endDate, required this.keyData, required this.qrcodeType,
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
                Icons.qr_code_2_rounded,
                size: 70,
              ),
              const SizedBox(height: 25),
              const Text(
                'Código QR generado correctamente',
                textAlign: TextAlign.center,
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
                        'Enlace del código QR',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 15),

                      SelectableText(
                        result.link,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 18),

                      const Text(
                        'Comparte este enlace para que el destinatario pueda visualizar el código QR.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                            text: result.link,
                          ),
                        );

                        if(!context.mounted) return;

                        ScaffoldMessenger.of(context)
                        .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Enlace copiado'
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

  String buildShareMessage() {
    final localEndDate = endDate;

    final hasEndDate = qrcodeType != 2;

    return [
      'Muy buen día,',
      '',
      'Has recibido el siguiente código QR de tipo '
      '${QrcodeFormData.typeNames[qrcodeType]?.toLowerCase()}:',
      '',
      'Abre el siguiente enlace para visualizar el código QR:',
      result.link,
      '',
      'Válido desde:',
      formatDateTime(startDate),
      'Hasta:',
      hasEndDate && localEndDate != null
          ? formatDateTime(localEndDate)
          : 'Indefinido',
      '',
      'Puedes aperturar la bóveda del vehículo económico:',
      keyData.lockInfo.lockAlias,
      '',
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