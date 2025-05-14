import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'main.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final Color primaryColor = const Color(0xFF57AC72);
  final Color secondaryColor = const Color.fromRGBO(87, 172, 114, 1);

  List<Map<String, String>> pendingUsers = [];
  List<Map<String, String>> confirmedUsers = [];

  Map<String, int> roleStats = {"Étudiant": 0, "Enseignant": 0, "Admin": 0};

  @override
  void initState() {
    super.initState();
    fetchUsers();
    fetchStats();
  }

  Future<void> fetchUsers() async {
    try {
      final pendingResponse =
      await http.get(Uri.parse('http://192.168.137.1:5000/utilisateurs_non_confirme'));
      final confirmedResponse =
      await http.get(Uri.parse('http://192.168.137.1:5000/utilisateurs_confirme'));

      if (pendingResponse.statusCode == 200 && confirmedResponse.statusCode == 200) {
        List<dynamic> pendingData = json.decode(pendingResponse.body);
        List<dynamic> confirmedData = json.decode(confirmedResponse.body);

        setState(() {
          pendingUsers = pendingData.map<Map<String, String>>((u) {
            return {
              'email': u[0],
              'prenom': u[1].trim(),
              'nom': u[2].trim(),
              'matricule': u[3],
              'role': u[4],
            };
          }).toList();

          confirmedUsers = confirmedData.map<Map<String, String>>((u) {
            return {
              'email': u[0],
              'prenom': u[1].trim(),
              'nom': u[2].trim(),
              'matricule': u[3],
              'role': u[4],
            };
          }).toList();
        });
      }
    } catch (e) {
      print("Erreur de chargement : $e");
    }
  }

  Future<void> fetchStats() async {
    try {
      final statsResponse = await http.get(Uri.parse('http://192.168.137.1:5000/stats'));

      if (statsResponse.statusCode == 200) {
        final data = json.decode(statsResponse.body);

        setState(() {
          roleStats = {
            "Étudiant": data['etudiants'] ?? 0,
            "Enseignant": data['enseignants'] ?? 0,
            "Admin": data['admins'] ?? 0,
          };
        });
      }
    } catch (e) {
      print("Erreur de chargement des stats : $e");
    }
  }

  void confirmUser(int index) async {
    final String matricule = pendingUsers[index]['matricule']!;

    try {
      final response = await http.put(
        Uri.parse('http://192.168.137.1:5000/confirme/$matricule'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Afficher une boîte de dialogue avec le message du backend
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Confirmation"),
            content: Text(data['message'] ?? 'Utilisateur confirmé.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );

        // Recharger les utilisateurs et les stats
        await fetchUsers();
        await fetchStats();
      } else {
        throw Exception("Erreur du serveur (${response.statusCode})");
      }
    } catch (e) {
      print("Erreur de confirmation : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de la confirmation de l'utilisateur.")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Espace Admin", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyApp()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // Tableau de bord
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    const Text("Tableau de Bord", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(
                      "Utilisateurs confirmés (${confirmedUsers.length})",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: roleStats.entries.map((entry) {
                            return PieChartSectionData(
                              color: entry.key == "Étudiant"
                                  ? Colors.blue
                                  : entry.key == "Enseignant"
                                  ? Colors.orange
                                  : Colors.red,
                              value: entry.value.toDouble(),
                              title: "${entry.key}\n(${entry.value})",
                              radius: 50,
                              titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Liste des inscriptions en attente
            Expanded(
              child: Column(
                children: [
                  Text(
                    "Inscriptions en attente (${pendingUsers.length})",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: pendingUsers.length,
                      itemBuilder: (context, index) {
                        return userCard(pendingUsers[index], () => confirmUser(index), "Confirmer", primaryColor);
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Liste des utilisateurs confirmés
            Expanded(
              child: Column(
                children: [
                  Text(
                    "Utilisateurs confirmés (${confirmedUsers.length})",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: confirmedUsers.length,
                      itemBuilder: (context, index) {
                        return userCard(confirmedUsers[index], null, "", secondaryColor);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget userCard(Map<String, String> user, VoidCallback? onPressed, String buttonText, Color buttonColor) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      elevation: 8,
      shadowColor: Colors.grey.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: buttonColor.withOpacity(0.2),
                  child: Icon(Icons.person, color: buttonColor),
                ),
                const SizedBox(width: 12),
                Text(
                  "${user['prenom']} ${user['nom']}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.credit_card, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text("Matricule : ${user['matricule']}", style: TextStyle(color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.mail, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text("Email : ${user['email']}", style: TextStyle(color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person_outline, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text("Rôle : ${user['role']}", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 15),
            if (onPressed != null)
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 4,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Text(buttonText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
