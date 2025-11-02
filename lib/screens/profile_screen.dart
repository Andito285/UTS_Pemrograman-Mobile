import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String selectedCity = 'MEDAN';
  String geoStatus = 'Menunggu lokasi...';
  bool isLoading = false;

  final List<String> cities = ['MEDAN', 'JAKARTA', 'BANDUNG', 'SURABAYA'];
  final List<Map<String, dynamic>> theaters = [
    {'name': 'XI CINEMA', 'address': 'Jl. Raya Medan No. 123', 'schedule': '14:00, 17:30, 20:00'},
    {'name': 'PONDOK KELAPA 21', 'address': 'Jl. Pondok Kelapa No. 456', 'schedule': '13:00, 16:30, 19:00'},
    {'name': 'CGV', 'address': 'Jl. Mall Medan No. 789', 'schedule': '15:00, 18:30, 21:00'},
    {'name': 'CINEPOLIS', 'address': 'Jl. Cinepolis Medan', 'schedule': '12:00, 15:30, 19:30'},
    {'name': 'CP MALL', 'address': 'CP Mall Lantai 3', 'schedule': '14:30, 18:00, 21:30'},
    {'name': 'HERMES', 'address': 'Hermes Plaza Medan', 'schedule': '13:30, 17:00, 20:30'},
  ];

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        geoStatus = 'Lokasi dinonaktifkan. Aktifkan di pengaturan.';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          geoStatus = 'Izinkan akses lokasi untuk fitur terbaik.';
        });
        return;
      }
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      isLoading = true;
      geoStatus = 'Mencari lokasi...';
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Simulasi deteksi kota berdasarkan koordinat
      String detectedCity = _detectCity(position.latitude, position.longitude);

      setState(() {
        selectedCity = detectedCity;
        geoStatus = 'Lokasi ditemukan: $detectedCity';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        geoStatus = 'Gagal mendeteksi lokasi: $e';
        isLoading = false;
      });
    }
  }

  String _detectCity(double lat, double lng) {
    // Simulasi sederhana — di produksi, gunakan reverse geocoding API
    if (lat > 3 && lat < 4 && lng > 98 && lng < 99) return 'MEDAN';
    if (lat > -6.5 && lat < -6 && lng > 106.5 && lng < 107) return 'JAKARTA';
    if (lat > -7 && lat < -6.5 && lng > 107.5 && lng < 108) return 'BANDUNG';
    return 'MEDAN';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile (Keranjang)'),
        backgroundColor: const Color(0xFF2C3E50),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedCity,
                    items: cities.map((city) {
                      return DropdownMenuItem(value: city, child: Text(city));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCity = value!;
                        geoStatus = 'Menampilkan bioskop di $selectedCity';
                      });
                    },
                    dropdownColor: Colors.grey[800],
                    style: const TextStyle(color: Colors.white),
                    underline: Container(height: 2, color: Colors.blue),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _getCurrentLocation,
                  icon: const Icon(Icons.location_on, size: 18),
                  label: const Text('GPS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C3E50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              geoStatus,
              style: TextStyle(
                color: isLoading ? Colors.blue : Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: theaters.length,
                itemBuilder: (context, index) {
                  final theater = theaters[index];
                  return _TheaterItem(
                    name: theater['name']!,
                    address: theater['address']!,
                    schedule: theater['schedule']!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TheaterItem extends StatefulWidget {
  final String name, address, schedule;

  const _TheaterItem({
    required this.name,
    required this.address,
    required this.schedule,
  });

  @override
  State<_TheaterItem> createState() => _TheaterItemState();
}

class _TheaterItemState extends State<_TheaterItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          ListTile(
            title: Text(widget.name),
            trailing: Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.grey),
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
          ),
          if (_expanded)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[850],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Alamat: ${widget.address}', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text('Jadwal: ${widget.schedule}', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}