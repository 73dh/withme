import 'package:flutter/material.dart';

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff6c538b),
      surfaceTint: Color(0xff6c538b),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffeedbff),
      onPrimaryContainer: Color(0xff543b72),
      secondary: Color(0xff655a6f),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffecddf7),
      onSecondaryContainer: Color(0xff4c4357),
      tertiary: Color(0xff80515a),
      onTertiary: Color(0xffffffff),
      // tertiaryContainer: Color(0xffffd9de),
      tertiaryContainer: Color(0xfff4e9fb),
      onTertiaryContainer: Color(0xff653b42),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffff7ff),
      onSurface: Color(0xff1d1a20),
      onSurfaceVariant: Color(0xff4a454e),
      outline: Color(0xff7b757f),
      outlineVariant: Color(0xffccc4cf),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff332f35),
      inversePrimary: Color(0xffd8bafa),
      primaryFixed: Color(0xffeedbff),
      onPrimaryFixed: Color(0xff260d44),
      primaryFixedDim: Color(0xffd8bafa),
      onPrimaryFixedVariant: Color(0xff543b72),
      secondaryFixed: Color(0xffecddf7),
      onSecondaryFixed: Color(0xff20182a),
      secondaryFixedDim: Color(0xffcfc1da),
      onSecondaryFixedVariant: Color(0xff4c4357),
      tertiaryFixed: Color(0xffffd9de),
      onTertiaryFixed: Color(0xff321018),
      tertiaryFixedDim: Color(0xfff2b7c0),
      onTertiaryFixedVariant: Color(0xff653b42),
      surfaceDim: Color(0xffdfd8e0),
      surfaceBright: Color(0xfffff7ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff9f1f9),
      surfaceContainer: Color(0xfff3ebf4),
      surfaceContainerHigh: Color(0xffede6ee),
      surfaceContainerHighest: Color(0xffe8e0e8),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff422a60),
      surfaceTint: Color(0xff6c538b),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff7b629b),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff3b3246),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff74697e),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff522a32),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff906068),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffd03b37),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff7ff),
      onSurface: Color(0xff131015),
      onSurfaceVariant: Color(0xff39343d),
      outline: Color(0xff56505a),
      outlineVariant: Color(0xff716b75),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff332f35),
      inversePrimary: Color(0xffd8bafa),
      primaryFixed: Color(0xff7b629b),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff624981),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff74697e),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff5b5165),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff906068),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff754850),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffcbc4cc),
      surfaceBright: Color(0xfffff7ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff9f1f9),
      surfaceContainer: Color(0xffede6ee),
      surfaceContainerHigh: Color(0xffe2dbe2),
      surfaceContainerHighest: Color(0xffd6cfd7),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff382055),
      surfaceTint: Color(0xff6c538b),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff563e75),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff31283b),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff4f4559),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff462128),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff683d45),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff7ff),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff2f2a33),
      outlineVariant: Color(0xff4c4750),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff332f35),
      inversePrimary: Color(0xffd8bafa),
      primaryFixed: Color(0xff563e75),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff3f275c),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff4f4559),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff382f42),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff683d45),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff4e272f),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffbdb7be),
      surfaceBright: Color(0xfffff7ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff6eef6),
      surfaceContainer: Color(0xffe8e0e8),
      surfaceContainerHigh: Color(0xffd9d2da),
      surfaceContainerHighest: Color(0xffcbc4cc),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffd8bafa),
      surfaceTint: Color(0xffd8bafa),
      onPrimary: Color(0xff3c245a),
      primaryContainer: Color(0xff543b72),
      onPrimaryContainer: Color(0xffeedbff),
      secondary: Color(0xffcfc1da),
      onSecondary: Color(0xff352d40),
      secondaryContainer: Color(0xff4c4357),
      onSecondaryContainer: Color(0xffecddf7),
      tertiary: Color(0xfff2b7c0),
      onTertiary: Color(0xff4b252c),
      tertiaryContainer: Color(0xff231d29),
      // tertiaryContainer: Color(0xff653b42),
      onTertiaryContainer: Color(0xffffd9de),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff151218),
      onSurface: Color(0xffe8e0e8),
      onSurfaceVariant: Color(0xffccc4cf),
      outline: Color(0xff958e99),
      outlineVariant: Color(0xff4a454e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe8e0e8),
      inversePrimary: Color(0xff6c538b),
      primaryFixed: Color(0xffeedbff),
      onPrimaryFixed: Color(0xff260d44),
      primaryFixedDim: Color(0xffd8bafa),
      onPrimaryFixedVariant: Color(0xff543b72),
      secondaryFixed: Color(0xffecddf7),
      onSecondaryFixed: Color(0xff20182a),
      secondaryFixedDim: Color(0xffcfc1da),
      onSecondaryFixedVariant: Color(0xff4c4357),
      tertiaryFixed: Color(0xffffd9de),
      onTertiaryFixed: Color(0xff321018),
      tertiaryFixedDim: Color(0xfff2b7c0),
      onTertiaryFixedVariant: Color(0xff653b42),
      surfaceDim: Color(0xff151218),
      surfaceBright: Color(0xff3b383e),
      surfaceContainerLowest: Color(0xff100d12),
      surfaceContainerLow: Color(0xff1d1a20),
      surfaceContainer: Color(0xff211e24),
      surfaceContainerHigh: Color(0xff2c292f),
      surfaceContainerHighest: Color(0xff373339),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffe9d4ff),
      surfaceTint: Color(0xffd8bafa),
      onPrimary: Color(0xff31194e),
      primaryContainer: Color(0xffa085c1),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffe5d7f0),
      onSecondary: Color(0xff2a2234),
      secondaryContainer: Color(0xff988ca3),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffffd1d7),
      onTertiary: Color(0xff3e1a22),
      tertiaryContainer: Color(0xffb7838b),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff151218),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffe2d9e5),
      outline: Color(0xffb7afba),
      outlineVariant: Color(0xff958e98),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe8e0e8),
      inversePrimary: Color(0xff553c73),
      primaryFixed: Color(0xffeedbff),
      onPrimaryFixed: Color(0xff1b0139),
      primaryFixedDim: Color(0xffd8bafa),
      onPrimaryFixedVariant: Color(0xff422a60),
      secondaryFixed: Color(0xffecddf7),
      onSecondaryFixed: Color(0xff150e1f),
      secondaryFixedDim: Color(0xffcfc1da),
      onSecondaryFixedVariant: Color(0xff3b3246),
      tertiaryFixed: Color(0xffffd9de),
      onTertiaryFixed: Color(0xff25060e),
      tertiaryFixedDim: Color(0xfff2b7c0),
      onTertiaryFixedVariant: Color(0xff522a32),
      surfaceDim: Color(0xff151218),
      surfaceBright: Color(0xff474349),
      surfaceContainerLowest: Color(0xff09070b),
      surfaceContainerLow: Color(0xff1f1c22),
      surfaceContainer: Color(0xff2a272c),
      surfaceContainerHigh: Color(0xff353137),
      surfaceContainerHighest: Color(0xff403c42),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfff8ecff),
      surfaceTint: Color(0xffd8bafa),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffd4b6f6),
      onPrimaryContainer: Color(0xff14002d),
      secondary: Color(0xfff8ecff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffcbbed6),
      onSecondaryContainer: Color(0xff0f0819),
      tertiary: Color(0xffffebed),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffeeb3bc),
      onTertiaryContainer: Color(0xff1d0308),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff151218),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xfff6edf8),
      outlineVariant: Color(0xffc8c0cb),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe8e0e8),
      inversePrimary: Color(0xff553c73),
      primaryFixed: Color(0xffeedbff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffd8bafa),
      onPrimaryFixedVariant: Color(0xff1b0139),
      secondaryFixed: Color(0xffecddf7),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffcfc1da),
      onSecondaryFixedVariant: Color(0xff150e1f),
      tertiaryFixed: Color(0xffffd9de),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xfff2b7c0),
      onTertiaryFixedVariant: Color(0xff25060e),
      surfaceDim: Color(0xff151218),
      surfaceBright: Color(0xff534f55),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff211e24),
      surfaceContainer: Color(0xff332f35),
      surfaceContainerHigh: Color(0xff3e3a40),
      surfaceContainerHighest: Color(0xff49454c),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
  );

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}

extension ColorSchemeX on ColorScheme {
  Color get onSurface38 => onSurface.withValues(alpha: 0.38);

  Color get onSurface12 => onSurface.withValues(alpha: 0.12);

  Color get onSurface60 => onSurface.withValues(alpha: 0.6);

  Color get onSurface80 => onSurface.withValues(alpha: 0.8);
}
