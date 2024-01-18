import 'package:flutter/material.dart';
import 'package:flutterevaluation/models/Anime.dart';
import '../blocs/AnimeBloc.dart';
import 'anime_details.dart';

class AnimeFavorite extends StatefulWidget {
  @override
  _AnimeListState createState() => _AnimeListState();
}

class _AnimeListState extends State<AnimeFavorite> {
  final _animeBloc = AnimeBloc(); // Blocs animes

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes animés favoris'),
      ),
      body: StreamBuilder<List<Anime>>(
        stream: _animeBloc.animeList, // Liste des animes
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            // Si les données ne sont pas encore disponibles, j'affiche un indicateur de chargement
            return const Center(child: CircularProgressIndicator());
          }
          final animeList = snapshot.data!;
          // Filtre la liste d'anime pour avoir que les favoris
          final favoriteAnimeList =
              animeList.where((anime) => anime.isFavorite).toList();
          return ListView.builder(
            itemCount:
                favoriteAnimeList.length, // nombres d'animes dans la liste
            itemBuilder: (context, index) {
              final anime = favoriteAnimeList[index]; // anime courant
              return Dismissible(
                key: Key(anime.title), // key pour le dismissible
                onDismissed: (direction) {
                  _animeBloc.deleteAnime(
                      anime); // suppression de l'anime quand je swipe
                },
                child: ListTile(
                  leading: Container(
                    height: 200,
                    width: 100,
                    child: Image.network(
                      anime.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext context, Object exception,
                          StackTrace? stackTrace) {
                        return const Text(
                            'Image introuvable'); //message d'erreur si l'image n'est pas trouvée
                      },
                    ),
                  ),
                  title: Text(anime.title),
                  subtitle: RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan>[
                        TextSpan(
                            text:
                                '${anime.description}\n'), //affiche la description de l'anime
                        TextSpan(
                            text:
                                '${anime.nextEpisodeCountdown.inDays} jours avant le prochain épisode', // nombre de jours avant le prochain épisode
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  // detail de l'anime quand je clique dessus
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            AnimeDetails(anime: anime),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;
                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);
                          return SlideTransition(
                              position: offsetAnimation, child: child);
                        },
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
