import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? pickedImage;
  String? email;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadEmail();
  }

  Future<void> loadEmail() async {
    final String? userMail = await AuthService().getEmail();
    setState(() {
      email = userMail;
      isLoading = false;
    });
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? result = await picker.pickImage(source: ImageSource.gallery);

    if (result != null) {
      setState(() {
        pickedImage = File(result.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        backgroundColor: Colors.red.shade400,
        elevation: 0,
        centerTitle: true,
        title: const Text("Profile", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // ------------------- PROFILE HEADER -------------------
              Text("Your Profile",
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),
              // ------------------- AVATAR -------------------
              Stack(alignment: Alignment.center,
                children: [
                  CircleAvatar(radius: 90,
                    backgroundColor: Colors.red.shade200,
                    backgroundImage: pickedImage != null
                        ? FileImage(pickedImage!)
                        : const NetworkImage("https://avatar.iran.liara.run/public")
                    as ImageProvider,
                  ),

                  Positioned(bottom: 0, right: 0,
                    child: GestureDetector(onTap: pickImage,
                      child: Container(padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red.shade400,
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
              // ------------------- EMAIL CARD -------------------
              isLoading ? const CircularProgressIndicator() : emailCard(email ?? "Unknown user"),

              const SizedBox(height: 30),

              // ------------------- EXTRA ACTIONS (OPTIONAL) -------------------
              Card(elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(dense: true,
                  leading: Icon(Icons.logout, color: Colors.red.shade400),
                  title: const Text("Log Out"),
                  onTap: () => AuthService().logout(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------- EMAIL CARD WIDGET -------------------
  Widget emailCard(String email) {
    return Card(elevation: 6,
      shadowColor: Colors.red.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 18.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.email, size: 30, color: Colors.red.shade400),
            const SizedBox(width: 12),
            Flexible(
              child: Text(email,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
