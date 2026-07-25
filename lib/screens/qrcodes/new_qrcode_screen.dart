import 'package:api_app/models/qrcodes/qrcode_form_data.dart';
import 'package:api_app/models/lock_communication_mode.dart';
import 'package:api_app/models/qrcodes/qrcode_creation_result.dart';
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
                      initialValue: availableTypes.contains(formData.type) ? formData.type : availableTypes.first,
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
                    if(showEndDateFields())
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
                        label: const Text("Crear QR", 
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                        ),),
                        onPressed: createQrcode, 
                      ),
                    )
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
  bool showEndDateFields() {
    switch(formData.type){
      case 1:
        return false;
      case 2:
        return false;
      case 4:
        return false;
      default:
        return true;
    }
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
      initialDate: formData.endDate!,
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