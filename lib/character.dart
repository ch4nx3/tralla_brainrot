class Skill {
  final String name;
  final int damage; // Attack skill damage
  final double defense; // Defense skill ratio (0~1)
  final String sound; // Skill sound file

  Skill({
    required this.name,
    this.damage = 0,
    this.defense = 0.0,
    required this.sound,
  });
}

class Character {
  final String name;
  final String image;
  final String description;
  final Skill attackSkill;
  final Skill defenseSkill;
  int starLevel; // 0~9 stars

  Character({
    required this.name,
    required this.image,
    required this.description,
    required this.attackSkill,
    required this.defenseSkill,
    this.starLevel = 0,
  });

  // HP and attack calculation (increases with upgrades)
  int get hp => 100 + starLevel * 10; // Base 100, +10 per star
  int get attack => 10 + starLevel * 2; // Base 10, +2 per star

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Character &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}

final List<Character> allCharacters = [
  Character(
    name: 'Tralalero Tralala',
    image: 'assets/tralalero_tralala.png',
    description: 'Strong bite, fast running speed, excellent jumping',
    attackSkill: Skill(
      name: 'Powerful Bite',
      damage: 20,
      sound: 'assets/trala.wav',
    ),
    defenseSkill: Skill(
      name: 'Swift Dodge',
      defense: 0.5,
      sound: 'assets/trala.wav',
    ),
  ),
  Character(
    name: 'Bombardiro Crocodillo',
    image: 'assets/bombardiro_crocodillo.png',
    description: 'Bombing, flying',
    attackSkill: Skill(
      name: 'Bombing Strike',
      damage: 25,
      sound: 'assets/bombardiro.wav',
    ),
    defenseSkill: Skill(
      name: 'Flying Defense',
      defense: 0.4,
      sound: 'assets/bombardiro.wav',
    ),
  ),
  Character(
    name: 'Trippi Troppi',
    image: 'assets/trippi_troppi.png',
    description: 'Fast swimming, wave attack, hail',
    attackSkill: Skill(
      name: 'Wave Attack',
      damage: 18,
      sound: 'assets/trippi.wav',
    ),
    defenseSkill: Skill(
      name: 'Hail Defense',
      defense: 0.5,
      sound: 'assets/trippi.wav',
    ),
  ),
  Character(
    name: 'Schimpanzini Bananini',
    image: 'assets/schimpanzini_bananini.png',
    description: 'Agility',
    attackSkill: Skill(
      name: 'Agile Rush',
      damage: 15,
      sound: 'assets/schimpanzini.wav',
    ),
    defenseSkill: Skill(
      name: 'Agile Defense',
      defense: 0.6,
      sound: 'assets/schimpanzini.wav',
    ),
  ),
  Character(
    name: 'Bombombini Gusini',
    image: 'assets/bombombini_gusini.png',
    description: 'Bombing flight, infinite ammo',
    attackSkill: Skill(
      name: 'Infinite Bombing',
      damage: 22,
      sound: 'assets/bombombini.wav',
    ),
    defenseSkill: Skill(
      name: 'Flight Evasion',
      defense: 0.4,
      sound: 'assets/bombombini.wav',
    ),
  ),
  Character(
    name: 'Frigo Camelo',
    image: 'assets/frigo_camelo.png',
    description: 'Cold breath',
    attackSkill: Skill(
      name: 'Frost Breath',
      damage: 20,
      sound: 'assets/frigo.wav',
    ),
    defenseSkill: Skill(
      name: 'Ice Defense',
      defense: 0.5,
      sound: 'assets/frigo.wav',
    ),
  ),
  Character(
    name: 'U Din Din Din Dun Ma Din Din Din Dun',
    image: 'assets/u_din_din_din_dun_ma_din_din_din_dun.png',
    description: 'Immense strength, incredible grip',
    attackSkill: Skill(
      name: 'Powerful Grip',
      damage: 30,
      sound: 'assets/u.wav',
    ),
    defenseSkill: Skill(
      name: 'Sturdy Body',
      defense: 0.3,
      sound: 'assets/u.wav',
    ),
  ),
  Character(
    name: 'Lirilì Larila',
    image: 'assets/lirili_larila.png',
    description: 'Time stop',
    attackSkill: Skill(
      name: 'Time Stop Attack',
      damage: 25,
      sound: 'assets/lirili.wav',
    ),
    defenseSkill: Skill(
      name: 'Time Defense',
      defense: 0.4,
      sound: 'assets/lirili.wav',
    ),
  ),
  Character(
    name: 'Brr Brr Patapim',
    image: 'assets/brr_brr_patapim.png',
    description: 'Forest control, trap setting',
    attackSkill: Skill(
      name: 'Trap Attack',
      damage: 18,
      sound: 'assets/brr.wav',
    ),
    defenseSkill: Skill(
      name: 'Forest Defense',
      defense: 0.5,
      sound: 'assets/brr.wav',
    ),
  ),
  Character(
    name: 'Tung Tung Tung Tung Sahur',
    image: 'assets/tung_tung_tung_tung_sahur.png',
    description: 'Transformation ability, powerful baseball bat swing',
    attackSkill: Skill(
      name: 'Baseball Swing',
      damage: 28,
      sound: 'assets/tung.wav',
    ),
    defenseSkill: Skill(
      name: 'Transform Defense',
      defense: 0.4,
      sound: 'assets/tung.wav',
    ),
  ),
];
