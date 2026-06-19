import 'speech_topic.dart';

class SpeechTopicCategory {
  const SpeechTopicCategory({
    required this.en,
    required this.zh,
  });

  final String en;
  final String zh;
}

const List<SpeechTopicCategory> speechTopicCategories = <SpeechTopicCategory>[
  SpeechTopicCategory(en: 'Life Experience', zh: '人生经历'),
  SpeechTopicCategory(en: 'Family & Relationships', zh: '家庭与关系'),
  SpeechTopicCategory(en: 'Work & Retirement', zh: '工作与退休'),
  SpeechTopicCategory(en: 'Personal Growth', zh: '个人成长'),
  SpeechTopicCategory(en: 'Hobbies & Daily Life', zh: '兴趣与日常'),
  SpeechTopicCategory(en: 'Society & Technology', zh: '社会与科技'),
  SpeechTopicCategory(en: 'Persuasion', zh: '观点说服'),
];

const List<String> _storyStructureEn = <String>[
  'Start with one specific moment.',
  'Explain what happened.',
  'Share what changed in your thinking.',
  'End with the lesson for the audience.',
];

const List<String> _storyStructureZh = <String>[
  '从一个具体时刻开始。',
  '说明发生了什么。',
  '分享你的想法如何改变。',
  '最后给听众一个启发。',
];

const List<String> _reflectionStructureEn = <String>[
  'Begin with the question or feeling.',
  'Share a personal example.',
  'Explain what you learned.',
  'Close with a simple takeaway.',
];

const List<String> _reflectionStructureZh = <String>[
  '先提出一个问题或感受。',
  '分享一个个人例子。',
  '说明你学到了什么。',
  '用一个简单启发收尾。',
];

const List<String> _persuasiveStructureEn = <String>[
  'Start with a clear opinion.',
  'Give one personal reason.',
  'Add one practical example.',
  'Invite the audience to take a small action.',
];

const List<String> _persuasiveStructureZh = <String>[
  '先清楚说出你的观点。',
  '给出一个个人理由。',
  '加入一个实际例子。',
  '邀请听众采取一个小行动。',
];

const List<String> _informativeStructureEn = <String>[
  'Introduce the topic simply.',
  'Share two or three useful points.',
  'Use one story or example.',
  'End with what the audience can remember.',
];

const List<String> _informativeStructureZh = <String>[
  '简单介绍题目。',
  '分享两三个有用重点。',
  '加入一个故事或例子。',
  '最后告诉听众可以记住什么。',
];

