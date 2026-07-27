import 'package:api_app/models/qrcodes/qrcode_form_data.dart';
import 'package:api_app/models/lock_communication_mode.dart';
import 'package:api_app/models/qrcodes/qrcode_creation_result.dart';
import 'package:api_app/models/qrcodes/cyclic_config.dart';
import 'package:api_app/models/ekey.dart';

import 'package:api_app/services/qrcodes/wifi_qrcode_service.dart';
import 'package:api_app/services/auth_manager.dart';

import 'package:api_app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:api_app/screens/qrcodes/created_qrcode_screen.dart';
import 'package:api_app/widgets/loading_overlay.dart';
import 'package:api_app/helpers/error_helper.dart';


class NewQrcodeScreen extends StatefulWidget {
  final EKey keyData;
  final LockCommunicationMode communicationMode;


  const NewQrcodeScreen({super.key, required this.communicationMode, required this.keyData});
  
  @override
  State<NewQrcodeScreen> createState() => _NewQrcodesScreenState();
}

class _NewQrcodesScreenState extends State<NewQrcodeScreen>{
  final wifiService = WifiQrcodeService();
  final nameController = TextEditingController();
  bool isSaving = false;
  late QrcodeFormData formData;
  late String token;
  List<int> get availableTypes => [1, 2, 4];
  
  
  //
  int selectedWeekDay = 1;
  TimeOfDay selectedStartTime = const TimeOfDay(
    hour: 9,
    minute: 0,
  );
  TimeOfDay selectedEndTime = const TimeOfDay(
    hour: 18,
    minute: 0,
  );
  static const weekDays = {
    1: 'Lunes',
    2: 'Martes',
    3: 'Miércoles',
    4: 'Jueves',
    5: 'Viernes',
    6: 'Sábado',
    7: 'Domingo',
  };

  @override
  void initState() {
    super.initState();
      formData = QrcodeFormData(
        type: 2,
        name: '',
        startDate: DateTime.now(),
        endDate: null,
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
  Widget build(BuildContext context) {
    final endDate = formData.endDate;
    return LoadingOverlay(
      isLoading: isSaving,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: const Text('Nuevo código QR '),
        ),
        body: SingleChildScrollView(
          child: SingleChildScrollView(
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
                    const SizedBox(height: 24),
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
                      value: formData.type,
                      decoration: buildInput('Tipo'),
                      items: availableTypes.map((type){
                        return DropdownMenuItem<int>(
                          value: type,
                          child: Text(
                            QrcodeFormData.typeNames[type]!,
                          )
                        );
                      }).toList(),
                      onChanged: (value) {
                        if(value == null) return;
                        if (!mounted) return;
                        setState(() {
                          formData.type = value;

                          switch (value) {
                            case 1: // Periódico
                              formData.endDate ??=
                                  formData.startDate.add(const Duration(days: 1));
                              formData.cyclicConfig.clear();
                              break;

                            case 2: // Permanente
                              formData.endDate = null;
                              formData.cyclicConfig.clear();
                              break;

                            case 4: // Cíclico
                              formData.endDate ??=
                                  formData.startDate.add(const Duration(days: 30));
                              break;
                          }
                        });
                      },
                    ),
                    if (formData.type == 2)
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          'El código permanecerá activo hasta ser eliminado.',
                          textAlign: TextAlign.center,
                        ),
                      ),

                    if (formData.type == 1)
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          'El código será válido únicamente dentro del rango de tiempo seleccionado.',
                          textAlign: TextAlign.center,
                        ),
                      ),

