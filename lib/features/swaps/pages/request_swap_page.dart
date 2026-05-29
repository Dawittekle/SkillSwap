import 'package:flutter/material.dart';
import 'package:skill_swap/data/models/app_user.dart';
import 'package:skill_swap/data/models/skill.dart' as firestore_skill;
import 'package:skill_swap/data/models/swap_request.dart';
import 'package:skill_swap/data/repositories/skill_repository.dart';
import 'package:skill_swap/data/repositories/swap_repository.dart';
import 'package:skill_swap/data/repositories/user_repository.dart';
import 'package:skill_swap/data/services/auth_service.dart';
import 'package:skill_swap/routing/app_routes.dart';
import 'package:skill_swap/core/theme/app_colors.dart';
import 'package:skill_swap/core/widgets/app_button.dart';
import 'package:skill_swap/core/widgets/app_card.dart';
import 'package:skill_swap/core/widgets/app_chip.dart';
import 'package:skill_swap/core/utils/app_validators.dart';

class RequestSwapPage extends StatefulWidget {
  const RequestSwapPage({
    required this.arguments,
    super.key,
    this.authService,
    this.userRepository,
    this.skillRepository,
    this.swapRepository,
  });

  final RequestSwapArguments? arguments;
  final AuthService? authService;
  final UserRepository? userRepository;
  final SkillRepository? skillRepository;
  final SwapRepository? swapRepository;

  @override
  State<RequestSwapPage> createState() => _RequestSwapPageState();
}

