import 'package:flutter/material.dart';
import '../models/group.dart';
import '../models/ekey.dart';
import '../services/auth_manager.dart';
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
  bool isLoading = true;
  bool initialized = false;
  late String token;

  List<EKey> getUngroupedKeys() {
    return allKeys.where((k) => k.groupId == 0).toList();
  }

  List<EKey> getKeysByGroup(int groupId) {
    return allKeys.where((k) => k.groupId == groupId).toList();
  }

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
    setState(() {
      isLoading = false;
    });
  }

  Future<void> showCreateGroupDialog() async {
    final controller = TextEditingController();
    List<EKey> selectedKeys = [];
    bool isSaving = false;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Crear grupo'),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del grupo',
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Seleccionar chapas',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...getUngroupedKeys().map((key) {
                      final isSelected = selectedKeys.contains(key);
                      return CheckboxListTile(
                        value: isSelected,
                        title: Text(key.lockAlias),
                        subtitle: Text('Batería ${key.electricQuantity}%'),
                        onChanged: (value) {
                          setModalState(() {
                            if (value == true) {
                              selectedKeys.add(key);
                            } else {
                              selectedKeys.remove(key);
                            }
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () {
                          Navigator.pop(context);
                        },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final groupName = controller.text.trim();
                          if (groupName.isEmpty) {
                            return;
                          }
                          setModalState(() {
                            isSaving = true;
                          });
                          final result = await GroupService().createGroup(
                            token,
                            groupName,
                          );

                          if (result['success'] != true) {
                            setModalState(() {
                              isSaving = false;
                            });
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result['message'])),
                            );

                            return;
                          }

                          final int groupId = result['groupId'];

                          for (final key in selectedKeys) {
                            await GroupService().setLockGroup(
                              token,
                              key.lockId,
                              groupId,
                            );
                          }

                          await loadGroups();
                          if (!mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Grupo creado')),
                          );
                        },

                  child: isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> showMoveLockDialog(EKey key) async {
    int selectedGroupId = key.groupId ?? 0;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Mover ${key.lockAlias}'),
          content: StatefulBuilder(
            builder: (context, setModalState) {
              return DropdownButton<int>(
                value: selectedGroupId,
                isExpanded: true,
                items: [
                  const DropdownMenuItem(value: 0, child: Text('Sin grupo')),
                  ...groups.map((group) {
                    return DropdownMenuItem(
                      value: group.groupId,
                      child: Text(group.groupName),
                    );
                  }),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setModalState(() {
                      selectedGroupId = value;
                    });
                  }
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await GroupService().setLockGroup(
                  token,
                  key.lockId,
                  selectedGroupId,
                );
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Chapa movida' : 'Error moviendo chapa',
                    ),
                  ),
                );
                if (success) {
                  await loadGroups();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> logout() async {
    await AuthManager.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GTekey'),
        actions: [
          IconButton(
            onPressed: showCreateGroupDialog,
            icon: const Icon(Icons.add),
          ),
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      // SIN GRUPO
                      if (getUngroupedKeys().isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            "Sin grupo",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        ...getUngroupedKeys().map((key) {
                          return ListTile(
                            title: Text(key.lockAlias),

                            subtitle: Text('Batería ${key.electricQuantity}%'),

                            trailing: const Icon(Icons.edit),

                            onTap: () {
                              showMoveLockDialog(key);
                            },
                          );
                        }),
                      ],

                      // GRUPOS
                      ...groups.map((group) {
                        final groupKeys = getKeysByGroup(group.groupId);

                        if (groupKeys.isEmpty) {
                          return const SizedBox();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                group.groupName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            ...groupKeys.map((key) {
                              return ListTile(
                                title: Text(key.lockAlias),
                                subtitle: Text(
                                  ' ID ${key.lockId} || Batería ${key.electricQuantity}%',
                                ),
                                trailing: const Icon(Icons.edit),
                                onTap: () {
                                  showMoveLockDialog(key);
                                },
                              );
                            }),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
