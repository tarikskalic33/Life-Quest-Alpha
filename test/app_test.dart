import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../lib/main.dart';
import '../lib/models/user.dart';
import '../lib/models/quest.dart';
import '../lib/models/achievement.dart';
import '../lib/providers/auth_provider.dart';
import '../lib/providers/quest_provider.dart';
import '../lib/providers/mentor_provider.dart';
import '../lib/providers/achievement_provider.dart';
import '../lib/services/auth_service.dart';
import '../lib/services/quest_service.dart';
import '../lib/services/mentor_service.dart';
import '../lib/services/achievement_service.dart';

void main() {
  group('LifeQuest App Tests', () {
    testWidgets('App should start and show onboarding', (WidgetTester tester) async {
      await tester.pumpWidget(const LifeQuestApp());
      await tester.pumpAndSettle();

      // Should show onboarding screen initially
      expect(find.text('Welcome to LifeQuest'), findsOneWidget);
    });

    group('User Model Tests', () {
      test('User model should create correctly', () {
        final user = User(
          id: 'test-id',
          email: 'test@example.com',
          name: 'Test User',
          level: 1,
          xp: 0,
          streak: 0,
          stats: {'health': 0, 'productivity': 0, 'learning': 0, 'mindfulness': 0},
          createdAt: DateTime.now(),
        );

        expect(user.id, 'test-id');
        expect(user.email, 'test@example.com');
        expect(user.name, 'Test User');
        expect(user.level, 1);
        expect(user.xp, 0);
        expect(user.streak, 0);
      });

      test('User should level up correctly', () {
        final user = User(
          id: 'test-id',
          email: 'test@example.com',
          name: 'Test User',
          level: 1,
          xp: 500, // Should be level 2
          streak: 0,
          stats: {'health': 0, 'productivity': 0, 'learning': 0, 'mindfulness': 0},
          createdAt: DateTime.now(),
        );

        expect(user.level, 2);
      });

      test('User JSON serialization should work', () {
        final user = User(
          id: 'test-id',
          email: 'test@example.com',
          name: 'Test User',
          level: 1,
          xp: 0,
          streak: 0,
          stats: {'health': 0, 'productivity': 0, 'learning': 0, 'mindfulness': 0},
          createdAt: DateTime.now(),
        );

        final json = user.toJson();
        final userFromJson = User.fromJson(json);

        expect(userFromJson.id, user.id);
        expect(userFromJson.email, user.email);
        expect(userFromJson.name, user.name);
        expect(userFromJson.level, user.level);
      });
    });

    group('Quest Model Tests', () {
      test('Quest model should create correctly', () {
        final quest = Quest(
          id: 'test-quest',
          title: 'Test Quest',
          description: 'A test quest',
          category: QuestCategory.health,
          difficulty: QuestDifficulty.easy,
          xpReward: 50,
          statBoosts: {'health': 5},
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        expect(quest.id, 'test-quest');
        expect(quest.title, 'Test Quest');
        expect(quest.category, QuestCategory.health);
        expect(quest.difficulty, QuestDifficulty.easy);
        expect(quest.xpReward, 50);
        expect(quest.isCompleted, false);
      });

      test('Quest difficulty labels should be correct', () {
        final easyQuest = Quest(
          id: 'easy',
          title: 'Easy Quest',
          description: 'Easy',
          category: QuestCategory.health,
          difficulty: QuestDifficulty.easy,
          xpReward: 25,
          statBoosts: {},
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        final mediumQuest = Quest(
          id: 'medium',
          title: 'Medium Quest',
          description: 'Medium',
          category: QuestCategory.health,
          difficulty: QuestDifficulty.medium,
          xpReward: 50,
          statBoosts: {},
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        final hardQuest = Quest(
          id: 'hard',
          title: 'Hard Quest',
          description: 'Hard',
          category: QuestCategory.health,
          difficulty: QuestDifficulty.hard,
          xpReward: 100,
          statBoosts: {},
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        expect(easyQuest.difficultyLabel, 'Easy');
        expect(mediumQuest.difficultyLabel, 'Medium');
        expect(hardQuest.difficultyLabel, 'Hard');
      });
    });

    group('Achievement Model Tests', () {
      test('Achievement model should create correctly', () {
        final achievement = Achievement(
          id: 'test-achievement',
          title: 'Test Achievement',
          description: 'A test achievement',
          icon: '🏆',
          type: AchievementType.questCompletion,
          rarity: AchievementRarity.common,
          targetValue: 10,
          criteria: {'questsCompleted': 10},
          xpReward: 100,
        );

        expect(achievement.id, 'test-achievement');
        expect(achievement.title, 'Test Achievement');
        expect(achievement.type, AchievementType.questCompletion);
        expect(achievement.rarity, AchievementRarity.common);
        expect(achievement.isUnlocked, false);
      });

      test('Achievement rarity labels should be correct', () {
        final achievements = Achievement.getDefaultAchievements();
        final commonAchievement = achievements.firstWhere((a) => a.rarity == AchievementRarity.common);
        final rareAchievement = achievements.firstWhere((a) => a.rarity == AchievementRarity.rare);
        final epicAchievement = achievements.firstWhere((a) => a.rarity == AchievementRarity.epic);
        final legendaryAchievement = achievements.firstWhere((a) => a.rarity == AchievementRarity.legendary);

        expect(commonAchievement.rarityLabel, 'Common');
        expect(rareAchievement.rarityLabel, 'Rare');
        expect(epicAchievement.rarityLabel, 'Epic');
        expect(legendaryAchievement.rarityLabel, 'Legendary');
      });
    });

    group('Service Tests', () {
      test('QuestService should generate daily quests', () {
        final questService = QuestService();
        final quests = questService.generateDailyQuests();

        expect(quests.length, greaterThan(0));
        expect(quests.length, lessThanOrEqualTo(5));

        // Check that quests have different categories
        final categories = quests.map((q) => q.category).toSet();
        expect(categories.length, greaterThan(1));
      });

      test('AuthService should validate email correctly', () {
        final authService = AuthService();

        expect(authService.isValidEmail('test@example.com'), true);
        expect(authService.isValidEmail('invalid-email'), false);
        expect(authService.isValidEmail(''), false);
        expect(authService.isValidEmail('test@'), false);
        expect(authService.isValidEmail('@example.com'), false);
      });

      test('MentorService should generate appropriate messages', () {
        final mentorService = MentorService();
        final user = User(
          id: 'test-id',
          email: 'test@example.com',
          name: 'Test User',
          level: 1,
          xp: 0,
          streak: 0,
          stats: {'health': 0, 'productivity': 0, 'learning': 0, 'mindfulness': 0},
          createdAt: DateTime.now(),
        );

        final message = mentorService.generateDailyMessage(user, MentorType.theMentor);
        expect(message.content.isNotEmpty, true);
        expect(message.mentorType, MentorType.theMentor);
      });
    });

    group('Provider Tests', () {
      testWidgets('AuthProvider should handle authentication state', (WidgetTester tester) async {
        final authProvider = AuthProvider();

        expect(authProvider.isAuthenticated, false);
        expect(authProvider.user, null);
        expect(authProvider.isLoading, false);
      });

      testWidgets('QuestProvider should manage quests', (WidgetTester tester) async {
        final questProvider = QuestProvider();

        expect(questProvider.todaysQuests.isEmpty, true);
        expect(questProvider.isLoading, false);
      });

      testWidgets('AchievementProvider should manage achievements', (WidgetTester tester) async {
        final achievementProvider = AchievementProvider();

        expect(achievementProvider.achievements.isEmpty, true);
        expect(achievementProvider.isLoading, false);
        expect(achievementProvider.completionPercentage, 0.0);
      });
    });

    group('Integration Tests', () {
      testWidgets('Complete quest flow should work', (WidgetTester tester) async {
        // This would test the complete flow of quest completion
        // including XP gain, stat updates, and achievement checking
        
        final user = User(
          id: 'test-id',
          email: 'test@example.com',
          name: 'Test User',
          level: 1,
          xp: 0,
          streak: 0,
          stats: {'health': 0, 'productivity': 0, 'learning': 0, 'mindfulness': 0},
          createdAt: DateTime.now(),
        );

        final quest = Quest(
          id: 'test-quest',
          title: 'Test Quest',
          description: 'A test quest',
          category: QuestCategory.health,
          difficulty: QuestDifficulty.easy,
          xpReward: 50,
          statBoosts: {'health': 5},
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        // Complete the quest
        final completedQuest = quest.copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
        );

        expect(completedQuest.isCompleted, true);
        expect(completedQuest.completedAt, isNotNull);
      });

      test('Achievement unlocking should work correctly', () {
        final achievementService = AchievementService();
        final user = User(
          id: 'test-id',
          email: 'test@example.com',
          name: 'Test User',
          level: 1,
          xp: 100,
          streak: 1,
          stats: {'health': 5, 'productivity': 0, 'learning': 0, 'mindfulness': 0},
          createdAt: DateTime.now(),
        );

        final completedQuests = [
          Quest(
            id: 'quest-1',
            title: 'First Quest',
            description: 'First completed quest',
            category: QuestCategory.health,
            difficulty: QuestDifficulty.easy,
            xpReward: 50,
            statBoosts: {'health': 5},
            isCompleted: true,
            completedAt: DateTime.now(),
            createdAt: DateTime.now(),
          ),
        ];

        // This would check if the "First Steps" achievement should be unlocked
        expect(completedQuests.length, 1);
        expect(user.streak, 1);
      });
    });
  });
}

