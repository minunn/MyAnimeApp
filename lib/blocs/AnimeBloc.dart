import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Anime.dart';

class AnimeBloc {
  final _animeListSubject = BehaviorSubject<List<Anime>>();
  Stream<List<Anime>> get animeList => _animeListSubject.stream;
  final List<Anime> _favoriteAnimes = [];
  final _favoriteAnimesController = StreamController<List<Anime>>.broadcast();
  List<Anime> get favoriteAnimes => _favoriteAnimes;

  // Constructor
  AnimeBloc() {
    // Chargement liste des animes et favoris
    _loadAnimeList();
    loadFavorites();
  }

//FutureBuilder pour charger les animes par défaut depuis les sharedPreferences
  Future<void> _loadAnimeList() async {
    final prefs = await SharedPreferences.getInstance();
    // Récupération de la liste des animes par défaut JSON et conversion en liste d'animes avec fromJson
    final animeListJson = prefs.getString('animeList') ?? '[]';
    final animeList = (json.decode(animeListJson) as List)
        .map((animeJson) => Anime.fromJson(animeJson))
        .toList();
    // Ajout des animes du JSON traité à la liste des animes
    _animeListSubject.add(animeList);
  }

//FutureBuilder pour charger les animes par défaut depuis le fichier JSON
  Future<List<Anime>> loadDefaultAnime() async {
    final jsonString = await rootBundle.loadString('default_anime.json');
    // Conversion du JSON en liste pour Anime et conversion en liste d'animes avec fromJson
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => Anime.fromJson(json)).toList();
  }

//FutureBuilder pour ajouter un anime et sauvegarder les sharedPreferences
  Future<void> addAnime(Anime anime) async {
    final animeList = _animeListSubject.value;
    // Ajout de l'anime à la liste et ajout de la nouvelle liste à la liste des animes 
    //et pour finir sauvegarde de la liste des animes avec les sharedPreferences
    animeList.add(anime);
    _animeListSubject.add(animeList);
    await _saveAnimeList(animeList);
  }

//FutureBuilder pour ajouter un anime aux favoris et sauvegarder les sharedPreferences
  Future<void> addFavoriteAnime(Anime anime) async {
    // Ajout de l'anime à la liste des favoris et ajout de la nouvelle liste à la liste des favoris
    _favoriteAnimes.add(anime);
    _favoriteAnimesController.add(_favoriteAnimes);
    print('Anime ajouté aux favoris: ' + anime.title);
    // Récupération des sharedPreferences et ajout de l'anime aux sharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(anime.title, true);
  }

  Future<void> removeFavoriteAnime(Anime anime) async {
    // Suppression de l'anime de la liste des favoris et ajout de la nouvelle liste à la liste des favoris
    _favoriteAnimes.remove(anime);
    _favoriteAnimesController.add(_favoriteAnimes);
    print('Anime supprimé des favoris: ' + anime.title);
    // Récupération des sharedPreferences et suppression de l'anime des sharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(anime.title);

    //update des animes favoris
    final animeList = _animeListSubject.value;
    final index = animeList.indexWhere((item) => item.title == anime.title);
    if (index != -1) {
      animeList[index].isFavorite = false; //defini l'anime comme non favori
      _animeListSubject.add(animeList);
    }
  }

//FutureBuilder pour charger les favoris depuis les sharedPreferences
  Future<void> loadFavorites() async {
    // Récupération des sharedPreferences
    final prefs = await SharedPreferences.getInstance();
    if (_animeListSubject.hasValue) {
      for (var anime in _animeListSubject.value) {
        anime.isFavorite = prefs.getBool(anime.title) ?? false;
        // Ajout de l'anime à la liste des favoris si il est favori dans les sharedPreferences
        if (anime.isFavorite) {
          _favoriteAnimes.add(anime);
        }
      }
      // Ajout de la liste des anime favoris à la liste des favoris
      _favoriteAnimesController.add(_favoriteAnimes);
    }
  }

//FutureBuilder pour supprimer un anime et sauvegarder les sharedPreferences
  Future<void> deleteAnime(Anime anime) async {
    //recupere la liste des animes et supprime l'anime pour ensuite ajouter la nouvelle liste avec l'anime supprimé
    // et sauvegarder la liste des animes avec les sharedPreferences
    final animeList = _animeListSubject.value;
    animeList.remove(anime);
    _animeListSubject.add(animeList);
    await _saveAnimeList(animeList);
  }

//FutureBuilder pour sauvegarder les sharedPreferences
  Future<void> _saveAnimeList(List<Anime> animeList) async {
    // Récupération des sharedPreferences, conversion de la liste des animes en JSON et sauvegarde de la liste des animes en JSON avec les sharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final animeListJson =
        json.encode(animeList.map((anime) => anime.toJson()).toList());
    await prefs.setString('animeList', animeListJson);
  }

//FutureBuilder pour fermer les streams des animes pour éviter les fuites de mémoire
  Future<void> dispose() async {
  //je ferme les streams des anime pour éviter les fuites de mémoire :)
    _animeListSubject.close();
  }
}