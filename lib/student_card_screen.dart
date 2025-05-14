import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';

class PhotoPage extends StatelessWidget {
  final String imageUrl;

  PhotoPage({required this.imageUrl});
  final Color primaryColor = const Color(0xFF57AC72);
  final Color backgroundColor = const Color(0xFFF1F8E9);

  Future<void> downloadImage(BuildContext context) async {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permission refusée")),
      );
      return;
    }

    try {
      var response = await http.get(Uri.parse(imageUrl));
      var bytes = response.bodyBytes;

      final directory = Directory('/storage/emulated/0/Pictures');
      if (!(await directory.exists())) {
        await directory.create(recursive: true);
      }

      final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = path.join(directory.path, fileName);
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      final channel = MethodChannel('gallery_scanner');
      await channel.invokeMethod('scanFile', {'path': filePath});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image enregistrée et visible dans la galerie")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false,
        title:  Center( // Center the title text
          child: const Text(
            'Carte Étudiant',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white, // Ensure the text is visible (change if needed)
            ),
          ),
        ),
      ),
      body: Center( // Center the whole column
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center the elements in the column
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Voici votre carte étudiant.\n Vous pouvez la télécharger et vous connecter",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 6,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                            color: primaryColor,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => downloadImage(context),
                icon: const Icon(Icons.download),
                label: const Text("Télécharger la carte"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  elevation: 5,
                ),
              ),
              const SizedBox(height: 15),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QRScannerScreen()),
                  );
                },
                icon: Icon(Icons.login, color: primaryColor),
                label: Text(
                  "Se connecter",
                  style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: primaryColor, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
