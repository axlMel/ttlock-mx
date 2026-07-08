import 'package:flutter/material.dart';
import 'package:api_app/models/passcode.dart';
import 'package:api_app/services/passcodes/wifi_passcode_service.dart';
import 'package:api_app/models/passcodes_form_data.dart';
import 'package:share_plus/share_plus.dart';
import 'package:api_app/theme/app_colors.dart';
import 'package:api_app/helpers/error_helper.dart';
import 'package:api_app/widgets/loading_overlay.dart';

class PasscodeDetailScreen extends StatefulWidget {
  final Passcode passcode;
  final String token;
  final int lockId;
  final String lockAlias;
  const PasscodeDetailScreen({
    super.key,
    required this.passcode,
    required this.token,
    required this.lockId,
    required this.lockAlias,
  });
  @override
  State<PasscodeDetailScreen> createState() => _PasscodeDetailScreenState();
}

class _PasscodeDetailScreenState extends State<PasscodeDetailScreen> {
  WifiPasscodeService wifiService = WifiPasscodeService();
  bool isEditing = false;
  bool isSaving = false;
  late TextEditingController nameController;
  late TextEditingController codeController;
  late PasscodesFormData formData;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: widget.passcode.keyboardPwdName,
    );
    codeController = TextEditingController(text: widget.passcode.keyboardPwd);
    formData = PasscodesFormData(
      isCustom: widget.passcode.isCustom == 1,
      type: widget.passcode.keyboardPwdType,
      name: widget.passcode.keyboardPwdName,
      customCode: widget.passcode.keyboardPwd,
      startDate: DateTime.fromMillisecondsSinceEpoch(widget.passcode.startDate),

      endDate: widget.passcode.endDate == 0
          ? null
          : DateTime.fromMillisecondsSinceEpoch(widget.passcode.endDate),
    );
  }

  Future<void> deletePasscode() async {
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
      await wifiService.deletePasscode(
        widget.token,
        widget.lockId,
        widget.passcode.keyboardPwdId,
      );
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
      await wifiService.changePasscode(
        widget.token,
        widget.lockId,
        widget.passcode.keyboardPwdId,
        formData.name,
        int.parse(formData.customCode!),
        formData.startDate.millisecondsSinceEpoch,
        formData.endDate?.millisecondsSinceEpoch ?? 0,
      );
      if (!mounted) return;
      setState(() {
        widget.passcode.keyboardPwd = formData.customCode!;
        widget.passcode.keyboardPwdName = formData.name;
        isEditing = false;
      });
      
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Código actualizado')));
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
                      const Icon(Icons.password, size: 60),
                      const SizedBox(height: 20),
                      if (!isEditing)
                        Text(
                          widget.passcode.keyboardPwd,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        )
                      else
                        TextField(
                          controller: codeController,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            formData.customCode = value;
                          },
                          decoration: buildInput('Código')
                        ),
                      const SizedBox(height: 20),
                      if (!isEditing)
                        Text(
                          widget.passcode.keyboardPwdName,
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
                        widget.passcode.typeName,
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
                          widget.passcode.formattedStartDate,
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
                          widget.passcode.formattedStartDate,
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
                            widget.passcode.formattedEndDate,
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
                            widget.passcode.formattedEndDate,
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
                        codeController.text =
                            widget.passcode.keyboardPwd;
                        nameController.text =
                            widget.passcode.keyboardPwdName;
                      });
                    } else {
                      deletePasscode();
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
        widget.passcode.keyboardPwdType != 1 &&
        widget.passcode.keyboardPwdType != 2;
    return [
      'Muy buen día,',
      'Has recibido el siguiente código de acceso de tipo '
      '${widget.passcode.typeName.toLowerCase()}:',
      '',
      widget.passcode.keyboardPwd.trim(),
      '',
      'Válido desde:',
      widget.passcode.formattedStartDate.trim(),
      'Hasta:',
      hasEndDate
          ? widget.passcode.formattedEndDate.trim()
          : 'Indefinido',
      'Puedes aperturar la bóveda del vehículo económico:',
      widget.lockAlias.trim(),
      'Saludos.',
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
