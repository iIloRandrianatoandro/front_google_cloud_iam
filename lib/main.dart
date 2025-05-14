import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'student_screen.dart';
import 'admin_screen.dart';
import 'student_card_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Projet IAM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Google Cloud IAM",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF1F8E9), // Same background color as QRScannerScreen
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App logo or image
            Image.asset(
              'assets/eni.jpg', // Image path
              width: 500,        // Set width for rectangle
              height: 150,       // Set height for rectangle (different from width)
              fit: BoxFit.cover, // Ensures the image covers the area
            ),

            SizedBox(height: 20),

            // Welcome text
            Text(
              'Bienvenue dans notre application!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),

            // App description
            Text(
              'Cette application utilise Google Cloud IAM pour gérer les rôles. Scannez un QR code pour vous connecter et accéder à votre page.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),

            // "Se connecter" button with an icon
            Container(
              width: double.infinity, // Make the button as wide as the text above
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QRScannerScreen()),
                  );
                },
                icon: Icon(Icons.login), // Login icon
                label: Text('Se connecter'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 30), // Increased vertical padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  backgroundColor: Colors.grey[300], // Neutral background color
                ),
              ),
            ),
            SizedBox(height: 20),

            // "S'inscrire" button with an icon
            Container(
              width: double.infinity, // Make the button as wide as the text above
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupScreen()),
                  );
                },
                icon: Icon(Icons.person_add), // Signup icon
                label: Text('S\'inscrire'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 30), // Increased vertical padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  backgroundColor: Colors.grey[300], // Neutral background color
                ),
              ),
            ),
            SizedBox(height: 20),

            // "Voir Page Étudiant" button
           /* Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StudentPage(
                        nom: "Rahariambelo",
                        prenom: "Ilo Mampionona",
                        matricule: "ETU20251234",
                        type: "Étudiant",
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  backgroundColor: Colors.grey[300],
                ),
                child: const Text("Voir Page Étudiant"),
              ),
            ),*/

            SizedBox(height: 20),

            // "Voir Page Admin" button
            Container(
              width: double.infinity, // Make the button as wide as the text above
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 30), // Increased vertical padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  backgroundColor: Colors.grey[300], // Neutral background color
                ),
                child: const Text("Voir Page Admin"),
              ),
            ),
            // "Voir Page carte etudiant" button
           /* Container(
              width: double.infinity, // Make the button as wide as the text above
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  PhotoPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 30), // Increased vertical padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  backgroundColor: Colors.grey[300], // Neutral background color
                ),
                child: const Text("Voir Page carte etudiant"),
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}
