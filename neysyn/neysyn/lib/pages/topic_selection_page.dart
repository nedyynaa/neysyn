import 'package:flutter/material.dart';

class TopicSelectionPage extends StatefulWidget {
  const TopicSelectionPage({super.key});

  @override
  State<TopicSelectionPage> createState() => _TopicSelectionPageState();
}

class _TopicSelectionPageState extends State<TopicSelectionPage> {
  final List<String> _topics = [
    'Nutrition',
    'Fitness',
    'Mental Health',
    'Medical Myths',
    'Sleep Science',
    'Heart Health',
    'Immune System',
    'Wellness Tips',
  ];

  final Set<String> _selectedTopics = {
    'Nutrition',
    'Mental Health',
    'Immune System',
  };

  void _toggleTopic(String topic) {
    setState(() {
      if (_selectedTopics.contains(topic)) {
        _selectedTopics.remove(topic);
      } else {
        _selectedTopics.add(topic);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PREFERENCES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'What interests you?',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Select medical or lifestyle streams to refine your daily updates.',
                style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.4),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 10.0,
                runSpacing: 12.0,
                children: _topics.map((topic) {
                  final isSelected = _selectedTopics.contains(topic);
                  return GestureDetector(
                    onTap: () => _toggleTopic(topic),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      child: Text(
                        topic,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/home');
                  },
                  child: const Text(
                    'CONTINUE',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Aksi skip
                  },
                  child: const Text(
                    'Skip for now, show general feed',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
