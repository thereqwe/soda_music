// event_bus.dart
import 'package:event_bus/event_bus.dart';

EventBus eventBus = EventBus();

class PlaySongEvent {
  final String action;
  PlaySongEvent(this.action);
}
