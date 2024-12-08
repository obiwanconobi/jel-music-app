import 'package:jel_music/models/bar%20chart/individual_bar.dart';

class BarData {
  final double monAmount;
  final double tueAmount;
  final double wedAmount;
  final double thuAmount;
  final double friAmount;
  final double satAmount;
  final double sunAmount;

  BarData({required this.monAmount, required this.tueAmount, required this.wedAmount, required this.thuAmount, required this.friAmount, required this.satAmount,required this.sunAmount});

  List<IndividualBar> barData = [];


  void initializeBarData(){
    barData = [
      IndividualBar(x: 1, y: monAmount),
      IndividualBar(x: 2, y: tueAmount),
      IndividualBar(x: 3, y: wedAmount),
      IndividualBar(x: 4, y: thuAmount),
      IndividualBar(x: 5, y: friAmount),
      IndividualBar(x: 6, y: satAmount),
      IndividualBar(x: 7, y: sunAmount)

    ];
  }

}