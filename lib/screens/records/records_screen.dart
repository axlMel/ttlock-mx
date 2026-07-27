import 'package:api_app/models/ekey.dart';
import 'package:api_app/models/lock_communication_mode.dart';
import 'package:api_app/models/records/record.dart';

import 'package:api_app/screens/records/record_detail_screen.dart';

import 'package:api_app/services/records/wifi_record_service.dart';
import 'package:api_app/services/auth_manager.dart';

import 'package:api_app/theme/app_colors.dart';
import 'package:flutter/material.dart';



import 'package:api_app/helpers/error_helper.dart';



class RecordsScreen extends StatefulWidget {
  final EKey keyData;
  final LockCommunicationMode communicationMode;
  const RecordsScreen({
    super.key,
    required this.keyData,
    required this.communicationMode,
  });
  @override
  State<RecordsScreen> createState() => _RecordsScreen();
}

class _RecordsScreen extends State<RecordsScreen> {
  final WifiRecordService wifiService = WifiRecordService();
  List<Record> records = [];
  bool isLoading = true;
  String searchText = '';
  late String token;

  @override
  void initState() {
    super.initState();
    initialize();
  }
  Future<void> initialize() async {
    token = await AuthManager.getToken() ?? '';
    await loadRecords();
  }

  Future<void> loadRecords() async {
    try {
      if (widget.communicationMode == LockCommunicationMode.wifi) {
        records = await wifiService.getAllRecords(
          token,
          widget.keyData.lockInfo.lockId,
        );
      } else {
        // espacio para servicio BT
      }
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorHelper.parse(e)),
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Record> get filteredRecords {
    if (searchText.trim().isEmpty) {
      return records;
    }
    return records.where((record) {
      final query = searchText.toLowerCase();
      return record.username.toLowerCase().contains(query); 
    }).toList();
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
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
          ),
        ),
        actions: const [
          SizedBox(width: 25),
        ],

        titleSpacing: 0,

        title: Container(
          height: 42,

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.grey.shade300,
            ),
          ),

          child: TextField(
            onChanged: (value) {
              setState(() {
                searchText=value.toLowerCase();
              });
            },

            decoration: InputDecoration(
              hintText:'Buscar Registro...',
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
              ),

              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey.shade600,
              ),

              border: InputBorder.none,

              contentPadding:
                  const EdgeInsets.symmetric(
                    vertical:10,
                  ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 70,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No existen Registros',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Los registros aparecerán cuando la chapa sincronice eventos.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredRecords.length,
                    itemBuilder: (context, index) {
                      final record = filteredRecords[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 2,
                        color: record.success
                        ? Colors.white
                        : Colors.red.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: record.success
                                ? Colors.transparent
                                : Colors.red.shade300,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              final refresh = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RecordDetailScreen(
                                    record: record,
                                    keyData: widget.keyData,
                                    communicationMode: widget.communicationMode,
                                  ),
                                ),
                              );
                              if (refresh == true) {
                                loadRecords();
                              }
                            },
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 4,
                              ),

                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor: record.success
                                ? AppColors.primary
                                : Colors.red,

                                child: Icon(
                                  record.icon,
                                  color: Colors.white,
                                ),
                              ),

                              title: Text(
                                record.username.isEmpty
                                    ? 'Sin usuario'
                                    : record.username,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,

                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),

                              subtitle: Padding(
                                padding: const EdgeInsets.only(
                                  top: 6,
                                ),

                                child: Row(
                                  children: [
                                    Text(
                                      record.formattedLockDate,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width:12),
                                    Expanded(
                                      child: Text(
                                        record.recordTypeName,
                                        overflow: TextOverflow.ellipsis,

                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize:13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size:18,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
