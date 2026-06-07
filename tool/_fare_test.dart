import 'package:rail_one/core/utils/fare_calculator.dart';

void main() {
  final r = FareCalculatorService.instance.calculate('BYR', 'ADH');
  print('BYR-ADH: ${r?.totalDistanceKm}km 2nd=${r?.secondClassFare} 1st=${r?.firstClassFare} ac=${r?.acEmuFare}');
  print('15x2nd=${(r!.secondClassFare * 15)}');
  // distance slab 21-25 AC = 1210
}
