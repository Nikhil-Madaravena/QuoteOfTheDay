import os

screens = {
    'auth': 'Login',
    'onboarding': 'Onboarding',
    'questionnaire': 'Questionnaire',
    'home': 'Home',
    'history': 'History',
    'favorites': 'Favorites',
    'profile': 'Profile',
    'notifications': 'Notifications'
}

template = """import 'package:flutter/material.dart';

class {name}Screen extends StatelessWidget {{
  const {name}Screen({{super.key}});

  @override
  Widget build(BuildContext context) {{
    return Scaffold(
      appBar: AppBar(title: const Text('{name}')),
      body: const Center(child: Text('{name} Screen')),
    );
  }}
}}
"""

for feature, name in screens.items():
    folder = f'lib/features/{feature}/presentation/screens'
    os.makedirs(folder, exist_ok=True)
    file_path = f'{folder}/{name.lower()}_screen.dart'
    with open(file_path, 'w') as f:
        f.write(template.format(name=name))
