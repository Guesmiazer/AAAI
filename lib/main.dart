import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Societé El Baraka',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          accentColor: Colors.tealAccent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<DataPoint>> _futureData;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _futureData = ApiService.fetchData();
      _isRefreshing = false;
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Societé El Baraka',
            style: GoogleFonts.poppins(
                fontSize: 22, fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade800, Colors.teal.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<DataPoint>>(
            future: _futureData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && !_isRefreshing) {
                return _buildLoadingUI();
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Erreur : ${snapshot.error}',
                      style: GoogleFonts.poppins(
                          color: Colors.redAccent, fontSize: 16)),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text('Aucune donnée disponible',
                      style: GoogleFonts.poppins(
                          fontSize: 16, color: Colors.grey)),
                );
              }

              final data = snapshot.data!;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    _buildDataCards(data),
                    const SizedBox(height: 30),
                    _buildCharts(data),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshData,
        child: const Icon(Icons.refresh),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  Widget _buildLoadingUI() {
    return ListView(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade800,
          highlightColor: Colors.grey.shade700,
          child: Container(
            height: 120,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade800,
          highlightColor: Colors.grey.shade700,
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataCards(List<DataPoint> data) {
    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCard('🌡️ Température', '${data.last.temperature}°C', 
              Colors.blueAccent, Icons.thermostat),
          _buildCard('💧 Humidité', '${data.last.humidity}%', 
              Colors.tealAccent, Icons.water_drop),
          _buildCard('🌡️ Température Sonde 1', '${data.last.temperatureDS18B20_1}°C', 
              Colors.pinkAccent, Icons.sensors),
          _buildCard('🌡️ Température Sonde 2', '${data.last.temperatureDS18B20_2}°C', 
              Colors.orangeAccent, Icons.sensors),
          _buildCard('🌡️ Température Sonde 3', '${data.last.temperatureDS18B20_3}°C', 
              Colors.purpleAccent, Icons.sensors),
        ],
      ),
    );
  }

  Widget _buildCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      width: 260, // Largeur ajustée pour afficher le texte complet
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 1,
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                            fontSize: 14, // Taille de police réduite
                            fontWeight: FontWeight.w600,
                            color: color),
                        overflow: TextOverflow.visible, // Pas de troncature
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(
      String title,
      List<DataPoint> data,
      ChartValueMapper<DataPoint, num> valueMapper,
      List<Color> colors) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.grey.shade900, Colors.grey.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colors.first),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 250,
                child: SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  margin: const EdgeInsets.all(0),
                  palette: colors,
                  primaryXAxis: CategoryAxis(
                    labelStyle: GoogleFonts.poppins(color: Colors.grey),
                    axisLine: const AxisLine(width: 0),
                    majorGridLines: const MajorGridLines(width: 0),
                  ),
                  primaryYAxis: NumericAxis(
                    labelStyle: GoogleFonts.poppins(color: Colors.grey),
                    axisLine: const AxisLine(width: 0),
                    majorTickLines: const MajorTickLines(size: 0),
                    majorGridLines: MajorGridLines(
                        color: Colors.grey.shade700.withOpacity(0.5)),
                  ),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <CartesianSeries>[
                    SplineSeries<DataPoint, String>(
                      dataSource: data,
                      xValueMapper: (DataPoint dp, _) => dp.timestamp,
                      yValueMapper: valueMapper,
                      markerSettings: MarkerSettings(
                        isVisible: true,
                        shape: DataMarkerType.circle,
                        borderWidth: 2,
                        borderColor: colors.first,
                        color: Colors.white,
                      ),
                      color: colors.first.withOpacity(0.8),
                      width: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCharts(List<DataPoint> data) {
    return Column(
      children: [
        _buildChart(
          'Température DHT22',
          data,
          (dp, _) => dp.temperature,
          [Colors.blueAccent],
        ),
        const SizedBox(height: 25),
        _buildChart(
          'Humidité',
          data,
          (dp, _) => dp.humidity,
          [Colors.tealAccent],
        ),
        const SizedBox(height: 25),
        _buildMultiSensorChart(
          'Températures des Sondes',
          data,
          [
            ChartSeries('Température Sonde 1', (dp, _) => dp.temperatureDS18B20_1, Colors.red),
            ChartSeries('Température Sonde 2', (dp, _) => dp.temperatureDS18B20_2, Colors.orange),
            ChartSeries('Température Sonde 3', (dp, _) => dp.temperatureDS18B20_3, Colors.purple),
          ],
        ),
      ],
    );
  }

  Widget _buildMultiSensorChart(
    String title,
    List<DataPoint> data,
    List<ChartSeries> seriesList,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.grey.shade900, Colors.grey.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 250,
                child: SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  margin: const EdgeInsets.all(0),
                  legend: Legend(
                    isVisible: true,
                    position: LegendPosition.top,
                    textStyle: GoogleFonts.poppins(color: Colors.grey),
                  ),
                  primaryXAxis: CategoryAxis(
                    labelStyle: GoogleFonts.poppins(color: Colors.grey),
                    axisLine: const AxisLine(width: 0),
                    majorGridLines: const MajorGridLines(width: 0),
                  ),
                  primaryYAxis: NumericAxis(
                    labelStyle: GoogleFonts.poppins(color: Colors.grey),
                    axisLine: const AxisLine(width: 0),
                    majorTickLines: const MajorTickLines(size: 0),
                    majorGridLines: MajorGridLines(
                        color: Colors.grey.shade700.withOpacity(0.5)),
                  ),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: seriesList.map((series) => SplineSeries<DataPoint, String>(
                    dataSource: data,
                    name: series.name,
                    xValueMapper: (dp, _) => dp.timestamp,
                    yValueMapper: series.valueMapper,
                    color: series.color,
                    markerSettings: MarkerSettings(
                      isVisible: true,
                      shape: DataMarkerType.circle,
                      borderWidth: 2,
                      borderColor: series.color,
                      color: Colors.white,
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartSeries {
  final String name;
  final ChartValueMapper<DataPoint, num> valueMapper;
  final Color color;

  ChartSeries(this.name, this.valueMapper, this.color);
}