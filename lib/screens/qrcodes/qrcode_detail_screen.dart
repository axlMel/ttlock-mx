import 'package:api_app/models/ekey.dart';
import 'package:flutter/material.dart';
import 'package:api_app/models/qrcodes/qrcode.dart';
import 'package:api_app/services/qrcodes/wifi_qrcode_service.dart';
import 'package:api_app/models/qrcodes/qrcode_form_data.dart';
import 'package:share_plus/share_plus.dart';
import 'package:api_app/theme/app_colors.dart';
import 'package:api_app/helpers/error_helper.dart';
import 'package:api_app/widgets/loading_overlay.dart';
import 'package:api_app/models/lock_communication_mode.dart';
import 'package:api_app/services/auth_manager.dart';

class QrcodeDetailScreen extends StatefulWidget {
  final EKey keyData;
  final Qrcode qrcode;
  final LockCommunicationMode communicationMode;
  const QrcodeDetailScreen({
    super.key,
    required this.qrcode,
    required this.keyData,
    required this.communicationMode,
  });
  @override
  State<QrcodeDetailScreen> createState() => _QrcodeDetailScreenState();
}

class _QrcodeDetailScreenState extends State<QrcodeDetailScreen> {
  WifiQrcodeService wifiService = WifiQrcodeService();
  bool isEditing = false;
  bool isSaving = false;
  late TextEditingController nameController;
  late TextEditingController codeController;
  late QrcodeFormData formData;
  late String token;

