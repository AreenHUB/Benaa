import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../core/api_client.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class AiNotifier extends StateNotifier<List<ChatMessage>> {
  AiNotifier()
    : super([
        ChatMessage(
          text:
              "مرحباً يا مهندس! أنا مساعدك الذكي. اسألني عن الأكواد، الخرسانة، أو طرق التنفيذ.",
          isUser: false,
        ),
      ]);

  bool isLoading = false;

  Future<void> sendMessage(String question) async {
    if (question.trim().isEmpty) return;

    state = [...state, ChatMessage(text: question, isUser: true)];
    isLoading = true;

    try {
      final response = await ApiClient.instance.post(
        '/ai/ask',
        data: {'question': question},
      );

      final answer = response.data['data']['answer'];

      state = [...state, ChatMessage(text: answer, isUser: false)];
    } catch (e) {
      state = [
        ...state,
        ChatMessage(
          text: "عذراً، فقدت الاتصال بالسيرفر. حاول مجدداً.",
          isUser: false,
        ),
      ];
    } finally {
      isLoading = false;
    }
  }

  void clearChat() {
    state = [ChatMessage(text: "كيف يمكنني مساعدتك اليوم؟", isUser: false)];
  }
}

final aiProvider = StateNotifierProvider<AiNotifier, List<ChatMessage>>(
  (ref) => AiNotifier(),
);
