import '../../presentation/core_presentation_import.dart';

AppBarTheme buildAppBarTheme(ColorScheme colors) {
  return AppBarTheme(
    backgroundColor: colors.surfaceContainerHighest,
    surfaceTintColor: Colors.transparent, // M3 오버레이 제거
    foregroundColor: colors.onSurface,
    elevation: 0,

    iconTheme: IconThemeData(color: colors.onSurface),
  );
}

BottomNavigationBarThemeData buildBottomNavTheme(ColorScheme colors) {
  return BottomNavigationBarThemeData(
    backgroundColor: colors.surface,
    selectedItemColor: colors.primary,
    unselectedItemColor: colors.onSurfaceVariant,
    type: BottomNavigationBarType.fixed,
    showUnselectedLabels: true,
  );
}

FloatingActionButtonThemeData buildFloatingActionButtonTheme(ColorScheme colors) {
  return FloatingActionButtonThemeData(
    backgroundColor: colors.primary,
    shape: const CircleBorder(),
  );
}
