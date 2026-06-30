import 'package:flutter/material.dart';
import 'package:api_app/models/passcode.dart';
import 'package:api_app/services/passcodes/wifi_passcode_service.dart';
import 'package:api_app/models/passcodes_form_data.dart';
import 'package:share_plus/share_plus.dart';

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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const Center(child: CircularProgressIndicator());
      },
    );
    try {
      await wifiService.deletePasscode(
        widget.token,
        widget.lockId,
        widget.passcode.keyboardPwdId,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Código eliminado')));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> saveChanges() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const Center(child: CircularProgressIndicator());
      },
    );
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
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Código actualizado')));
      setState(() {
        isEditing = false;
        widget.passcode.keyboardPwd = formData.customCode!;
        widget.passcode.keyboardPwdName = formData.name;
      });
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del código')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
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
                        decoration: const InputDecoration(
                          labelText: 'Código',
                          border: OutlineInputBorder(),
                        ),
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
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                          border: OutlineInputBorder(),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Tipo'),
              subtitle: Text(widget.passcode.typeName),
            ),

            const Divider(),

            if (!isEditing)
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Inicio'),
                subtitle: Text(widget.passcode.formattedStartDate),
              )
            else
              ListTile(
                leading: const Icon(Icons.calendar_today),

                title: const Text('Inicio'),

                subtitle: Text(widget.passcode.formattedStartDate),

                trailing: IconButton(
                  icon: const Icon(Icons.edit_calendar),

                  onPressed: selectStartDate,
                ),
              ),

            const Divider(),

            if (formData.requiresEndDate)
              if (!isEditing)
                ListTile(
                  leading: const Icon(Icons.event_busy),
                  title: const Text('Fin'),
                  subtitle: Text(widget.passcode.formattedEndDate),
                )
              else
                ListTile(
                  leading: const Icon(Icons.event_busy),

                  title: const Text('Fin'),

                  subtitle: Text(widget.passcode.formattedEndDate),

                  trailing: IconButton(
                    icon: const Icon(Icons.edit_calendar),

                    onPressed: selectEndDate,
                  ),
                ),

            const SizedBox(height: 40),
            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                icon: Icon(isEditing ? Icons.save : Icons.edit),
                label: Text(isEditing ? 'Guardar cambios' : 'Editar código'),
                onPressed: () {
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
                icon: const Icon(Icons.delete),
                label: const Text('Eliminar código'),
                onPressed: deletePasscode,
              ),
            ),
          ],
        ),
      ),
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
    return [
      'Muy buenas tardes,',
      'Has recibido el siguiente código de acceso:',
      widget.passcode.keyboardPwd.trim(),
      'Válido desde:',
      widget.passcode.formattedStartDate.trim(),
      'Hasta:',
      widget.passcode.formattedEndDate.trim(),
      'Puedes aperturar la bóveda del vehículo económico:',
      widget.lockAlias.trim(),
      'Saludos.',
    ].join('\n');
  }
}
