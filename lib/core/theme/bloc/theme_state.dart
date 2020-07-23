part of 'theme_bloc.dart';

class AppThemeState extends Equatable {
  final ThemeData themeData;

  AppThemeState({@required this.themeData});

  @override
  List<Object> get props => [themeData];
}
