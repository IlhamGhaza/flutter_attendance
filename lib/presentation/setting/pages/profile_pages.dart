import 'package:flutter/material.dart';
import 'package:flutter_attendance/presentation/setting/profile/pages/update_profile_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/variables.dart';
import '../../../core/core.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../profile/bloc/get_user/get_user_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<GetUserBloc>().add(const GetUserEvent.getUser());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 20.0),
            _buildAccountSection(context),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 290.0,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Assets.images.bgHome.provider(),
              alignment: Alignment.topCenter,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 40.0,
          left: 16.0,
          child: _buildAppBar(context),
        ),
        Positioned(
          top: 120.0,
          left: 0,
          right: 0,
          child: buildProfileImage(
            imageUrl: null, // Replace with actual user image URL when available
            onEditPressed: () {
              // Action to edit profile photo
            },
          ),
        ),
        Positioned(
          bottom: 10.0,
          left: 0,
          right: 0,
          child: _buildProfileInfo(),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 16.0),
        const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget buildProfileImage({
    required String? imageUrl,
    double radius = 80,
    VoidCallback? onEditPressed,
  }) {
    return Center(
      child: Stack(
        children: [
          imageUrl != null
              ? CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      NetworkImage("${Variables.baseUrl}/storage/$imageUrl"),
                )
              : const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    'https://i.pinimg.com/originals/1b/14/53/1b14536a5f7e70664550df4ccaa5b231.jpg',
                  ),
                ),
          if (onEditPressed != null)
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: radius * 0.1875,
                child: IconButton(
                  icon: Icon(Icons.edit,
                      color: Colors.blue, size: radius * 0.1875),
                  onPressed: onEditPressed,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Center(
      child: FutureBuilder(
        future: AuthLocalDatasource().getAuthData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Loading...');
          } else {
            final user = snapshot.data?.user;
            return Column(
              children: [
                Text(
                  'Hello, ${user?.name ?? 'Hello, Ilham Sensei'}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    color: AppColors.white,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 20.0),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10.0),
          BlocBuilder<GetUserBloc, GetUserState>(
            builder: (context, state) {
              return state.maybeWhen(orElse: () {
                return const SizedBox.shrink();
              }, loading: () {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }, success: (user) {
                return Column(
                  children: [
                    _buildAccountTile('Edit Profile', () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) =>
                                UpdateProfilePage(user: user)),
                      );
                    }),
                    _buildAccountTile('Jabatan', () {}),
                    _buildAccountTile('Perangkat Terdaftar', () {}),
                  ],
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTile(String title, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          title: Text(title),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: onTap,
        ),
        const Divider(),
      ],
    );
  }
}
