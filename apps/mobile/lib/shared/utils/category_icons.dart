import 'package:flutter/material.dart';

/// Maps schedule block categories to Material Icons.
///
/// Supported categories: class, club, study, workout, work, meal, other.
/// "gym" is treated as an alias for workout.
IconData iconForCategory(String category) {
  switch (category) {
    case 'class':
      return Icons.school;
    case 'club':
      return Icons.groups;
    case 'study':
      return Icons.menu_book;
    case 'workout':
    case 'gym':
      return Icons.fitness_center;
    case 'work':
      return Icons.work;
    case 'meal':
      return Icons.restaurant;
    case 'other':
    default:
      return Icons.event;
  }
}
