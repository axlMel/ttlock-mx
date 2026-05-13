class Group {
  final int groupId;
  final String groupName;

  Group({
    required this.groupId,
    required this.groupName,
  });
  
  factory Group.fromJson(Map<String, dynamic> json){
    return Group(
      groupId: json['groupId'], 
      groupName: json['groupName'] ?? 'Sin nombre',
    );
  }
}