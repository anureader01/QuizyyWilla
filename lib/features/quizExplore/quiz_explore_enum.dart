import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum QuizCategory{
  mostPlayed,
  newThisWeek,
  recentlyAdded,
  highestPrize,
  lowestEntryFees,
  byTag
}

extension QuizCategoryExtenstion on QuizCategory{
  String get title {
    switch(this){
      case QuizCategory.mostPlayed : return "Most Played";
      case QuizCategory.newThisWeek : return "Weekly Dhamaka";
      case QuizCategory.recentlyAdded : return "Recenlty Added";
      case QuizCategory.highestPrize : return "Biggest Winning";
      case QuizCategory.lowestEntryFees : return "Lowest Entry Fees";
      case QuizCategory.byTag : return "Browse By Tag";
    }
  }

  IconData get icon{
    switch(this){
        case QuizCategory.mostPlayed : return Icons.favorite;
      case QuizCategory.newThisWeek : return Icons.new_releases;
      case QuizCategory.recentlyAdded : return Icons.bolt;
      case QuizCategory.highestPrize : return Icons.emoji_events;
      case QuizCategory.lowestEntryFees : return Icons.savings;
      case QuizCategory.byTag : return Icons.tag;
    }
  }
}
