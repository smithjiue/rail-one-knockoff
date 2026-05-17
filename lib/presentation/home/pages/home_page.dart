import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rail_one/core/theme/app_colors.dart';
import 'package:rail_one/presentation/home/widgets/home_bottom_nav.dart';
import 'package:rail_one/presentation/home/widgets/home_header.dart';
import 'package:rail_one/presentation/home/widgets/journey_planner_section.dart';
import 'package:rail_one/presentation/home/widgets/more_offerings_section.dart';
import 'package:rail_one/presentation/home/widgets/do_you_know_section.dart';
import 'package:rail_one/presentation/home/widgets/follow_us_section.dart';
import 'package:rail_one/presentation/home/widgets/upcoming_journey_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      HomeHeader(),
                      JourneyPlannerSection(),
                      MoreOfferingsSection(),
                      UpcomingJourneySection(),
                      DoYouKnowSection(),
                      FollowUsSection(),
                    ],
                  ),
                ),
              ),
              HomeBottomNav(
                currentIndex: _navIndex,
                onTap: (index) => setState(() => _navIndex = index),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
