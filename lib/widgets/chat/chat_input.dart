import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final VoidCallback? onTyping;
  final bool enabled;

  const ChatInput({
    super.key,
    required this.onSendMessage,
    this.onTyping,
    this.enabled = true,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);

        // Notify typing
        if (hasText && widget.onTyping != null) {
          widget.onTyping!();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && widget.enabled) {
      widget.onSendMessage(text);
      _controller.clear();
      setState(() => _hasText = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Emoji button
            IconButton(
              onPressed: widget.enabled
                  ? () {
                      // Show emoji picker or other actions
                      _showEmojiActions(context);
                    }
                  : null,
              icon: Icon(
                Icons.emoji_emotions_outlined,
                color: widget.enabled
                    ? theme.colorScheme.primary
                    : theme.disabledColor,
              ),
            ),

            // Text input
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: widget.enabled
                        ? "Type a message..."
                        : "Chat disabled",
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.3),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 1,
                      ),
                    ),
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Material(
                color: _hasText && widget.enabled
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(25),
                child: InkWell(
                  onTap: _hasText && widget.enabled ? _sendMessage : null,
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.send_rounded,
                      color: _hasText && widget.enabled
                          ? Colors.white
                          : theme.colorScheme.onSurface.withOpacity(0.5),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmojiActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Quick emoji responses - FIXED EMOJIS
            Wrap(
              spacing: 8,
              children: [
                _buildQuickEmoji('👍', 'Thumbs up'),
                _buildQuickEmoji('👌', 'OK'),
                _buildQuickEmoji('😊', 'Smile'),
                _buildQuickEmoji('🙏', 'Thank you'),
                _buildQuickEmoji('✅', 'Done'),
                _buildQuickEmoji('❌', 'No'),
              ],
            ),

            const SizedBox(height: 16),

            // Quick text responses
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuickText('Ji haan'),
                _buildQuickText('Theek hai'),
                _buildQuickText('Samjh gaya'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickEmoji(String emoji, String label) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _controller.text = _controller.text + emoji;
        setState(() => _hasText = _controller.text.trim().isNotEmpty);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickText(String text) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _controller.text = text;
        setState(() => _hasText = true);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Text(text, style: const TextStyle(color: Colors.blue)),
      ),
    );
  }
}
