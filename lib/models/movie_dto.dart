class MovieDTO {
  final int? id;
  final String? name;
  final String? time;
  final String? released;

  MovieDTO({
    required this.id,
    required this.name,
    required this.time,
    required this.released,
  });

  factory MovieDTO.fromJson(Map<String, dynamic> json) {
    return MovieDTO(
      id: json['id'],
      name: json['name'],
      time: json['time'],
      released: json['released'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'time': time, 'released': released};
  }
}
