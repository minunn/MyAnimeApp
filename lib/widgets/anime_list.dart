import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Anime.dart';
import '../blocs/AnimeBloc.dart';
import 'anime_details.dart';

class AnimeList extends StatefulWidget {
  @override
  _AnimeListState createState() => _AnimeListState();
}

class _AnimeListState extends State<AnimeList> {
  final _animeBloc = AnimeBloc(); // Blocs animes

  @override
  Widget build(BuildContext context) {
    //interface utilisateur
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes animés à regarder'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddAnimeDialog, //dialogue ajouter un nouvel anime
          ),
        ],
      ),
      body: StreamBuilder<List<Anime>>(
        stream: _animeBloc.animeList, // Liste des animes
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            // Si les données ne sont pas encore disponibles, j'affiche un indicateur de chargement
            return const Center(child: CircularProgressIndicator());
          }
          final animeList = snapshot.data!;
          return ListView.builder(
            itemCount: animeList.length,
            itemBuilder: (context, index) {
              final anime = animeList[index];
              return Dismissible(
                key: Key(anime.title),
                onDismissed: (direction) {
                  _animeBloc
                      .deleteAnime(anime); // Supprime l'anime quand je swipe
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
                                '${anime.nextEpisodeCountdown.inDays} jours avant le prochain épisode', //affiche le nombre de jours avant le prochain épisode
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.favorite,
                            color: anime.isFavorite ? Colors.red : Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                    onPressed: () {
                      print('Bouton favori cliqué !');
                      if (anime.isFavorite) {
                        _animeBloc.removeFavoriteAnime(
                            anime); // Supprime l'anime des favoris
                      } else {
                        _animeBloc.addFavoriteAnime(
                            anime); // Ajoute l'anime aux favoris
                      }
                      setState(() {
                        anime.isFavorite = !anime
                            .isFavorite; // Change l'état de favori de l'anime
                      });
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            AnimeDetails(
                                anime: anime), // Affiche les détails de l'anime
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

  @override
  void initState() {
    super.initState();
    loadAnimeData(); // Charge les animes au démarrage de l'application
  }

  void loadAnimeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loaded = prefs.getBool('loaded') ?? false;

    if (!loaded) {
      _animeBloc.loadDefaultAnime().then((defaultAnime) {
        for (var anime in defaultAnime) {
          _animeBloc.addAnime(
              anime); // Ajoute les animes par défaut à la liste (fichier json)
        }
      });

      await prefs.setBool('loaded',
          true); // Marque les données comme chargées pour ne pas les recharger à chaque démarrage de l'application ou rechargement de la page
    }
  }

  void _showAddAnimeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String title = '';
        String description = '';
        String imageUrl = '';
        DateTime nextEpisodeDate = DateTime.now();
        String crunchyrollUrl = '';
        String trailerUrl = '';

        return AlertDialog(
          title: const Text('Ajouter un anime'),
          content: Column(
            children: [
              TextField(
                onChanged: (value) => title = value,
                decoration: InputDecoration(labelText: 'Titre de l\'anime'),
              ),
              TextField(
                onChanged: (value) => description = value,
                decoration:
                    InputDecoration(labelText: 'Description de l\'anime'),
              ),
              TextField(
                onChanged: (value) => imageUrl = value,
                decoration:
                    InputDecoration(labelText: 'Image de l\'anime (URL)'),
              ),
              ElevatedButton(
                child: Text('Date du prochain épisode'),
                onPressed: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (selectedDate != null) {
                    nextEpisodeDate =
                        selectedDate; // Met à jour la date du prochain épisode
                  }
                },
              ),
              TextField(
                onChanged: (value) => crunchyrollUrl = value,
                decoration: InputDecoration(
                    labelText: 'Lien Crunchyroll de l\'anime (URL)'),
              ),
              // TextField(
              //   onChanged: (value) => trailerEmbedUrl = value,
              //   decoration: InputDecoration(
              //       labelText: 'Lien de la bande-annonce de l\'anime (URL)'),
              // ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Ajouter l\'anime'),
              onPressed: () {
                final anime = Anime(
                  title: title,
                  description: description,
                  imageUrl: imageUrl,
                  nextEpisodeDate: nextEpisodeDate,
                  crunchyrollUrl: crunchyrollUrl,
                  trailerUrl: trailerUrl,
                );
                _animeBloc.addAnime(anime); // Ajoute le nouvel anime à la liste
                Navigator.of(context).pop(); // Ferme le dialogue
              },
            ),
          ],
        );
      },
    );
  }
}
