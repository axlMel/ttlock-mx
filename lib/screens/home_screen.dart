import 'package:flutter/material.dart';
import '../models/group.dart';
import '../models/ekey.dart';
import '../services/group_service.dart';
import '../services/ekey_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Group> groups = [];
  List<EKey> allKeys = [];
  List<EKey> filteredKeys = [];
  bool isLoading = true;
  bool initialized = false;
  late String token;
  Group? selectedGroup;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      token = ModalRoute.of(context)!.settings.arguments as String;
      loadGroups();
      initialized = true;
    }
  }

  Future<void> loadGroups() async {
    groups = await GroupService().getGroups(token);
    allKeys = await EKeyService().getEKeys(token);
    filteredKeys = allKeys;
    setState(() {
      isLoading = false;
    });
  }

  Future<void> changeGroup(Group group) async {
    setState(() {
      isLoading = true;
      selectedGroup = group;
    });
    filteredKeys = allKeys.where((k) {
      return k.groupId == group.groupId;
    }).toList();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> testCreateGroup() async {
    final success = await GroupService().createGroup(token, 'TEST APP');
    await loadGroups();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Grupo creado'
              : 'Error creando grupo',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GTekey'), actions: [
        IconButton(onPressed: testCreateGroup, icon: const Icon(Icons.add),),
      ],),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
            children: [
              DropdownButton<Group>(
                value: selectedGroup,
                isExpanded: true,
                items: groups.map((g) {
                  return DropdownMenuItem<Group>(
                    value: g,
                    child: Text(g.groupName),
                  );
                }).toList(),
                onChanged: (g) {
                  if (g != null) {
                    changeGroup(g);
                  }
                },
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: allKeys.length,
                  itemBuilder: (context, index) {
                    final key = allKeys[index];
                    return ListTile(
                      title: Text(key.lockAlias),
                      subtitle: Text(
                        '''
                        ID ${key.lockId}
                        Batería ${key.electricQuantity}%
                        Grupo: ${key.groupName.isEmpty ? "Sin grupo" : key.groupName}
                        '''
                      ),
                    );
                  },
                ),
              )
            ],
          )
    );
  }
}
