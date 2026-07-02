import 'package:api_app/models/passcodes_form_data.dart';
import 'package:api_app/services/passcodes/wifi_passcode_service.dart';
import 'package:api_app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:api_app/models/lock_communication_mode.dart';
import 'package:api_app/models/passcode_creation_result.dart';
import 'package:api_app/screens/passcodes/created_passcode_screen.dart';

class NewPasscodeScreen extends StatefulWidget {
  final int lockId;
  final String token;
  final String lockData;
  final LockCommunicationMode communicationMode;

  const NewPasscodeScreen({super.key, required this.lockId, required this.token, required this.lockData, required this.communicationMode});
  
  @override
  State<NewPasscodeScreen> createState() => _NewPasscodesScreenState();
}

class _NewPasscodesScreenState extends State<NewPasscodeScreen>{
  final wifiService = WifiPasscodeService();
  final nameController = TextEditingController();
  final codeController = TextEditingController();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 1));
  late PasscodesFormData formData;
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
      isCustom: false, 
      type: 2, 
      name: '', 
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 1))
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('Nuevo código'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                if (!mounted) return;
                setState(() {
                  formData.isCustom = value.first;
                  if (formData.isCustom) {
                    formData.type=2;
                  } else {
                    formData.type=1;
                  }
                });
              },
            ),
            const SizedBox(height: 25),
            if (formData.isCustom)
            TextField(
              controller: codeController,
              onChanged: (value) {
                formData.customCode = value;
              },
              keyboardType: TextInputType.number,
              decoration: buildInput('Código')
            ),
            if (formData.isCustom) const SizedBox(height: 15),
            TextField(
              controller: nameController,
              onChanged: (value) {
                formData.name = value;
              },
              decoration: buildInput('Nombre')
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<int>(
              dropdownColor: Colors.white,
              initialValue: availableTypes.contains(formData.type) ? formData.type : availableTypes.first,
              decoration: InputDecoration(
                labelText: 'Tipo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.primary,
                    width:1.5,
                  ),
                ),
                filled:true,
                fillColor: Colors.white,
                
              ),
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
                });
              },
            ),
            const SizedBox(height:20),
            const Text(
              'Inicio',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height:10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(
                        color: AppColors.primary,
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
                const SizedBox(width:10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(
                        color: AppColors.primary,
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
            const SizedBox(height:20),
            if(showEndDateFields())
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Fin',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height:10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(
                            color: AppColors.primary,
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
                    const SizedBox(width:10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(
                            color: AppColors.primary,
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

            const SizedBox(height:20),
            buildInfoMessage(),
            const SizedBox(height: 30,),
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
                onPressed: createPasscode, 
              ),
            )
          ],
        ),
      ),
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
  Future<void> createPasscode() async {
    final startMills = formData.startDate.millisecondsSinceEpoch;
    final endMills = formData.endDate?.millisecondsSinceEpoch ?? 0;
    PasscodeCreationResult? result;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const Center(
          child:  CircularProgressIndicator(),
        );
      }
    );
    try {
      if (formData.isCustom) {
        result = await wifiService.getCustomPasscode(
          widget.token,
          widget.lockId,
          int.parse(formData.customCode!),
          formData.name,
          formData.type,
          startMills,
          endMills
        );
      } else {
        result = await wifiService.getRandomPasscode(
          widget.token,
          widget.lockId,
          formData.type,
          formData.name,
          startMills,
          endMills
        );
      }
      if(!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      if (result==null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No fue posible generar el código')));
        return;
      }
      Navigator.push(context, MaterialPageRoute(builder: (_) => CreatedPasscodeScreen(result: result!)));
      
    } catch (e) {
      if(!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  InputDecoration buildInput(String label){
    return InputDecoration(
      labelText: label,

      filled:true,
      fillColor: Colors.white,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),

        borderSide: BorderSide.none,
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