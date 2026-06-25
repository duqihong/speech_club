import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Speech Club'**
  String get appTitle;

  /// No description provided for @navTimer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get navTimer;

  /// No description provided for @navSpeaker.
  ///
  /// In en, this message translates to:
  /// **'Speaker'**
  String get navSpeaker;

  /// No description provided for @navTopicSelection.
  ///
  /// In en, this message translates to:
  /// **'Topic Selection'**
  String get navTopicSelection;

  /// No description provided for @navTableTopics.
  ///
  /// In en, this message translates to:
  /// **'Table Topics'**
  String get navTableTopics;

  /// No description provided for @navRoleAssistant.
  ///
  /// In en, this message translates to:
  /// **'Role Assistant'**
  String get navRoleAssistant;

  /// No description provided for @navCommittees.
  ///
  /// In en, this message translates to:
  /// **'Committees'**
  String get navCommittees;

  /// No description provided for @navPathways.
  ///
  /// In en, this message translates to:
  /// **'Pathways'**
  String get navPathways;

  /// No description provided for @navVoteBests.
  ///
  /// In en, this message translates to:
  /// **'Vote Bests'**
  String get navVoteBests;

  /// No description provided for @buttonStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get buttonStart;

  /// No description provided for @buttonStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get buttonStop;

  /// No description provided for @buttonReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get buttonReset;

  /// No description provided for @buttonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get buttonSave;

  /// No description provided for @buttonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// No description provided for @buttonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get buttonDelete;

  /// No description provided for @buttonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get buttonEdit;

  /// No description provided for @buttonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get buttonAdd;

  /// No description provided for @buttonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get buttonDone;

  /// No description provided for @buttonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get buttonClose;

  /// No description provided for @buttonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get buttonBack;

  /// No description provided for @buttonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get buttonConfirm;

  /// No description provided for @buttonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get buttonOk;

  /// No description provided for @buttonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get buttonNext;

  /// No description provided for @buttonPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get buttonPrevious;

  /// No description provided for @buttonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get buttonRetry;

  /// No description provided for @buttonExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get buttonExit;

  /// No description provided for @labelNoData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get labelNoData;

  /// No description provided for @dialogExitTimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit Timer?'**
  String get dialogExitTimerTitle;

  /// No description provided for @dialogExitTimerMessage.
  ///
  /// In en, this message translates to:
  /// **'Timer is running. Exit anyway?'**
  String get dialogExitTimerMessage;

  /// No description provided for @timerCustomPreset.
  ///
  /// In en, this message translates to:
  /// **'Custom Preset'**
  String get timerCustomPreset;

  /// No description provided for @timerEditCustomPreset.
  ///
  /// In en, this message translates to:
  /// **'Edit custom preset'**
  String get timerEditCustomPreset;

  /// No description provided for @timerStageGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get timerStageGreen;

  /// No description provided for @timerStageYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get timerStageYellow;

  /// No description provided for @timerStageRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get timerStageRed;

  /// No description provided for @timerStageOvertime.
  ///
  /// In en, this message translates to:
  /// **'Overtime'**
  String get timerStageOvertime;

  /// No description provided for @timerUnitMin.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get timerUnitMin;

  /// No description provided for @timerUnitSec.
  ///
  /// In en, this message translates to:
  /// **'Sec'**
  String get timerUnitSec;

  /// No description provided for @timerTestPanel.
  ///
  /// In en, this message translates to:
  /// **'Test Panel'**
  String get timerTestPanel;

  /// No description provided for @timerDing.
  ///
  /// In en, this message translates to:
  /// **'Ding'**
  String get timerDing;

  /// No description provided for @timerOvertimeReachedHint.
  ///
  /// In en, this message translates to:
  /// **'Overtime reached. Tap anywhere to reset.'**
  String get timerOvertimeReachedHint;

  /// No description provided for @timerPresetOrderError.
  ///
  /// In en, this message translates to:
  /// **'Must be Green < Yellow < Red < Overtime'**
  String get timerPresetOrderError;

  /// No description provided for @tableTopicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Table Topics'**
  String get tableTopicsTitle;

  /// No description provided for @tableTopicsGenerate10.
  ///
  /// In en, this message translates to:
  /// **'Generate 10 Topics'**
  String get tableTopicsGenerate10;

  /// No description provided for @tableTopicsEdit10.
  ///
  /// In en, this message translates to:
  /// **'Edit 10 Topics'**
  String get tableTopicsEdit10;

  /// No description provided for @tableTopicsPresenterMode.
  ///
  /// In en, this message translates to:
  /// **'Presenter Mode'**
  String get tableTopicsPresenterMode;

  /// No description provided for @tableTopicsCustomTopics.
  ///
  /// In en, this message translates to:
  /// **'Custom Topics'**
  String get tableTopicsCustomTopics;

  /// No description provided for @tableTopicsUseTheseTopics.
  ///
  /// In en, this message translates to:
  /// **'Use These Topics'**
  String get tableTopicsUseTheseTopics;

  /// No description provided for @tableTopicsEnterCustomTopics.
  ///
  /// In en, this message translates to:
  /// **'Enter up to 10 custom topics.'**
  String get tableTopicsEnterCustomTopics;

  /// No description provided for @tableTopicsTopicLabel.
  ///
  /// In en, this message translates to:
  /// **'Topic {number}'**
  String tableTopicsTopicLabel(int number);

  /// No description provided for @tableTopicsEditTopics.
  ///
  /// In en, this message translates to:
  /// **'Edit Topics'**
  String get tableTopicsEditTopics;

  /// No description provided for @tableTopicsCategoriesSelection.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get tableTopicsCategoriesSelection;

  /// No description provided for @tableTopicsCustomTopicsSaved.
  ///
  /// In en, this message translates to:
  /// **'Custom topics saved.'**
  String get tableTopicsCustomTopicsSaved;

  /// No description provided for @tableTopicsAddAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one topic.'**
  String get tableTopicsAddAtLeastOne;

  /// No description provided for @tableTopicsNoSetFound.
  ///
  /// In en, this message translates to:
  /// **'No 10-topic set found. Return to setup and generate topics.'**
  String get tableTopicsNoSetFound;

  /// No description provided for @tableTopicsToggleUsedHint.
  ///
  /// In en, this message translates to:
  /// **'Long press a tile to toggle used/unused.'**
  String get tableTopicsToggleUsedHint;

  /// No description provided for @tableTopicsPlaceholderTopic.
  ///
  /// In en, this message translates to:
  /// **'(Topic)'**
  String get tableTopicsPlaceholderTopic;

  /// No description provided for @tableTopicsErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get tableTopicsErrorPrefix;

  /// No description provided for @tableTopicsCategoryCommunication.
  ///
  /// In en, this message translates to:
  /// **'Communication'**
  String get tableTopicsCategoryCommunication;

  /// No description provided for @tableTopicsCategoryDailyLife.
  ///
  /// In en, this message translates to:
  /// **'Daily Life'**
  String get tableTopicsCategoryDailyLife;

  /// No description provided for @tableTopicsCategoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get tableTopicsCategoryEducation;

  /// No description provided for @tableTopicsCategoryTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get tableTopicsCategoryTravel;

  /// No description provided for @tableTopicsCategoryWorkCareer.
  ///
  /// In en, this message translates to:
  /// **'Work & Career'**
  String get tableTopicsCategoryWorkCareer;

  /// No description provided for @tableTopicsCategoryEnglishOriginExpressions.
  ///
  /// In en, this message translates to:
  /// **'English-Origin Expressions'**
  String get tableTopicsCategoryEnglishOriginExpressions;

  /// No description provided for @tableTopicsCategoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get tableTopicsCategoryFood;

  /// No description provided for @tableTopicsCategoryHealthExercise.
  ///
  /// In en, this message translates to:
  /// **'Health & Exercise'**
  String get tableTopicsCategoryHealthExercise;

  /// No description provided for @tableTopicsCategoryChineseIdioms.
  ///
  /// In en, this message translates to:
  /// **'Chinese Idioms'**
  String get tableTopicsCategoryChineseIdioms;

  /// No description provided for @tableTopicsCategoryClassicalPoetryLines.
  ///
  /// In en, this message translates to:
  /// **'Classical Poetry Lines'**
  String get tableTopicsCategoryClassicalPoetryLines;

  /// No description provided for @flashcardsMySpeech.
  ///
  /// In en, this message translates to:
  /// **'My Speech'**
  String get flashcardsMySpeech;

  /// No description provided for @flashcardsMySpeeches.
  ///
  /// In en, this message translates to:
  /// **'My Speeches'**
  String get flashcardsMySpeeches;

  /// No description provided for @flashcardsAddCard.
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get flashcardsAddCard;

  /// No description provided for @flashcardsEditCard.
  ///
  /// In en, this message translates to:
  /// **'Edit Card'**
  String get flashcardsEditCard;

  /// No description provided for @flashcardsPasteMultipleCards.
  ///
  /// In en, this message translates to:
  /// **'Paste Multiple Cards'**
  String get flashcardsPasteMultipleCards;

  /// No description provided for @flashcardsEditMySpeech.
  ///
  /// In en, this message translates to:
  /// **'Edit My Speech'**
  String get flashcardsEditMySpeech;

  /// No description provided for @flashcardsEditCards.
  ///
  /// In en, this message translates to:
  /// **'Edit Cards'**
  String get flashcardsEditCards;

  /// No description provided for @flashcardsStartPresentation.
  ///
  /// In en, this message translates to:
  /// **'Start Presentation'**
  String get flashcardsStartPresentation;

  /// No description provided for @flashcardsNoCardsYet.
  ///
  /// In en, this message translates to:
  /// **'No cards yet. Please add cards first.'**
  String get flashcardsNoCardsYet;

  /// No description provided for @flashcardsEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No cards yet.\nTap \"Add Card\" to create your first one.'**
  String get flashcardsEmptyState;

  /// No description provided for @flashcardsMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get flashcardsMoveUp;

  /// No description provided for @flashcardsMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get flashcardsMoveDown;

  /// No description provided for @flashcardsPresenter.
  ///
  /// In en, this message translates to:
  /// **'Presenter'**
  String get flashcardsPresenter;

  /// No description provided for @flashcardsToggleTheme.
  ///
  /// In en, this message translates to:
  /// **'Toggle theme'**
  String get flashcardsToggleTheme;

  /// No description provided for @flashcardsNoCardsToPresent.
  ///
  /// In en, this message translates to:
  /// **'No cards to present.'**
  String get flashcardsNoCardsToPresent;

  /// No description provided for @flashcardsPasteHint.
  ///
  /// In en, this message translates to:
  /// **'Paste your speech here.\n\nUse blank lines to separate cards.'**
  String get flashcardsPasteHint;

  /// No description provided for @flashcardsCardHint.
  ///
  /// In en, this message translates to:
  /// **'Type your card text...'**
  String get flashcardsCardHint;

  /// No description provided for @roleAssistantFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load roles: {error}'**
  String roleAssistantFailedToLoad(String error);

  /// No description provided for @roleAssistantNoRolesFound.
  ///
  /// In en, this message translates to:
  /// **'No roles found.'**
  String get roleAssistantNoRolesFound;

  /// No description provided for @roleAssistantRolePurpose.
  ///
  /// In en, this message translates to:
  /// **'Role Purpose'**
  String get roleAssistantRolePurpose;

  /// No description provided for @roleAssistantChecklist.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get roleAssistantChecklist;

  /// No description provided for @roleAssistantBefore.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get roleAssistantBefore;

  /// No description provided for @roleAssistantDuring.
  ///
  /// In en, this message translates to:
  /// **'During'**
  String get roleAssistantDuring;

  /// No description provided for @roleAssistantAfter.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get roleAssistantAfter;

  /// No description provided for @roleAssistantQuickTips.
  ///
  /// In en, this message translates to:
  /// **'Quick Tips'**
  String get roleAssistantQuickTips;

  /// No description provided for @roleAssistantExamplePhrasing.
  ///
  /// In en, this message translates to:
  /// **'Example Phrasing'**
  String get roleAssistantExamplePhrasing;

  /// No description provided for @roleAssistantCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get roleAssistantCopied;

  /// No description provided for @roleAssistantOpenTimerTool.
  ///
  /// In en, this message translates to:
  /// **'Open Timer Tool'**
  String get roleAssistantOpenTimerTool;

  /// No description provided for @roleAssistantOpenTableTopics.
  ///
  /// In en, this message translates to:
  /// **'Open Table Topics'**
  String get roleAssistantOpenTableTopics;

  /// No description provided for @roleAssistantOpenTool.
  ///
  /// In en, this message translates to:
  /// **'Open Tool'**
  String get roleAssistantOpenTool;

  /// No description provided for @roleAssistantOpenSpeakerFlashcard.
  ///
  /// In en, this message translates to:
  /// **'Open Speaker Flashcard'**
  String get roleAssistantOpenSpeakerFlashcard;

  /// No description provided for @roleAssistantTitleToastmasterOfTheDay.
  ///
  /// In en, this message translates to:
  /// **'Toastmaster of the Day'**
  String get roleAssistantTitleToastmasterOfTheDay;

  /// No description provided for @roleAssistantTitleTimer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get roleAssistantTitleTimer;

  /// No description provided for @roleAssistantTitleTableTopicsMaster.
  ///
  /// In en, this message translates to:
  /// **'Table Topics Master'**
  String get roleAssistantTitleTableTopicsMaster;

  /// No description provided for @roleAssistantTitleEvaluator.
  ///
  /// In en, this message translates to:
  /// **'Evaluator'**
  String get roleAssistantTitleEvaluator;

  /// No description provided for @roleAssistantTitleLanguageEvaluator.
  ///
  /// In en, this message translates to:
  /// **'Language Evaluator'**
  String get roleAssistantTitleLanguageEvaluator;

  /// No description provided for @roleAssistantTitleAhCounter.
  ///
  /// In en, this message translates to:
  /// **'Ah-Counter'**
  String get roleAssistantTitleAhCounter;

  /// No description provided for @roleAssistantTitleSpeaker.
  ///
  /// In en, this message translates to:
  /// **'Speaker'**
  String get roleAssistantTitleSpeaker;

  /// No description provided for @roleAssistantTitleGeneralEvaluator.
  ///
  /// In en, this message translates to:
  /// **'General Evaluator'**
  String get roleAssistantTitleGeneralEvaluator;

  /// No description provided for @committeesTitle.
  ///
  /// In en, this message translates to:
  /// **'Committees'**
  String get committeesTitle;

  /// No description provided for @committeesRolePurpose.
  ///
  /// In en, this message translates to:
  /// **'Role Purpose'**
  String get committeesRolePurpose;

  /// No description provided for @committeesKeyResponsibilities.
  ///
  /// In en, this message translates to:
  /// **'Key Responsibilities'**
  String get committeesKeyResponsibilities;

  /// No description provided for @committeesQuickTips.
  ///
  /// In en, this message translates to:
  /// **'Quick Tips'**
  String get committeesQuickTips;

  /// No description provided for @topicSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Topic Selection'**
  String get topicSelectionTitle;

  /// No description provided for @topicSelectionIntro.
  ///
  /// In en, this message translates to:
  /// **'Almost any topic can become a speech if it connects to your experience, feeling, or point of view.'**
  String get topicSelectionIntro;

  /// No description provided for @topicSelectionCategoryPurpose.
  ///
  /// In en, this message translates to:
  /// **'Category Purpose'**
  String get topicSelectionCategoryPurpose;

  /// No description provided for @topicSelectionTopicIdeas.
  ///
  /// In en, this message translates to:
  /// **'Topic Ideas'**
  String get topicSelectionTopicIdeas;

  /// No description provided for @topicSelectionHowToChoose.
  ///
  /// In en, this message translates to:
  /// **'How to Choose'**
  String get topicSelectionHowToChoose;

  /// No description provided for @topicSelectionSpeechStructure.
  ///
  /// In en, this message translates to:
  /// **'Speech Structure'**
  String get topicSelectionSpeechStructure;

  /// No description provided for @topicSelectionOpeningLines.
  ///
  /// In en, this message translates to:
  /// **'Opening Lines'**
  String get topicSelectionOpeningLines;

  /// No description provided for @pathwaysTitle.
  ///
  /// In en, this message translates to:
  /// **'Pathways'**
  String get pathwaysTitle;

  /// No description provided for @pathwaysIntro.
  ///
  /// In en, this message translates to:
  /// **'Pathways helps you grow step by step in speaking, confidence, leadership, and communication.'**
  String get pathwaysIntro;

  /// No description provided for @pathwaysBaseCampNote.
  ///
  /// In en, this message translates to:
  /// **'Use this as a simple club guide. For official project details, check Toastmasters Base Camp.'**
  String get pathwaysBaseCampNote;

  /// No description provided for @pathwaysWhatThisPathBuilds.
  ///
  /// In en, this message translates to:
  /// **'What This Path Builds'**
  String get pathwaysWhatThisPathBuilds;

  /// No description provided for @pathwaysGoodForMembers.
  ///
  /// In en, this message translates to:
  /// **'Good For Members Who Want To'**
  String get pathwaysGoodForMembers;

  /// No description provided for @pathwaysTypicalSpeechFocus.
  ///
  /// In en, this message translates to:
  /// **'Typical Speech Focus'**
  String get pathwaysTypicalSpeechFocus;

  /// No description provided for @pathwaysHowToStart.
  ///
  /// In en, this message translates to:
  /// **'How to Start'**
  String get pathwaysHowToStart;

  /// No description provided for @pathwaysMentorTips.
  ///
  /// In en, this message translates to:
  /// **'Mentor Tips'**
  String get pathwaysMentorTips;

  /// No description provided for @voteBestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Vote Bests'**
  String get voteBestsTitle;

  /// No description provided for @voteBestsModeIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to count meeting award votes.'**
  String get voteBestsModeIntro;

  /// No description provided for @voteBestsManualCount.
  ///
  /// In en, this message translates to:
  /// **'Manual Count'**
  String get voteBestsManualCount;

  /// No description provided for @voteBestsManualCountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Count votes locally on this device.'**
  String get voteBestsManualCountSubtitle;

  /// No description provided for @voteBestsOnlineCount.
  ///
  /// In en, this message translates to:
  /// **'Online Count'**
  String get voteBestsOnlineCount;

  /// No description provided for @voteBestsOnlineCountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Cloud-supported voting is pending design.'**
  String get voteBestsOnlineCountSubtitle;

  /// No description provided for @voteBestsOnlineDescription.
  ///
  /// In en, this message translates to:
  /// **'Online voting will be designed later. It may support cloud counting, meeting links, or QR-based voting.'**
  String get voteBestsOnlineDescription;

  /// No description provided for @voteBestsOnlineNote.
  ///
  /// In en, this message translates to:
  /// **'For now, please use Manual Count.'**
  String get voteBestsOnlineNote;

  /// No description provided for @voteBestsGoToManualCount.
  ///
  /// In en, this message translates to:
  /// **'Go to Manual Count'**
  String get voteBestsGoToManualCount;

  /// No description provided for @voteBestsSendResultsToPresident.
  ///
  /// In en, this message translates to:
  /// **'Send Results to President'**
  String get voteBestsSendResultsToPresident;

  /// No description provided for @voteBestsCopyResults.
  ///
  /// In en, this message translates to:
  /// **'Copy Results'**
  String get voteBestsCopyResults;

  /// No description provided for @voteBestsPresidentContact.
  ///
  /// In en, this message translates to:
  /// **'President Contact'**
  String get voteBestsPresidentContact;

  /// No description provided for @voteBestsContactNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get voteBestsContactNotSet;

  /// No description provided for @voteBestsPresidentName.
  ///
  /// In en, this message translates to:
  /// **'President name'**
  String get voteBestsPresidentName;

  /// No description provided for @voteBestsPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get voteBestsPhoneNumber;

  /// No description provided for @voteBestsPresidentNameError.
  ///
  /// In en, this message translates to:
  /// **'Please enter president name.'**
  String get voteBestsPresidentNameError;

  /// No description provided for @voteBestsPhoneNumberError.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number.'**
  String get voteBestsPhoneNumberError;

  /// No description provided for @voteBestsMissingContactMessage.
  ///
  /// In en, this message translates to:
  /// **'President contact is not set. Please add president name and phone number first.'**
  String get voteBestsMissingContactMessage;

  /// No description provided for @voteBestsMissingPresidentPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please set the president phone number first.'**
  String get voteBestsMissingPresidentPhoneNumber;

  /// No description provided for @voteBestsSetNow.
  ///
  /// In en, this message translates to:
  /// **'Set Now'**
  String get voteBestsSetNow;

  /// No description provided for @voteBestsResultsCopied.
  ///
  /// In en, this message translates to:
  /// **'Results copied. You can paste them into SMS or WhatsApp.'**
  String get voteBestsResultsCopied;

  /// No description provided for @voteBestsWhatsAppOpened.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp opened. Please review and send the results.'**
  String get voteBestsWhatsAppOpened;

  /// No description provided for @voteBestsWhatsAppOpenFailedCopied.
  ///
  /// In en, this message translates to:
  /// **'Could not open WhatsApp. Results copied instead.'**
  String get voteBestsWhatsAppOpenFailedCopied;

  /// No description provided for @voteBestsIntro.
  ///
  /// In en, this message translates to:
  /// **'Use this as a simple local tally tool for meeting awards. It does not collect online votes.'**
  String get voteBestsIntro;

  /// No description provided for @voteBestsAwardSummary.
  ///
  /// In en, this message translates to:
  /// **'{candidateCount} candidates · {voteCount} votes'**
  String voteBestsAwardSummary(int candidateCount, int voteCount);

  /// No description provided for @voteBestsResetMeetingVotes.
  ///
  /// In en, this message translates to:
  /// **'Reset Meeting Votes'**
  String get voteBestsResetMeetingVotes;

  /// No description provided for @voteBestsResetConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Reset all candidates and votes for this meeting?'**
  String get voteBestsResetConfirmMessage;

  /// No description provided for @voteBestsDetailHelp.
  ///
  /// In en, this message translates to:
  /// **'Add candidates, then tap +1 when a vote is counted.'**
  String get voteBestsDetailHelp;

  /// No description provided for @voteBestsCandidates.
  ///
  /// In en, this message translates to:
  /// **'Candidates'**
  String get voteBestsCandidates;

  /// No description provided for @voteBestsResults.
  ///
  /// In en, this message translates to:
  /// **'Current Results'**
  String get voteBestsResults;

  /// No description provided for @voteBestsAddCandidate.
  ///
  /// In en, this message translates to:
  /// **'Add Candidate'**
  String get voteBestsAddCandidate;

  /// No description provided for @voteBestsCandidateName.
  ///
  /// In en, this message translates to:
  /// **'Candidate name'**
  String get voteBestsCandidateName;

  /// No description provided for @voteBestsPleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name.'**
  String get voteBestsPleaseEnterName;

  /// No description provided for @voteBestsDuplicateName.
  ///
  /// In en, this message translates to:
  /// **'This name already exists.'**
  String get voteBestsDuplicateName;

  /// No description provided for @voteBestsRemoveCandidateMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove this candidate?'**
  String get voteBestsRemoveCandidateMessage;

  /// No description provided for @voteBestsVotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Votes: {votes}'**
  String voteBestsVotesLabel(int votes);

  /// No description provided for @voteBestsNoCandidatesYet.
  ///
  /// In en, this message translates to:
  /// **'No candidates yet.'**
  String get voteBestsNoCandidatesYet;

  /// No description provided for @voteBestsNoVotesYet.
  ///
  /// In en, this message translates to:
  /// **'No votes counted yet.'**
  String get voteBestsNoVotesYet;

  /// No description provided for @voteBestsCurrentLeader.
  ///
  /// In en, this message translates to:
  /// **'Current leader: {name}'**
  String voteBestsCurrentLeader(String name);

  /// No description provided for @voteBestsCurrentTie.
  ///
  /// In en, this message translates to:
  /// **'Current tie'**
  String get voteBestsCurrentTie;

  /// No description provided for @languageMenuLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageMenuLabel;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSimplifiedChinese.
  ///
  /// In en, this message translates to:
  /// **'Simplified Chinese'**
  String get languageSimplifiedChinese;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
