class Wand {
  String wood = '';
  String core = '';
  String length = "No definido";

  Wand({required this.wood, required this.core, required this.length});

  Wand.fromJson(Map<String, dynamic> json) {
    wood = json['wood'];
    core = json['core'];
    length = json['length'] == '' ? 'No definido' : json['length'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['wood'] = this.wood;
    data['core'] = this.core;
    data['length'] = this.length;
    return data;
  }
}
