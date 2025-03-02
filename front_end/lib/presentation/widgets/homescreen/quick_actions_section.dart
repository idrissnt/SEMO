import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class TimeEarningsWidgets extends StatelessWidget {
  const TimeEarningsWidgets({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding:
              EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 4.0),
          child: Text(
            'Ça te dit de...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            children: [
              Expanded(
                child: QuickActionCard(
                  icon: FontAwesomeIcons.clock,
                  badgeText: "5h gagnées",
                  title: "Déleguer une tâche",
                  subtitle: "Et focus sur une autre activité ?",
                  buttonText: "Déleguer",
                  actionIcon: FontAwesomeIcons.handshake,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0066FF), // Bright vibrant blue
                      Color.fromARGB(255, 1, 42, 105),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onPressed: (context) => context.go('/mission'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: QuickActionCard(
                  icon: FontAwesomeIcons.euroSign,
                  badgeText: "12 tâches dispo",
                  title: "Gagner de l'argent",
                  subtitle: "En accomplissant des tâches ?",
                  buttonText: "Parcourir",
                  actionIcon: FontAwesomeIcons.coins,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFA726),
                      Color.fromARGB(255, 145, 56, 4)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onPressed: (context) => context.go('/earn'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String badgeText;
  final String title;
  final String subtitle;
  final String buttonText;
  final LinearGradient gradient;
  final Function(BuildContext) onPressed;
  final IconData? actionIcon;

  const QuickActionCard({
    Key? key,
    required this.icon,
    required this.badgeText,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.gradient,
    required this.onPressed,
    required this.actionIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => onPressed(context),
          child: Padding(
            padding: const EdgeInsets.only(
                top: 4.0, left: 10.0, right: 10.0, bottom: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, size: 24, color: Colors.white),
                    // const SizedBox(width: 8),
                    Container(
                      width: 110,
                      height: 30,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => onPressed(context),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white24,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize:
                        const Size.fromHeight(40), // Set minimum height
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center the content
                    mainAxisSize: MainAxisSize.max, // Take full width
                    children: [
                      Text(
                        buttonText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        actionIcon,
                        size: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
