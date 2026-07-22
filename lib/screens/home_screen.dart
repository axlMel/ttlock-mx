import 'package:api_app/widgets/lock_card.dart';
import 'package:flutter/material.dart';
import '../models/group.dart';
import '../models/ekey.dart';
import '../services/auth_manager.dart';
import '../services/group_service.dart';
import '../services/ekey_service.dart';
import '../theme/app_colors.dart';

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

  Widget BuildLocksGrid(List<EKey> keys) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: keys.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 118,
      ),
      itemBuilder: (context, index) {
        final key = keys[index];
        return LockCard(
          keyData: key,
          onTap: () {
            showMoveLockDialog(key);
          },
        );
      },
    );
  }

  Future<void> initialize() async {
    token = await AuthManager.getToken() ?? '';

    await loadGroups();

    initialized = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      initialize();
    }
  }

  Future<void> loadGroups() async {
    groups = await GroupService().getGroups(token);
    allKeys = await EKeyService().getEKeys(token);
    AuthManager.saveGroups(groups);
    AuthManager.saveEKeys(allKeys);
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
                        title: Text(key.lockInfo.lockAlias),
                        subtitle: Text(
                          'Batería ${key.lockState.electricQuantity}%',
                        ),
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
                              key.lockInfo.lockId,
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
          title: Text('Mover ${key.lockInfo.lockAlias}'),
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
                  key.lockInfo.lockId,
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
      backgroundColor: AppColors.background,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Stack(
                children: [
                  // FONDO DECORATIVO
                  Positioned(
                    top: -120,
                    right: -80,
                    child: Container(
                      height: 260,
                      width: 260,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  Positioned(
                    top: 40,
                    left: -100,
                    child: Container(
                      height: 220,
                      width: 220,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  Column(
                    children: [
                      // HEADER
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // TITULOS
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'GTLocks',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    'Centro de administración',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Column(
                              children: [
                                GestureDetector(
                                  onTap: showCreateGroupDialog,
                                  child: Container(
                                    width: 58,
                                    height: 58,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(
                                            0.25,
                                          ),
                                          blurRadius: 18,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                GestureDetector(
                                  onTap: logout,

                                  child: Container(
                                    width: 58,
                                    height: 58,

                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,

                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),

                                    child: const Icon(
                                      Icons.logout_rounded,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // LISTA
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.only(bottom: 30),
                          children: [
                            // SIN GRUPO
                            if (getUngroupedKeys().isNotEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                child: Text(
                                  "Sin grupo",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              BuildLocksGrid(getUngroupedKeys()),
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
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      24,
                                      20,
                                      10,
                                    ),
                                    child: Text(
                                      group.groupName,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  BuildLocksGrid(groupKeys),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
