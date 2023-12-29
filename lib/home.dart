import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:images_picker/images_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:baseflow_plugin_template/baseflow_plugin_template.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Homepage(),
    );
  }
}

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _page = 0;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  late PageController _pageController;
  String? path;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _page);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _page,
        height: 60.0,
        items: <Widget>[
          Icon(Icons.add, size: 30),
          Icon(Icons.list, size: 30),
          Icon(Icons.compare_arrows, size: 30),
          Icon(Icons.call_split, size: 30),
          Icon(Icons.perm_identity, size: 30),
        ],
        color: Color(0xff71aa34),
        buttonBackgroundColor: Colors.white,
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        onTap: (index) {
          setState(() {
            _page = index;
            _pageController.jumpToPage(index);
          });
        },
        letIndexChange: (index) => true,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _page = index;
          });
        },
        children: [
          Container(
            alignment: Alignment.center,
            child: ElevatedButton(
              child: Text('Pick Image'),
              onPressed: () async {
                if (await requestPermission(Permission.storage)) {
                  List<Media>? res = await ImagesPicker.pick(
                    count: 3,
                    pickType: PickType.all,
                    language: Language.System,
                    maxTime: 30,
                    cropOpt: CropOption(
                      cropType: CropType.circle,
                    ),
                  );
                  print(res);
                  if (res != null) {
                    print(res.map((e) => e.path).toList());
                    setState(() {
                      path = res[0].thumbPath;
                    });
                  }
                }
              },
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: ElevatedButton(
              child: Text('Open Camera'),
              onPressed: () async {
                if (await requestPermission(Permission.camera)) {
                  List<Media>? res = await ImagesPicker.openCamera(
                    pickType: PickType.image,
                    quality: 0.8,
                    maxSize: 800,
                    maxTime: 15,
                  );
                  print(res);
                  if (res != null) {
                    print(res[0].path);
                    setState(() {
                      path = res[0].thumbPath;
                    });
                  }
                }
              },
            ),
          ),
          PermissionHandlerWidget(),
          Container(
            alignment: Alignment.center,
            child: Text('Call Split Page Content'),
          ),
          Container(
            alignment: Alignment.center,
            child: Text('Perm Identity Page Content'),
          ),
        ],
      ),
    );
  }

  Future<bool> requestPermission(Permission permission) async {
    final status = await permission.request();

    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Permission required to proceed.'),
          action: SnackBarAction(
            label: 'Grant',
            onPressed: () {
              openAppSettings();
            },
          ),
        ),
      );
      return false;
    }

    return true;
  }
}

class PermissionHandlerWidget extends StatefulWidget {
  @override
  _PermissionHandlerWidgetState createState() =>
      _PermissionHandlerWidgetState();
}

class _PermissionHandlerWidgetState extends State<PermissionHandlerWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        children: [
          PermissionWidget(Permission.camera),
          PermissionWidget(Permission.contacts),
          PermissionWidget(Permission.calendar),
          PermissionWidget(Permission.location),
          PermissionWidget(Permission.phone),
          PermissionWidget(Permission.photos),
          
        ],
      ),
    );
  }
}

class PermissionWidget extends StatefulWidget {
  const PermissionWidget(this._permission);

  final Permission _permission;

  @override
  _PermissionState createState() => _PermissionState(_permission);
}

class _PermissionState extends State<PermissionWidget> {
  _PermissionState(this._permission);

  final Permission _permission;
  PermissionStatus _permissionStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    _listenForPermissionStatus();
  }

  void _listenForPermissionStatus() async {
    final status = await _permission.status;
    setState(() => _permissionStatus = status);
  }

  Color getPermissionColor() {
    switch (_permissionStatus) {
      case PermissionStatus.denied:
        return Colors.red;
      case PermissionStatus.granted:
        return Colors.green;
      case PermissionStatus.limited:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        _permission.toString(),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      subtitle: Text(
        _permissionStatus.toString(),
        style: TextStyle(color: getPermissionColor()),
      ),
      trailing: (_permission is PermissionWithService)
          ? IconButton(
              icon: const Icon(
                Icons.info,
                color: Colors.white,
              ),
              onPressed: () {
                checkServiceStatus(
                    context, _permission as PermissionWithService);
              })
          : null,
      onTap: () {
        requestPermission(_permission);
      },
    );
  }

  void checkServiceStatus(
      BuildContext context, PermissionWithService permission) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text((await permission.serviceStatus).toString()),
    ));
  }

  Future<void> requestPermission(Permission permission) async {
    final status = await permission.request();

    setState(() {
      print(status);
      _permissionStatus = status;
      print(_permissionStatus);
    });
  }
}