                    if (formData.type == 4)
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          'Selecciona el rango de validéz junto con los días y horarios permitidos.',
                          textAlign: TextAlign.center,
                        ),
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
                    if (showEndDateFields())
                    Builder(
                      builder: (_) {
                        final endDate = formData.endDate;

                        if (endDate == null) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: const Text(
                                'Caducidad',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
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
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    icon: const Icon(Icons.calendar_month),
                                    label: Text(
                                      '${endDate.day}/${endDate.month}/${endDate.year}',
                                    ),
                                    onPressed: selectEndDate,
                                  ),
                                ),
                                const SizedBox(width: 18),
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
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    icon: const Icon(Icons.schedule),
                                    label: Text(
                                      '${endDate.hour}:${endDate.minute.toString().padLeft(2, '0')}',
                                    ),
                                    onPressed: selectEndTime,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),

                    if (formData.type == 4)
                      buildCyclicConfiguration(),
                    const SizedBox(height:18),
                    // buildInfoMessage(),
                    // const SizedBox(height: 18,),
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
                        label: const Text("Crear QR", 
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                        ),),
                        onPressed: createQrcode, 
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              )
            ),
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
  
  Widget buildCyclicConfiguration() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const SizedBox(height: 20),

        const Text(
          'Configuración semanal',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),

        const SizedBox(height: 15),

        DropdownButtonFormField<int>(
          initialValue: selectedWeekDay,
          decoration: buildInput('Día'),
          items: weekDays.entries.map((day) {
            return DropdownMenuItem(
              value: day.key,
              child: Text(day.value),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              selectedWeekDay = value;
            });
          },
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.schedule),
                label: Text(formatTime24(selectedStartTime)),
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: selectedStartTime,
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
                    selectedStartTime = picked;
                  });
                },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.schedule),
                label: Text(formatTime24(selectedEndTime)),
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: selectedEndTime,
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
                    selectedEndTime = picked;
                  });
                },
              ),
            ),

          ],
        ),

        const SizedBox(height: 15),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text("Agregar horario"),
            onPressed: addCyclicSchedule,
          ),
        ),

        const SizedBox(height: 20),

        ...formData.cyclicConfig.map(buildScheduleTile),

      ],
    );
  }
  
  Widget buildScheduleTile(CyclicConfig config) {
    String formatMinutes(int minutes) {

      final h = (minutes ~/ 60).toString().padLeft(2, '0');

      final m = (minutes % 60).toString().padLeft(2, '0');

      return '$h:$m';
    }

    return Card(
      child: ListTile(

        leading: const Icon(Icons.calendar_today),

        title: Text(
          weekDays[config.weekDay]!,
        ),

        subtitle: Text(
          '${formatMinutes(config.startTime)} - ${formatMinutes(config.endTime)}',
        ),

        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {

            setState(() {

              formData.cyclicConfig.remove(config);

            });

          },
        ),

      ),
    );
  }

  void addCyclicSchedule() {
    final startMinutes =
        selectedStartTime.hour * 60 +
        selectedStartTime.minute;

    final endMinutes =
        selectedEndTime.hour * 60 +
        selectedEndTime.minute;

    if (endMinutes <= startMinutes) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La hora final debe ser mayor.',
          ),
        ),
      );

      return;
    }
    final alreadyExists = formData.cyclicConfig.any(
      (e) =>
          e.weekDay == selectedWeekDay &&
          e.startTime == startMinutes &&
          e.endTime == endMinutes,
    );
    if (alreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ese horario ya fue agregado.'),
        ),
      );
      return;
    }

    final overlap = formData.cyclicConfig.any((e) {
      if (e.weekDay != selectedWeekDay) {
        return false;
      }

      return startMinutes < e.endTime &&
          endMinutes > e.startTime;
    });

    if (overlap) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ese horario se traslapa con otro existente.',
          ),
        ),
      );
      return;
    }

    setState(() {
      formData.cyclicConfig.add(
        CyclicConfig(
          weekDay: selectedWeekDay,
          startTime: startMinutes,
          endTime: endMinutes,
        ),
      );
      formData.cyclicConfig.sort((a, b) {
        if (a.weekDay != b.weekDay) {
          return a.weekDay.compareTo(b.weekDay);
        }
        return a.startTime.compareTo(b.startTime);
      });
    });
  }

  bool showEndDateFields() {
    return formData.type == 1 || formData.type == 4;
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
      if (formData.endDate != null &&
          formData.endDate!.isBefore(formData.startDate)) {
        formData.endDate = DateTime(
          formData.startDate.year,
          formData.startDate.month,
          formData.startDate.day,
          formData.endDate!.hour,
          formData.endDate!.minute,
        );
      }
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
  String formatTime24(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  Future<void> createQrcode() async {
    final startMills = formData.startDate.millisecondsSinceEpoch;
    final endMills = formData.endDate?.millisecondsSinceEpoch ?? 0;

    late QrcodeCreationResult result;

    setState(() {
      isSaving = true;
    });

    try {
      if (widget.communicationMode == LockCommunicationMode.bluetooth) {
        // TODO: Implementar creación por Bluetooth.
      } else {
        // Validaciones
        if (formData.name.trim().isEmpty) {
          throw Exception('Debes ingresar un nombre.');
        }
        if (formData.type == 4 && formData.cyclicConfig.isEmpty) {
          throw Exception(
            'Debes agregar al menos un horario para un código cíclico.',
          );
        }

        if ((formData.type == 1 || formData.type == 4) &&
        formData.endDate != null &&
        formData.endDate!.isBefore(formData.startDate)) {
          throw Exception(
              'La fecha final debe ser posterior a la inicial.');
        }
        result = await wifiService.getQrcode(
          token,
          widget.keyData.lockInfo.lockId,
          formData.name,
          formData.type,
          startMills,
          endMills,
          formData.refreshTime,
          formData.cyclicConfig.isEmpty
              ? null
              : formData.cyclicConfig,
        );
      }
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) {
            print('ENTRO AL BUILDER');
            return CreatedQrcodeScreen(
              result: result,
              startDate: formData.startDate,
              endDate: formData.endDate,
              keyData: widget.keyData,
              qrcodeType: formData.type,
            );
          },
        ),
      );
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