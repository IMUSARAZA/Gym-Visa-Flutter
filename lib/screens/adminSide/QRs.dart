import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:gymvisa/models/GymModel.dart';
import 'package:gymvisa/services/Database_Service.dart';

class QRsController extends GetxController {
  var selectedMonth = 'January'.obs; 
  var gyms = <Map<String, dynamic>>[].obs;
  var gymQrCounts = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchGyms();
  }

  Future<void> fetchGyms() async {
    List<Gym> gymList = await Database_Service.getAllGyms();
    gyms.value = gymList.map((gym) => {
      'gymName': gym.name,
      'gymAddress': gym.address,
    }).toList();

    // Initialize the gymQrCounts map with gym addresses and zero counts
    gymQrCounts.value = {
      for (var gym in gyms) gym['gymAddress']: 0,
    };

    fetchQrCounts(); // Fetch QR counts after initializing gyms
  }

  Future<void> fetchQrCounts() async {
    // Get QR counts for the selected month
    Map<String, int> counts = await Database_Service.getQrCountsForMonth(selectedMonth.value);

    // Update the gymQrCounts with fetched counts and ensure all gyms are included
    for (var gym in gymQrCounts.keys) {
      gymQrCounts[gym] = counts[gym] ?? 0;
    }
  }

  void onMonthSelected(String month) {
    selectedMonth.value = month;
    fetchQrCounts(); // Refresh QR counts when month changes
  }
}

class QRs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final QRsController controller = Get.put(QRsController());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('QRs Scanned'),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Obx(() {
            return DropdownButton<String>(
              value: controller.selectedMonth.value,
              items: [
                'January',
                'February',
                'March',
                'April',
                'May',
                'June',
                'July',
                'August',
                'September',
                'October',
                'November',
                'December',
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  controller.onMonthSelected(newValue);
                }
              },
            );
          }),
          SizedBox(height: 20),
          Expanded(
            child: Obx(() {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Index', style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text('Gym Name', style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text('Gym Address', style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text('Number of QRs Scanned', style: TextStyle(color: Colors.white))),
                    ],
                    rows: controller.gyms.asMap().entries.map((entry) {
                      int index = entry.key + 1;
                      Map<String, dynamic> gym = entry.value;
                      String gymName = gym['gymName'] ?? 'Unknown Gym';
                      String gymAddress = gym['gymAddress'] ?? 'Unknown Address';
                      int qrCount = controller.gymQrCounts[gymAddress] ?? 0;
                      return DataRow(cells: [
                        DataCell(Text(index.toString(), style: TextStyle(color: Colors.white))),
                        DataCell(Text(gymName, style: TextStyle(color: Colors.white))),
                        DataCell(Text(gymAddress, style: TextStyle(color: Colors.white))),
                        DataCell(Text(qrCount.toString(), style: TextStyle(color: Colors.white))),
                      ]);
                    }).toList(),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

