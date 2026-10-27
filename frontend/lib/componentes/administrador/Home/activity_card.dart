import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

class ActivityCard extends StatelessWidget {
  final String action;
  final String detail;
  final String time;

  const ActivityCard({
    super.key,
    required this.action,
    required this.detail,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grisOscuro,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grisMedio.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.history, color: AppColors.verdePrimario, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action,
                  style: const TextStyle(
                    color: AppColors.blancoPuro,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: const TextStyle(
                    color: AppColors.grisClaro,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: AppColors.grisMedio,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}