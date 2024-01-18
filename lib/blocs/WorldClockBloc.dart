import 'dart:async';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

class WorldClockBloc {
  final _clockController = StreamController<Map<String, String>>();
  final DateTime _nextEpisodeDate;
  Timer? _timer;

  // Constructeur
  WorldClockBloc(this._nextEpisodeDate) {
    // fuseaux horaires
    tz.initializeTimeZones();
    // Démarrage de la clock
    _startClock();
  }

  Stream<Map<String, String>> get clockStream => _clockController.stream;

  void _startClock() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      // date du prochain épisode en heure JP
      final japanTime =
          tz.TZDateTime.from(_nextEpisodeDate, tz.getLocation('Asia/Tokyo'));
      // date du prochain épisode en heure FR
      final franceTime =
          tz.TZDateTime.from(_nextEpisodeDate, tz.getLocation('Europe/Paris'));
      // date du prochain épisode en heure US
      final usTime = tz.TZDateTime.from(
          _nextEpisodeDate, tz.getLocation('America/New_York'));

      // formatage de la date
      final formatter = DateFormat('dd/MM/yyyy HH:mm:ss');

      // ajout des dates précisé précédemment
      _clockController.add({
        'Prochain épisode au Japon': formatter.format(japanTime),
        'Prochain épisode en France': formatter.format(franceTime),
        'Prochain épisode aux USA': formatter.format(usTime),
      });
    });
  }

  // supprime le timer et ferme le stream
  void dispose() {
    _timer?.cancel();
    _clockController.close();
  }
}