import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mentor.dart';
import '../models/user.dart';
import '../models/quest.dart';

class MentorService {
  static const String _messagesKey = 'mentor_messages';
  static const String _lastInteractionKey = 'last_mentor_interaction';

  // Get mentor messages
  Future<List<MentorMessage>> getMentorMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString(_messagesKey) ?? '[]';
      final messagesList = List<Map<String, dynamic>>.from(jsonDecode(messagesJson));
      
      return messagesList.map((json) => MentorMessage.fromJson(json)).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      print('Error getting mentor messages: $e');
      return [];
    }
  }

  // Save mentor messages
  Future<bool> saveMentorMessages(List<MentorMessage> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = jsonEncode(messages.map((m) => m.toJson()).toList());
      await prefs.setString(_messagesKey, messagesJson);
      return true;
    } catch (e) {
      print('Error saving mentor messages: $e');
      return false;
    }
  }

  // Add a new mentor message
  Future<bool> addMentorMessage(MentorMessage message) async {
    final messages = await getMentorMessages();
    messages.insert(0, message);
    
    // Keep only the last 50 messages to avoid storage bloat
    if (messages.length > 50) {
      messages.removeRange(50, messages.length);
    }
    
    return await saveMentorMessages(messages);
  }

  // Mark message as read
  Future<bool> markMessageAsRead(String messageId) async {
    final messages = await getMentorMessages();
    final messageIndex = messages.indexWhere((m) => m.id == messageId);
    
    if (messageIndex == -1) return false;
    
    messages[messageIndex] = messages[messageIndex].copyWith(isRead: true);
    return await saveMentorMessages(messages);
  }

  // Get unread message count
  Future<int> getUnreadMessageCount() async {
    final messages = await getMentorMessages();
    return messages.where((m) => !m.isRead).length;
  }

  // Generate greeting message
  Future<MentorMessage> generateGreeting(User user) async {
    final mentor = Mentor.getMentorByArchetype(_getMentorArchetype(user.mentorType));
    final greeting = mentor.getGreeting();
    
    return MentorMessage(
      id: 'greeting_${DateTime.now().millisecondsSinceEpoch}',
      message: greeting,
      type: MentorMessageType.greeting,
      timestamp: DateTime.now(),
    );
  }

  // Generate motivation message
  Future<MentorMessage> generateMotivation(User user) async {
    final mentor = Mentor.getMentorByArchetype(_getMentorArchetype(user.mentorType));
    final motivation = mentor.getMotivation();
    
    return MentorMessage(
      id: 'motivation_${DateTime.now().millisecondsSinceEpoch}',
      message: motivation,
      type: MentorMessageType.motivation,
      timestamp: DateTime.now(),
    );
  }

  // Generate quest completion message
  Future<MentorMessage> generateQuestCompletionMessage(User user, Quest quest) async {
    final mentor = Mentor.getMentorByArchetype(_getMentorArchetype(user.mentorType));
    final celebration = mentor.getCelebration();
    
    final contextualMessage = _getContextualQuestMessage(quest, celebration);
    
    return MentorMessage(
      id: 'quest_completion_${DateTime.now().millisecondsSinceEpoch}',
      message: contextualMessage,
      type: MentorMessageType.questCompletion,
      timestamp: DateTime.now(),
    );
  }

  // Generate level up message
  Future<MentorMessage> generateLevelUpMessage(User user, int newLevel) async {
    final mentor = Mentor.getMentorByArchetype(_getMentorArchetype(user.mentorType));
    final celebration = mentor.getCelebration();
    
    final levelUpMessage = 'Congratulations! You\'ve reached Level $newLevel! $celebration';
    
    return MentorMessage(
      id: 'level_up_${DateTime.now().millisecondsSinceEpoch}',
      message: levelUpMessage,
      type: MentorMessageType.levelUp,
      timestamp: DateTime.now(),
    );
  }

  // Generate streak encouragement
  Future<MentorMessage> generateStreakEncouragement(User user) async {
    final mentor = Mentor.getMentorByArchetype(_getMentorArchetype(user.mentorType));
    
    String message;
    if (user.streak == 0) {
      message = 'Every journey begins with a single step. Today could be the start of an amazing streak!';
    } else if (user.streak < 7) {
      message = 'You\'re building momentum! ${user.streak} days strong. Keep the streak alive!';
    } else if (user.streak < 30) {
      message = 'Incredible dedication! ${user.streak} days in a row shows real commitment. ${mentor.getMotivation()}';
    } else {
      message = 'Absolutely legendary! ${user.streak} days of consistency is truly inspiring! ${mentor.getCelebration()}';
    }
    
    return MentorMessage(
      id: 'streak_${DateTime.now().millisecondsSinceEpoch}',
      message: message,
      type: MentorMessageType.streakEncouragement,
      timestamp: DateTime.now(),
    );
  }

  // Generate guidance based on user progress
  Future<MentorMessage> generateGuidance(User user, List<Quest> recentQuests) async {
    final mentor = Mentor.getMentorByArchetype(_getMentorArchetype(user.mentorType));
    
    String guidance = _getPersonalizedGuidance(user, recentQuests, mentor);
    
    return MentorMessage(
      id: 'guidance_${DateTime.now().millisecondsSinceEpoch}',
      message: guidance,
      type: MentorMessageType.guidance,
      timestamp: DateTime.now(),
    );
  }

  // Generate challenge message
  Future<MentorMessage> generateChallenge(User user) async {
    final mentor = Mentor.getMentorByArchetype(_getMentorArchetype(user.mentorType));
    final challenge = mentor.getChallenge();
    
    return MentorMessage(
      id: 'challenge_${DateTime.now().millisecondsSinceEpoch}',
      message: challenge,
      type: MentorMessageType.challenge,
      timestamp: DateTime.now(),
    );
  }

  // Check if daily interaction is needed
  Future<bool> shouldSendDailyMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final lastInteraction = prefs.getString(_lastInteractionKey);
    
    if (lastInteraction == null) return true;
    
    final lastDate = DateTime.parse(lastInteraction);
    final today = DateTime.now();
    
    return lastDate.day != today.day ||
           lastDate.month != today.month ||
           lastDate.year != today.year;
  }

  // Send daily mentor interaction
  Future<MentorMessage?> sendDailyInteraction(User user) async {
    if (!await shouldSendDailyMessage()) return null;
    
    final random = Random();
    final messageType = random.nextInt(3);
    
    MentorMessage message;
    switch (messageType) {
      case 0:
        message = await generateGreeting(user);
        break;
      case 1:
        message = await generateMotivation(user);
        break;
      default:
        message = await generateStreakEncouragement(user);
        break;
    }
    
    await addMentorMessage(message);
    
    // Update last interaction date
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastInteractionKey, DateTime.now().toIso8601String());
    
    return message;
  }

  // Helper methods
  MentorArchetype _getMentorArchetype(String mentorType) {
    switch (mentorType.toLowerCase()) {
      case 'the warrior':
        return MentorArchetype.theWarrior;
      case 'the scholar':
        return MentorArchetype.theScholar;
      case 'the healer':
        return MentorArchetype.theHealer;
      case 'the explorer':
        return MentorArchetype.theExplorer;
      default:
        return MentorArchetype.theMentor;
    }
  }

  String _getContextualQuestMessage(Quest quest, String baseCelebration) {
    final categoryMessages = {
      QuestCategory.health: 'Your body is your temple, and you\'re taking great care of it!',
      QuestCategory.productivity: 'Productivity is the bridge between dreams and reality. Well built!',
      QuestCategory.learning: 'Knowledge is the only treasure that grows when shared. Keep learning!',
      QuestCategory.mindfulness: 'Inner peace is the foundation of all achievement. Beautiful work!',
      QuestCategory.creativity: 'Creativity is intelligence having fun. You\'re brilliant!',
      QuestCategory.social: 'Connection is what gives life meaning. You\'re building something beautiful!',
    };
    
    final contextMessage = categoryMessages[quest.category] ?? baseCelebration;
    return '$baseCelebration $contextMessage';
  }

  String _getPersonalizedGuidance(User user, List<Quest> recentQuests, Mentor mentor) {
    // Analyze user's quest completion patterns
    final completedQuests = recentQuests.where((q) => q.isCompleted).toList();
    final categoryCount = <QuestCategory, int>{};
    
    for (final quest in completedQuests) {
      categoryCount[quest.category] = (categoryCount[quest.category] ?? 0) + 1;
    }
    
    // Find the most and least active categories
    if (categoryCount.isEmpty) {
      return 'I notice you haven\'t completed many quests lately. ${mentor.getMotivation()} Remember, small steps lead to big changes!';
    }
    
    final mostActive = categoryCount.entries.reduce((a, b) => a.value > b.value ? a : b);
    final leastActive = QuestCategory.values.where((cat) => (categoryCount[cat] ?? 0) == 0).toList();
    
    if (leastActive.isNotEmpty) {
      final category = leastActive.first;
      final categoryName = category.toString().split('.').last;
      return 'I see you\'re excelling in ${mostActive.key.toString().split('.').last}! Consider exploring $categoryName quests to create more balance in your growth.';
    }
    
    return 'Your progress across all areas is impressive! ${mentor.getMotivation()} Keep up this well-rounded approach to growth.';
  }
}