  @override
  void initState() {
    super.initState();
    initialize();
    nameController = TextEditingController(
      text: widget.qrcode.name,
    );
    formData = QrcodeFormData(
      type: widget.qrcode.type,
      name: widget.qrcode.name,
      startDate: DateTime.fromMillisecondsSinceEpoch(
        widget.qrcode.startDate,
      ),
      endDate: widget.qrcode.endDate == 0
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              widget.qrcode.endDate,
            ),
    );
  }
  Future<void> initialize() async {
    token = await AuthManager.getToken() ?? '';
  }

  Future<void> deleteQrcode() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Eliminar código'),
          content: const Text('¿Deseas eliminar este código?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }
    setState(() {
      isSaving = true;
    });
    try {
      if (widget.communicationMode == LockCommunicationMode.bluetooth) {
          // Bluetooth pendiente
      } else {
          await wifiService.deleteQrcode(
              token,
              widget.keyData.lockInfo.lockId,
              widget.qrcode.qrCodeId,
              0,
          );
      }
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Código eliminado')));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(ErrorHelper.parse(e))));
    }
    finally{
      if(mounted){
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Future<void> saveChanges() async {
    setState(() {
      isSaving = true;
    });
    try {
      if (widget.communicationMode == LockCommunicationMode.bluetooth) {
        //
      } else {
        if (widget.communicationMode == LockCommunicationMode.wifi) {
          await wifiService.updateQrcode(
              token,
              widget.qrcode.qrCodeId,
              formData.name,
              formData.startDate.millisecondsSinceEpoch,
              formData.endDate?.millisecondsSinceEpoch,
              null,
              formData.type,
              null,
              0,
          );
        }
      }
      if (!mounted) return;
      setState(() {
        widget.qrcode.name = formData.name;

        widget.qrcode.startDate =
            formData.startDate.millisecondsSinceEpoch;

        widget.qrcode.endDate =
            formData.endDate?.millisecondsSinceEpoch ?? 0;
        isEditing = false;
      });
      
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Código actualizado')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ErrorHelper.parse(e)))
      );
    }
    finally{
      if(mounted){
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isSaving, 
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: const Text('Detalle del código'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
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
                      const Icon(Icons.qr_code_2, size: 60),
                      const SizedBox(height: 20),
                      SelectableText(
                          widget.qrcode.link,
                      ),
                      const SizedBox(height: 20),
                      if (!isEditing)
                        Text(
                          widget.qrcode.name,
                          style: const TextStyle(fontSize: 18),
                        )
                      else
                        TextField(
                          controller: nameController,
                          onChanged: (value) {
                            formData.name = value;
                          },
                          decoration: buildInput('Nombre')
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
                        widget.qrcode.typeName,
                      ),
                    ),

                    Divider(
                      height: 1,
                      color: Colors.grey.shade300,
                    ),

                    if (!isEditing)
                      ListTile(
                        leading: Icon(
                          Icons.calendar_today,
                          color: AppColors.primary,
                        ),
                        title: const Text('Inicio'),
                        subtitle: Text(
                          widget.qrcode.formattedStartDate,
                        ),
                      )
                    else
                      ListTile(
                        leading: Icon(
                          Icons.calendar_today,
                          color: AppColors.primary,
                        ),
                        title: const Text('Inicio'),
                        subtitle: Text(
                          widget.qrcode.formattedStartDate,
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.edit_calendar,
                            color: AppColors.primary,
                          ),
                          onPressed: selectStartDate,
                        ),
                      ),

                    if(formData.requiresEndDate)
                    Divider(
                      height:1,
                      color: Colors.grey.shade300,
                    ),

                    if(formData.requiresEndDate)

                      if(!isEditing)
                        ListTile(
                          leading: Icon(
                            Icons.event_busy,
                            color: AppColors.primary,
                          ),
                          title: const Text('Fin'),
                          subtitle: Text(
                            widget.qrcode.formattedEndDate,
                          ),
                        )
                      else
                        ListTile(
                          leading: Icon(
                            Icons.event_busy,
                            color: AppColors.primary,
                          ),
                          title: const Text('Fin'),
                          subtitle: Text(
                            widget.qrcode.formattedEndDate,
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.edit_calendar,
                              color: AppColors.primary,
                            ),
                            onPressed: selectEndDate,
                          ),
                        ),
                  ],
                ),
              ),

              const SizedBox(height: 15),
              SizedBox(
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: Icon(isEditing ? Icons.save : Icons.edit),
                  label: Text(
                    isSaving
                        ? 'Guardando...'
                        : isEditing
                            ? 'Guardar cambios'
                            : 'Editar código'),
                  onPressed: isSaving
                  ? null
                  : () {
                      if (isEditing) {
                        saveChanges();
                      } else {
                        setState(() {
                          isEditing = true;
                        });
                      }
                    },
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 55,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    side: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: const Icon(Icons.share),
                  label: const Text('Compartir'),
                  onPressed: () {
                    Share.share(buildShareMessage());
                  },
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 55,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: isEditing
                        ? Colors.grey.shade500
                        : Colors.red.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: Icon(
                    isEditing
                        ? Icons.close
                        : Icons.delete,
                  ),
                  label: Text(
                    isEditing
                        ? 'Cancelar edición'
                        : 'Eliminar código',
                  ),
                  onPressed: () {
                    if (isEditing) {
                      setState(() {
                        isEditing = false;
                        nameController.text =
                            widget.qrcode.name;
                      });
                    } else {
                      deleteQrcode();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  Future<void> selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: formData.startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked == null) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(formData.startDate),
    );
    if (pickedTime == null) return;
    setState(() {
      formData.startDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: formData.endDate!,
      firstDate: formData.startDate,
      lastDate: DateTime(2030),
    );

    if (picked == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(formData.endDate!),
    );
    if (pickedTime == null) return;
    setState(() {
      formData.endDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  String buildShareMessage() {
    final hasEndDate =
        widget.qrcode.type == 4;

    return [
      'Buen día.',
      '',
      'Se comparte el siguiente código QR.',
      '',
      'Tipo:',
      widget.qrcode.typeName,
      '',
      'Acceso al QR:',
      widget.qrcode.link,
      '',
      'Válido desde:',
      widget.qrcode.formattedStartDate,
      '',
      'Válido hasta:',
      hasEndDate
          ? '-'
          : widget.qrcode.formattedEndDate,
      '',
      'Cerradura:',
      widget.keyData.lockInfo.lockAlias,
    ].join('\n');
  }

  InputDecoration buildInput(String label){
    return InputDecoration(
      labelText: label,
      filled:true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300)
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300)
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.primary,
          width:1.5,
        ),
      ),
    );
  }

}
