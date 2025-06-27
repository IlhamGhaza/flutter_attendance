import 'package:flutter/material.dart';
import 'package:flutter_attendance/presentation/home/pages/location_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_attendance/presentation/auth/bloc/logout/logout_bloc.dart';
import 'package:flutter_attendance/presentation/auth/pages/login_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 20),
          // _buildSectionHeader('Account'),
          // _buildListTile('Edit Profile', () {
          //   //navigate to other
          //   Navigator.of(context).push(
          //     MaterialPageRoute(builder: (context) => const ProfilePage()),
          //   );
          // }),
          // _buildListTile('Password', () {}),

          _buildSectionHeader('Preferences'),
          _buildListTile('Language', () {}),
          _buildListTile('Theme', () {}),
          _buildListTile('Notifications', () {}),
          _buildListTile('Location', () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const LocationPage()),
            );
          }),
          const SizedBox(height: 30),
          _buildSectionHeader('Support'),
          _buildListTile('Terms of Service & Privacy', () {}),
          _buildListTile('Clear Cache', () {}),
          _buildListTile('About Me', () {}),
          const SizedBox(height: 50),
          // _buildSectionHeader(''),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildListTile(String title, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          title: Text(title),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
          onTap: onTap,
        ),
        const Divider(height: 1, color: Colors.grey),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return BlocConsumer<LogoutBloc, LogoutState>(
      listener: (context, state) {
        state.maybeMap(
          orElse: () {},
          success: (_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
          error: (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(value.error),
                backgroundColor: Colors.red,
              ),
            );
          },
        );
      },
      builder: (context, state) {
        return state.maybeWhen(
          orElse: () => ElevatedButton(
            onPressed: () {
              context.read<LogoutBloc>().add(const LogoutEvent.logout());
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
