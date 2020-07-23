part of 'theme_bloc.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
}

class ChangeAppTheme extends ThemeEvent {
  final AppTheme theme;

  ChangeAppTheme({@required this.theme});

  @override
  List<Object> get props => [theme];
}