const List<SpeechTopic> speechTopics = <SpeechTopic>[
  SpeechTopic(
    id: 'turning_point',
    titleEn: 'A turning point in my life',
    titleZh: '我人生中的一个转折点',
    categoryEn: 'Life Experience',
    categoryZh: '人生经历',
    promptEn:
        'Tell a story about one decision, event, or challenge that changed your direction.',
    promptZh: '讲一个改变你方向的决定、事件或挑战。',
    styleEn: 'Storytelling',
    styleZh: '故事型演讲',
    whyItWorksEn:
        'A turning point has a clear before and after, so the audience can follow your journey easily.',
    whyItWorksZh: '转折点有清楚的前后变化，听众容易跟着你的经历走。',
    structureEn: _storyStructureEn,
    structureZh: _storyStructureZh,
    starterQuestionsEn: <String>[
      'What was life like before this moment?',
      'What choice or event changed your direction?',
      'What lesson can the audience use?',
    ],
    starterQuestionsZh: <String>[
      '这个时刻之前，你的生活是什么样？',
      '哪个选择或事件改变了方向？',
      '听众可以带走什么启发？',
    ],
    openingLineEn: 'There was a day when one choice quietly changed my life.',
    openingLineZh: '有一天，一个选择悄悄改变了我的人生方向。',
  ),
  SpeechTopic(
    id: 'mistake_taught_me',
    titleEn: 'A mistake that taught me something',
    titleZh: '一个让我成长的错误',
    categoryEn: 'Life Experience',
    categoryZh: '人生经历',
    promptEn:
        'Share a mistake honestly and focus on the lesson rather than regret.',
    promptZh: '诚实分享一个错误，把重点放在学到的东西，而不是后悔。',
    styleEn: 'Reflective',
    styleZh: '反思型演讲',
    whyItWorksEn:
        'Everyone makes mistakes, so a sincere lesson can feel close and useful.',
    whyItWorksZh: '每个人都会犯错，真诚的反思会让听众觉得亲近、有用。',
    structureEn: _reflectionStructureEn,
    structureZh: _reflectionStructureZh,
    starterQuestionsEn: <String>[
      'What did you misunderstand at first?',
      'How did the mistake affect you or others?',
      'What do you do differently now?',
    ],
    starterQuestionsZh: <String>[
      '一开始你误解了什么？',
      '这个错误怎样影响你或别人？',
      '现在你会怎么做得不同？',
    ],
    openingLineEn: 'I once learned an important lesson the uncomfortable way.',
    openingLineZh: '我曾经用不太舒服的方式，学到一个重要功课。',
  ),
  SpeechTopic(
    id: 'person_changed_thinking',
    titleEn: 'A person who changed the way I think',
    titleZh: '一个改变我想法的人',
    categoryEn: 'Life Experience',
    categoryZh: '人生经历',
    promptEn:
        'Introduce one person and one idea or value they helped you see differently.',
    promptZh: '介绍一个人，以及他让你重新理解的一个想法或价值。',
    styleEn: 'Inspirational',
    styleZh: '启发型演讲',
    whyItWorksEn:
        'A person-focused speech gives your message warmth and a clear human connection.',
    whyItWorksZh: '以人物为中心的演讲有温度，也容易建立人与人的连接。',
    structureEn: _storyStructureEn,
    structureZh: _storyStructureZh,
    starterQuestionsEn: <String>[
      'Who was this person?',
      'What did they say or do?',
      'How did your thinking change afterward?',
    ],
    starterQuestionsZh: <String>[
      '这个人是谁？',
      '他做了什么或说了什么？',
      '之后你的想法有什么改变？',
    ],
    openingLineEn: 'Sometimes one person can open a door in our mind.',
    openingLineZh: '有时候，一个人能打开我们心里的一扇门。',
  ),
  SpeechTopic(
    id: 'moment_proud',
    titleEn: 'A moment I felt proud',
    titleZh: '一个让我感到自豪的时刻',
    categoryEn: 'Life Experience',
    categoryZh: '人生经历',
    promptEn:
        'Describe a proud moment and explain the effort or value behind it.',
    promptZh: '描述一个自豪的时刻，并说明背后的努力或价值。',
    styleEn: 'Storytelling',
    styleZh: '故事型演讲',
    whyItWorksEn:
        'Pride becomes meaningful when the audience understands the struggle behind the result.',
    whyItWorksZh: '当听众理解成果背后的努力时，自豪就会变得更有意义。',
    structureEn: _storyStructureEn,
    structureZh: _storyStructureZh,
    starterQuestionsEn: <String>[
      'What made this moment special?',
      'What effort came before it?',
      'What does this moment mean to you now?',
    ],
    starterQuestionsZh: <String>[
      '这个时刻为什么特别？',
      '在这之前你付出了什么努力？',
      '现在回想，它对你有什么意义？',
    ],
    openingLineEn: 'I do not feel proud often, but this moment stayed with me.',
    openingLineZh: '我不是常常感到自豪，但这个时刻一直留在我心里。',
  ),
  SpeechTopic(
    id: 'learned_from_parents',
    titleEn: 'What I learned from my parents',
    titleZh: '我从父母身上学到的事',
    categoryEn: 'Family & Relationships',
    categoryZh: '家庭与关系',
    promptEn:
        'Share one lesson from your parents through a memory or repeated habit.',
    promptZh: '通过一个回忆或习惯，分享你从父母身上学到的一件事。',
    styleEn: 'Reflective',
    styleZh: '反思型演讲',
    whyItWorksEn:
        'Family lessons are easy to understand because they come from daily life.',
    whyItWorksZh: '家庭中的功课来自日常生活，听众容易理解和共鸣。',
    structureEn: _reflectionStructureEn,
    structureZh: _reflectionStructureZh,
    starterQuestionsEn: <String>[
      'What did your parents often do or say?',
      'When did you understand the lesson?',
      'How does it guide you today?',
    ],
    starterQuestionsZh: <String>[
      '父母常做或常说什么？',
      '你什么时候真正理解这件事？',
      '它今天怎样影响你？',
    ],
    openingLineEn: 'My parents taught me many things without giving speeches.',
    openingLineZh: '父母教会我很多事，却很少需要长篇大论。',
  ),
  SpeechTopic(
    id: 'lesson_from_child',
    titleEn: 'A lesson from my child or grandchild',
    titleZh: '孩子或孙辈教会我的事',
    categoryEn: 'Family & Relationships',
    categoryZh: '家庭与关系',
    promptEn:
        'Tell how a younger family member helped you see life in a fresh way.',
    promptZh: '讲一个年轻家人如何让你用新的眼光看生活。',
    styleEn: 'Inspirational',
    styleZh: '启发型演讲',
    whyItWorksEn:
        'It gently reverses expectations and shows that learning can go both ways.',
    whyItWorksZh: '这个题目温和地打破期待，说明学习可以双向发生。',
    structureEn: _storyStructureEn,
    structureZh: _storyStructureZh,
    starterQuestionsEn: <String>[
      'What did the child do or say?',
      'Why did it surprise you?',
      'What did you learn from it?',
    ],
    starterQuestionsZh: <String>[
      '孩子做了什么或说了什么？',
      '为什么让你惊讶？',
      '你从中学到什么？',
    ],
    openingLineEn:
        'I thought I was the teacher, but that day I became the student.',
    openingLineZh: '我以为自己是老师，但那一天，我成了学生。',
  ),
  SpeechTopic(
    id: 'meaning_friendship',
    titleEn: 'The meaning of friendship',
    titleZh: '朋友的意义',
    categoryEn: 'Family & Relationships',
    categoryZh: '家庭与关系',
    promptEn:
        'Explain friendship through one friend, one action, or one difficult season.',
    promptZh: '通过一个朋友、一个行动或一段困难时期，说明朋友的意义。',
    styleEn: 'Reflective',
    styleZh: '反思型演讲',
    whyItWorksEn:
        'Friendship is familiar, but a specific story can make the message personal.',
    whyItWorksZh: '友情人人熟悉，但具体故事能让主题更有个人温度。',
    structureEn: _reflectionStructureEn,
    structureZh: _reflectionStructureZh,
    starterQuestionsEn: <String>[
      'Who showed you friendship?',
      'What did they do?',
      'What kind of friend do you want to be?',
    ],
    starterQuestionsZh: <String>[
      '谁让你看见友情？',
      '他做了什么？',
      '你想成为怎样的朋友？',
    ],
    openingLineEn: 'Friendship is easy to say, but sometimes hard to define.',
    openingLineZh: '朋友两个字很容易说，但有时不容易解释。',
  ),
  SpeechTopic(
    id: 'listen_better',
    titleEn: 'How to listen better',
    titleZh: '如何更好地倾听',
    categoryEn: 'Family & Relationships',
    categoryZh: '家庭与关系',
    promptEn:
        'Share practical ways listening can improve conversations and relationships.',
    promptZh: '分享倾听如何改善沟通和关系的实际方法。',
    styleEn: 'Informative',
    styleZh: '信息型演讲',
    whyItWorksEn:
        'Listening is a simple skill with immediate value for every audience member.',
    whyItWorksZh: '倾听是简单却实用的能力，听众马上能用在生活里。',
    structureEn: _informativeStructureEn,
    structureZh: _informativeStructureZh,
    starterQuestionsEn: <String>[
      'When did poor listening cause a problem?',
      'What does good listening look like?',
      'What is one habit people can try today?',
    ],
    starterQuestionsZh: <String>[
      '什么时候因为没有好好听而出问题？',
      '好的倾听是什么样子？',
      '听众今天可以尝试哪个习惯？',
    ],
    openingLineEn:
        'Many conversations improve when we stop preparing our reply.',
    openingLineZh: '很多对话会变好，只要我们先停止准备反驳。',
  ),
  SpeechTopic(
    id: 'work_taught_me',
    titleEn: 'What work taught me',
    titleZh: '工作教会我的事',
    categoryEn: 'Work & Retirement',
    categoryZh: '工作与退休',
    promptEn:
        'Choose one lesson from your working life and show how it shaped you.',
    promptZh: '选择工作中的一个功课，说明它如何塑造了你。',
    styleEn: 'Reflective',
    styleZh: '反思型演讲',
    whyItWorksEn:
        'Work stories carry real pressure, people, and decisions, which make lessons concrete.',
    whyItWorksZh: '工作故事有压力、人物和选择，会让道理变得具体。',
    structureEn: _reflectionStructureEn,
    structureZh: _reflectionStructureZh,
    starterQuestionsEn: <String>[
      'What kind of work shaped you most?',
      'What challenge taught the lesson?',
      'How do you use that lesson now?',
    ],
    starterQuestionsZh: <String>[
      '哪段工作最塑造你？',
      '哪个挑战教会你这件事？',
      '现在你如何使用这个功课？',
    ],
    openingLineEn: 'My work gave me more than a salary; it gave me lessons.',
    openingLineZh: '工作给我的不只是收入，也给了我许多功课。',
  ),
  SpeechTopic(
    id: 'life_after_retirement',
    titleEn: 'Life after retirement',
    titleZh: '退休后的生活',
    categoryEn: 'Work & Retirement',
    categoryZh: '工作与退休',
    promptEn:
        'Talk about what changed after retirement and what you are discovering now.',
    promptZh: '谈谈退休后有什么改变，以及你现在正在发现什么。',
    styleEn: 'Reflective',
    styleZh: '反思型演讲',
    whyItWorksEn:
        'Retirement is a major life transition that invites honest reflection and hope.',
    whyItWorksZh: '退休是人生重要转变，很适合真诚反思，也可以带出希望。',
    structureEn: _reflectionStructureEn,
    structureZh: _reflectionStructureZh,
    starterQuestionsEn: <String>[
      'What changed most after retirement?',
      'What surprised you?',
      'What gives your days meaning now?',
    ],
    starterQuestionsZh: <String>[
      '退休后最大的改变是什么？',
      '什么事情让你意外？',
      '现在什么让你的日子有意义？',
    ],
    openingLineEn: 'Retirement did not end my story; it changed the chapter.',
    openingLineZh: '退休没有结束我的故事，只是换了一个章节。',
  ),
  SpeechTopic(
    id: 'manage_time_now',
    titleEn: 'How I manage my time now',
    titleZh: '我现在如何安排时间',
    categoryEn: 'Work & Retirement',
    categoryZh: '工作与退休',
    promptEn:
        'Share the routines, priorities, or boundaries that help your days feel balanced.',
    promptZh: '分享哪些日常、优先顺序或界限，让你的生活更平衡。',
    styleEn: 'Informative',
    styleZh: '信息型演讲',
    whyItWorksEn:
        'Time management becomes more useful when it is shown through real daily choices.',
    whyItWorksZh: '时间安排通过真实日常来讲，会更具体，也更有参考价值。',
    structureEn: _informativeStructureEn,
    structureZh: _informativeStructureZh,
    starterQuestionsEn: <String>[
      'What do you protect time for?',
      'What habit helps you stay balanced?',
      'What did you stop doing?',
    ],
    starterQuestionsZh: <String>[
      '你会为哪些事情保留时间？',
      '哪个习惯帮助你保持平衡？',
      '你停止做了什么？',
    ],
    openingLineEn: 'Having time is not the same as using time well.',
    openingLineZh: '有时间，不等于会安排时间。',
  ),
  SpeechTopic(
    id: 'skill_to_learn',
    titleEn: 'A skill I still want to learn',
    titleZh: '我还想学习的一项技能',
    categoryEn: 'Work & Retirement',
    categoryZh: '工作与退休',
    promptEn:
        'Describe a skill you still want to learn and why it matters to you now.',
    promptZh: '描述一项你仍想学习的技能，以及它现在为什么重要。',
    styleEn: 'Inspirational',
    styleZh: '启发型演讲',
    whyItWorksEn:
        'It shows curiosity and reminds the audience that growth has no age limit.',
    whyItWorksZh: '这个题目展现好奇心，也提醒听众成长没有年龄限制。',
    structureEn: _storyStructureEn,
    structureZh: _storyStructureZh,
    starterQuestionsEn: <String>[
      'What skill interests you?',
      'Why have you not learned it yet?',
      'What first step can you take?',
    ],
    starterQuestionsZh: <String>[
      '你对哪项技能有兴趣？',
      '为什么还没有开始学习？',
      '第一步可以怎么做？',
    ],
    openingLineEn: 'There is one skill that still keeps calling my name.',
    openingLineZh: '有一项技能，一直在心里提醒我去学习。',
  ),
  SpeechTopic(
    id: 'handle_worry',
    titleEn: 'How I handle worry',
    titleZh: '我如何面对担忧',
    categoryEn: 'Personal Growth',
    categoryZh: '个人成长',
    promptEn:
        'Explain one or two ways you respond when worry becomes too loud.',
    promptZh: '说明当担忧变得太强时，你会用哪一两个方法回应它。',
    styleEn: 'Reflective',
    styleZh: '反思型演讲',
    whyItWorksEn:
        'Worry is common, and practical honesty can help the audience feel less alone.',
    whyItWorksZh: '担忧很普遍，诚实又实际的分享能让听众不觉得孤单。',
    structureEn: _reflectionStructureEn,
    structureZh: _reflectionStructureZh,
    starterQuestionsEn: <String>[
      'What usually makes you worry?',
      'What helps you calm down?',
      'What advice would you give a friend?',
    ],
    starterQuestionsZh: <String>[
      '什么事情常让你担忧？',
      '什么方法帮助你安定下来？',
      '如果朋友担忧，你会给什么建议？',
    ],
    openingLineEn:
        'Worry visits me too, but I have learned not to give it the whole house.',
    openingLineZh: '担忧也会来找我，但我学会不把整个心都交给它。',
  ),
  SpeechTopic(
    id: 'habit_changed_life',
    titleEn: 'A habit that changed my life',
    titleZh: '一个改变我生活的习惯',
    categoryEn: 'Personal Growth',
    categoryZh: '个人成长',
    promptEn:
        'Describe one small habit and the larger change it created over time.',
    promptZh: '描述一个小习惯，以及它长期带来的较大改变。',
    styleEn: 'Inspirational',
    styleZh: '启发型演讲',
    whyItWorksEn:
        'Small habits are believable, so the audience can imagine trying them too.',
    whyItWorksZh: '小习惯容易相信，也让听众觉得自己可以尝试。',
    structureEn: _storyStructureEn,
    structureZh: _storyStructureZh,
    starterQuestionsEn: <String>[
      'What habit did you begin?',
      'Why did you choose it?',
      'What changed after weeks or months?',
    ],
    starterQuestionsZh: <String>[
      '你开始了什么习惯？',
      '为什么选择它？',
      '几周或几个月后有什么改变？',
    ],
    openingLineEn: 'One small habit quietly changed the shape of my days.',
    openingLineZh: '一个小习惯，悄悄改变了我每天的样子。',
  ),
  SpeechTopic(
    id: 'confidence_means',
    titleEn: 'What confidence means to me',
    titleZh: '自信对我的意义',
    categoryEn: 'Personal Growth',
    categoryZh: '个人成长',
    promptEn:
        'Define confidence through your own experience, not a dictionary.',
    promptZh: '用自己的经历说明自信，而不是照字典解释。',
    styleEn: 'Reflective',
    styleZh: '反思型演讲',
    whyItWorksEn:
        'Confidence is personal, and your definition can encourage others gently.',
    whyItWorksZh: '自信很个人，你的定义可以温和地鼓励别人。',
    structureEn: _reflectionStructureEn,
    structureZh: _reflectionStructureZh,
    starterQuestionsEn: <String>[
      'When did you lack confidence?',
      'What helped it grow?',
      'How do you recognize confidence now?',
    ],
    starterQuestionsZh: <String>[
      '你什么时候缺乏自信？',
      '什么帮助它慢慢成长？',
      '现在你如何理解自信？',
    ],
    openingLineEn: 'For me, confidence is not being loud; it is being willing.',
    openingLineZh: '对我来说，自信不是声音大，而是愿意尝试。',
  ),
  SpeechTopic(
    id: 'learning_public_speaking',
    titleEn: 'Learning to speak in public',
    titleZh: '学习公众演讲',
    categoryEn: 'Personal Growth',
    categoryZh: '个人成长',
    promptEn:
        'Share what public speaking has taught you about courage, practice, or connection.',
    promptZh: '分享公众演讲如何教会你勇气、练习或连接。',
    styleEn: 'Inspirational',
    styleZh: '启发型演讲',
    whyItWorksEn:
        'The audience can relate directly because everyone in the club is learning too.',
    whyItWorksZh: '俱乐部里的每个人都在学习演讲，听众很容易产生共鸣。',
    structureEn: _storyStructureEn,
    structureZh: _storyStructureZh,
    starterQuestionsEn: <String>[
      'What was your first speaking fear?',
      'What helped you improve?',
      'What do you want to keep practicing?',
    ],
    starterQuestionsZh: <String>[
      '你最早害怕演讲的什么？',
      '什么帮助你进步？',
      '你还想继续练习什么？',
    ],
    openingLineEn:
        'Public speaking is not only about speaking; it is about becoming braver.',
    openingLineZh: '公众演讲不只是说话，也是让自己变得更勇敢。',
  ),
  SpeechTopic(
    id: 'why_running',
    titleEn: 'Why I enjoy running',
    titleZh: '我为什么喜欢跑步',
    categoryEn: 'Hobbies & Daily Life',
    categoryZh: '兴趣与日常',
    promptEn:
        'Explain what running gives you physically, mentally, or socially.',
    promptZh: '说明跑步在身体、心情或社交上带给你什么。',
    styleEn: 'Informative',
    styleZh: '信息型演讲',
    whyItWorksEn:
        'A hobby speech feels natural when you connect the activity to a personal benefit.',
    whyItWorksZh: '兴趣题目只要连接到个人收获，就会自然又有内容。',
    structureEn: _informativeStructureEn,
    structureZh: _informativeStructureZh,
    starterQuestionsEn: <String>[
      'When did you begin running?',
      'What keeps you going?',
      'What can non-runners learn from it?',
    ],
    starterQuestionsZh: <String>[
      '你什么时候开始跑步？',
      '什么让你坚持？',
      '不跑步的人也能学到什么？',
    ],
    openingLineEn: 'Running looks simple, but it has taught me a lot.',
    openingLineZh: '跑步看起来简单，却教会我很多。',
  ),
  SpeechTopic(
    id: 'book_stayed',
    titleEn: 'A book that stayed with me',
    titleZh: '一本让我难忘的书',
    categoryEn: 'Hobbies & Daily Life',
    categoryZh: '兴趣与日常',
    promptEn:
        'Share one book and the idea, scene, or lesson you still remember.',
    promptZh: '分享一本书，以及你一直记得的想法、画面或功课。',
    styleEn: 'Reflective',
    styleZh: '反思型演讲',
    whyItWorksEn:
        'A book gives you a clear object to discuss and a doorway into your own values.',
    whyItWorksZh: '一本书是清楚的切入点，也能带出你自己的价值观。',
    structureEn: _reflectionStructureEn,
    structureZh: _reflectionStructureZh,
    starterQuestionsEn: <String>[
      'What book stayed with you?',
      'Which part do you remember most?',
      'How did it affect your life or thinking?',
    ],
    starterQuestionsZh: <String>[
      '哪本书让你难忘？',
      '哪一部分你记得最清楚？',
      '它怎样影响你的生活或想法？',
    ],
    openingLineEn:
        'Some books end on the last page; others continue in our lives.',
    openingLineZh: '有些书在最后一页结束，有些书会继续留在生活里。',
  ),
  SpeechTopic(
    id: 'simple_routines',
    titleEn: 'The joy of simple routines',
    titleZh: '简单日常的快乐',
    categoryEn: 'Hobbies & Daily Life',
    categoryZh: '兴趣与日常',
    promptEn:
        'Talk about a small daily routine that brings calm, meaning, or joy.',
    promptZh: '谈一个带来平静、意义或快乐的小日常。',
    styleEn: 'Reflective',
    styleZh: '反思型演讲',
    whyItWorksEn:
        'Simple routines are relatable and can reveal what you value most.',
    whyItWorksZh: '简单日常人人都有，也能透露你最重视的东西。',
    structureEn: _reflectionStructureEn,
    structureZh: _reflectionStructureZh,
    starterQuestionsEn: <String>[
      'What routine do you enjoy?',
      'What feeling does it give you?',
      'Why is simple joy important?',
    ],
    starterQuestionsZh: <String>[
      '你喜欢哪个日常习惯？',
      '它带给你什么感觉？',
      '为什么简单快乐很重要？',
    ],
    openingLineEn: 'Not every happy moment is big; some are very small.',
    openingLineZh: '快乐不一定很大，有些快乐其实很小。',
  ),
  SpeechTopic(
    id: 'place_love_visit',
    titleEn: 'A place I love to visit',
    titleZh: '一个我喜欢去的地方',
    categoryEn: 'Hobbies & Daily Life',
    categoryZh: '兴趣与日常',
    promptEn:
        'Describe a place and explain why it matters to your heart or memory.',
    promptZh: '描述一个地方，并说明它为什么在你心里有意义。',
    styleEn: 'Storytelling',
    styleZh: '故事型演讲',
    whyItWorksEn:
        'A place gives your speech sights, sounds, and feelings the audience can imagine.',
    whyItWorksZh: '一个地方能带出画面、声音和感受，听众容易想象。',
    structureEn: _storyStructureEn,
    structureZh: _storyStructureZh,
    starterQuestionsEn: <String>[
      'Where is this place?',
      'What do you see, hear, or feel there?',
      'Why do you return to it?',
    ],
    starterQuestionsZh: <String>[
      '这个地方在哪里？',
      '在那里你看到、听到或感受到什么？',
      '为什么你会想再去？',
    ],
    openingLineEn:
        'There is one place I visit when I need to feel myself again.',
    openingLineZh: '有一个地方，会让我重新找回自己。',
  ),
  SpeechTopic(
    id: 'technology_changed_life',
    titleEn: 'How technology changed my life',
    titleZh: '科技如何改变我的生活',
    categoryEn: 'Society & Technology',
    categoryZh: '社会与科技',
    promptEn:
        'Explain one way technology changed your habits, relationships, or learning.',
    promptZh: '说明科技如何改变你的习惯、关系或学习方式。',
    styleEn: 'Informative',
    styleZh: '信息型演讲',
    whyItWorksEn:
        'Technology is broad, but one personal example makes it clear and human.',
    whyItWorksZh: '科技很大，但一个个人例子能让它变得清楚、有温度。',
    structureEn: _informativeStructureEn,
    structureZh: _informativeStructureZh,
    starterQuestionsEn: <String>[
      'Which technology changed your daily life?',
      'What became easier or harder?',
      'What do you hope people use wisely?',
    ],
    starterQuestionsZh: <String>[
      '哪项科技改变了你的日常？',
      '什么变容易了，什么变困难了？',
      '你希望大家如何明智使用它？',
    ],
    openingLineEn:
        'Technology did not only change machines; it changed my routines.',
    openingLineZh: '科技改变的不只是机器，也改变了我的日常。',
  ),
  SpeechTopic(
    id: 'young_people_teach',
    titleEn: 'What young people can teach us',
    titleZh: '年轻人能教会我们什么',
    categoryEn: 'Society & Technology',
    categoryZh: '社会与科技',
    promptEn:
        'Share what you appreciate or learn from younger people around you.',
    promptZh: '分享你从身边年轻人身上欣赏或学到的事。',
    styleEn: 'Inspirational',
    styleZh: '启发型演讲',
    whyItWorksEn:
        'It encourages respect between generations and gives the speech a positive tone.',
    whyItWorksZh: '这个题目鼓励代际尊重，也让演讲带有积极气氛。',
    structureEn: _storyStructureEn,
    structureZh: _storyStructureZh,
    starterQuestionsEn: <String>[
      'What quality do you admire in young people?',
      'Who showed you this quality?',
      'How can generations learn together?',
    ],
    starterQuestionsZh: <String>[
      '你欣赏年轻人的哪种特质？',
      '谁让你看见这种特质？',
      '不同世代如何一起学习？',
    ],
    openingLineEn:
        'Young people do not only need advice; sometimes they give it.',
    openingLineZh: '年轻人不只是需要建议，有时他们也给我们启发。',
  ),
  SpeechTopic(
    id: 'older_people_teach',
    titleEn: 'What older people can teach society',
    titleZh: '年长者能给社会什么',
    categoryEn: 'Society & Technology',
    categoryZh: '社会与科技',
    promptEn:
        'Speak about experience, patience, memory, or perspective older people offer.',
    promptZh: '谈年长者能带来的经验、耐心、记忆或视角。',
    styleEn: 'Persuasive',
    styleZh: '说服型演讲',
    whyItWorksEn:
        'It lets you advocate for dignity while using lived experience as evidence.',
    whyItWorksZh: '这个题目能用真实经历支持尊重年长者的观点。',
    structureEn: _persuasiveStructureEn,
    structureZh: _persuasiveStructureZh,
    starterQuestionsEn: <String>[
      'What value do older people bring?',
      'Where is that value overlooked?',
      'What should society do differently?',
    ],
    starterQuestionsZh: <String>[
      '年长者带来什么价值？',
      '这些价值在哪里被忽略？',
      '社会可以怎么做得不同？',
    ],
    openingLineEn:
        'A society loses wisdom when it stops listening to older voices.',
    openingLineZh: '当社会不再听年长者的声音，就会失去一部分智慧。',
  ),
  SpeechTopic(
    id: 'thoughts_ai',
    titleEn: 'My thoughts on artificial intelligence',
    titleZh: '我对人工智能的看法',
    categoryEn: 'Society & Technology',
    categoryZh: '社会与科技',
    promptEn:
        'Share a balanced view of AI through one hope, one concern, and one example.',
    promptZh: '用一个期待、一个担忧和一个例子，分享你对人工智能的看法。',
    styleEn: 'Informative',
    styleZh: '信息型演讲',
    whyItWorksEn:
        'AI is current and interesting, but a balanced personal view keeps it understandable.',
    whyItWorksZh: '人工智能很新也很热门，个人而平衡的看法会更容易听懂。',
    structureEn: _informativeStructureEn,
    structureZh: _informativeStructureZh,
    starterQuestionsEn: <String>[
      'Where have you seen AI used?',
      'What benefit interests you?',
      'What concern should people remember?',
    ],
    starterQuestionsZh: <String>[
      '你在哪里看到人工智能被使用？',
      '哪一个好处让你感兴趣？',
      '人们应该记住什么担忧？',
    ],
    openingLineEn:
        'Artificial intelligence sounds distant, but it is already near us.',
    openingLineZh: '人工智能听起来很远，其实已经离我们很近。',
  ),
  SpeechTopic(
    id: 'try_public_speaking',
    titleEn: 'Why everyone should try public speaking',
    titleZh: '为什么每个人都该尝试公众演讲',
    categoryEn: 'Persuasion',
    categoryZh: '观点说服',
    promptEn:
        'Persuade the audience that speaking practice builds more than speaking skill.',
    promptZh: '说服听众：练习演讲培养的不只是说话能力。',
    styleEn: 'Persuasive',
    styleZh: '说服型演讲',
    whyItWorksEn:
        'The audience already understands the setting, so your message can be direct and motivating.',
    whyItWorksZh: '听众熟悉演讲练习的场景，所以你的观点可以直接又有鼓励性。',
    structureEn: _persuasiveStructureEn,
    structureZh: _persuasiveStructureZh,
    starterQuestionsEn: <String>[
      'What fear keeps people from speaking?',
      'What benefit surprised you?',
      'What first step can beginners take?',
    ],
    starterQuestionsZh: <String>[
      '什么恐惧让人不敢开口？',
      '哪个好处让你意外？',
      '初学者可以先做哪一步？',
    ],
    openingLineEn:
        'Public speaking is not only for speakers; it is for anyone with a voice.',
    openingLineZh: '公众演讲不只是给演讲者的，而是给每个有声音的人。',
  ),
  SpeechTopic(
    id: 'kindness_practical',
    titleEn: 'Why kindness is practical',
    titleZh: '为什么善良很实际',
    categoryEn: 'Persuasion',
    categoryZh: '观点说服',
    promptEn:
        'Argue that kindness is not weakness, but a practical way to build trust.',
    promptZh: '说明善良不是软弱，而是建立信任的实际方法。',
    styleEn: 'Persuasive',
    styleZh: '说服型演讲',
    whyItWorksEn:
        'It challenges a common assumption and gives you room for strong examples.',
    whyItWorksZh: '这个题目挑战常见误解，也很适合加入有力例子。',
    structureEn: _persuasiveStructureEn,
    structureZh: _persuasiveStructureZh,
    starterQuestionsEn: <String>[
      'When did kindness solve a real problem?',
      'Why do some people see kindness as weak?',
      'How can kindness build trust?',
    ],
    starterQuestionsZh: <String>[
      '什么时候善良解决了真实问题？',
      '为什么有人觉得善良是软弱？',
      '善良如何建立信任？',
    ],
    openingLineEn: 'Kindness is often gentle, but it is not soft thinking.',
    openingLineZh: '善良常常很温和，但它不是软弱的想法。',
  ),
  SpeechTopic(
    id: 'learning_never_stop',
    titleEn: 'Why learning should never stop',
    titleZh: '为什么学习不该停止',
    categoryEn: 'Persuasion',
    categoryZh: '观点说服',
    promptEn:
        'Encourage lifelong learning through personal benefits and one practical example.',
    promptZh: '用个人收获和一个实际例子，鼓励终身学习。',
    styleEn: 'Persuasive',
    styleZh: '说服型演讲',
    whyItWorksEn:
        'It is positive, practical, and especially suitable for a club built on growth.',
    whyItWorksZh: '这个题目积极、实际，也很适合以成长为核心的俱乐部。',
    structureEn: _persuasiveStructureEn,
    structureZh: _persuasiveStructureZh,
    starterQuestionsEn: <String>[
      'What did you learn recently?',
      'How did learning keep you active?',
      'What stops people from learning?',
    ],
    starterQuestionsZh: <String>[
      '你最近学了什么？',
      '学习如何让你保持活力？',
      '什么阻碍人们继续学习？',
    ],
    openingLineEn: 'The moment we stop learning, our world becomes smaller.',
    openingLineZh: '当我们停止学习，世界就会变小。',
  ),
  SpeechTopic(
    id: 'community_matters',
    titleEn: 'Why community matters',
    titleZh: '为什么社群很重要',
    categoryEn: 'Persuasion',
    categoryZh: '观点说服',
    promptEn:
        'Explain why people need community for encouragement, belonging, and growth.',
    promptZh: '说明人为什么需要社群来获得鼓励、归属和成长。',
    styleEn: 'Persuasive',
    styleZh: '说服型演讲',
    whyItWorksEn:
        'Community is easy to connect with because the audience is already sitting in one.',
    whyItWorksZh: '听众本身就在社群中，所以很容易和这个主题连接。',
    structureEn: _persuasiveStructureEn,
    structureZh: _persuasiveStructureZh,
    starterQuestionsEn: <String>[
      'What community has supported you?',
      'What changes when people feel they belong?',
      'How can we build a better community?',
    ],
    starterQuestionsZh: <String>[
      '哪个社群曾经支持你？',
      '当人有归属感时，会有什么改变？',
      '我们如何建立更好的社群？',
    ],
    openingLineEn: 'People grow better when they do not grow alone.',
    openingLineZh: '人不孤单成长时，往往成长得更好。',
  ),
];
