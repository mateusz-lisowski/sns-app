class Satellite {
  final int prn;
  final String name;
  final double signalStrength;
  final double azimuth;
  final double elevation;

  Satellite({
    required this.prn,
    required this.name,
    required this.signalStrength,
    required this.azimuth,
    required this.elevation,
  });
}
