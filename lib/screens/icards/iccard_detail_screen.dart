import 'package:api_app/models/ekey.dart';
import 'package:flutter/material.dart';
import 'package:api_app/models/iccards/iccards.dart';
import 'package:api_app/services/iccards/wifi_iccard_service.dart';
import 'package:api_app/models/iccards/iccard_form_data.dart';
import 'package:share_plus/share_plus.dart';
import 'package:api_app/theme/app_colors.dart';
import 'package:api_app/helpers/error_helper.dart';
import 'package:api_app/widgets/loading_overlay.dart';
import 'package:api_app/models/lock_communication_mode.dart';
import 'package:api_app/services/auth_manager.dart';

class IccardDetailScreen extends StatefulWidget {
  final EKey keyData;
  final Iccard iccard;
  final LockCommunicationMode communicationMode;
  const IccardDetailScreen({
    super.key,
    required this.iccard,
    required this.keyData,
    required this.communicationMode,
  });
  @override
  State<IccardDetailScreen> createState() => _IccardDetailScreenState();
}

class _IccardDetailScreenState extends State<IccardDetailScreen> {
  WifiIccardService wifiService = WifiIccardService();
  bool isEditing = false;
  bool isSaving = false;
  bool hasChanges = false;
  late TextEditingController nameController;
  late TextEditingController codeController;
  late IccardFormData formData;
  late String token;
  String weekDayName(int day) {
    switch (day) {
      case 1:
        return 'Lunes';
      case 2:
        return 'Martes';
      case 3:
        return 'Miércoles';
      case 4:
        return 'Jueves';
      case 5:
        return 'Viernes';
      case 6:
        return 'Sábado';
      case 7:
        return 'Domingo';
      default:
        return '';
    }
  }

  String formatMinutes(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');

    return '$h:$m';
  }

  @override
  void initState() {
    super.initState();
    initialize();
    nameController = TextEditingController(
      text: widget.iccard.cardName,
    );
    formData = IccardFormData(
      type: widget.iccard.cardType,
      name: widget.iccard.cardName,
      startDate: DateTime.fromMillisecondsSinceEpoch(
        widget.iccard.startDate,
      ),
      endDate: widget.iccard.endDate == 0
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              widget.iccard.endDate,
            ),
    );
  }
  String formatDate(DateTime date) {
    return
        '${date.day}/'
        '${date.month}/'
        '${date.year}'
        ' ${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
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
              widget.iccard.cardId,
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
              widget.iccard.cardId,
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
        widget.iccard.cardName = formData.name;

        widget.iccard.startDate =
            formData.startDate.millisecondsSinceEpoch;

        widget.iccard.endDate =
            formData.endDate?.millisecondsSinceEpoch ?? 0;
        isEditing = false;
        hasChanges = true;
        nameController.text = formData.name;
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
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context,hasChanges);
      },
      child: LoadingOverlay(
        isLoading: isSaving, 
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context, hasChanges);
              },
            ),
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
                            widget.iccard.cardName,
                        ),
                        const SizedBox(height: 20),
                        if (!isEditing)
                          Text(
                            widget.iccard.cardName,
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
                          widget.iccard.typeName,
                        ),
                      ),
                      Divider(
                        height: 1,
                        color: Colors.grey.shade300,
                      ),

                      ListTile(
                        leading: Icon(
                          Icons.verified,
                          color: AppColors.primary,
                        ),
                        title: const Text('Usuario que autorizó'),
                        subtitle: Text(widget.iccard.senderUsername),
                      ),

                      Divider(
                        height: 1,
                        color: Colors.grey.shade300,
                      ),

                      ListTile(
                        leading: Icon(
                          Icons.person,
                          color: AppColors.primary,
                        ),
                        title: const Text('Creado por'),
                        subtitle: Text(widget.iccard.senderUsername),
                      ),

                      Divider(
                        height: 1,
                        color: Colors.grey.shade300,
                      ),

                      ListTile(
                        leading: Icon(
                          Icons.schedule,
                          color: AppColors.primary,
                        ),
                        title: const Text('Fecha de creación'),
                        subtitle: Text(widget.iccard.formattedCreateDate),
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
                            widget.iccard.formattedStartDate,
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
                            isEditing
                                ? formatDate(formData.startDate)
                                : widget.iccard.formattedStartDate,
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
                              widget.iccard.formattedEndDate,
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
                              isEditing
                                  ? (formData.endDate == null
                                        ? 'Sin fecha límite'
                                        : formatDate(formData.endDate!))
                                  : widget.iccard.formattedEndDate,
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.edit_calendar,
                                color: AppColors.primary,
                              ),
                              onPressed: selectEndDate,
                            ),
                          ),
                          if (widget.iccard.cardType == 4) ...[
                            Divider(
                              height: 1,
                              color: Colors.grey.shade300,
                            ),

                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  const Text(
                                    'Configuración semanal',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  ...widget.iccard.cyclicConfig.map((config) {

                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: ListTile(
                                        leading: const Icon(Icons.calendar_today),
                                        title: Text(
                                          weekDayName(config.weekDay),
                                        ),
                                        subtitle: Text(
                                          '${formatMinutes(config.startTime)} - ${formatMinutes(config.endTime)}',
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
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

                          nameController.text = widget.iccard.cardName;

                          formData = IccardFormData(
                            type: widget.iccard.cardType,
                            name: widget.iccard.cardName,
                            startDate: DateTime.fromMillisecondsSinceEpoch(
                              widget.iccard.startDate,
                            ),
                            endDate: widget.iccard.endDate == 0
                                ? null
                                : DateTime.fromMillisecondsSinceEpoch(
                                    widget.iccard.endDate,
                                  ),
                          );
                        });
                      } else {
                        deleteQrcode();
                      }
                      
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        )
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
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true,
          ),
          child: child!,
        );
      },
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
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true,
          ),
          child: child!,
        );
      },
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
    final hasEndDate = widget.iccard.endDate != 0;

    return [
      'Buen día.',
      '',
      'Se te ha compartido una tarjeta de Acceso',
      '',
      'Tipo:',
      widget.iccard.typeName,
      '',
      'Heredado por:',
      widget.iccard.senderUsername,
      '',
      'Válido desde:',
      widget.iccard.formattedStartDate,
      '',
      'Válido hasta:',
      hasEndDate
      ? widget.iccard.formattedEndDate
      : 'Sin fecha límite'
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
