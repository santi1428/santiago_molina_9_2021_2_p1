import 'wand.dart';

class Character {
  String name = '';
  String species = '';
  String gender = '';
  String house = '';
  String dateOfBirth = '';
  String yearOfBirth = '0';
  bool wizard = true;
  String ancestry = '';
  String eyeColour = '';
  String hairColour = '';
  Wand wand = Wand(wood: '', core: '', length: 'Not defined');
  String patronus = '';
  bool hogwartsStudent = false;
  bool hogwartsStaff = false;
  String actor = '';
  List<String> alternateActors = [];
  bool alive = true;
  String image = '';

  Character(
      {required this.name,
      required this.species,
      required this.gender,
      required this.house,
      required this.dateOfBirth,
      required this.yearOfBirth,
      required this.wizard,
      required this.ancestry,
      required this.eyeColour,
      required this.hairColour,
      required this.wand,
      required this.patronus,
      required this.hogwartsStudent,
      required this.hogwartsStaff,
      required this.actor,
      required this.alternateActors,
      required this.alive,
      required this.image});

  Character.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    species = json['species'];
    gender = json['gender'];
    house = json['house'];
    dateOfBirth = json['dateOfBirth'];
    yearOfBirth = json['yearOfBirth'] == ''
        ? 'Not defined'
        : json['yearOfBirth'].toString();
    wizard = json['wizard'];
    ancestry = json['ancestry'];
    eyeColour = json['eyeColour'];
    hairColour = json['hairColour'];
    wand = json['wand'] != null
        ? Wand.fromJson(json['wand'])
        : Wand(wood: '', core: '', length: 'Not defined');
    patronus = json['patronus'] == '' ? 'Not defined' : json['patronus'];
    hogwartsStudent = json['hogwartsStudent'];
    hogwartsStaff = json['hogwartsStaff'];
    actor = json['actor'];
    alternateActors = json['alternate_actors'].cast<String>();
    alive = json['alive'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['species'] = this.species;
    data['gender'] = this.gender;
    data['house'] = this.house;
    data['dateOfBirth'] = this.dateOfBirth;
    data['yearOfBirth'] = this.yearOfBirth;
    data['wizard'] = this.wizard;
    data['ancestry'] = this.ancestry;
    data['eyeColour'] = this.eyeColour;
    data['hairColour'] = this.hairColour;
    if (this.wand != null) {
      data['wand'] = this.wand.toJson();
    }
    data['patronus'] = this.patronus;
    data['hogwartsStudent'] = this.hogwartsStudent;
    data['hogwartsStaff'] = this.hogwartsStaff;
    data['actor'] = this.actor;
    data['alternate_actors'] = this.alternateActors;
    data['alive'] = this.alive;
    data['image'] = this.image;
    return data;
  }
}
