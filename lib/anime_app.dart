import 'package:flutter/material.dart';
import '../widgets/anime_favorite.dart';
import 'widgets/anime_list.dart';
import 'widgets/anime_inprogress.dart';

class MyAnimeApp extends StatefulWidget {
  @override
  _MyAnimeAppState createState() => _MyAnimeAppState();
}

class _MyAnimeAppState extends State<MyAnimeApp> {
  bool isNightMode = false; // Mode nuit désactivé par défaut
  bool isHovered = false; // État de survol de la souris

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mes animés app !',
      theme: isNightMode
          ? ThemeData.dark()
          : ThemeData.light(), // Thème de l'application
      debugShowCheckedModeBanner: false, // Désactive le bandeau de mode debug
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Mes animés'),
            bottom: TabBar(
              tabs: [
                // Onglets de la barre d'onglets
                Tab(text: 'Mes animes à regarder'),
                Tab(text: 'Mes animés vus favoris'),
                Tab(text: 'Prochains animés')
              ],
            ),
            actions: [
              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    isHovered = true; // changement état de survol
                  });
                },
                onExit: (_) {
                  setState(() {
                    isHovered = false; // changement état de survol
                  });
                },
                child: AnimatedTheme(
                  duration: Duration(milliseconds: 200),
                  data: isNightMode ? ThemeData.dark() : ThemeData.light(),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isNightMode = !isNightMode;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Icon(
                        isNightMode ? Icons.brightness_3_rounded: Icons.wb_sunny_rounded,
                        color: isNightMode
                            ? Colors.deepPurple
                            : (isHovered
                                ? Colors.blue.withOpacity(0.8)
                                : Colors.blue),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              TabBarView(
                children: [
                  AnimeList(), // Liste des animes
                  AnimeFavorite(), // Liste des animes favoris
                  AnimeInProgress(), // Liste des animes en cours
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
