import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class DashboardPage extends StatefulWidget {
  final String userId;
  final VoidCallback onLogout;

  const DashboardPage({
    super.key,
    required this.userId,
    required this.onLogout,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.onLogout,
          ),
        ],
      ),
      body: FutureBuilder<User?>(
        future: _authService.getUserDetails(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;

          if (user == null) {
            return const Center(
              child: Text(
                "User profile not loaded",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          // ✅ THIS IS THE “SIMILAR” DASHBOARD UI
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : "?",
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Account info card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Account Information",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text("Email: ${user.email}"),
                        const SizedBox(height: 6),
                        Text("User ID: ${user.uid}"),
                        const SizedBox(height: 6),
                        Text("Member since: ${_formatDate(user.createdAt)}"),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Quick access
                const Text(
                  "Quick Access",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    _quickCard("Tasks", Icons.task_alt, Colors.blue),
                    const SizedBox(width: 12),
                    _quickCard("Profile", Icons.person, Colors.green),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _quickCard(String title, IconData icon, Color color) {
    return Expanded(
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}
