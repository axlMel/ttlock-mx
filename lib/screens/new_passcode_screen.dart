import 'package:api_app/models/passcodes_form_data.dart';
import 'package:api_app/services/passcodes/wifi_passcode_service.dart';
import 'package:flutter/material.dart';
import 'package:api_app/models/lock_communication_mode.dart';
import 'package:api_app/services/passcodes/wifi_passcode_service.dart';
import 'package:api_app/models/passcode_creation_result.dart';

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
      appBar: AppBar(
        title: const Text('Nuevo código'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            SegmentedButton(
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
              decoration: const InputDecoration(
                labelText: 'Código',
                border: OutlineInputBorder(),
              ),
            ),
            if (formData.isCustom) const SizedBox(height: 15),
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
            const SizedBox(height: 15),
            DropdownButtonFormField<int>(
              value: availableTypes.contains(formData.type) ? formData.type : availableTypes.first,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                border: OutlineInputBorder(),
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
                  formData.type = value!;
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                icon: const Icon(Icons.lock_open),
                label: const Text("Crear código", 
                style: TextStyle(
                  fontSize: 16
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
      Navigator.pop(context);
      if (result==null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No fue posible generar el código')));
        return;
      }
      print(result.keyboardPwd);
      print(result.keyboardPwdId);
      
    } catch (e) {
      if(!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}