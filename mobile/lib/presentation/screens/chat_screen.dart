import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/chat_service.dart';
import '../widgets/glass_card.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final List<Map<String, String>> _messages = [
    {'sender': 'ai', 'text': 'Bonjour ! Je suis votre assistant financier hospitalier. Comment puis-je vous aider aujourd\'hui ?'}
  ];
  bool _isTyping = false;

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _messageController.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final response = await _chatService.sendMessage(text);
      if (mounted) {
        setState(() {
          _messages.add({'sender': 'ai', 'text': response});
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({'sender': 'ai', 'text': 'Désolé, une erreur est survenue.'});
          _isTyping = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant IA'),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Chip(
                        label: Text('L\'IA écrit...'),
                        backgroundColor: AppColors.background,
                      ),
                    ),
                  );
                }
                final message = _messages[index];
                final isUser = message['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isUser ? const Radius.circular(16) : Radius.circular(0),
                        bottomRight: isUser ? Radius.circular(0) : const Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      message['text']!,
                      style: TextStyle(
                        color: isUser ? Colors.white : AppColors.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Posez votre question...',
                      border: InputBorder.none,
                      filled: false,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
