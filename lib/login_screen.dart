import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'main.dart';
import 'student_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'teacher_screen.dart';
import 'admin_screen.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isScanning = true;
  bool _hasProcessed = false;

  void _sendQRCodeData(String qrCode) async {
    final String apiUrl = 'http://192.168.137.1:5000/bienvenu/$qrCode';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String type = data['type'];

        if (type == 'Étudiant') {
          final String nom = data['nom'];
          final String prenom = data['prenom'];
          final String matricule = data['Matricule'];

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => StudentPage(
                nom: nom,
                prenom: prenom,
                matricule: matricule,
                type: type,
              ),
            ),
          );
        }
        else if (type == 'Enseignant') {
          final String nom = data['nom'];
          final String prenom = data['prenom'];
          final String matricule = data['Matricule'];

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TeacherPage(
                nom: nom,
                prenom: prenom,
                matricule: matricule,
                type: type,
              ),
            ),
          );
        }
        else if (type == 'Administratif') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdminPage(),
            ),
          );
        }
        else {
          _showDialog('Accès refusé', 'Type non reconnu : $type');
        }
      } else {
        _showDialog('Erreur', 'Échec de la connexion au serveur');
      }
    } catch (e) {
      _showDialog('Erreur', 'Une erreur est survenue : $e');
    } finally {
      setState(() {
        _isScanning = true;
        _hasProcessed = false;
      });
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Scanner le QR Code",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF1F8E9),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              'Scannez votre QR Code pour vous connecter.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: MobileScanner(
                    onDetect: (capture) {
                      if (_isScanning && !_hasProcessed) {
                        final List<Barcode> barcodes = capture.barcodes;
                        if (barcodes.isNotEmpty &&
                            barcodes.first.rawValue != null) {
                          final String code = barcodes.first.rawValue!;
                          setState(() {
                            _isScanning = false;
                            _hasProcessed = true;
                          });
                          _sendQRCodeData(code);
                        }
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
