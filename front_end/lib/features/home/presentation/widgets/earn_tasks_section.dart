import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/utils/logger.dart';

class EarnTasksSection extends StatelessWidget {
  final String title;
  final List<EarnTask> earnTasks;

  final AppLogger _logger = AppLogger();

  EarnTasksSection({
    Key? key,
    required this.title,
    required this.earnTasks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (earnTasks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  _logger.debug('Show more earn tasks button pressed');
                  context.go('/earn');
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(40, 40),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_forward,
                      size: 20,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: earnTasks.length,
            itemBuilder: (context, index) {
              final task = earnTasks[index];
              return EarnTaskCard(
                task: task,
                onTap: () {
                  _logger.info('Tapped earn task: ${task.title}');
                  context.go('/earn');
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class EarnTaskCard extends StatelessWidget {
  final EarnTask task;
  final VoidCallback onTap;

  const EarnTaskCard({
    Key? key,
    required this.task,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: task.iconBackgroundColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        task.icon,
                        color: task.iconBackgroundColor,
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        task.payment,
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  task.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        task.location,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EarnTask {
  final String id;
  final String title;
  final String description;
  final String payment;
  final String location;
  final IconData icon;
  final Color iconBackgroundColor;

  EarnTask({
    required this.id,
    required this.title,
    required this.description,
    required this.payment,
    required this.location,
    required this.icon,
    required this.iconBackgroundColor,
  });
}

// Sample data for earn tasks
List<EarnTask> getSampleEarnTasks() {
  return [
    EarnTask(
      id: '1',
      title: 'Livraison de repas',
      description: 'Livrer des repas',
      payment: '12€/h',
      location: 'Paris 11e',
      icon: FontAwesomeIcons.utensils,
      iconBackgroundColor: Colors.orange,
    ),
    EarnTask(
      id: '2',
      title: 'Aide aux courses',
      description: 'Aider une personne âgée',
      payment: '15€/h',
      location: 'Paris 15e',
      icon: FontAwesomeIcons.handHoldingHeart,
      iconBackgroundColor: Colors.red,
    ),
    EarnTask(
      id: '3',
      title: 'Distribution de flyers',
      description: 'Distribuer des flyers',
      payment: '11€/h',
      location: 'Paris 9e',
      icon: FontAwesomeIcons.fileLines,
      iconBackgroundColor: Colors.blue,
    ),
    EarnTask(
      id: '4',
      title: 'Inventaire magasin',
      description: 'Réaliser inventaire',
      payment: '14€/h',
      location: 'Paris 2e',
      icon: FontAwesomeIcons.clipboardList,
      iconBackgroundColor: Colors.green,
    ),
    EarnTask(
      id: '5',
      title: 'Saisie de données',
      description: 'Saisir des données',
      payment: '13€/h',
      location: 'Télétravail',
      icon: FontAwesomeIcons.keyboard,
      iconBackgroundColor: Colors.purple,
    ),
  ];
}
