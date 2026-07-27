import 'package:api_app/models/ekey.dart';
import 'package:api_app/models/lock_communication_mode.dart';
import 'package:api_app/models/records/record.dart';

import 'package:flutter/material.dart';
import 'package:api_app/theme/app_colors.dart';

class RecordDetailScreen extends StatefulWidget {
  final EKey keyData;
  final Record record;
  final LockCommunicationMode communicationMode;
  const RecordDetailScreen({
    super.key,
    required this.record,
    required this.keyData,
    required this.communicationMode,
  });
  @override
  State<RecordDetailScreen> createState() => _RecordDetailScreen();
}

class _RecordDetailScreen extends State<RecordDetailScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {Navigator.pop(context);},
        ),
        title: const Text('Detalle de registro'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20,5,20,20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18)
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      widget.record.icon,
                      size: 60,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.record.recordTypeName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.record.username.isEmpty
                          ? 'Sin usuario'
                          : widget.record.username,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            Card(
              elevation: 2,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.category,
                      color: AppColors.primary,
                    ),
                    title: const Text('Tipo'),
                    subtitle: Text(
                      widget.record.recordTypeName,
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: Colors.grey.shade300,
                  ),
                  buildTile(Icons.badge, 'Usuario', widget.record.username.isEmpty ? 'Sin usuario' : widget.record.username,),
                  Divider(height:1,color:Colors.grey.shade300),
                  buildTile(Icons.pin,'PIN',widget.record.keyboardPwd ?? 'No aplica'),
                  Divider(height:1,color:Colors.grey.shade300),
                  buildTile(Icons.event, 'Fecha del evento', widget.record.formattedLockDate,),
                  Divider(height:1,color:Colors.grey.shade300),
                  buildTile(Icons.cloud_done, 'Fecha de Sincronización', widget.record.formattedServerDate,),
                  Divider(height:1,color:Colors.grey.shade300),
                  ListTile(
                    leading: Icon(
                      widget.record.success
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: widget.record.success
                          ? Colors.green
                          : Colors.red,
                    ),
                    title: const Text('Resultado'),
                    subtitle: Text(
                      widget.record.success
                          ? 'Operación exitosa'
                          : 'Operación fallida',
                      style: TextStyle(
                        color: widget.record.success
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Divider(height:1,color:Colors.grey.shade300),
                  buildTile(Icons.lock_outline, 'Económico:', widget.keyData.lockInfo.lockAlias,),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  Widget buildTile(
    IconData icon,
    String title,
    String value,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primary,
      ),
      title: Text(title),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
