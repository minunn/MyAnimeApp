import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/Anime.dart';
import '../blocs/CountdownBloc.dart';
import '../blocs/WorldClockBloc.dart';

class AnimeDetails extends StatefulWidget {
  final Anime anime;

  AnimeDetails({required this.anime});

  @override
  _AnimeDetailsState createState() => _AnimeDetailsState();
}

class _AnimeDetailsState extends State<AnimeDetails>
    with SingleTickerProviderStateMixin {
  // Blocs
  late CountdownBloc _countdownBloc;
  late WorldClockBloc _worldClockBloc;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _countdownBloc = CountdownBloc(widget.anime.nextEpisodeDate);
    _worldClockBloc = WorldClockBloc(widget.anime.nextEpisodeDate);

// Animation du container de l'anime avec un effet de zoom
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();

// ajout d'une courbe pour l'animation
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
  }

  // Suppression des blocs
  @override
  void dispose() {
    _countdownBloc.dispose();
    _worldClockBloc.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.anime.title),
        centerTitle: true,
      ),
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (BuildContext context, Widget? child) {
            return Transform.scale(
              scale: _animation.value,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 243, 243, 243),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color:
                          const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // ombrage du container
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        widget.anime.title,
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.0),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          widget.anime.imageUrl,
                          width: 200,
                          height: 200,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        widget.anime
                            .description, //affiche la description de l'anime
                        style: TextStyle(
                          fontSize: 16.0,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        '${widget.anime.nextEpisodeCountdown.inDays} jours avant le prochain épisode', // afficha le nombre de jours avant le prochain épisode
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      StreamBuilder<String>(
                        stream: _countdownBloc
                            .countdownStream, //compte à rebours avec les jours, heures, minutes et secondes
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ?? '',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 0, 0, 0),
                            ),
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                      // Heure de sortie de l'épisode suivant la zone horaire de chaque pays
                      StreamBuilder<Map<String, String>>(
                        stream: _worldClockBloc.clockStream,
                        builder: (context, snapshot) {
                          final clockData = snapshot.data ?? {};
                          return Column(
                            children: clockData.entries.map((entry) {
                              return Text(
                                '${entry.key}: ${entry.value}',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                ),
                                textAlign: TextAlign.center,
                              );
                            }).toList(),
                          );
                        },
                      ),
                      // Bouton pour ouvrir l'anime sur Crunchyroll si un lien est disponible
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () async {
                          //j'utilise le package url_launcher pour ouvrir le lien
                          launchUrl(Uri.parse(widget.anime.crunchyrollUrl));
                        },
                        child: Text('Regarder sur Crunchyroll'),
                      ),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                          onPressed: () async {
                            launchUrl(Uri.parse(widget.anime.trailerUrl));
                          },
                          child: Text('Regarder le trailer de l\'anime'))
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
