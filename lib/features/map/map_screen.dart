import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

// iOS:
// Please add the following keys to your Info.plist file.
// <key>NSLocationWhenInUseUsageDescription</key>
// <string>This app needs access to location to show nearby users.</string>
// <key>NSLocationAlwaysUsageDescription</key>
// <string>This app needs access to location to show nearby users.</string>

// Android:
// Please add the following permissions to your AndroidManifest.xml file.
// <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
// <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

double _parseCoordinate(dynamic value) {
  if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  if (value is num) {
    return value.toDouble();
  }
  return 0.0;
}

Map<String, dynamic> _convertMap(Map<dynamic, dynamic> originalMap) {
  final Map<String, dynamic> newMap = {};
  originalMap.forEach((key, value) {
    if (value is Map) {
      newMap[key.toString()] = _convertMap(value);
    } else {
      newMap[key.toString()] = value;
    }
  });
  return newMap;
}

class UserModel {
  final String id;
  final String name;
  final String learnerBirth;
  final String learnerHabit;
  final String learnerRole;
  final String learnerType;
  final String address;
  final LatLng location;

  UserModel({
    required this.id, 
    required this.name, 
    required this.learnerBirth, 
    required this.learnerHabit,
    required this.learnerRole,
    required this.learnerType,
    required this.address,
    required this.location
  });

  factory UserModel.fromFirebase(String id, Map<String, dynamic> data) {
    print('data: $data');
    // Parse latlngColumn string format: "24.819444,120.960278"
    final latlngString = data['latlngColumn'] as String;
    final coordinates = latlngString.split(',');
    return UserModel(
      id: id,
      name: data['name'] ?? 'Unknown User',
      learnerBirth: data['learner_birth'] ?? '1980',
      learnerHabit: data['learner_habit'] ?? '未知',
      learnerRole: data['learner_role'] ?? '未知',
      learnerType: data['learner_type'] ?? '未知',
      address: data['address'] ?? '未知地區',
      location: LatLng(
        _parseCoordinate(coordinates[0].trim()),
        _parseCoordinate(coordinates[1].trim()),
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  final String? latlng;
  const MapScreen({super.key, this.latlng});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  Future<List<UserModel>>? _usersFuture;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsers();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the 
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 

    try {

      if (widget.latlng != null) {
        final latlng = widget.latlng!.split(',');
        print('latlng: $latlng');

        // 設定當前位置
        setState(() {
          _currentPosition = Position(
            latitude: _parseCoordinate(latlng[0]),
            longitude: _parseCoordinate(latlng[1]),
            timestamp: DateTime.now(),
            accuracy: 10,
            altitude: 0,  
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
          );  
          _mapController.move(
            LatLng(_parseCoordinate(latlng[0]), _parseCoordinate(latlng[1])),
            13.0,
          );

        });
      } else {
        final position = await Geolocator.getCurrentPosition();
        setState(() {
          _currentPosition = position;
          _mapController.move(
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            13.0,
          );
        });
      }
    } catch (e) {
      print("Failed to get current position: $e");
    }
  }

  Future<List<UserModel>> _fetchUsers() async {
    final ref = FirebaseDatabase.instance.ref('users');
    final snapshot = await ref.get();

    if (snapshot.exists && snapshot.value != null) {
      final data = _convertMap(snapshot.value as Map);
      final List<UserModel> users = [];
      data.forEach((key, value) {
        if (value is Map) {
          final userData = value as Map<String, dynamic>;
          if (userData['latlngColumn'] != null &&
              userData['latlngColumn'] is String &&
              userData['latlngColumn'].toString().contains(',')) {
            
            // 過濾掉互助旗已降下的用戶
            final flagDown = userData['flag_down'] as bool? ?? false;
            if (!flagDown) {
              users.add(UserModel.fromFirebase(key, userData));
            }
          }
        }
      });
      return users;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('地圖'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _determinePosition,
            tooltip: '回到我的位置',
          )
        ],
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('發生錯誤: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('在地圖上找不到用戶'));
          }

          final users = snapshot.data!;
          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition != null
                  ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                  : const LatLng(23.97, 120.97), // Taiwan's center
              initialZoom: _currentPosition != null ? 13.0 : 8.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'tw.org.alearn.auto30',
              ),
              MarkerLayer(
                markers: [
                  ...users.map((user) => Marker(
                        width: 80.0,
                        height: 80.0,
                        point: user.location,
                        child: GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (builder) {
                                return _buildUserInfoSheet(user);
                              },
                            );
                          },
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.person, color: Colors.white),
                              ),
                              Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, backgroundColor: Colors.white)),
                            ],
                          ),
                        ),
                      )),
                  if (_currentPosition != null)
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      child: const Column(
                        children: [
                          Icon(Icons.my_location, color: Colors.blue, size: 30),
                          Text('我的位置', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserInfoSheet(UserModel user) {

    final learnerBirth = user.learnerBirth;
    final currentYear = DateTime.now().year;
    final age = currentYear - int.parse(learnerBirth);
  
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          // You can fetch more user details here if needed
          // Text('ID: ${user.id}'),
          // Text('座標: ${user.location.latitude.toStringAsFixed(4)}, ${user.location.longitude.toStringAsFixed(4)}'),

          // 用learner_birth(西元年) 來計算年齡
          Text('年齡:約 $age 歲'),
          Text('身份: ${user.learnerRole}'),
          Text('地區: ${user.address}'),
          Text('興趣: ${user.learnerHabit}'),

          const SizedBox(height: 16),
          ElevatedButton(
            child: const Text('查看完整資料'),
            onPressed: () {
              Navigator.pop(context);
              context.push('/user/${user.id}');
            },
          )
        ],
      ),
    );
  }
}
