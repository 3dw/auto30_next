import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

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
  final LatLng location;

  UserModel({required this.id, required this.name, required this.location});

  factory UserModel.fromFirebase(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      name: data['name'] ?? 'Unknown User',
      location: LatLng(
        _parseCoordinate(data['latlngColumn']['lat']),
        _parseCoordinate(data['latlngColumn']['lng']),
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

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
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _mapController.move(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          13.0,
        );
      });
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
              userData['latlngColumn'] is Map &&
              userData['latlngColumn']['lat'] != null &&
              userData['latlngColumn']['lng'] != null) {
            users.add(UserModel.fromFirebase(key, userData));
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
          Text('ID: ${user.id}'),
          Text('座標: ${user.location.latitude.toStringAsFixed(4)}, ${user.location.longitude.toStringAsFixed(4)}'),
          const SizedBox(height: 16),
          ElevatedButton(
            child: const Text('查看完整資料'),
            onPressed: () {
              // TODO: Navigate to this user's profile screen
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('查看用戶資料功能開發中')),
              );
            },
          )
        ],
      ),
    );
  }
}
