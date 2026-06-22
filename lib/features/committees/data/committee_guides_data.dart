import 'models/committee_guide.dart';

const List<CommitteeGuide> committeeGuides = <CommitteeGuide>[
  CommitteeGuide(
    id: 'president',
    titleEn: 'President',
    titleZh: '会长',
    icon: '🧭',
    rolePurposeEn:
        'You guide the club, support the committee, and keep the club moving in a healthy direction.',
    rolePurposeZh: '你带领俱乐部，支持执委团队，让俱乐部保持健康、温暖、有方向地发展。',
    responsibilitySectionsEn: <CommitteeResponsibilitySection>[
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
    responsibilitySectionsZh: <CommitteeResponsibilitySection>[
      CommitteeResponsibilitySection(
        title: '会前',
        items: <String>[
          '确认重要会议角色已经安排。',
          '必要时支持例会主持人。',
          '欢迎会员和来宾。',
        ],
      ),
      CommitteeResponsibilitySection(
        title: '会中',
        items: <String>[
          '需要时开场或总结会议。',
          '保持会议温暖、尊重、准时。',
          '认可会员和来宾的参与。',
        ],
      ),
      CommitteeResponsibilitySection(
        title: '每月',
        items: <String>[
          '主持或参与执委会议。',
          '跟进俱乐部目标和会员需要。',
          '支持需要帮助的执委。',
        ],
      ),
    ],
    quickTipsEn: <String>[
      'Listen more than you speak.',
      'Encourage new leaders.',
      'Keep the club atmosphere positive.',
    ],
    quickTipsZh: <String>[
      '多听，少急着决定。',
      '鼓励新领导者成长。',
      '保持俱乐部气氛积极。',
    ],
  ),
  CommitteeGuide(
    id: 'vpe',
    titleEn: 'Vice President Education',
    titleZh: '教育副会长',
    icon: '🎓',
    rolePurposeEn:
        'You help members grow by planning speeches, roles, mentoring, and education progress.',
    rolePurposeZh: '你帮助会员成长，安排演讲、角色、导师和教育进度。',
    responsibilitySectionsEn: <CommitteeResponsibilitySection>[
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
    responsibilitySectionsZh: <CommitteeResponsibilitySection>[
      CommitteeResponsibilitySection(
        title: '会前',
        items: <String>[
          '确认演讲者和点评者。',
          '协助安排会议角色。',
          '了解会员的学习进度。',
        ],
      ),
      CommitteeResponsibilitySection(
        title: '会中',
        items: <String>[
          '支持会议流程顺利进行。',
          '留意需要演讲机会的会员。',
          '适当向来宾介绍教育项目。',
        ],
      ),
      CommitteeResponsibilitySection(
        title: '每月',
        items: <String>[
          '规划例会安排。',
          '鼓励会员继续完成项目。',
          '必要时协调比赛或特别会议。',
        ],
      ),
    ],
    quickTipsEn: <String>[
      'Keep the agenda ready early.',
      'Balance experienced and new members.',
      'Encourage progress gently.',
    ],
    quickTipsZh: <String>[
      '尽早准备议程。',
      '平衡新会员和资深会员的机会。',
      '用鼓励的方式推动进步。',
    ],
  ),
  CommitteeGuide(
    id: 'vpm',
    titleEn: 'Vice President Membership',
    titleZh: '会员副会长',
    icon: '🤝',
    rolePurposeEn:
        'You welcome guests and help them become comfortable members of the club.',
    rolePurposeZh: '你欢迎来宾，帮助他们了解俱乐部，并逐步成为舒适的会员。',
    responsibilitySectionsEn: <CommitteeResponsibilitySection>[
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
    responsibilitySectionsZh: <CommitteeResponsibilitySection>[
      CommitteeResponsibilitySection(
        title: '会前',
        items: <String>[
          '准备欢迎来宾。',
          '确认是否有来宾需要介绍。',
          '帮助来宾了解会议流程。',
        ],
      ),
      CommitteeResponsibilitySection(
        title: '会中',
        items: <String>[
          '热情接待来宾。',
          '用简单语言说明俱乐部如何运作。',
          '适当邀请来宾分享感受。',
        ],
      ),
      CommitteeResponsibilitySection(
        title: '会后',
        items: <String>[
          '跟进来宾。',
          '回答入会问题。',
          '鼓励合适的来宾再次参加。',
        ],
      ),
    ],
    quickTipsEn: <String>[
      'A warm welcome is more powerful than a hard sell.',
      'Remember guest names.',
      'Make joining feel simple and friendly.',
    ],
    quickTipsZh: <String>[
      '温暖欢迎比强力推销更有效。',
      '尽量记住来宾姓名。',
      '让入会感觉简单、友好。',
    ],
  ),
  CommitteeGuide(
    id: 'vppr',
    titleEn: 'Vice President Public Relations',
    titleZh: '公关副会长',
    icon: '📣',
    rolePurposeEn:
        'You help people outside the club understand the club’s value and activities.',
    rolePurposeZh: '你帮助俱乐部对外展示价值，让更多人了解俱乐部活动和会员成长。',
    responsibilitySectionsEn: <CommitteeResponsibilitySection>[
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
    responsibilitySectionsZh: <CommitteeResponsibilitySection>[
      CommitteeResponsibilitySection(
        title: '会前',
        items: <String>[
          '准备简单清楚的宣传内容。',
          '留意特别演讲或活动。',
          '合适时协调照片或宣传素材。',
        ],
      ),
      CommitteeResponsibilitySection(
        title: '会后',
        items: <String>[
          '分享会议亮点。',
          '宣传下一次活动。',
          '保持俱乐部形象友好、活跃。',
        ],
      ),
      CommitteeResponsibilitySection(
        title: '每月',
        items: <String>[
          '维护对外沟通渠道。',
          '支持会员招募活动。',
          '收集会员成长故事。',
        ],
      ),
    ],
    quickTipsEn: <String>[
      'Use clear and simple messages.',
      'Show real member growth.',
      'Avoid over-promising.',
    ],
    quickTipsZh: <String>[
      '信息要简单清楚。',
      '展示真实的会员成长。',
      '不要过度承诺。',
    ],
  ),
  CommitteeGuide(
    id: 'secretary',
    titleEn: 'Secretary',
    titleZh: '秘书',
    icon: '📝',
    rolePurposeEn: 'You keep club records clear, organized, and easy to find.',
    rolePurposeZh: '你让俱乐部记录清楚、有序，方便日后查找和延续。',
    responsibilitySectionsEn: <CommitteeResponsibilitySection>[
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
    responsibilitySectionsZh: <CommitteeResponsibilitySection>[
      CommitteeResponsibilitySection(
        title: '会前',
        items: <String>[
          '必要时准备会议记录资料。',
          '检查重要文件。',
        ],
      ),
      CommitteeResponsibilitySection(
        title: '会中',
        items: <String>[
          '记录重要决定。',
          '必要时记录出席或重要事项。',
        ],
      ),
      CommitteeResponsibilitySection(
        title: '会后',
        items: <String>[
          '整理并分享会议记录。',
          '更新俱乐部资料。',
          '帮助执委查找过去决定。',
        ],
      ),
    ],
    quickTipsEn: <String>[
      'Write clearly and simply.',
      'Record decisions, not every word.',
      'Keep files organized.',
    ],
    quickTipsZh: <String>[
      '记录要清楚简单。',
      '重点记录决定，不必记录每一句话。',
      '文件保持有序。',
    ],
  ),
  CommitteeGuide(
    id: 'treasurer',
    titleEn: 'Treasurer',
    titleZh: '财务',
    icon: '💰',
    rolePurposeEn:
        'You help the club manage money responsibly and transparently.',
    rolePurposeZh: '你帮助俱乐部负责任、透明地管理财务。',
    responsibilitySectionsEn: <CommitteeResponsibilitySection>[
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
    responsibilitySectionsZh: <CommitteeResponsibilitySection>[
      CommitteeResponsibilitySection(
        title: '每月',
        items: <String>[
          '记录收入和支出。',
          '更新付款记录。',
          '向执委团队报告财务状况。',
        ],
      ),
      CommitteeResponsibilitySection(
        title: '需要时',
        items: <String>[
          '协助收取会员费用。',
          '支付已批准的俱乐部开支。',
          '提醒团队注意预算限制。',
        ],
      ),
    ],
    quickTipsEn: <String>[
      'Keep records simple and accurate.',
      'Report early if there is an issue.',
      'Make money matters transparent.',
    ],
    quickTipsZh: <String>[
      '记录简单但准确。',
      '有问题要尽早报告。',
      '财务事项要透明。',
    ],
  ),
  CommitteeGuide(
    id: 'sergeant_at_arms',
    titleEn: 'Sergeant at Arms',
    titleZh: '礼宾司',
    icon: '🛠️',
    rolePurposeEn:
        'You prepare the meeting environment and help the meeting start smoothly.',
    rolePurposeZh: '你准备会议环境，帮助会议顺利开始和进行。',
    responsibilitySectionsEn: <CommitteeResponsibilitySection>[
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
    responsibilitySectionsZh: <CommitteeResponsibilitySection>[
      CommitteeResponsibilitySection(
        title: '会前',
        items: <String>[
          '准备会议场地或线上设备。',
          '检查器材。',
          '欢迎会员和来宾。',
        ],
      ),
      CommitteeResponsibilitySection(
        title: '会中',
        items: <String>[
          '协助处理现场事务。',
          '支持流程顺利转换。',
          '安静处理实际问题。',
        ],
      ),
      CommitteeResponsibilitySection(
        title: '会后',
        items: <String>[
          '收拾器材。',
          '确认场地整洁。',
          '反馈任何设备或场地问题。',
        ],
      ),
    ],
    quickTipsEn: <String>[
      'Arrive early.',
      'Check equipment before people arrive.',
      'A smooth setup helps everyone relax.',
    ],
    quickTipsZh: <String>[
      '尽量早到。',
      '在大家到达前检查设备。',
      '顺畅的准备会让大家更放松。',
    ],
  ),
  CommitteeGuide(
    id: 'immediate_past_president',
    titleEn: 'Immediate Past President',
    titleZh: '前任会长',
    icon: '🌟',
    rolePurposeEn:
        'You provide experience, continuity, and quiet support to the current committee.',
    rolePurposeZh: '你提供经验、延续性和安静的支持，帮助现任执委团队成长。',
    responsibilitySectionsEn: <CommitteeResponsibilitySection>[
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
    responsibilitySectionsZh: <CommitteeResponsibilitySection>[
      CommitteeResponsibilitySection(
        title: '每月',
        items: <String>[
          '在需要时给会长建议。',
          '支持执委团队的延续。',
          '分享过去经验，但不代替现任团队。',
        ],
      ),
      CommitteeResponsibilitySection(
        title: '需要时',
        items: <String>[
          '协助处理敏感问题。',
          '鼓励新执委。',
          '支持俱乐部稳定发展。',
        ],
      ),
    ],
    quickTipsEn: <String>[
      'Guide, don’t control.',
      'Share lessons from experience.',
      'Help new leaders grow.',
    ],
    quickTipsZh: <String>[
      '引导，但不要控制。',
      '分享经验中的教训。',
      '帮助新领导者成长。',
    ],
  ),
];
