import 'package:flutter/material.dart';
import 'package:nsothinktank/pages/key_data/catalog.dart';
import 'package:nsothinktank/pages/key_data/pages/chart_page.dart';
import 'package:nsothinktank/pages/main_page.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_menu/flutter_menu.dart';
import 'package:nsothinktank/constants.dart';
import 'package:nsothinktank/theme/app_theme.dart';

class LineChartPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  LineChartPage({Key? key}) : super(key: key);

  @override
  LineChartPageState createState() => LineChartPageState();
}

class LineChartPageState extends State<LineChartPage> {
  final List<_SalesData> chartData = [
    _SalesData("2556", 64785908),
    _SalesData("2557", 65124716),
    _SalesData("2558", 65729096),
    _SalesData("2559", 65931552),
    _SalesData("2560", 66188504),
    _SalesData("2561", 66413980),
    _SalesData("2562", 66558936),
    _SalesData("2563", 66186728),
  ];

  late TooltipBehavior _tooltipBehavior;
  // SelectionBehavior _selectionBehavior;
  @override
  void initState() {
    // _tooltipBehavior = TooltipBehavior(enable: true);
    _tooltipBehavior = TooltipBehavior(enable: true, header: "จำนวนประชากร");
    // _selectionBehavior = SelectionBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final theme = Theme.of(context).platform == TargetPlatform.android
        ? Theme.of(context)
        : AppTheme.lightTheme;
        
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/nso.png',
                width: 40, height: 40, fit: BoxFit.contain),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                "สำนักงานสถิติแห่งชาติ",
                style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Container(
         decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.primaryColor.withOpacity(0.05), Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Custom Navigation Bar / Toolbar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                   _buildNavButton(
                      icon: Icons.list_alt,
                      label: "ความถี่",
                      onTap: () {
                         Navigator.pushReplacementNamed(context, '/catalog');
                      }, 
                  ),
                  _buildNavButton(
                    icon: Icons.show_chart,
                    label: "กราฟ",
                    isActive: true,
                    onTap: () {
                       // Already on chart
                       Navigator.pushReplacementNamed(context, '/barchart');
                    },
                  ),
                  _buildNavButton(
                    icon: Icons.table_chart,
                    label: "ตาราง",
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/datatable');
                    },
                  ),
                  _buildNavButton(
                    icon: Icons.info_outline,
                    label: "คำอธิบาย",
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/metadata');
                    },
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                         child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'จำนวนประชากรที่มีชื่ออยู่ในทะเบียนราษฎร',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (true) // Keeping placeholder for measure if needed
                                Text(
                                  '(ประชากร)',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                     color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              const SizedBox(height: 20),
                              Container(
                                height: height * 0.55,
                        child: SfCartesianChart(
                            plotAreaBorderWidth: 0,
                            legend: Legend(
                                isVisible: true,
                                position: LegendPosition.bottom,
                                overflowMode: LegendItemOverflowMode.wrap),
                            tooltipBehavior: _tooltipBehavior,
                            primaryXAxis: CategoryAxis(
                              labelRotation: -45,
                              labelStyle: const TextStyle(fontSize: 10, color: Colors.grey),
                              majorGridLines: const MajorGridLines(width: 0),
                              axisLine: const AxisLine(width: 0),
                            ),
                            primaryYAxis: NumericAxis(
                               numberFormat: NumberFormat.compact(),
                                interval: 10000000,
                                minimum: 0,
                                maximum: 80000000,
                                axisLine: const AxisLine(width: 0),
                                majorTickLines: const MajorTickLines(size: 0),
                                majorGridLines: MajorGridLines(width: 1, dashArray: [5, 5], color: Colors.grey.withOpacity(0.2)),
                                plotBands: <PlotBand>[
                                PlotBand(
                                  isVisible: true,
                                  color: theme.primaryColor.withOpacity(0.05),
                                  start: 0,
                                  end: 80000000,
                                ),
                              ],
                            ),
                            series: <CartesianSeries>[
                              SplineAreaSeries<_SalesData, String>(
                                name: "ประชากร",
                                enableTooltip: true,
                                dataSource: chartData,
                                xValueMapper: (_SalesData sales, _) =>
                                    sales.year,
                                yValueMapper: (_SalesData sales, _) =>
                                    sales.sales,
                                borderColor: theme.primaryColor,
                                borderWidth: 3,
                                gradient: LinearGradient(
                                  colors: [theme.primaryColor.withOpacity(0.4), theme.primaryColor.withOpacity(0.0)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                markerSettings: MarkerSettings(isVisible: true, height: 4, width: 4, color: Colors.white, borderColor: theme.primaryColor, borderWidth: 2),
                                dataLabelSettings:
                                    const DataLabelSettings(isVisible: true, textStyle: TextStyle(fontSize: 10, color: Colors.grey)),
                              ),
                            ]),
                          ),
                        ]
                      )
                    )
                  )
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        height: kToolbarHeight + 20, 
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               InkWell(
                 onTap: () => Navigator.pushReplacementNamed(context, '/catalog'),
                   child: Row(
                     children: [
                       Icon(Icons.arrow_back_ios, color: theme.primaryColor),
                       Text("ย้อนกลับ", style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                     ],
                   ),
               ),
               
               InkWell(
                 onTap: () {
                     Navigator.push(context,
                        MaterialPageRoute(builder: (_) {
                      return MainPage();
                    }));
                 },
                 child: Row(
                    children: [
                      Icon(Icons.add_circle, color: Colors.blue), // Changed to blue to match theme or keep red if it's a specific action
                      const SizedBox(width: 4),
                      Text("ข้อมูลเพิ่มเติม", style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                    ],
                 )
               )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({required IconData icon, required String label, required VoidCallback onTap, bool isActive = false, Widget? child}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          child ?? Icon(icon, color: isActive ? AppTheme.primaryColor : Colors.grey[600]),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: isActive ? AppTheme.primaryColor : Colors.grey[600], fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

class _SalesData {
  _SalesData(this.year, this.sales);

  final String year;
  final double sales;
}
