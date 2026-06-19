import 'models/committee_guide.dart';

const List<CommitteeGuide> committeeGuides = <CommitteeGuide>[
  CommitteeGuide(
    id: 'president',
    title: 'President',
    icon: '🧭',
    rolePurpose:
        'You guide the club, support the committee, and keep the club moving in a healthy direction.',
    responsibilitySections: <CommitteeResponsibilitySection>[
      CommitteeResponsibilitySection(
        title: 'Before Meeting',
        items: <String>[
          'Check that key meeting roles are filled.',
          'Support the Toastmaster of the Day if needed.',
          'Welcome guests and members.',
        ],
      ),
      CommitteeResponsibilitySection(
        title: 'During Meeting',
        items: <String>[
          'Open or close the meeting when required.',
          'Keep the meeting warm, respectful, and on time.',
          'Recognize members and guests.',
        ],
      ),
      CommitteeResponsibilitySection(
        title: 'Monthly',
        items: <String>[
          'Lead committee discussions.',
          'Follow up on club goals and member needs.',
          'Support officers who need help.',
        ],
      ),
    ],
    quickTips: <String>[
      'Listen more than you speak.',
      'Encourage new leaders.',
      'Keep the club atmosphere positive.',
    ],
  ),
  CommitteeGuide(
    id: 'vpe',
    title: 'VPE',
    icon: '🎓',
    rolePurpose:
        'You help members grow by planning speeches, roles, mentoring, and education progress.',
    responsibilitySections: <CommitteeResponsibilitySection>[
      CommitteeResponsibilitySection(
        title: 'Before Meeting',
        items: <String>[
          'Confirm speakers and evaluators.',
          'Help assign meeting roles.',
          'Check members’ speech progress.',
        ],
      ),
      CommitteeResponsibilitySection(
        title: 'During Meeting',
        items: <String>[
          'Support the agenda flow.',
          'Notice members who may need a speaking opportunity.',
          'Help guests understand the education program when appropriate.',
        ],
      ),
      CommitteeResponsibilitySection(
        title: 'Monthly',
        items: <String>[
          'Plan the meeting schedule.',
          'Encourage members to continue projects.',
          'Coordinate contests or special meetings if needed.',
        ],
      ),
    ],
    quickTips: <String>[
      'Keep the agenda ready early.',
      'Balance experienced and new members.',
      'Encourage progress gently.',
    ],
  ),
  CommitteeGuide(
    id: 'vpm',
    title: 'VPM',
    icon: '🤝',
    rolePurpose:
        'You welcome guests and help them become comfortable members of the club.',
    responsibilitySections: <CommitteeResponsibilitySection>[
      CommitteeResponsibilitySection(
        title: 'Before Meeting',
        items: <String>[
          'Prepare to welcome guests.',
          'Check if any guests need introduction.',
          'Help guests understand the meeting flow.',
        ],
      ),
      CommitteeResponsibilitySection(
        title: 'During Meeting',
        items: <String>[
          'Greet guests warmly.',
          'Explain how the club works in simple language.',
          'Invite guests to share feedback if appropriate.',
        ],
      ),
      CommitteeResponsibilitySection(
        title: 'After Meeting',
        items: <String>[
          'Follow up with guests.',
          'Answer membership questions.',
          'Encourage suitable guests to return.',
        ],
      ),
    ],
    quickTips: <String>[
      'A warm welcome is more powerful than a hard sell.',
      'Remember guest names.',
      'Make joining feel simple and friendly.',
    ],
  ),
  CommitteeGuide(
    id: 'vppr',
    title: 'VPPR',
    icon: '📣',
    rolePurpose:
        'You help people outside the club understand the club’s value and activities.',
    responsibilitySections: <CommitteeResponsibilitySection>[
      CommitteeResponsibilitySection(
        title: 'Before Meeting',
        items: <String>[
          'Prepare simple publicity messages.',
          'Take note of special speeches or events.',
          'Coordinate photos only when appropriate.',
        ],
      ),
      CommitteeResponsibilitySection(
        title: 'After Meeting',
        items: <String>[
          'Share meeting highlights.',
          'Promote upcoming events.',
          'Keep the club image friendly and active.',
        ],
      ),
      CommitteeResponsibilitySection(
        title: 'Monthly',
        items: <String>[
          'Maintain public communication channels.',
          'Support membership campaigns.',
          'Collect simple stories from members.',
        ],
      ),
    ],
    quickTips: <String>[
      'Use clear and simple messages.',
      'Show real member growth.',
      'Avoid over-promising.',
    ],
  ),
  CommitteeGuide(
    id: 'secretary',
    title: 'Secretary',
    icon: '📝',
    rolePurpose: 'You keep club records clear, organized, and easy to find.',
    responsibilitySections: <CommitteeResponsibilitySection>[
      CommitteeResponsibilitySection(
        title: 'Before Meeting',
        items: <String>[
          'Prepare records or minutes if needed.',
          'Check important club documents.',
        ],
      ),
      CommitteeResponsibilitySection(
        title: 'During Meeting',
        items: <String>[
          'Note key decisions.',
          'Record attendance or important updates if needed.',
        ],
      ),
      CommitteeResponsibilitySection(
        title: 'After Meeting',
        items: <String>[
          'Share minutes or notes.',
          'Keep records updated.',
          'Help officers find past decisions.',
        ],
      ),
    ],
    quickTips: <String>[
      'Write clearly and simply.',
      'Record decisions, not every word.',
      'Keep files organized.',
    ],
  ),
  CommitteeGuide(
    id: 'treasurer',
    title: 'Treasurer',
    icon: '💰',
    rolePurpose:
        'You help the club manage money responsibly and transparently.',
    responsibilitySections: <CommitteeResponsibilitySection>[
      CommitteeResponsibilitySection(
        title: 'Monthly',
        items: <String>[
          'Track income and expenses.',
          'Keep payment records updated.',
          'Report financial status to the committee.',
        ],
      ),
      CommitteeResponsibilitySection(
        title: 'When Needed',
        items: <String>[
          'Support membership fee collection.',
          'Pay approved club expenses.',
          'Remind the committee about budget limits.',
        ],
      ),
    ],
    quickTips: <String>[
      'Keep records simple and accurate.',
      'Report early if there is an issue.',
      'Make money matters transparent.',
    ],
  ),
  CommitteeGuide(
    id: 'sergeant_at_arms',
    title: 'Sergeant at Arms',
    icon: '🛠️',
    rolePurpose:
        'You prepare the meeting environment and help the meeting start smoothly.',
    responsibilitySections: <CommitteeResponsibilitySection>[
      CommitteeResponsibilitySection(
        title: 'Before Meeting',
        items: <String>[
          'Prepare the room or online setup.',
          'Check equipment.',
          'Welcome members and guests.',
        ],
      ),
      CommitteeResponsibilitySection(
        title: 'During Meeting',
        items: <String>[
          'Help with logistics.',
          'Support smooth transitions.',
          'Handle practical issues quietly.',
        ],
      ),
      CommitteeResponsibilitySection(
        title: 'After Meeting',
        items: <String>[
          'Pack up equipment.',
          'Check the room is tidy.',
          'Report any setup problems.',
        ],
      ),
    ],
    quickTips: <String>[
      'Arrive early.',
      'Check equipment before people arrive.',
      'A smooth setup helps everyone relax.',
    ],
  ),
  CommitteeGuide(
    id: 'immediate_past_president',
    title: 'Immediate Past President',
    icon: '🌟',
    rolePurpose:
        'You provide experience, continuity, and quiet support to the current committee.',
    responsibilitySections: <CommitteeResponsibilitySection>[
      CommitteeResponsibilitySection(
        title: 'Monthly',
        items: <String>[
          'Advise the President when helpful.',
          'Support committee continuity.',
          'Share past experience without taking over.',
        ],
      ),
      CommitteeResponsibilitySection(
        title: 'When Needed',
        items: <String>[
          'Help solve sensitive issues.',
          'Encourage new officers.',
          'Support club stability.',
        ],
      ),
    ],
    quickTips: <String>[
      'Guide, don’t control.',
      'Share lessons from experience.',
      'Help new leaders grow.',
    ],
  ),
];
