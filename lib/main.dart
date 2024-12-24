import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase',
      debugShowCheckedModeBanner: false, // Tắt Debug Banner
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TemperatureScreen(),
    );
  }
}

class TemperatureScreen extends StatefulWidget {
  @override
  _TemperatureScreenState createState() => _TemperatureScreenState();
}

class _TemperatureScreenState extends State<TemperatureScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  List<String> macAddresses = [];
  List<String> dates = [];
  String? selectedMac;
  String? selectedDate;

  List<ChartData> chartData = [];
  double? currentTemperature;
  double? currentHumidity;
  bool isDeviceActive = false; // Trạng thái thiết bị (ON/OFF)
  DateTime? lastDataReceivedTime;

  @override
  void initState() {
    super.initState();
    _getMacAddresses();
  }

  void _getMacAddresses() async {
    _database.child("sensor").once().then((event) {
      final snapshot = event.snapshot;
      if (snapshot.exists) {
        setState(() {
          macAddresses =
              snapshot.children.map((e) => e.key.toString()).toList();
        });
      }
    });
  }

  void _getDatesForMac(String mac) async {
    setState(() {
      selectedDate = null;
      dates.clear();
      chartData.clear();
      currentTemperature = null;
      currentHumidity = null;
      isDeviceActive = false; // Mặc định là OFF khi chọn MAC mới
    });

    _database.child("sensor/$mac").once().then((event) {
      final snapshot = event.snapshot;
      if (snapshot.exists) {
        setState(() {
          // Lọc danh sách ngày trước khi gán
          dates = snapshot.children.map((e) => e.key.toString()).where((date) {
            // Điều kiện lọc, thay bằng logic cụ thể của bạn
            // Ví dụ: chỉ hiển thị ngày sau ngày 2024-01-01
            DateTime parsedDate = DateTime.parse(date);
            return parsedDate.isAfter(DateTime(2024, 1, 1));
          }).toList();
        });
      }
    });
  }

  StreamSubscription? _dataSubscription; // Biến lưu subscription

  void _getDataForDate(String mac, String date) async {
    // Hủy sự kiện lắng nghe trước đó nếu tồn tại
    _dataSubscription?.cancel();

    setState(() {
      chartData.clear(); // Xóa dữ liệu biểu đồ cũ
      currentTemperature = null;
      currentHumidity = null;
      isDeviceActive = false;
    });

    // Thiết lập sự kiện lắng nghe mới
    _dataSubscription =
        _database.child("sensor/$mac/$date").onValue.listen((event) async {
      final snapshot = event.snapshot;
      if (snapshot.exists) {
        List<ChartData> dataList = [];
        for (var e in snapshot.children) {
          final data = e.value as Map;
          String time = e.key.toString();
          double temperature = double.parse(data['temperature'].toString());
          double humidity = double.parse(data['humidity'].toString());

          // Kiểm tra dữ liệu hợp lệ
          if (temperature != null && humidity != null) {
            currentTemperature = temperature;
            currentHumidity = humidity;
            lastDataReceivedTime = DateTime.now();
            isDeviceActive = true;
            dataList.add(ChartData(time, temperature, humidity));
          } else {
            // Xóa dữ liệu không hợp lệ
            await _database.child("sensor/$mac/$date/$time").remove();
          }
        }

        setState(() {
          chartData = dataList;
        });
      }
    });

    // Kiểm tra trạng thái thiết bị mỗi 30 giây
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (lastDataReceivedTime != null &&
          DateTime.now().difference(lastDataReceivedTime!).inSeconds > 30) {
        setState(() {
          isDeviceActive = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dữ liệu Nhiệt độ và Độ ẩm"),
      ),
      body: Column(
        children: [
          // ComboBox cho MAC và ngày nằm trên cùng một hàng
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Chọn MAC Address",
                          style: TextStyle(fontSize: 16)),
                      DropdownButton<String>(
                        hint: const Text("Chọn MAC Address"),
                        value: selectedMac,
                        onChanged: (value) {
                          setState(() {
                            selectedMac = value;
                            selectedDate = null;
                            dates.clear();
                            chartData.clear();
                            currentTemperature = null;
                            currentHumidity = null;
                            isDeviceActive =
                                false; // Mặc định là OFF khi chọn MAC mới
                          });
                          _getDatesForMac(value!);
                        },
                        items: macAddresses.map((mac) {
                          return DropdownMenuItem(
                            value: mac,
                            child: Text(mac),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10), // Khoảng cách giữa MAC và ngày
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Chọn Ngày", style: TextStyle(fontSize: 16)),
                      DropdownButton<String>(
                        hint: const Text("Chọn Ngày"),
                        value: selectedDate,
                        onChanged: (value) {
                          setState(() {
                            selectedDate = value;
                            chartData.clear();
                            isDeviceActive =
                                false; // Mặc định là OFF khi chọn ngày mới
                          });
                          _getDataForDate(selectedMac!, value!);
                        },
                        items: dates.map((date) {
                          return DropdownMenuItem(
                            value: date,
                            child: Text(date),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Hiển thị trạng thái ON/OFF với dấu chấm
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text(
                  "Trạng thái thiết bị: ",
                  style: TextStyle(fontSize: 16),
                ),
                Icon(
                  isDeviceActive ? Icons.circle : Icons.circle_outlined,
                  color: isDeviceActive ? Colors.green : Colors.grey,
                  size: 16,
                ),
                Text(
                  isDeviceActive ? " ON" : " OFF",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),

          // Hiển thị nhiệt độ và độ ẩm theo thời gian thực
          if (currentTemperature != null && currentHumidity != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    "Nhiệt độ hiện tại: ${currentTemperature?.toStringAsFixed(1)}°C",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Độ ẩm hiện tại: ${currentHumidity?.toStringAsFixed(1)}%",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

          // Biểu đồ dữ liệu
          if (chartData.isNotEmpty)
            Expanded(
                child: SfCartesianChart(
              title: const ChartTitle(text: 'Biểu đồ nhiệt độ và độ ẩm'),
              primaryXAxis: const CategoryAxis(),
              legend: const Legend(isVisible: true),
              series: <CartesianSeries<ChartData, String>>[
                LineSeries<ChartData, String>(
                  name: 'Nhiệt độ',
                  dataSource: chartData,
                  xValueMapper: (ChartData data, _) => data.time,
                  yValueMapper: (ChartData data, _) => data.temperature,
                  markerSettings:
                      const MarkerSettings(isVisible: false), // Tắt marker
                ),
                LineSeries<ChartData, String>(
                  name: 'Độ ẩm',
                  dataSource: chartData,
                  xValueMapper: (ChartData data, _) => data.time,
                  yValueMapper: (ChartData data, _) => data.humidity,
                  markerSettings:
                      const MarkerSettings(isVisible: false), // Tắt marker
                ),
              ],
            )),
        ],
      ),
    );
  }
}

class ChartData {
  final String time;
  final double temperature;
  final double humidity;

  ChartData(this.time, this.temperature, this.humidity);
}
