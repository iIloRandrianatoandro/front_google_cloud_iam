import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart'; // For picking images
import 'dart:io'; // To handle file paths
import 'login_screen.dart';
import 'student_card_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _matriculeController = TextEditingController();
  String? _selectedRole;
  File? _imageFile; // For storing the selected image

  final List<String> _roles = ['Étudiant', 'Enseignant', 'Administratif'];
  final Color primaryColor = const Color(0xFF57AC72);

  final ImagePicker _picker = ImagePicker();

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // Set the picked image
      });
    }
  }

  void _signup() async {
    final String firstName = _firstNameController.text;
    final String lastName = _lastNameController.text;
    final String email = _emailController.text;
    final String matricule = _matriculeController.text;

    if (_selectedRole == null) {
      _showErrorDialog('Veuillez sélectionner un rôle.');
      return;
    }

    if (_imageFile == null) {
      _showErrorDialog('Veuillez sélectionner une photo.');
      return;
    }

    const String url = 'http://192.168.137.1:5000/';

    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));

      request.fields['prenom'] = firstName;
      request.fields['nom'] = lastName;
      request.fields['email'] = email;
      request.fields['type'] = _selectedRole!;
      request.fields['matricule'] = matricule;

      request.files.add(
        await http.MultipartFile.fromPath('photo', _imageFile!.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Inscription réussie'),
            content: Text(
                'Votre demande d\'inscription a été effectuée avec succès.\n'
                    'Veuillez attendre la validation de l\'administrateur.\n'
                    'Vous recevrez un e-mail contenant votre carte d\'étudiant pour vous connecter.'
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(); // Ferme la boîte de dialogue
                  Navigator.pushReplacementNamed(context, '/'); // Redirige vers main.dart (route racine)
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
      else {
        _showErrorDialog('Erreur lors de l\'inscription');
        _showErrorDialog('Erreur : ${response.body}');
      }
    } catch (e) {
      _showErrorDialog('Erreur : $e');
    }
  }


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "S'inscrire",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // First Name input
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'Prénom',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Veuillez entrer votre prénom' : null,
                    ),
                    const SizedBox(height: 15),
                    // Last Name input
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Veuillez entrer votre nom' : null,
                    ),
                    const SizedBox(height: 15),
                    // Role selection
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Rôle',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.work),
                      ),
                      value: _selectedRole,
                      items: _roles.map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      )).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value;
                        });
                      },
                      validator: (value) =>
                      value == null ? 'Veuillez sélectionner un rôle' : null,
                    ),
                    const SizedBox(height: 15),
                    // Email input
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Veuillez entrer un email' : null,
                    ),
                    const SizedBox(height: 15),
                    // Matricule input
                    TextFormField(
                      controller: _matriculeController,
                      decoration: const InputDecoration(
                        labelText: 'Matricule',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.confirmation_number),
                      ),
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Quel est votre matricule ?' : null,
                    ),
                    const SizedBox(height: 15),
                    // Photo upload button
                    // Image picker + image preview
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_imageFile != null) ...[
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                _imageFile!,
                                height: 150,
                                width: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.camera_alt, color: Colors.white),
                            label: const Text(
                              "Choisir une photo",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              textStyle: const TextStyle(fontSize: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _signup();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          textStyle: const TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.app_registration, color: Colors.white),
                        label: const Text(
                          "S'inscrire",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
