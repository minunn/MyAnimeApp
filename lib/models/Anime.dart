// model Anime
class Anime {
  String title;
  String description;
  String imageUrl;
  DateTime nextEpisodeDate;
  bool isFavorite;
  String crunchyrollUrl;
  String trailerUrl;

  // Constructor
  Anime({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.nextEpisodeDate,
    this.isFavorite = false,
    required this.crunchyrollUrl,
    required this.trailerUrl,
  });

  // Getter pour le temps restant avant le prochain épisode
  Duration get nextEpisodeCountdown =>
      nextEpisodeDate.difference(DateTime.now());

  // Création d'un JSON à partir d'un objet Anime (pour le stockage) DTO
  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'nextEpisodeDate': nextEpisodeDate.toIso8601String(),
        'crunchyrollUrl': crunchyrollUrl,
        'trailerUrl': trailerUrl,
      };

  // Création d'un objet Anime à partir d'un JSON (pour le stockage) DTO
  factory Anime.fromJson(Map<String, dynamic> json) => Anime(
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        imageUrl: json['imageUrl'] ?? '',
        nextEpisodeDate: json['nextEpisodeDate'] != null
            ? DateTime.parse(json['nextEpisodeDate'])
            : DateTime.now(),
        crunchyrollUrl: json['crunchyrollUrl'] ?? '',
        trailerUrl: json['trailerUrl'] ?? '',
      );
}
