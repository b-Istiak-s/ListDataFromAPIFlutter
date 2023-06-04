import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  List<dynamic> users = [];
  bool isLoading = true;
  bool isTapped = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : buildUserList(),
    );
  }

  Widget buildUserList() {
    if (users.isEmpty) {
      return const Center(
        child: Text("No users found."),
      );
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user['picture']['thumbnail']),
          ),
          title: Text(
              '${user['name']['title']} ${user['name']['first']} ${user['name']['last']}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user['email']),
              Text('Phone: ${user['phone']}'),
            ],
          ),
          tileColor: isTapped ? Colors.grey.shade200 : null,
          onTap: () async {
            call(user['phone']);
          },
        );
      },
    );
  }

  Future<void> call(phoneNumber) async {
    String callPhone = 'tel:$phoneNumber';
    final callUri = Uri.parse(callPhone);
    PermissionStatus status = await Permission.phone.request();
    if (status.isGranted) {
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      } else {
        // throw 'Could not launch phone call.';
        Fluttertoast.showToast(
            msg: 'Could not launch phone call.',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);
      }
    } else {
      // throw 'Permission denied for making phone calls.';
      Fluttertoast.showToast(
          msg: 'Permission denied for making phone calls.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
    }
  }

  Future<void> fetchData() async {
    const url = "https://randomuser.me/api/?results=50&gender=female";
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    final body = response.body;
    final json = jsonDecode(body);
    setState(() {
      users = json['results'];
      isLoading = false;
    });
    // You can process the response body here
  }
}
