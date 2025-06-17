import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perfume_app_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:perfume_app_mobile/features/perfume/presentation/pages/for_you_page.dart';
import 'package:perfume_app_mobile/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:perfume_app_mobile/features/profile/presentation/bloc/profile_event.dart';
import 'package:perfume_app_mobile/features/profile/presentation/pages/profile_page.dart';
import 'features/perfume/presentation/bloc/perfume_bloc.dart';
import 'features/perfume/presentation/pages/shop_page.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init(); // Initialize GetIt
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Perfume Shop',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MultiBlocProvider( // Use MultiBlocProvider for multiple BLoCs
        providers: [
          BlocProvider(
            create: (_) => di.sl<PerfumeBloc>(),
          ),
          BlocProvider(
            create: (_) => di.sl<ProfileBloc>(), // Provide ProfileBloc
          ),
          BlocProvider( // Provide AuthBloc
            create: (_) => di.sl<AuthBloc>(),
          ),
        ],
        child: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Current selected tab index

  // List of pages to display
  final List<Widget> _pages = [
    const ShopPage(),
    const ForYouPage(), // Placeholder
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // If navigating to the Profile tab, ensure it fetches data
    if (index == 2) { // Assuming ProfilePage is at index 2
      BlocProvider.of<ProfileBloc>(context).add(GetProfileDataEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack( // Use IndexedStack to keep pages alive
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black87,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              activeIcon: Icon(Icons.storefront),
              label: 'Shop',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline),
              activeIcon: Icon(Icons.favorite),
              label: 'For You',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}