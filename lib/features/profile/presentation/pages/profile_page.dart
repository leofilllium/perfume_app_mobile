import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // Add intl dependency to pubspec.yaml
import 'package:perfume_app_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:perfume_app_mobile/features/auth/presentation/pages/auth_page.dart';
import 'package:perfume_app_mobile/features/perfume/presentation/bloc/order/order_bloc.dart';
import 'package:perfume_app_mobile/features/perfume/presentation/bloc/order/order_state.dart';
import 'package:perfume_app_mobile/features/perfume/presentation/bloc/perfume/perfume_bloc.dart';
import 'package:perfume_app_mobile/features/perfume/presentation/bloc/perfume/perfume_state.dart';
import 'package:perfume_app_mobile/features/perfume/presentation/widgets/perfume_image.dart';
import 'package:perfume_app_mobile/features/profile/domain/entities/order.dart';
import 'package:perfume_app_mobile/features/profile/presentation/widgets/modern_order_card.dart';

import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  void initState() {
    super.initState();
    // Trigger fetching profile data when the page loads
    BlocProvider.of<ProfileBloc>(context).add(GetProfileDataEvent());
  }

  void _navigateToAuthPage(BuildContext context) async {
    // Navigate to AuthPage and wait for it to pop back
    final authBloc = BlocProvider.of<AuthBloc>(context);
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) =>
            BlocProvider
                .value( // Use BlocProvider.value to pass existing AuthBloc
              value: authBloc,
              child: AuthPage(
                onAuthSuccess: () {
                  // Pop the AuthPage when authentication is successful
                  Navigator.of(routeContext).pop(true);
                },
              ),
            ),
      ),
    );

    // After AuthPage pops, re-fetch profile data to update UI
    if (result == true) { // result might be null if popped via back button
      BlocProvider.of<ProfileBloc>(context).add(GetProfileDataEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Your Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFE2E8F0),
          ),
        ),
        actions: [
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoaded) {
                return TextButton.icon(
                  onPressed: () {
                    BlocProvider.of<ProfileBloc>(context).add(LogoutEvent());
                  },
                  icon: const Icon(
                      Icons.logout, color: Color(0xFF64748B), size: 20),
                  label: const Text('Logout',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Logged in successfully!')),
            );
          } else if (state is LogoutSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Logged out successfully!')),
            );
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          // Add a BlocListener to listen for OrderSuccess from PerfumeBloc
          return BlocListener<OrderBloc, OrderState>(
            listener: (context, perfumeState) {
              if (perfumeState is OrderSuccess) {
                // When an order is successfully placed, refresh the profile data
                BlocProvider.of<ProfileBloc>(context).add(
                    GetProfileDataEvent());
              }
            },
            child: _buildProfileContent(context, state),
          );
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, ProfileState state) {
    if (state is ProfileLoading) {
      return const Center(child: CupertinoActivityIndicator());
    } else if (state is ProfileLoaded) {
      final user = state.profileData.user;
      final preferences = state.profileData.preferences;
      final orders = state.profileData.orders;

      return SingleChildScrollView(
        child: Column(
          children: [
            // User Info Section
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 32,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A202C),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.email_outlined,
                              size: 16,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              user.email,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // User Preferences Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Fragrance Preferences',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A202C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    preferences != null
                        ? Column(
                      children: [
                        _buildPreferencesList([
                          PreferenceItem('Preferred Gender',
                              preferences.preferredGender),
                          PreferenceItem('Favorite Season',
                              preferences.favoriteSeasons.map(_capitalizeFirst)
                                  .join(', ')),
                          PreferenceItem('Occasion',
                              preferences.preferredOccasions.map(
                                  _capitalizeFirst).join(', ')),
                          PreferenceItem('Intensity',
                              preferences.intensityPreference),
                        ]),
                      ],
                    )
                        : _buildEmptyPreferences(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // User Orders Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Orders',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A202C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    orders.isEmpty
                        ? _buildEmptyOrders()
                        : Column(
                      children: [
                        ...orders.take(3).map((order) =>
                            ModernOrderCard(order: order)).toList(),
                        if (orders.length > 3) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_bag_outlined,
                                  color: Color(0xFF64748B),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'You have more orders! Check back later.',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                DefaultTabController.of(context)?.animateTo(0);
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                                side: const BorderSide(
                                    color: Color(0xFFE2E8F0)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Start Shopping',
                                style: TextStyle(
                                  color: Color(0xFF2D3748),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      );
    } else if (state is ProfileUnauthenticated) {
      return _buildUnauthenticatedView();
    } else {
      // Fallback for initial state or unexpected states
      return const Center(child: Text('Press to load profile.'));
    }
  }

  Widget _buildUnauthenticatedView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(60),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
            ),
            child: const Icon(
              Icons.person_outline,
              size: 60,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Welcome to Your Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A202C),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Sign in to view your fragrance preferences,\norder history, and personalized recommendations.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ElevatedButton(
              onPressed: () => _navigateToAuthPage(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown.shade400,

                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Sign In / Create Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildPreferencesList(List<PreferenceItem> items) {
    return Column(
      children: items.map((item) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1A202C),
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildEmptyPreferences() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.tune,
                size: 40,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              const Text(
                'No preferences set yet',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigate to Quiz page (not implemented)')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Set Your Preferences',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyOrders() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 40,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              const Text(
                'No more orders yet',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              DefaultTabController.of(context)?.animateTo(0);
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Start Shopping',
              style: TextStyle(
                color: Color(0xFF2D3748),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _capitalizeFirst(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }
}

class PreferenceItem {
  final String label;
  final String value;

  PreferenceItem(this.label, this.value);
}

