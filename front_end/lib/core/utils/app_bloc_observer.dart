import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/core/utils/logger.dart';

/// A BlocObserver that logs all bloc events, state changes, and errors
/// This provides a centralized way to monitor the behavior of all blocs in the application
class AppBlocObserver extends BlocObserver {
  final AppLogger _logger;
  
  AppBlocObserver(this._logger);
  
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    _logger.debug('onCreate -- ${bloc.runtimeType}', {
      'component': 'BlocObserver',
      'bloc_type': '${bloc.runtimeType}',
      'event_type': 'create'
    });
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    _logger.debug('onEvent -- ${bloc.runtimeType}, $event', {
      'component': 'BlocObserver',
      'bloc_type': '${bloc.runtimeType}',
      'event_type': '${event.runtimeType}'
    });
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    _logger.debug('onChange -- ${bloc.runtimeType}, ${change.currentState.runtimeType} → ${change.nextState.runtimeType}', {
      'component': 'BlocObserver',
      'bloc_type': '${bloc.runtimeType}',
      'current_state': '${change.currentState.runtimeType}',
      'next_state': '${change.nextState.runtimeType}'
    });
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    
    final currentState = transition.currentState.runtimeType.toString();
    final nextState = transition.nextState.runtimeType.toString();
    final event = transition.event.runtimeType.toString();
    
    _logger.debug('onTransition -- ${bloc.runtimeType}, Event: $event, $currentState → $nextState', {
      'component': 'BlocObserver',
      'bloc_type': '${bloc.runtimeType}',
      'event': event,
      'current_state': currentState,
      'next_state': nextState
    });
    
    // Track error states for better monitoring
    if (transition.nextState.toString().contains('Failure')) {
      _logger.warning('State transition to error state: $nextState');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    _logger.error(
      'onError -- ${bloc.runtimeType}',
      error: error, 
      stackTrace: stackTrace
    );
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    _logger.debug('onClose -- ${bloc.runtimeType}', {
      'component': 'BlocObserver',
      'bloc_type': '${bloc.runtimeType}',
      'event_type': 'close'
    });
  }
}
