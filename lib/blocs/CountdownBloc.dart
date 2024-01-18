import 'dart:async';

class CountdownBloc {
  late DateTime _nextEpisodeDate;
  late Timer _timer;
  final _countdownController = StreamController<String>();

  // Constructeur
  CountdownBloc(DateTime nextEpisodeDate) {
    _nextEpisodeDate = nextEpisodeDate;
    _startTimer();
  }

//getter
  Stream<String> get countdownStream => _countdownController.stream;

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      final duration = _nextEpisodeDate.difference(DateTime.now()); //calcul prochain episode 
      final days = duration.inDays;
      final hours = duration.inHours.remainder(24);
      final minutes = duration.inMinutes.remainder(60);
      final seconds = duration.inSeconds.remainder(60);

      // Ajout du compte à rebours au flux
      if (!_countdownController.isClosed) {
        _countdownController.add(
            '$days jours $hours heures $minutes minutes $seconds secondes restantes !');
      }
    });
  }

  // suppression du timer
  void dispose() {
    _timer.cancel();
    _countdownController.close();
  }
}