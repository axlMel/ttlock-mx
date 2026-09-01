import 'package:api_app/models/passcodes/passcodes_form_data.dart';
import 'package:api_app/services/passcodes/wifi_passcode_service.dart';
import 'package:api_app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:api_app/models/lock_communication_mode.dart';
import 'package:api_app/models/passcodes/passcode_creation_result.dart';
import 'package:api_app/screens/passcodes/created_passcode_screen.dart';
import 'package:api_app/widgets/loading_overlay.dart';
import 'package:api_app/helpers/error_helper.dart';
import 'package:api_app/services/passcodes/bluetooth_passcode_service.dart';
import 'package:api_app/models/ekey.dart';
import 'package:api_app/services/auth_manager.dart';

class NewPasscodeScreen extends StatefulWidget {
  final EKey keyData;
  final LockCommunicationMode communicationMode;


  const NewPasscodeScreen({super.key, required this.communicationMode, required this.keyData});
  
  @override
  State<NewPasscodeScreen> createState() => _NewPasscodesScreenState();
}

class _NewPasscodesScreenState extends State<NewPasscodeScreen>{
  final wifiService = WifiPasscodeService();
  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final bluetoothService = BluetoothPasscodeService();
  bool isSaving = false;
  late PasscodesFormData formData;
  late String token;
  List<int> get availableTypes {
    if (formData.isCustom) {
      return [2,3];
    }
    return [1,2,3,5,6,7,8,9,10,11,12,13,14];
  }

