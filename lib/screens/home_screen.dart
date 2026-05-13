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
  List<EKey> keys = [];
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

    if (groups.isNotEmpty) {
      selectedGroup = groups.first;

      final allKeys =
          await EKeyService().getEKeys(token);

      keys = allKeys.where((k) {
        return k.groupId ==
            selectedGroup!.groupId;
      }).toList();
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> changeGroup(Group group) async {
    setState(() {
      isLoading = true;
      selectedGroup = group;
    });
    final allkeys = await EKeyService().getEKeys(token);
    keys = allkeys.where((k) {
      return k.groupId == group.groupId;
    }).toList();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GTekey'),),
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
                  itemCount: keys.length,
                  itemBuilder: (context, index) {
                    final key = keys[index];
                    return ListTile(
                      title: Text(key.lockAlias),
                      subtitle: Text(
                        "ID ${key.lockId}"
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
