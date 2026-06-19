// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Speech Club';

  @override
  String get navTimer => 'Timer';

  @override
  String get navSpeaker => 'Speaker';

  @override
  String get navTopicSelection => 'Topic Selection';

  @override
  String get navTableTopics => 'Table Topics';

  @override
  String get navRoleAssistant => 'Role Assistant';

  @override
  String get navCommittees => 'Committees';

  @override
  String get navPathways => 'Pathways';

  @override
  String get buttonStart => 'Start';

  @override
  String get buttonStop => 'Stop';

  @override
  String get buttonReset => 'Reset';

  @override
  String get buttonSave => 'Save';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonDelete => 'Delete';

  @override
  String get buttonEdit => 'Edit';

  @override
  String get buttonAdd => 'Add';

  @override
  String get buttonDone => 'Done';

  @override
  String get buttonClose => 'Close';

  @override
  String get buttonBack => 'Back';

  @override
  String get buttonConfirm => 'Confirm';

  @override
  String get buttonOk => 'OK';

  @override
  String get buttonNext => 'Next';

  @override
  String get buttonPrevious => 'Previous';

  @override
  String get buttonRetry => 'Retry';

  @override
  String get buttonExit => 'Exit';

  @override
  String get labelNoData => 'No data';

  @override
  String get dialogExitTimerTitle => 'Exit Timer?';

  @override
  String get dialogExitTimerMessage => 'Timer is running. Exit anyway?';

  @override
  String get timerCustomPreset => 'Custom Preset';

  @override
  String get timerEditCustomPreset => 'Edit custom preset';

  @override
  String get timerStageGreen => 'Green';

  @override
  String get timerStageYellow => 'Yellow';

  @override
  String get timerStageRed => 'Red';

  @override
  String get timerStageOvertime => 'Overtime';

  @override
  String get timerUnitMin => 'Min';

  @override
  String get timerUnitSec => 'Sec';

  @override
  String get timerTestPanel => 'Test Panel';

  @override
  String get timerDing => 'Ding';

  @override
  String get timerOvertimeReachedHint =>
      'Overtime reached. Tap anywhere to reset.';

  @override
  String get timerPresetOrderError => 'Must be Green < Yellow < Red < Overtime';

  @override
  String get tableTopicsTitle => 'Table Topics';

  @override
  String get tableTopicsGenerate10 => 'Generate 10 Topics';

  @override
  String get tableTopicsEdit10 => 'Edit 10 Topics';

  @override
  String get tableTopicsPresenterMode => 'Presenter Mode';

  @override
  String get tableTopicsCustomTopics => 'Custom Topics';

  @override
  String get tableTopicsUseTheseTopics => 'Use These Topics';

  @override
  String get tableTopicsEnterCustomTopics => 'Enter up to 10 custom topics.';

  @override
  String tableTopicsTopicLabel(int number) {
    return 'Topic $number';
  }

  @override
  String get tableTopicsEditTopics => 'Edit Topics';

  @override
  String get tableTopicsCategoriesSelection => 'Categories';

  @override
  String get tableTopicsCustomTopicsSaved => 'Custom topics saved.';

  @override
  String get tableTopicsAddAtLeastOne => 'Please add at least one topic.';

  @override
  String get tableTopicsNoSetFound =>
      'No 10-topic set found. Return to setup and generate topics.';

  @override
  String get tableTopicsToggleUsedHint =>
      'Long press a tile to toggle used/unused.';

  @override
  String get tableTopicsPlaceholderTopic => '(Topic)';

  @override
  String get tableTopicsErrorPrefix => 'Error';

  @override
  String get tableTopicsCategoryDailyLife => 'Daily Life';

  @override
  String get tableTopicsCategoryFamily => 'Family';

  @override
  String get tableTopicsCategoryTravel => 'Travel';

  @override
  String get tableTopicsCategoryWorkCareer => 'Work & Career';

  @override
  String get tableTopicsCategoryFriendship => 'Friendship';

  @override
  String get tableTopicsCategoryHealthFitness => 'Health & Fitness';

  @override
  String get tableTopicsCategoryFood => 'Food';

  @override
  String get tableTopicsCategoryTechnology => 'Technology';

  @override
  String get tableTopicsCategoryMoney => 'Money';

  @override
  String get tableTopicsCategoryEducation => 'Education';

  @override
  String get tableTopicsCategoryHobbies => 'Hobbies';

  @override
  String get tableTopicsCategoryLeadership => 'Leadership';

  @override
  String get tableTopicsCategoryCommunication => 'Communication';

  @override
  String get tableTopicsCategoryValues => 'Values';

  @override
  String get tableTopicsCategoryCulture => 'Culture';

  @override
  String get tableTopicsCategoryFunHumor => 'Fun & Humor';

  @override
  String get tableTopicsCategoryEnglishSourceExpressions =>
      'English Source Expressions';

  @override
  String get tableTopicsCategoryChineseSourceExpressions =>
      'Chinese Source Expressions';

  @override
  String get flashcardsMySpeech => 'My Speech';

  @override
  String get flashcardsMySpeeches => 'My Speeches';

  @override
  String get flashcardsAddCard => 'Add Card';

  @override
  String get flashcardsEditCard => 'Edit Card';

  @override
  String get flashcardsPasteMultipleCards => 'Paste Multiple Cards';

  @override
  String get flashcardsEditMySpeech => 'Edit My Speech';

  @override
  String get flashcardsEditCards => 'Edit Cards';

  @override
  String get flashcardsStartPresentation => 'Start Presentation';

  @override
  String get flashcardsNoCardsYet => 'No cards yet. Please add cards first.';

  @override
  String get flashcardsEmptyState =>
      'No cards yet.\nTap \"Add Card\" to create your first one.';

  @override
  String get flashcardsMoveUp => 'Move up';

  @override
  String get flashcardsMoveDown => 'Move down';

  @override
  String get flashcardsPresenter => 'Presenter';

  @override
  String get flashcardsToggleTheme => 'Toggle theme';

  @override
  String get flashcardsNoCardsToPresent => 'No cards to present.';

  @override
  String get flashcardsPasteHint =>
      'Paste your speech here.\n\nUse blank lines to separate cards.';

  @override
  String get flashcardsCardHint => 'Type your card text...';

  @override
  String roleAssistantFailedToLoad(String error) {
    return 'Failed to load roles: $error';
  }

  @override
  String get roleAssistantNoRolesFound => 'No roles found.';

  @override
  String get roleAssistantRolePurpose => 'Role Purpose';

  @override
  String get roleAssistantChecklist => 'Checklist';

  @override
  String get roleAssistantBefore => 'Before';

  @override
  String get roleAssistantDuring => 'During';

  @override
  String get roleAssistantAfter => 'After';

  @override
  String get roleAssistantQuickTips => 'Quick Tips';

  @override
  String get roleAssistantExamplePhrasing => 'Example Phrasing';

  @override
  String get roleAssistantCopied => 'Copied';

  @override
  String get roleAssistantOpenTimerTool => 'Open Timer Tool';

  @override
  String get roleAssistantOpenTableTopics => 'Open Table Topics';

  @override
  String get roleAssistantOpenTool => 'Open Tool';

  @override
  String get roleAssistantOpenSpeakerFlashcard => 'Open Speaker Flashcard';

  @override
  String get roleAssistantTitleToastmasterOfTheDay => 'Toastmaster of the Day';

  @override
  String get roleAssistantTitleTimer => 'Timer';

  @override
  String get roleAssistantTitleTableTopicsMaster => 'Table Topics Master';

  @override
  String get roleAssistantTitleEvaluator => 'Evaluator';

  @override
  String get roleAssistantTitleLanguageEvaluator => 'Language Evaluator';

  @override
  String get roleAssistantTitleAhCounter => 'Ah-Counter';

  @override
  String get roleAssistantTitleSpeaker => 'Speaker';

  @override
  String get roleAssistantTitleGeneralEvaluator => 'General Evaluator';

  @override
  String get committeesTitle => 'Committees';

  @override
  String get committeesRolePurpose => 'Role Purpose';

  @override
  String get committeesKeyResponsibilities => 'Key Responsibilities';

  @override
  String get committeesQuickTips => 'Quick Tips';

  @override
  String get topicSelectionTitle => 'Topic Selection';

  @override
  String get topicSelectionIntro =>
      'Almost any topic can become a speech if it connects to your experience, feeling, or point of view.';

  @override
  String get topicSelectionCategoryPurpose => 'Category Purpose';

  @override
  String get topicSelectionTopicIdeas => 'Topic Ideas';

  @override
  String get topicSelectionHowToChoose => 'How to Choose';

  @override
  String get topicSelectionSpeechStructure => 'Speech Structure';

  @override
  String get topicSelectionOpeningLines => 'Opening Lines';

  @override
  String get pathwaysTitle => 'Pathways';

  @override
  String get pathwaysIntro =>
      'Pathways helps you grow step by step in speaking, confidence, leadership, and communication.';

  @override
  String get pathwaysBaseCampNote =>
      'Use this as a simple club guide. For official project details, check Toastmasters Base Camp.';

  @override
  String get pathwaysWhatThisPathBuilds => 'What This Path Builds';

  @override
  String get pathwaysGoodForMembers => 'Good For Members Who Want To';

  @override
  String get pathwaysTypicalSpeechFocus => 'Typical Speech Focus';

  @override
  String get pathwaysHowToStart => 'How to Start';

  @override
  String get pathwaysMentorTips => 'Mentor Tips';

  @override
  String get languageMenuLabel => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSimplifiedChinese => 'Simplified Chinese';
}