class _RequestSwapPageState extends State<RequestSwapPage> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();

  String? _selectedOfferedSkillId;
  String _selectedTimeOption = 'Tomorrow afternoon';
  String _selectedMode = 'Campus';
  bool _isSending = false;

  AuthService get _authService => widget.authService ?? AuthService();
  UserRepository get _userRepository =>
      widget.userRepository ?? UserRepository();
  SkillRepository get _skillRepository =>
      widget.skillRepository ?? SkillRepository();
  SwapRepository get _swapRepository =>
      widget.swapRepository ?? SwapRepository();

  static const _timeOptions = [
    'Tomorrow afternoon',
    'This weekend',
    'Next week',
  ];
  static const _modes = ['Campus', 'Online', 'Flexible'];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendRequest(
    AppUser currentUser,
    firestore_skill.Skill selectedSkill,
    List<firestore_skill.Skill> offeredSkills,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    final offeredSkill = offeredSkills.firstWhere(
      (skill) => skill.id == _selectedOfferedSkillId,
    );
    final now = DateTime.now();

    setState(() => _isSending = true);
    try {
      final existingRequest = await _swapRepository.findActiveRequest(
        fromUserId: currentUser.uid,
        toUserId: selectedSkill.ownerId,
        wantedSkillId: selectedSkill.id,
      );

      if (existingRequest != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'You already have an active request with this student.',
            ),
            action: SnackBarAction(
              label: 'View',
              onPressed: () => Navigator.of(context).pushReplacementNamed(
                AppRoutes.swapDetails,
                arguments: existingRequest,
              ),
            ),
          ),
        );
        return;
      }

      final requestId = await _swapRepository.createSwapRequest(
        SwapRequest(
          id: '',
          fromUserId: currentUser.uid,
          fromUserName: currentUser.fullName,
          toUserId: selectedSkill.ownerId,
          toUserName: widget.arguments?.teacherName ?? selectedSkill.ownerName,
          offeredSkillId: offeredSkill.id,
          offeredSkillTitle: offeredSkill.title,
          wantedSkillId: selectedSkill.id,
          wantedSkillTitle: selectedSkill.title,
          message: _messageController.text.trim(),
          status: 'pending',
          suggestedTime: _suggestedDateTime(now),
          mode: _selectedMode,
          createdAt: now,
          updatedAt: now,
        ),
      );

      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacementNamed(AppRoutes.requestSent, arguments: requestId);
    } catch (error) {
      if (!mounted) return;
      showAuthMessage(context, error.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  DateTime _suggestedDateTime(DateTime now) {
    return switch (_selectedTimeOption) {
      'This weekend' => now.add(const Duration(days: 3)),
      'Next week' => now.add(const Duration(days: 7)),
      _ => now.add(const Duration(days: 1)),
    };
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;
    final selectedSkill = widget.arguments?.selectedSkill;

    return Scaffold(
      appBar: AppBar(title: const Text('Request Swap')),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (currentUser == null) {
              return const _RequestMessage(
                message: 'Please login before requesting a swap.',
              );
            }

            if (selectedSkill == null) {
              return const _RequestMessage(
                message:
                    'Choose a skill from Discover first, then request a swap.',
              );
            }

            return FutureBuilder<AppUser?>(
              future: _userRepository.getUser(currentUser.uid),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGreen,
                    ),
                  );
                }

                if (userSnapshot.hasError) {
                  return _RequestMessage(
                    message: userSnapshot.error.toString(),
                  );
                }

                final appUser = userSnapshot.data;
                if (appUser == null) {
                  return const _RequestMessage(
                    message: 'Complete your profile before requesting a swap.',
                  );
                }

                return StreamBuilder<List<firestore_skill.Skill>>(
                  stream: _skillRepository.watchCurrentUserSkills(
                    currentUser.uid,
                  ),
                  builder: (context, skillSnapshot) {
                    final offeredSkills = (skillSnapshot.data ?? []).where((
                      skill,
                    ) {
                      return skill.type == 'offered' && skill.isActive;
                    }).toList();

                    final selectedSkillExists = offeredSkills.any((skill) {
                      return skill.id == _selectedOfferedSkillId;
                    });
                    if (offeredSkills.isNotEmpty &&
                        (_selectedOfferedSkillId == null ||
                            !selectedSkillExists)) {
                      _selectedOfferedSkillId = offeredSkills.first.id;
                    }

                    if (skillSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryGreen,
                        ),
                      );
                    }

                    if (skillSnapshot.hasError) {
                      return _RequestMessage(
                        message: skillSnapshot.error.toString(),
                      );
                    }

                    return _RequestForm(
                      formKey: _formKey,
                      selectedSkill: selectedSkill,
                      currentUser: appUser,
                      offeredSkills: offeredSkills,
                      selectedOfferedSkillId: _selectedOfferedSkillId,
                      messageController: _messageController,
                      selectedTimeOption: _selectedTimeOption,
                      selectedMode: _selectedMode,
                      timeOptions: _timeOptions,
                      modes: _modes,
                      isSending: _isSending,
                      onOfferedSkillChanged: (value) {
                        setState(() => _selectedOfferedSkillId = value);
                      },
                      onTimeChanged: (value) {
                        setState(() => _selectedTimeOption = value);
                      },
                      onModeChanged: (value) {
                        setState(() => _selectedMode = value);
                      },
                      onSend: offeredSkills.isEmpty || _isSending
                          ? null
                          : () => _sendRequest(
                              appUser,
                              selectedSkill,
                              offeredSkills,
                            ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _RequestForm extends StatelessWidget {
  const _RequestForm({
    required this.formKey,
    required this.selectedSkill,
    required this.currentUser,
    required this.offeredSkills,
    required this.selectedOfferedSkillId,
    required this.messageController,
    required this.selectedTimeOption,
    required this.selectedMode,
    required this.timeOptions,
    required this.modes,
    required this.isSending,
    required this.onOfferedSkillChanged,
    required this.onTimeChanged,
    required this.onModeChanged,
    required this.onSend,
  });

  final GlobalKey<FormState> formKey;
  final firestore_skill.Skill selectedSkill;
  final AppUser currentUser;
  final List<firestore_skill.Skill> offeredSkills;
  final String? selectedOfferedSkillId;
  final TextEditingController messageController;
  final String selectedTimeOption;
  final String selectedMode;
  final List<String> timeOptions;
  final List<String> modes;
  final bool isSending;
  final ValueChanged<String?> onOfferedSkillChanged;
  final ValueChanged<String> onTimeChanged;
  final ValueChanged<String> onModeChanged;
  final VoidCallback? onSend;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('You want to learn', style: textTheme.titleLarge),
                        const SizedBox(height: 12),
                        _SkillSummary(
                          icon: Icons.north_east,
                          title: selectedSkill.title,
                          subtitle:
                              '${selectedSkill.ownerName} - ${selectedSkill.university}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  AppCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Offer one of your skills',
                          style: textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        if (offeredSkills.isEmpty)
                          Text(
                            'Add an offered skill first so you have something to exchange.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.textGray,
                            ),
                          )
                        else
                          DropdownButtonFormField<String>(
                            initialValue: selectedOfferedSkillId,
                            decoration: const InputDecoration(
                              labelText: 'Skill you can teach',
                            ),
                            items: offeredSkills.map((skill) {
                              return DropdownMenuItem(
                                value: skill.id,
                                child: Text(skill.title),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Choose one offered skill';
                              }

                              return null;
                            },
                            onChanged: onOfferedSkillChanged,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  AppCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Message', style: textTheme.titleLarge),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: messageController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Write a short note',
                            hintText:
                                'Hi, I would love to swap sessions this week...',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Write a short message';
                            }

                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  AppCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Session preference', style: textTheme.titleLarge),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: selectedTimeOption,
                          decoration: const InputDecoration(
                            labelText: 'Suggested time',
                          ),
                          items: timeOptions.map((option) {
                            return DropdownMenuItem(
                              value: option,
                              child: Text(option),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) onTimeChanged(value);
                          },
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final mode in modes)
                              CategoryChip(
                                label: mode,
                                selected: mode == selectedMode,
                                icon: _modeIcon(mode),
                                onTap: () => onModeChanged(mode),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: isSending ? 'Sending...' : 'Send Request',
                    icon: Icons.send_outlined,
                    onPressed: onSend,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SkillSummary extends StatelessWidget {
  const _SkillSummary({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.softBlue,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.textGray),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestMessage extends StatelessWidget {
  const _RequestMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          child: Text(message, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }
}

IconData _modeIcon(String mode) {
  return switch (mode.toLowerCase()) {
    'online' => Icons.videocam_outlined,
    'flexible' => Icons.tune,
    _ => Icons.place_outlined,
  };
}