  @override
  void initState() {
    super.initState();

    formData = PasscodesFormData(
      isCustom: widget.communicationMode == LockCommunicationMode.bluetooth,
      type: widget.communicationMode == LockCommunicationMode.bluetooth ? 2 : 1,
      name: '',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 1)),
    );

    initialize();
  }

  Future<void> initialize() async {
    token = await AuthManager.getToken() ?? '';

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    codeController.dispose();
    super.dispose();
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
          title: const Text('Nuevo código'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 2,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24)
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Modo de generación',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SegmentedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith((states){
                        if (states.contains(WidgetState.selected)) {
                          return AppColors.primary;
                        }
                        return Colors.white;
                      }),
                      foregroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return Colors.white;
                        }
                        return Colors.black87;
                      }),
                      side: WidgetStatePropertyAll(
                        BorderSide(color: Colors.grey.shade300, width: 1)
                      ),
                      elevation: const WidgetStatePropertyAll(0),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)
                        )
                      )
                    ),
                    segments: const [
                      ButtonSegment(
                        value: false,
                        label: Text('Aleatorio'),
                        icon: Icon(Icons.shuffle)
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text('Personalizado'),
                        icon: Icon(Icons.pin)
                      ),
                    ],
                    selected: {formData.isCustom},
                    onSelectionChanged: (value) {
                      if (widget.communicationMode == LockCommunicationMode.bluetooth) {
                        return;
                      }
                      setState(() {
                        formData.isCustom = value.first;

                        if (formData.isCustom) {
                          formData.type = 2;
                        } else {
                          formData.type = 1;
                          formData.customCode = null;
                          codeController.clear();
                        }

                        if (!formData.requiresEndDate) {
                          formData.endDate = null;
                        } else {
                          formData.endDate ??=
                              formData.startDate.add(const Duration(days: 1));
                        }
                      });
                    },
                  ),
                  if (widget.communicationMode == LockCommunicationMode.bluetooth)
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      'Bluetooth solo permite códigos personalizados.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (formData.isCustom)
                  TextField(
                    controller: codeController,
                    onChanged: (value) {
                      formData.customCode = value;
                    },
                    keyboardType: TextInputType.number,
                    decoration: buildInput('Código')
                  ),
                  if (formData.isCustom) const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    onChanged: (value) {
                      formData.name = value;
                    },
                    decoration: buildInput('Nombre')
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    dropdownColor: Colors.white,
                    initialValue: availableTypes.contains(formData.type) ? formData.type : availableTypes.first,
                    decoration: buildInput('Tipo'),
                    items: availableTypes.map((type){
                      return DropdownMenuItem<int>(
                        value: type,
                        child: Text(
                          PasscodesFormData.typeNames[type]!,
                        )
                      );
                    }).toList(),
                    onChanged: (value) {
                      if(value == null) return;
                      if (!mounted) return;
                      setState(() {
                        formData.type = value;
                        if (!formData.requiresEndDate) {
                          formData.endDate = null;
                        } else {
                          formData.endDate ??= formData.startDate.add(const Duration(days:1));
                        }
                      });
                    },
                  ),
                  const SizedBox(height:18),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Inicio',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height:10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            side: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical:16,
                            ),
                          ),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            '${formData.startDate.day}/'
                            '${formData.startDate.month}/'
                            '${formData.startDate.year}',
                          ),
                          onPressed: selectStartDate,
                        ),
                      ),
                      const SizedBox(width:18),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            side: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical:16,
                            ),
                          ),
                          icon: const Icon(Icons.schedule),
                          label: Text(
                            '${formData.startDate.hour}:'
                            '${formData.startDate.minute.toString().padLeft(2,'0')}',
                          ),
                          onPressed: selectStartTime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height:18),
                  if (formData.requiresEndDate)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Fin',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height:10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primary,
                                side: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical:16,
                                ),
                              ),
                              icon: const Icon(Icons.calendar_month),
                              label: Text(
                                '${formData.endDate!.day}/'
                                '${formData.endDate!.month}/'
                                '${formData.endDate!.year}',
                              ),
                              onPressed: selectEndDate,
                            ),
                          ),
                          const SizedBox(width:18),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primary,
                                side: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical:16,
                                ),
                              ),
                              icon: const Icon(Icons.schedule),
                              label: Text(
                                '${formData.endDate!.hour}:'
                                '${formData.endDate!.minute.toString().padLeft(2,'0')}',
                              ),
                              onPressed: selectEndTime,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height:18),
                  buildInfoMessage(),
                  const SizedBox(height: 18,),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child:  ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)
                        )
                      ),
                      icon: const Icon(Icons.lock_open),
                      label: const Text("Crear código", 
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                      ),),
                      onPressed: isSaving ? null : createPasscode,
                    ),
                  )
                ],
              ),
            )
          ),
        ),
        
      )
    ); 
  }
  Widget buildInfoMessage() {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.info_outline),
            const SizedBox(width:10),
            Expanded(
              child: Text(
                formData.typeDescription,
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
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: formData.startDate,
    );
    if(picked == null) return;
    setState(() {
      formData.startDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        formData.startDate.hour,
        formData.startDate.minute,
      );
    });
  }
  Future<void> selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        formData.startDate
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true,
          ),
          child: child!,
        );
      },
    );
    if(picked == null) return;
    setState(() {
      formData.startDate = DateTime(
        formData.startDate.year,
        formData.startDate.month,
        formData.startDate.day,
        picked.hour,
        picked.minute,
      );
    });
  }
  Future<void> selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: formData.startDate,
      lastDate: DateTime(2030),
      initialDate: formData.endDate!.isBefore(formData.startDate)
      ? formData.startDate
      : formData.endDate!,
    );
    if (picked == null) return;
    setState(() {
      formData.endDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        formData.endDate!.hour,
        formData.endDate!.minute,
      );
    });
  }
  Future<void> selectEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        formData.endDate!,
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true,
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    setState(() {
      formData.endDate = DateTime(
        formData.endDate!.year,
        formData.endDate!.month,
        formData.endDate!.day,
        picked.hour,
        picked.minute,
      );
    });
  }
  Future<void> createPasscode() async {
    final startMills = formData.startDate.millisecondsSinceEpoch;
    final endMills = formData.endDate?.millisecondsSinceEpoch ?? 0;

    late PasscodeCreationResult result;

    setState(() {
      isSaving = true;
    });

    try {
      if (formData.name.trim().isEmpty) {
        throw Exception('Debes ingresar un nombre.');
      }
      if (formData.requiresEndDate &&
          formData.endDate != null &&
          formData.endDate!.isBefore(formData.startDate)) {
        throw Exception(
          'La fecha final debe ser posterior a la fecha inicial.',
        );
      }
      if (widget.communicationMode == LockCommunicationMode.bluetooth) {
        if (formData.isCustom &&
            (formData.customCode == null ||
            formData.customCode!.trim().isEmpty)) {
          throw Exception('Debes ingresar un código.');
        }
        result = await bluetoothService.createCustomPasscode(
          passcode: formData.customCode!,
          startDate: startMills,
          endDate: endMills,
          lockData: widget.keyData.lockInfo.lockData,
        );
      } else {
        if (formData.isCustom) {
          final code = int.tryParse(formData.customCode!);
          if (code == null) {
            throw Exception('El código debe ser numérico.');
          }
          result = await wifiService.getCustomPasscode(
            token,
            widget.keyData.lockInfo.lockId,
            code,
            formData.name,
            formData.type,
            startMills,
            endMills,
          );
        } else {
          result = await wifiService.getRandomPasscode(
            token,
            widget.keyData.lockInfo.lockId,
            formData.type,
            formData.name,
            startMills,
            endMills,
          );
        }
      }
      if (!mounted) return;

      final refresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreatedPasscodeScreen(
          result: result,
          startDate: formData.startDate,
          endDate: formData.endDate,
          keyData: widget.keyData,
          passcodeType: formData.type,
        ),
      ),
    );

    if (refresh == true && mounted) {
      Navigator.pop(context, true);
    }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorHelper.parse(e)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
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