import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/utils/logger.dart';

class TaskSuggestionsSection extends StatelessWidget {
  final String title;
  final List<TaskSuggestion> taskSuggestions;

  final AppLogger _logger = AppLogger();

  TaskSuggestionsSection({
    Key? key,
    required this.title,
    required this.taskSuggestions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (taskSuggestions.isEmpty) {
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
                  _logger.debug('Show more tasks button pressed');
                  context.go('/mission');
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
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: taskSuggestions.length,
            itemBuilder: (context, index) {
              final task = taskSuggestions[index];
              return TaskSuggestionCard(
                task: task,
                onTap: () {
                  _logger.info('Tapped task: ${task.title}');
                  context.go('/mission');
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

class TaskSuggestionCard extends StatelessWidget {
  final TaskSuggestion task;
  final VoidCallback onTap;

  const TaskSuggestionCard({
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
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        task.reward,
                        style: const TextStyle(
                          color: Colors.blue,
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
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      task.timeEstimate,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
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

class TaskSuggestion {
  final String id;
  final String title;
  final String description;
  final String reward;
  final String timeEstimate;
  final IconData icon;
  final Color iconBackgroundColor;

  TaskSuggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    required this.timeEstimate,
    required this.icon,
    required this.iconBackgroundColor,
  });
}

// Sample data for task suggestions
List<TaskSuggestion> getSampleTaskSuggestions() {
  return [
    TaskSuggestion(
      id: '1',
      title: 'Faire les courses',
      description: 'Acheter des produits alimentaires',
      reward: '15€',
      timeEstimate: '1h',
      icon: FontAwesomeIcons.cartShopping,
      iconBackgroundColor: Colors.blue,
    ),
    TaskSuggestion(
      id: '2',
      title: 'Livraison de colis',
      description: 'Récupérer et livrer un colis',
      reward: '10€',
      timeEstimate: '45min',
      icon: FontAwesomeIcons.box,
      iconBackgroundColor: Colors.orange,
    ),
    TaskSuggestion(
      id: '3',
      title: 'Montage de meuble',
      description: 'Assembler un meuble IKEA',
      reward: '25€',
      timeEstimate: '2h',
      icon: FontAwesomeIcons.screwdriverWrench,
      iconBackgroundColor: Colors.green,
    ),
    TaskSuggestion(
      id: '4',
      title: 'Ménage à domicile',
      description: 'Nettoyer un appartement',
      reward: '30€',
      timeEstimate: '3h',
      icon: FontAwesomeIcons.broom,
      iconBackgroundColor: Colors.purple,
    ),
    TaskSuggestion(
      id: '5',
      title: 'Promener un chien',
      description: 'Sortir un chien pendant 1h',
      reward: '12€',
      timeEstimate: '1h',
      icon: FontAwesomeIcons.dog,
      iconBackgroundColor: Colors.brown,
    ),
  ];
}
