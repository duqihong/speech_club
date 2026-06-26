// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '演讲俱乐部';

  @override
  String get navTimer => '计时器';

  @override
  String get navSpeaker => '演讲卡片';

  @override
  String get navTopicSelection => '选题助手';

  @override
  String get navTableTopics => '即席演讲';

  @override
  String get navRoleAssistant => '角色助手';

  @override
  String get navCommittees => '执委职责';

  @override
  String get navPathways => '学习路径';

  @override
  String get navVoteBests => '最佳投票';

  @override
  String get buttonStart => '开始';

  @override
  String get buttonStop => '停止';

  @override
  String get buttonReset => '重置';

  @override
  String get buttonSave => '保存';

  @override
  String get buttonCancel => '取消';

  @override
  String get buttonDelete => '删除';

  @override
  String get buttonEdit => '编辑';

  @override
  String get buttonAdd => '添加';

  @override
  String get buttonDone => '完成';

  @override
  String get buttonClose => '关闭';

  @override
  String get buttonBack => '返回';

  @override
  String get buttonConfirm => '确认';

  @override
  String get buttonOk => '确定';

  @override
  String get buttonNext => '下一步';

  @override
  String get buttonPrevious => '上一步';

  @override
  String get buttonRetry => '重试';

  @override
  String get buttonExit => '退出';

  @override
  String get labelNoData => '暂无数据';

  @override
  String get dialogExitTimerTitle => '退出计时器？';

  @override
  String get dialogExitTimerMessage => '计时仍在进行中。仍要退出吗？';

  @override
  String get timerCustomPreset => '自定义预设';

  @override
  String get timerEditCustomPreset => '编辑自定义预设';

  @override
  String get timerStageGreen => '绿灯';

  @override
  String get timerStageYellow => '黄灯';

  @override
  String get timerStageRed => '红灯';

  @override
  String get timerStageOvertime => '超时';

  @override
  String get timerUnitMin => '分';

  @override
  String get timerUnitSec => '秒';

  @override
  String get timerTestPanel => '测试面板';

  @override
  String get timerDing => '提示音';

  @override
  String get timerOvertimeReachedHint => '已超时，点击任意位置即可重置。';

  @override
  String get timerPresetOrderError => '必须满足 绿灯 < 黄灯 < 红灯 < 超时';

  @override
  String get tableTopicsTitle => '即席演讲';

  @override
  String get tableTopicsGenerate10 => '生成 10 个题目';

  @override
  String get tableTopicsEdit10 => '编辑 10 个题目';

  @override
  String get tableTopicsPresenterMode => '展示模式';

  @override
  String get tableTopicsCustomTopics => '自定义题目';

  @override
  String get tableTopicsUseTheseTopics => '使用这些题目';

  @override
  String get tableTopicsEnterCustomTopics => '最多输入 10 个自定义题目。';

  @override
  String tableTopicsTopicLabel(int number) {
    return '题目 $number';
  }

  @override
  String get tableTopicsEditTopics => '编辑题目';

  @override
  String get tableTopicsCategoriesSelection => '分类';

  @override
  String get tableTopicsCustomTopicsSaved => '自定义题目已保存。';

  @override
  String get tableTopicsAddAtLeastOne => '请至少添加一个题目。';

  @override
  String get tableTopicsNoSetFound => '未找到 10 个题目，请返回上一页先生成题目。';

  @override
  String get tableTopicsToggleUsedHint => '长按题块可切换已使用或未使用。';

  @override
  String get tableTopicsPlaceholderTopic => '（题目）';

  @override
  String get tableTopicsErrorPrefix => '错误';

  @override
  String get tableTopicsCategoryCommunication => '沟通';

  @override
  String get tableTopicsCategoryDailyLife => '日常生活';

  @override
  String get tableTopicsCategoryEducation => '教育';

  @override
  String get tableTopicsCategoryTravel => '旅行';

  @override
  String get tableTopicsCategoryWorkCareer => '工作与职业';

  @override
  String get tableTopicsCategoryEnglishOriginExpressions => '英语来源表达';

  @override
  String get tableTopicsCategoryFood => '美食';

  @override
  String get tableTopicsCategoryHealthExercise => '健康与运动';

  @override
  String get tableTopicsCategoryChineseIdioms => '成语';

  @override
  String get tableTopicsCategoryClassicalPoetryLines => '诗句';

  @override
  String get flashcardsMySpeech => '我的演讲';

  @override
  String get flashcardsMySpeeches => '我的演讲';

  @override
  String get flashcardsAddCard => '添加卡片';

  @override
  String get flashcardsEditCard => '编辑卡片';

  @override
  String get flashcardsPasteMultipleCards => '粘贴多张卡片';

  @override
  String get flashcardsEditMySpeech => '编辑我的演讲';

  @override
  String get flashcardsEditCards => '编辑卡片';

  @override
  String get flashcardsStartPresentation => '开始展示';

  @override
  String get flashcardsNoCardsYet => '还没有卡片，请先添加卡片。';

  @override
  String get flashcardsEmptyState => '还没有卡片。\n点击“添加卡片”创建第一张。';

  @override
  String get flashcardsMoveUp => '上移';

  @override
  String get flashcardsMoveDown => '下移';

  @override
  String get flashcardsPresenter => '展示模式';

  @override
  String get flashcardsToggleTheme => '切换主题';

  @override
  String get flashcardsNoCardsToPresent => '没有可展示的卡片。';

  @override
  String get flashcardsPasteHint => '请在这里粘贴演讲内容。\n\n可用空行分隔卡片。';

  @override
  String get flashcardsCardHint => '输入卡片内容…';

  @override
  String roleAssistantFailedToLoad(String error) {
    return '加载角色失败：$error';
  }

  @override
  String get roleAssistantNoRolesFound => '未找到角色。';

  @override
  String get roleAssistantRolePurpose => '角色职责';

  @override
  String get roleAssistantChecklist => '检查清单';

  @override
  String get roleAssistantBefore => '事前';

  @override
  String get roleAssistantDuring => '进行中';

  @override
  String get roleAssistantAfter => '结束后';

  @override
  String get roleAssistantQuickTips => '小贴士';

  @override
  String get roleAssistantExamplePhrasing => '示例话术';

  @override
  String get roleAssistantCopied => '已复制';

  @override
  String get roleAssistantOpenTimerTool => '打开计时器';

  @override
  String get roleAssistantOpenTableTopics => '打开即兴问答';

  @override
  String get roleAssistantOpenTool => '打开工具';

  @override
  String get roleAssistantOpenSpeakerFlashcard => '打开演讲卡片';

  @override
  String get roleAssistantTitleToastmasterOfTheDay => '司仪';

  @override
  String get roleAssistantTitleTimer => '计时员';

  @override
  String get roleAssistantTitleTableTopicsMaster => '即席演讲主持';

  @override
  String get roleAssistantTitleEvaluator => '评论员';

  @override
  String get roleAssistantTitleLanguageEvaluator => '语言评论';

  @override
  String get roleAssistantTitleAhCounter => '尾音记录员';

  @override
  String get roleAssistantTitleSpeaker => '演讲者';

  @override
  String get roleAssistantTitleGeneralEvaluator => '总评论';

  @override
  String get committeesTitle => '执委职责';

  @override
  String get committeesRolePurpose => '角色定位';

  @override
  String get committeesKeyResponsibilities => '主要责任';

  @override
  String get committeesQuickTips => '小提示';

  @override
  String get topicSelectionTitle => '选题助手';

  @override
  String get topicSelectionIntro => '基本上什么题目都可以讲，只要它连接到你的经历、感受或观点。';

  @override
  String get topicSelectionCategoryPurpose => '这类题目适合什么';

  @override
  String get topicSelectionTopicIdeas => '可以讲这些题目';

  @override
  String get topicSelectionHowToChoose => '怎样选一个好题目';

  @override
  String get topicSelectionSpeechStructure => '可以这样组织';

  @override
  String get topicSelectionOpeningLines => '开场句参考';

  @override
  String get pathwaysTitle => '学习路径';

  @override
  String get pathwaysIntro => '学习路径帮助你一步一步提升演讲、自信、领导力和沟通能力。';

  @override
  String get pathwaysBaseCampNote =>
      '这是俱乐部内使用的简明参考。正式项目要求请以 Toastmasters Base Camp 为准。';

  @override
  String get pathwaysWhatThisPathBuilds => '这条路径训练什么';

  @override
  String get pathwaysGoodForMembers => '适合这样的会员';

  @override
  String get pathwaysTypicalSpeechFocus => '常见演讲重点';

  @override
  String get pathwaysHowToStart => '如何开始';

  @override
  String get pathwaysMentorTips => '导师提示';

  @override
  String get voteBestsTitle => '最佳投票';

  @override
  String get voteBestsModeIntro => '选择本次例会奖项的计票方式。';

  @override
  String get voteBestsManualCount => '手动计票';

  @override
  String get voteBestsManualCountSubtitle => '在本机手动添加候选人和票数。';

  @override
  String get voteBestsOnlineCount => '在线计票';

  @override
  String get voteBestsOnlineCountSubtitle => '创建云端投票轮次并收集线上投票。';

  @override
  String get voteBestsOnlineDescription => '创建云端会议，每次开放一个奖项投票，并分享投票链接。';

  @override
  String get voteBestsOnlineNote => '目前请先使用手动计票。';

  @override
  String get voteBestsGoToManualCount => '前往手动计票';

  @override
  String get voteBestsSendResultsToPresident => '发送结果给会长';

  @override
  String get voteBestsCopyResults => '复制结果';

  @override
  String get voteBestsPresidentContact => '会长联系方式';

  @override
  String get voteBestsContactNotSet => '未设置';

  @override
  String get voteBestsPresidentName => '会长姓名';

  @override
  String get voteBestsPhoneNumber => '电话号码';

  @override
  String get voteBestsPresidentNameError => '请输入会长姓名。';

  @override
  String get voteBestsPhoneNumberError => '请输入电话号码。';

  @override
  String get voteBestsMissingContactMessage => '还没有设置会长联系方式。请先填写会长姓名和电话号码。';

  @override
  String get voteBestsMissingPresidentPhoneNumber => '请先设置会长电话号码。';

  @override
  String get voteBestsSetNow => '现在设置';

  @override
  String get voteBestsResultsCopied => '结果已复制。你可以粘贴到短信或 WhatsApp。';

  @override
  String get voteBestsWhatsAppOpened => '已打开 WhatsApp。请确认后发送结果。';

  @override
  String get voteBestsWhatsAppOpenFailedCopied => '无法打开 WhatsApp，结果已复制。';

  @override
  String get voteBestsIntro => '这是一个本地计票工具，用来记录例会奖项投票。它不会收集线上投票。';

  @override
  String voteBestsAwardSummary(int candidateCount, int voteCount) {
    return '$candidateCount 位候选人 · $voteCount 票';
  }

  @override
  String get voteBestsResetMeetingVotes => '重置本场投票';

  @override
  String get voteBestsResetConfirmMessage => '确定要清空本场所有候选人和票数吗？';

  @override
  String get voteBestsDetailHelp => '先添加候选人，计到一票时点击 +1。';

  @override
  String get voteBestsCandidates => '候选人';

  @override
  String get voteBestsResults => '当前结果';

  @override
  String get voteBestsAddCandidate => '添加候选人';

  @override
  String get voteBestsCandidateName => '候选人姓名';

  @override
  String get voteBestsPleaseEnterName => '请输入姓名。';

  @override
  String get voteBestsDuplicateName => '这个姓名已经存在。';

  @override
  String get voteBestsRemoveCandidateMessage => '删除这位候选人吗？';

  @override
  String voteBestsVotesLabel(int votes) {
    return '票数：$votes';
  }

  @override
  String get voteBestsNoCandidatesYet => '还没有候选人。';

  @override
  String get voteBestsNoVotesYet => '还没有计票。';

  @override
  String voteBestsCurrentLeader(String name) {
    return '当前领先：$name';
  }

  @override
  String get voteBestsCurrentTie => '当前并列';

  @override
  String get onlineCountCloudSetup => '在线俱乐部设置';

  @override
  String get onlineCountBackendUrl => '后台网址';

  @override
  String get onlineCountClubName => '俱乐部名称';

  @override
  String get onlineCountClubSlug => '俱乐部代号';

  @override
  String get onlineCountAdminPin => '管理员密码';

  @override
  String get onlineCountCreateClub => '创建在线俱乐部';

  @override
  String get onlineCountClubReadyTitle => '在线俱乐部已准备好';

  @override
  String get onlineCountCheckOnlineStatus => '检查云端状态';

  @override
  String get onlineCountDeleteOnlineClub => '删除在线俱乐部';

  @override
  String get onlineCountResetDeviceSetup => '重置本机在线计票资料';

  @override
  String get onlineCountStartFreshDevice => '本机重新开始';

  @override
  String get onlineCountDangerZone => '危险操作';

  @override
  String get onlineCountDangerZoneHelp => '仅在在线设置错误，或本机不应继续使用已保存在线俱乐部时使用这些操作。';

  @override
  String get onlineCountSlugHelp => '用于永久投票链接。请使用小写字母、数字和连字符。';

  @override
  String get onlineCountSaveSetup => '保存设置';

  @override
  String get onlineCountSetupPurpose => '设置永久在线俱乐部身份和投票链接。';

  @override
  String get onlineCountAdminPinHelp => '管理员密码用于执委管理在线投票，请不要分享给投票者。';

  @override
  String get onlineCountAdminPinVoterNote => '投票者不需要这个密码。';

  @override
  String get onlineCountSetupButtonHelp =>
      '保存设置会把资料保存在本机。\n创建在线俱乐部会在云端投票服务中建立俱乐部。';

  @override
  String get onlineCountAdvancedSettings => '高级设置';

  @override
  String get onlineCountBackendUrlHelp => '普通俱乐部执委通常不需要修改后台网址。它主要用于测试或未来更换后台。';

  @override
  String get onlineCountOnlineClubLabel => '在线俱乐部';

  @override
  String get onlineCountClubCodeLabel => '俱乐部代号';

  @override
  String get onlineCountLinkReadyAfterCreate => '创建俱乐部后，永久投票链接即可使用。';

  @override
  String get onlineCountClubReady => '在线俱乐部已准备好。';

  @override
  String get onlineCountCurrentMeeting => '当前会议';

  @override
  String get onlineCountMeetingExplanation =>
      '每次会议都有独立的投票场次。先创建会议并开放会议，然后一次只开放一个奖项投票。';

  @override
  String get onlineCountMeetingStep1Title => '步骤一：创建会议';

  @override
  String get onlineCountMeetingStep1Body => '准备今天的投票场次。';

  @override
  String get onlineCountMeetingStep2Title => '步骤二：开放会议';

  @override
  String get onlineCountMeetingStep2Body => '允许开始各奖项投票。';

  @override
  String get onlineCountMeetingStep3Title => '步骤三：开放一个奖项投票';

  @override
  String get onlineCountMeetingStep3Body => '会员使用同一个链接投票。';

  @override
  String get onlineCountMeetingStep4Title => '步骤四：结束会议';

  @override
  String get onlineCountMeetingStep4Body => '停止投票并确认最终结果。';

  @override
  String get onlineCountMeetingTitle => '会议名称';

  @override
  String get onlineCountMeetingDate => '会议日期';

  @override
  String get onlineCountCreateMeeting => '创建会议';

  @override
  String get onlineCountCreateCurrentMeeting => '创建当前会议';

  @override
  String get onlineCountNoCurrentMeeting => '当前没有会议';

  @override
  String get onlineCountDeleteCurrentMeeting => '删除当前会议';

  @override
  String get onlineCountOpenMeeting => '开放会议';

  @override
  String get onlineCountCloseMeeting => '结束会议';

  @override
  String get onlineCountCandidateSetup => '候选人设置';

  @override
  String get onlineCountSaveBestSpeakerCandidates => '保存最佳演讲候选人';

  @override
  String get onlineCountSaveTableTopicsCandidates => '保存即席演讲候选人';

  @override
  String get onlineCountSaveEvaluatorCandidates => '保存点评候选人';

  @override
  String get onlineCountVotingRound => '投票轮次';

  @override
  String get onlineCountOpenVoting => '开放投票';

  @override
  String get onlineCountCloseVoting => '结束投票';

  @override
  String get onlineCountVotesReceived => '已收到票数';

  @override
  String get onlineCountFinalVotes => '最终票数';

  @override
  String get onlineCountRefreshVoteCount => '刷新票数';

  @override
  String get onlineCountVoteCountsAutoRefresh => '票数每 5 秒自动刷新。';

  @override
  String get onlineCountVoteCountsLastUpdated => '最后更新：刚刚';

  @override
  String get onlineCountCouldNotRefreshVoteCount => '无法刷新票数。';

  @override
  String get onlineCountVotingLink => '投票链接';

  @override
  String get onlineCountPermanentVotingQr => '永久投票二维码';

  @override
  String get onlineCountPermanentVotingQrHelp =>
      '每次会议都可以使用同一个二维码。投票页面只会显示当前开放的奖项投票。';

  @override
  String get onlineCountQrScheduleShareHelp =>
      '可将此二维码分享给制作会议流程表的人。此二维码属于在线俱乐部，可重复用于每次会议。';

  @override
  String get onlineCountQrLifecycleReminder =>
      '删除当前会议不会改变此二维码。本机重新开始或删除在线俱乐部后，旧二维码将不能继续使用。';

  @override
  String get onlineCountChineseVotingPage => '中文投票页面';

  @override
  String get onlineCountEnglishVotingPage => '英文投票页面';

  @override
  String get onlineCountAutoLanguage => '自动语言';

  @override
  String get onlineCountQrChinese => '中文';

  @override
  String get onlineCountQrEnglish => 'English';

  @override
  String get onlineCountQrAuto => 'Auto';

  @override
  String get onlineCountCopyQrLink => '复制二维码链接';

  @override
  String get onlineCountShareQrCode => '分享二维码';

  @override
  String get onlineCountCopyPrintText => '复制打印文字';

  @override
  String get onlineCountEnterClubCodeFirst => '请先填写并保存俱乐部代号。';

  @override
  String get onlineCountCompleteSetupFirst => '请先完成在线俱乐部设置。';

  @override
  String get onlineCountCopyChineseLink => '复制中文链接';

  @override
  String get onlineCountCopyEnglishLink => '复制英文链接';

  @override
  String get onlineCountCopyAutoLink => '复制自动语言链接';

  @override
  String get onlineCountResults => '结果';

  @override
  String get onlineCountRefreshResults => '刷新结果';

  @override
  String get onlineCountRefreshResultsFirst => '请先刷新结果。';

  @override
  String get onlineCountCopyResults => '复制结果';

  @override
  String get onlineCountDraft => '草稿';

  @override
  String get onlineCountOpen => '开放';

  @override
  String get onlineCountClosed => '已结束';

  @override
  String get onlineCountSessionOpen => '开放中';

  @override
  String get onlineCountDraftHelp => '会议已创建，但投票尚未开放。';

  @override
  String get onlineCountOpenHelp => '会议已开放。准备好后，请开放一个奖项投票。';

  @override
  String get onlineCountClosedHelp => '会议已结束，结果已最终确认。';

  @override
  String get onlineCountFinalResults => '最终结果';

  @override
  String get onlineCountResultsNotFinal => '结果尚未最终确认';

  @override
  String get onlineCountSaved => '已保存';

  @override
  String get onlineCountCopied => '已复制。';

  @override
  String get onlineCountQrReadyToShare => '二维码已准备分享。';

  @override
  String get onlineCountCouldNotShareQr => '无法分享二维码。';

  @override
  String get onlineCountPleaseCompleteSetup => '请先完成设置';

  @override
  String get onlineCountCouldNotConnect => '无法连接在线投票服务';

  @override
  String get onlineCountAnotherAwardOpen => '已有一个奖项投票正在开放';

  @override
  String get onlineCountCreateMeetingFirst => '请先创建会议。';

  @override
  String get onlineCountOpenMeetingFirst => '请先开放会议。';

  @override
  String get onlineCountAddCandidatesFirst => '请先添加候选人，再开放此项投票。';

  @override
  String get onlineCountClubMayExist => '在线俱乐部可能已经存在。请换一个俱乐部代号，或继续使用已保存的设置。';

  @override
  String get onlineCountOwnerAlreadyHasClub =>
      '本机在云端已有一个在线俱乐部。如需放弃旧在线俱乐部并创建新的，请使用“本机重新开始”。';

  @override
  String get onlineCountClubSlugExists => '这个俱乐部代号已经被使用，请换一个代号。';

  @override
  String get onlineCountCurrentMeetingExists => '当前已有一个会议。请先删除当前会议，再创建新的会议。';

  @override
  String get onlineCountOwnerOrAdminInvalid => '设备凭证或管理员密码不正确。';

  @override
  String get onlineCountCurrentMeetingDeleted => '当前会议已删除。';

  @override
  String get onlineCountOnlineClubDeleted => '在线俱乐部已删除。';

  @override
  String get onlineCountDeviceSetupReset => '本机在线计票设置已重置。';

  @override
  String get onlineCountStartedFresh => '本机在线计票已重新开始。';

  @override
  String get onlineCountTypeDeleteToContinue => '输入 DELETE 继续';

  @override
  String get onlineCountTypeResetToContinue => '输入 RESET 继续';

  @override
  String get onlineCountTypeFreshToContinue => '输入 FRESH 继续';

  @override
  String get onlineCountDeleteCurrentMeetingWarning =>
      '要删除当前在线会议吗？\n这会删除本次会议的候选人、投票和结果。\n请先复制或发送结果。';

  @override
  String get onlineCountDeleteOnlineClubWarning =>
      '要删除在线俱乐部吗？\n这会删除云端俱乐部、当前会议、候选人、投票和结果。\n此操作无法撤销。\n本机手动计票资料不会被删除。';

  @override
  String get onlineCountResetDeviceSetupWarning =>
      '这会清除本机保存的在线投票设置。\n不会删除云端记录。';

  @override
  String get onlineCountStartFreshTitle => '要重新开始吗？';

  @override
  String get onlineCountStartFreshWarning =>
      '这会让本机断开之前的在线俱乐部。\n旧的在线测试资料可能会保留在云端，直到自动过期。\n旧二维码不应继续使用。\n本机手动计票资料不会被删除。';

  @override
  String get onlineCountLegacySessionsWarning => '云端存在多个旧会议。当前显示最新会议。';

  @override
  String get onlineCountNoSessionYet => '请先创建会议，再设置候选人或开放投票。';

  @override
  String get onlineCountSessionId => '会议编号';

  @override
  String get onlineCountSessionStatus => '会议状态';

  @override
  String get onlineCountTechnicalDetails => '技术信息';

  @override
  String get onlineCountCandidateHint => '每行一位候选人';

  @override
  String get onlineCountNoResultsYet => '还没有加载结果。';

  @override
  String get onlineCountVotingLinkHelp => '每个奖项都使用同一个链接。请一次只开放一个奖项投票。';

  @override
  String onlineCountWinner(String name) {
    return '获奖者：$name';
  }

  @override
  String onlineCountTie(String names) {
    return '并列：$names';
  }

  @override
  String onlineCountVotes(int votes) {
    return '$votes 票';
  }

  @override
  String get onlineCountActionComplete => '完成';

  @override
  String get languageMenuLabel => '语言';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSimplifiedChinese => '简体中文';
}
