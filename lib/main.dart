import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:helloworld/firebase_options.dart';
import 'package:helloworld/pages/home/home_page.dart';
import 'package:helloworld/pages/ideas/create_idea_page.dart';
import 'package:helloworld/pages/ideas/idea_details_page.dart';
import 'package:helloworld/pages/notifications/notifications_page.dart';
import 'package:helloworld/pages/recommendations/recommendations_page.dart';
import 'package:helloworld/pages/stubs/analytics_page.dart';
import 'package:helloworld/pages/stubs/calendar_page.dart';
import 'package:helloworld/pages/stubs/clipboard_page.dart';
import 'package:helloworld/pages/stubs/grid_page.dart';
import 'package:helloworld/pages/tasks/create_task_page.dart';
import 'package:helloworld/screens/login_screen.dart';
import 'package:helloworld/screens/registration_screen.dart';
import 'package:helloworld/screens/welcome_screen.dart';
import 'package:helloworld/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AIdeaApp());
}

class AIdeaApp extends StatelessWidget {
  const AIdeaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIdea',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: WelcomeScreen.routeName,
      routes: {
        WelcomeScreen.routeName: (context) => const WelcomeScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        RegistrationScreen.routeName: (context) => const RegistrationScreen(),
        HomePage.routeName: (context) => const HomePage(),
        CreateIdeaPage.routeName: (context) => const CreateIdeaPage(),
        CreateTaskPage.routeName: (context) => const CreateTaskPage(),
        NotificationsPage.routeName: (context) => const NotificationsPage(),
        RecommendationPage.routeName: (context) => const RecommendationPage(),
        ClipboardPage.routeName: (context) => const ClipboardPage(),
        GridPage.routeName: (context) => const GridPage(),
        CalendarPage.routeName: (context) => const CalendarPage(),
        AnalyticsPage.routeName: (context) => const AnalyticsPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == IdeaDetailsPage.routeName) {
          final ideaId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => IdeaDetailsPage(ideaId: ideaId),
          );
        }
        return null;
      },
    );
  }
}
