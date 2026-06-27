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
  /// **'Create cloud voting rounds and collect online votes.'**
  String get voteBestsOnlineCountSubtitle;

  /// No description provided for @voteBestsOnlineDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a cloud meeting, open one award round at a time, and share the voting link.'**
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

  /// No description provided for @onlineCountCloudSetup.
  ///
  /// In en, this message translates to:
  /// **'Online Club Setup'**
  String get onlineCountCloudSetup;

  /// No description provided for @onlineCountBackendUrl.
  ///
  /// In en, this message translates to:
  /// **'Backend URL'**
  String get onlineCountBackendUrl;

  /// No description provided for @onlineCountClubName.
  ///
  /// In en, this message translates to:
  /// **'Club Name'**
  String get onlineCountClubName;

  /// No description provided for @onlineCountClubSlug.
  ///
  /// In en, this message translates to:
  /// **'Club Code'**
  String get onlineCountClubSlug;

  /// No description provided for @onlineCountAdminPin.
  ///
  /// In en, this message translates to:
  /// **'Admin PIN'**
  String get onlineCountAdminPin;

  /// No description provided for @onlineCountCreateClub.
  ///
  /// In en, this message translates to:
  /// **'Create Online Club'**
  String get onlineCountCreateClub;

  /// No description provided for @onlineCountClubReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Online Club Ready'**
  String get onlineCountClubReadyTitle;

  /// No description provided for @onlineCountCheckOnlineStatus.
  ///
  /// In en, this message translates to:
  /// **'Check Online Status'**
  String get onlineCountCheckOnlineStatus;

  /// No description provided for @onlineCountCheckOnlineStatusHelp.
  ///
  /// In en, this message translates to:
  /// **'Use this only if the screen looks out of sync with online voting.'**
  String get onlineCountCheckOnlineStatusHelp;

  /// No description provided for @onlineCountDeleteOnlineClub.
  ///
  /// In en, this message translates to:
  /// **'Delete Online Club'**
  String get onlineCountDeleteOnlineClub;

  /// No description provided for @onlineCountResetDeviceSetup.
  ///
  /// In en, this message translates to:
  /// **'Reset Online Count on This Device'**
  String get onlineCountResetDeviceSetup;

  /// No description provided for @onlineCountStartFreshDevice.
  ///
  /// In en, this message translates to:
  /// **'Start Fresh on This Device'**
  String get onlineCountStartFreshDevice;

  /// No description provided for @onlineCountDangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get onlineCountDangerZone;

  /// No description provided for @onlineCountDangerZoneHelp.
  ///
  /// In en, this message translates to:
  /// **'Use only if setup is wrong or you want to stop using this online club.'**
  String get onlineCountDangerZoneHelp;

  /// No description provided for @onlineCountSlugHelp.
  ///
  /// In en, this message translates to:
  /// **'Used in the permanent voting link. Use lowercase letters, numbers, and hyphens.'**
  String get onlineCountSlugHelp;

  /// No description provided for @onlineCountSaveSetup.
  ///
  /// In en, this message translates to:
  /// **'Save Setup'**
  String get onlineCountSaveSetup;

  /// No description provided for @onlineCountSetupPurpose.
  ///
  /// In en, this message translates to:
  /// **'Enter your club name. The app will create a permanent online voting QR code for this club.'**
  String get onlineCountSetupPurpose;

  /// No description provided for @onlineCountAdminPinHelp.
  ///
  /// In en, this message translates to:
  /// **'Admin PIN is used by club officers to manage online voting. Do not share it with voters.'**
  String get onlineCountAdminPinHelp;

  /// No description provided for @onlineCountAdminPinVoterNote.
  ///
  /// In en, this message translates to:
  /// **'Voters do not need this PIN.'**
  String get onlineCountAdminPinVoterNote;

  /// No description provided for @onlineCountSetupButtonHelp.
  ///
  /// In en, this message translates to:
  /// **'Save Setup stores these details on this device.\nCreate Online Club creates the club in the online voting service.'**
  String get onlineCountSetupButtonHelp;

  /// No description provided for @onlineCountAdvancedSettings.
  ///
  /// In en, this message translates to:
  /// **'Advanced Settings'**
  String get onlineCountAdvancedSettings;

  /// No description provided for @onlineCountAdvancedSettingsHelp.
  ///
  /// In en, this message translates to:
  /// **'Use this only if online setup is stuck or this device already has an old online club.'**
  String get onlineCountAdvancedSettingsHelp;

  /// No description provided for @onlineCountBackendUrlHelp.
  ///
  /// In en, this message translates to:
  /// **'Normal club officers should not need to edit the Backend URL. It is mainly for testing or future backend changes.'**
  String get onlineCountBackendUrlHelp;

  /// No description provided for @onlineCountOnlineClubLabel.
  ///
  /// In en, this message translates to:
  /// **'Club'**
  String get onlineCountOnlineClubLabel;

  /// No description provided for @onlineCountClubCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Club code'**
  String get onlineCountClubCodeLabel;

  /// No description provided for @onlineCountVotingLinkAvailableBelow.
  ///
  /// In en, this message translates to:
  /// **'Voting QR is ready below.'**
  String get onlineCountVotingLinkAvailableBelow;

  /// No description provided for @onlineCountLinkReadyAfterCreate.
  ///
  /// In en, this message translates to:
  /// **'Permanent voting link is ready after the club is created.'**
  String get onlineCountLinkReadyAfterCreate;

  /// No description provided for @onlineCountClubReady.
  ///
  /// In en, this message translates to:
  /// **'Online club is ready.'**
  String get onlineCountClubReady;

  /// No description provided for @onlineCountCurrentStatus.
  ///
  /// In en, this message translates to:
  /// **'Current Status'**
  String get onlineCountCurrentStatus;

  /// No description provided for @onlineCountCurrentMeeting.
  ///
  /// In en, this message translates to:
  /// **'Current Meeting'**
  String get onlineCountCurrentMeeting;

  /// No description provided for @onlineCountMeetingOpenTitle.
  ///
  /// In en, this message translates to:
  /// **'Meeting Open'**
  String get onlineCountMeetingOpenTitle;

  /// No description provided for @onlineCountMeetingClosedTitle.
  ///
  /// In en, this message translates to:
  /// **'Meeting Closed'**
  String get onlineCountMeetingClosedTitle;

  /// No description provided for @onlineCountNextStep.
  ///
  /// In en, this message translates to:
  /// **'Next step'**
  String get onlineCountNextStep;

  /// No description provided for @onlineCountNextStepAddCandidatesShort.
  ///
  /// In en, this message translates to:
  /// **'Add candidates'**
  String get onlineCountNextStepAddCandidatesShort;

  /// No description provided for @onlineCountCurrentVote.
  ///
  /// In en, this message translates to:
  /// **'Current vote'**
  String get onlineCountCurrentVote;

  /// No description provided for @onlineCountNotCreated.
  ///
  /// In en, this message translates to:
  /// **'Not created'**
  String get onlineCountNotCreated;

  /// No description provided for @onlineCountNotOpened.
  ///
  /// In en, this message translates to:
  /// **'Not opened'**
  String get onlineCountNotOpened;

  /// No description provided for @onlineCountResultsAreFinal.
  ///
  /// In en, this message translates to:
  /// **'Results are final'**
  String get onlineCountResultsAreFinal;

  /// No description provided for @onlineCountNextStepAddCandidates.
  ///
  /// In en, this message translates to:
  /// **'Add candidates, then open meeting'**
  String get onlineCountNextStepAddCandidates;

  /// No description provided for @onlineCountNextStepCloseVoting.
  ///
  /// In en, this message translates to:
  /// **'Close voting when ready'**
  String get onlineCountNextStepCloseVoting;

  /// No description provided for @onlineCountNextStepOpenNextVotingRound.
  ///
  /// In en, this message translates to:
  /// **'Open the next voting round'**
  String get onlineCountNextStepOpenNextVotingRound;

  /// No description provided for @onlineCountNextStepRefreshAndSendResults.
  ///
  /// In en, this message translates to:
  /// **'Refresh and send results'**
  String get onlineCountNextStepRefreshAndSendResults;

  /// No description provided for @onlineCountNextStepSendOrDelete.
  ///
  /// In en, this message translates to:
  /// **'Send results or delete meeting'**
  String get onlineCountNextStepSendOrDelete;

  /// No description provided for @onlineCountAllVotingRoundsClosed.
  ///
  /// In en, this message translates to:
  /// **'All voting rounds are closed.'**
  String get onlineCountAllVotingRoundsClosed;

  /// No description provided for @onlineCountAllVotingRoundsClosedFinalize.
  ///
  /// In en, this message translates to:
  /// **'All voting rounds are closed. Close the voting session to finalize results.'**
  String get onlineCountAllVotingRoundsClosedFinalize;

  /// No description provided for @onlineCountMeetingExplanation.
  ///
  /// In en, this message translates to:
  /// **'Each meeting has its own voting session. Create a meeting, open it, then open one award vote at a time.'**
  String get onlineCountMeetingExplanation;

  /// No description provided for @onlineCountMeetingStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Step 1: Create Meeting'**
  String get onlineCountMeetingStep1Title;

  /// No description provided for @onlineCountMeetingStep1Body.
  ///
  /// In en, this message translates to:
  /// **'Prepare today’s voting session.'**
  String get onlineCountMeetingStep1Body;

  /// No description provided for @onlineCountMeetingStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Step 2: Open Voting Session'**
  String get onlineCountMeetingStep2Title;

  /// No description provided for @onlineCountMeetingStep2Body.
  ///
  /// In en, this message translates to:
  /// **'Allow award voting rounds to start.'**
  String get onlineCountMeetingStep2Body;

  /// No description provided for @onlineCountMeetingStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Step 3: Open one award voting round'**
  String get onlineCountMeetingStep3Title;

  /// No description provided for @onlineCountMeetingStep3Body.
  ///
  /// In en, this message translates to:
  /// **'Members vote using the same link.'**
  String get onlineCountMeetingStep3Body;

  /// No description provided for @onlineCountMeetingStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Step 4: Close Voting Session'**
  String get onlineCountMeetingStep4Title;

  /// No description provided for @onlineCountMeetingStep4Body.
  ///
  /// In en, this message translates to:
  /// **'Finish voting and make results final.'**
  String get onlineCountMeetingStep4Body;

  /// No description provided for @onlineCountMeetingTitle.
  ///
  /// In en, this message translates to:
  /// **'Meeting Title'**
  String get onlineCountMeetingTitle;

  /// No description provided for @onlineCountMeetingDate.
  ///
  /// In en, this message translates to:
  /// **'Meeting Date'**
  String get onlineCountMeetingDate;

  /// No description provided for @onlineCountCreateMeeting.
  ///
  /// In en, this message translates to:
  /// **'Create Meeting'**
  String get onlineCountCreateMeeting;

  /// No description provided for @onlineCountCreateCurrentMeeting.
  ///
  /// In en, this message translates to:
  /// **'Create Current Meeting'**
  String get onlineCountCreateCurrentMeeting;

  /// No description provided for @onlineCountNoCurrentMeeting.
  ///
  /// In en, this message translates to:
  /// **'No current meeting'**
  String get onlineCountNoCurrentMeeting;

  /// No description provided for @onlineCountNoMeetingHelper.
  ///
  /// In en, this message translates to:
  /// **'Create a meeting before adding candidates or opening voting.'**
  String get onlineCountNoMeetingHelper;

  /// No description provided for @onlineCountDraftMeetingHelper.
  ///
  /// In en, this message translates to:
  /// **'Add candidates, then open the meeting.'**
  String get onlineCountDraftMeetingHelper;

  /// No description provided for @onlineCountOpenMeetingHelper.
  ///
  /// In en, this message translates to:
  /// **'Open one award voting round at a time. Close the voting session when all voting is finished.'**
  String get onlineCountOpenMeetingHelper;

  /// No description provided for @onlineCountClosedMeetingHelper.
  ///
  /// In en, this message translates to:
  /// **'Results are final. Send or copy results before deleting the meeting.'**
  String get onlineCountClosedMeetingHelper;

  /// No description provided for @onlineCountReadyToStartVoting.
  ///
  /// In en, this message translates to:
  /// **'Ready for award voting?'**
  String get onlineCountReadyToStartVoting;

  /// No description provided for @onlineCountAddAllCandidatesBeforeOpening.
  ///
  /// In en, this message translates to:
  /// **'Save candidates for all awards before opening the voting session.'**
  String get onlineCountAddAllCandidatesBeforeOpening;

  /// No description provided for @onlineCountDeleteCurrentMeeting.
  ///
  /// In en, this message translates to:
  /// **'Delete Current Meeting'**
  String get onlineCountDeleteCurrentMeeting;

  /// No description provided for @onlineCountOpenMeeting.
  ///
  /// In en, this message translates to:
  /// **'Open Voting Session'**
  String get onlineCountOpenMeeting;

  /// No description provided for @onlineCountCloseMeeting.
  ///
  /// In en, this message translates to:
  /// **'Close Voting Session'**
  String get onlineCountCloseMeeting;

  /// No description provided for @onlineCountCandidateSetup.
  ///
  /// In en, this message translates to:
  /// **'Candidate Setup'**
  String get onlineCountCandidateSetup;

  /// No description provided for @onlineCountSaveBestSpeakerCandidates.
  ///
  /// In en, this message translates to:
  /// **'Save Best Speaker Candidates'**
  String get onlineCountSaveBestSpeakerCandidates;

  /// No description provided for @onlineCountSaveTableTopicsCandidates.
  ///
  /// In en, this message translates to:
  /// **'Save Table Topics Candidates'**
  String get onlineCountSaveTableTopicsCandidates;

  /// No description provided for @onlineCountSaveEvaluatorCandidates.
  ///
  /// In en, this message translates to:
  /// **'Save Evaluator Candidates'**
  String get onlineCountSaveEvaluatorCandidates;

  /// No description provided for @onlineCountBestSpeakerCandidatesSaved.
  ///
  /// In en, this message translates to:
  /// **'Best Speaker Candidates Saved'**
  String get onlineCountBestSpeakerCandidatesSaved;

  /// No description provided for @onlineCountTableTopicsCandidatesSaved.
  ///
  /// In en, this message translates to:
  /// **'Table Topics Candidates Saved'**
  String get onlineCountTableTopicsCandidatesSaved;

  /// No description provided for @onlineCountEvaluatorCandidatesSaved.
  ///
  /// In en, this message translates to:
  /// **'Evaluator Candidates Saved'**
  String get onlineCountEvaluatorCandidatesSaved;

  /// No description provided for @onlineCountVotingRound.
  ///
  /// In en, this message translates to:
  /// **'Voting Round'**
  String get onlineCountVotingRound;

  /// No description provided for @onlineCountOpenVoting.
  ///
  /// In en, this message translates to:
  /// **'Open Voting'**
  String get onlineCountOpenVoting;

  /// No description provided for @onlineCountCloseVoting.
  ///
  /// In en, this message translates to:
  /// **'Close Voting'**
  String get onlineCountCloseVoting;

  /// No description provided for @onlineCountVotesReceived.
  ///
  /// In en, this message translates to:
  /// **'Votes received'**
  String get onlineCountVotesReceived;

  /// No description provided for @onlineCountFinalVotes.
  ///
  /// In en, this message translates to:
  /// **'Final votes'**
  String get onlineCountFinalVotes;

  /// No description provided for @onlineCountAwardStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get onlineCountAwardStatusLabel;

  /// No description provided for @onlineCountRefreshVoteCount.
  ///
  /// In en, this message translates to:
  /// **'Refresh Vote Count'**
  String get onlineCountRefreshVoteCount;

  /// No description provided for @onlineCountVoteCountsAutoRefresh.
  ///
  /// In en, this message translates to:
  /// **'Vote counts auto-refresh every 5 seconds.'**
  String get onlineCountVoteCountsAutoRefresh;

  /// No description provided for @onlineCountVoteCountsLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: just now'**
  String get onlineCountVoteCountsLastUpdated;

  /// No description provided for @onlineCountOpenVotingRoundToReceiveVotes.
  ///
  /// In en, this message translates to:
  /// **'Open a voting round to start receiving votes.'**
  String get onlineCountOpenVotingRoundToReceiveVotes;

  /// No description provided for @onlineCountVoteCountingComplete.
  ///
  /// In en, this message translates to:
  /// **'Vote counting is complete for all rounds.'**
  String get onlineCountVoteCountingComplete;

  /// No description provided for @onlineCountCouldNotRefreshVoteCount.
  ///
  /// In en, this message translates to:
  /// **'Could not refresh vote count.'**
  String get onlineCountCouldNotRefreshVoteCount;

  /// No description provided for @onlineCountVotingLink.
  ///
  /// In en, this message translates to:
  /// **'Voting Link'**
  String get onlineCountVotingLink;

  /// No description provided for @onlineCountPermanentVotingQr.
  ///
  /// In en, this message translates to:
  /// **'Permanent Voting QR'**
  String get onlineCountPermanentVotingQr;

  /// No description provided for @onlineCountPermanentVotingQrHelp.
  ///
  /// In en, this message translates to:
  /// **'Reusable for every meeting.'**
  String get onlineCountPermanentVotingQrHelp;

  /// No description provided for @onlineCountQrScheduleShareHelp.
  ///
  /// In en, this message translates to:
  /// **'The voting page follows each voter’s phone language.'**
  String get onlineCountQrScheduleShareHelp;

  /// No description provided for @onlineCountQrLifecycleReminder.
  ///
  /// In en, this message translates to:
  /// **'Deleting a meeting keeps this QR. Deleting the club or starting fresh makes it unusable.'**
  String get onlineCountQrLifecycleReminder;

  /// No description provided for @onlineCountChineseVotingPage.
  ///
  /// In en, this message translates to:
  /// **'Chinese voting page'**
  String get onlineCountChineseVotingPage;

  /// No description provided for @onlineCountEnglishVotingPage.
  ///
  /// In en, this message translates to:
  /// **'English voting page'**
  String get onlineCountEnglishVotingPage;

  /// No description provided for @onlineCountAutoLanguage.
  ///
  /// In en, this message translates to:
  /// **'Auto language'**
  String get onlineCountAutoLanguage;

  /// No description provided for @onlineCountQrChinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get onlineCountQrChinese;

  /// No description provided for @onlineCountQrEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get onlineCountQrEnglish;

  /// No description provided for @onlineCountQrAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get onlineCountQrAuto;

  /// No description provided for @onlineCountCopyQrLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Voting Link'**
  String get onlineCountCopyQrLink;

  /// No description provided for @onlineCountShareQrCode.
  ///
  /// In en, this message translates to:
  /// **'Share QR Code'**
  String get onlineCountShareQrCode;

  /// No description provided for @onlineCountCopyPrintText.
  ///
  /// In en, this message translates to:
  /// **'Copy Print Text'**
  String get onlineCountCopyPrintText;

  /// No description provided for @onlineCountEnterClubCodeFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter and save a club code first.'**
  String get onlineCountEnterClubCodeFirst;

  /// No description provided for @onlineCountCompleteSetupFirst.
  ///
  /// In en, this message translates to:
  /// **'Please complete online club setup first.'**
  String get onlineCountCompleteSetupFirst;

  /// No description provided for @onlineCountCopyChineseLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Chinese Link'**
  String get onlineCountCopyChineseLink;

  /// No description provided for @onlineCountCopyEnglishLink.
  ///
  /// In en, this message translates to:
  /// **'Copy English Link'**
  String get onlineCountCopyEnglishLink;

  /// No description provided for @onlineCountCopyAutoLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Auto Link'**
  String get onlineCountCopyAutoLink;

  /// No description provided for @onlineCountResults.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get onlineCountResults;

  /// No description provided for @onlineCountRefreshResults.
  ///
  /// In en, this message translates to:
  /// **'Refresh Results'**
  String get onlineCountRefreshResults;

  /// No description provided for @onlineCountRefreshResultsFirst.
  ///
  /// In en, this message translates to:
  /// **'Please refresh results first.'**
  String get onlineCountRefreshResultsFirst;

  /// No description provided for @onlineCountRefreshResultsThenCheckFinal.
  ///
  /// In en, this message translates to:
  /// **'Tap Refresh Results first, then check the final results.'**
  String get onlineCountRefreshResultsThenCheckFinal;

  /// No description provided for @onlineCountCopyResults.
  ///
  /// In en, this message translates to:
  /// **'Copy Results'**
  String get onlineCountCopyResults;

  /// No description provided for @onlineCountDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get onlineCountDraft;

  /// No description provided for @onlineCountPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get onlineCountPreparing;

  /// No description provided for @onlineCountOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get onlineCountOpen;

  /// No description provided for @onlineCountClosed.
  ///
  /// In en, this message translates to:
  /// **'Voting Session Closed'**
  String get onlineCountClosed;

  /// No description provided for @onlineCountSessionOpen.
  ///
  /// In en, this message translates to:
  /// **'Voting Session Open'**
  String get onlineCountSessionOpen;

  /// No description provided for @onlineCountDraftHelp.
  ///
  /// In en, this message translates to:
  /// **'Meeting is prepared, but voting is not open yet.'**
  String get onlineCountDraftHelp;

  /// No description provided for @onlineCountOpenHelp.
  ///
  /// In en, this message translates to:
  /// **'Meeting is open. Open one award voting round when ready.'**
  String get onlineCountOpenHelp;

  /// No description provided for @onlineCountClosedHelp.
  ///
  /// In en, this message translates to:
  /// **'Voting session is closed. Results are final.'**
  String get onlineCountClosedHelp;

  /// No description provided for @onlineCountFinalResults.
  ///
  /// In en, this message translates to:
  /// **'Final Results'**
  String get onlineCountFinalResults;

  /// No description provided for @onlineCountFinalResultsReady.
  ///
  /// In en, this message translates to:
  /// **'Final results are ready.'**
  String get onlineCountFinalResultsReady;

  /// No description provided for @onlineCountResultsNotFinal.
  ///
  /// In en, this message translates to:
  /// **'Results are not final yet'**
  String get onlineCountResultsNotFinal;

  /// No description provided for @onlineCountSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get onlineCountSaved;

  /// No description provided for @onlineCountCandidatesSaved.
  ///
  /// In en, this message translates to:
  /// **'Candidates saved.'**
  String get onlineCountCandidatesSaved;

  /// No description provided for @onlineCountCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied.'**
  String get onlineCountCopied;

  /// No description provided for @onlineCountQrReadyToShare.
  ///
  /// In en, this message translates to:
  /// **'QR code is ready to share.'**
  String get onlineCountQrReadyToShare;

  /// No description provided for @onlineCountCouldNotShareQr.
  ///
  /// In en, this message translates to:
  /// **'Could not share QR code.'**
  String get onlineCountCouldNotShareQr;

  /// No description provided for @onlineCountOnlineStatusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Online status updated.'**
  String get onlineCountOnlineStatusUpdated;

  /// No description provided for @onlineCountNoCurrentMeetingFound.
  ///
  /// In en, this message translates to:
  /// **'No current meeting found.'**
  String get onlineCountNoCurrentMeetingFound;

  /// No description provided for @onlineCountCouldNotCheckStatus.
  ///
  /// In en, this message translates to:
  /// **'Could not check online status.'**
  String get onlineCountCouldNotCheckStatus;

  /// No description provided for @onlineCountPleaseCompleteSetup.
  ///
  /// In en, this message translates to:
  /// **'Please complete setup first'**
  String get onlineCountPleaseCompleteSetup;

  /// No description provided for @onlineCountCouldNotConnect.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to online voting service'**
  String get onlineCountCouldNotConnect;

  /// No description provided for @onlineCountAnotherAwardOpen.
  ///
  /// In en, this message translates to:
  /// **'Another award voting round is already open'**
  String get onlineCountAnotherAwardOpen;

  /// No description provided for @onlineCountCreateMeetingFirst.
  ///
  /// In en, this message translates to:
  /// **'Please create a meeting first.'**
  String get onlineCountCreateMeetingFirst;

  /// No description provided for @onlineCountOpenMeetingFirst.
  ///
  /// In en, this message translates to:
  /// **'Please open the voting session first.'**
  String get onlineCountOpenMeetingFirst;

  /// No description provided for @onlineCountAddCandidatesFirst.
  ///
  /// In en, this message translates to:
  /// **'Please add candidates before opening this vote.'**
  String get onlineCountAddCandidatesFirst;

  /// No description provided for @onlineCountClubMayExist.
  ///
  /// In en, this message translates to:
  /// **'Online club may already exist. Try another club code or continue with the saved setup.'**
  String get onlineCountClubMayExist;

  /// No description provided for @onlineCountOwnerAlreadyHasClub.
  ///
  /// In en, this message translates to:
  /// **'This device already has an active online club in the cloud. Use Start Fresh only if you want to abandon the old online club and create a new one.'**
  String get onlineCountOwnerAlreadyHasClub;

  /// No description provided for @onlineCountClubSlugExists.
  ///
  /// In en, this message translates to:
  /// **'This club code is already used. Please choose another club code.'**
  String get onlineCountClubSlugExists;

  /// No description provided for @onlineCountCurrentMeetingExists.
  ///
  /// In en, this message translates to:
  /// **'A current meeting already exists. Delete the current meeting before creating a new one.'**
  String get onlineCountCurrentMeetingExists;

  /// No description provided for @onlineCountOwnerOrAdminInvalid.
  ///
  /// In en, this message translates to:
  /// **'Owner token or admin PIN is invalid.'**
  String get onlineCountOwnerOrAdminInvalid;

  /// No description provided for @onlineCountCurrentMeetingDeleted.
  ///
  /// In en, this message translates to:
  /// **'Current meeting deleted.'**
  String get onlineCountCurrentMeetingDeleted;

  /// No description provided for @onlineCountOnlineClubDeleted.
  ///
  /// In en, this message translates to:
  /// **'Online club deleted.'**
  String get onlineCountOnlineClubDeleted;

  /// No description provided for @onlineCountDeviceSetupReset.
  ///
  /// In en, this message translates to:
  /// **'Online Count setup reset on this device.'**
  String get onlineCountDeviceSetupReset;

  /// No description provided for @onlineCountStartedFresh.
  ///
  /// In en, this message translates to:
  /// **'Online Count started fresh on this device.'**
  String get onlineCountStartedFresh;

  /// No description provided for @onlineCountDeleteCurrentMeetingTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete current meeting?'**
  String get onlineCountDeleteCurrentMeetingTitle;

  /// No description provided for @onlineCountDeleteCurrentMeetingWarning.
  ///
  /// In en, this message translates to:
  /// **'This will delete this meeting’s candidates, votes, and results.\nPlease send or copy results before deleting this meeting.\nDeleting this meeting will not change the QR code.\nManual Count data will not be deleted.'**
  String get onlineCountDeleteCurrentMeetingWarning;

  /// No description provided for @onlineCountDeleteOnlineClubTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete online club?'**
  String get onlineCountDeleteOnlineClubTitle;

  /// No description provided for @onlineCountDeleteOnlineClubWarning.
  ///
  /// In en, this message translates to:
  /// **'This will delete the online club, current meeting, candidates, votes, and results from the cloud.\nThe old QR code will no longer be usable.\nManual Count data will not be deleted.'**
  String get onlineCountDeleteOnlineClubWarning;

  /// No description provided for @onlineCountResetDeviceSetupWarning.
  ///
  /// In en, this message translates to:
  /// **'This will clear local Online Count setup on this phone.\nCloud data will not be deleted.\nManual Count data will not be deleted.'**
  String get onlineCountResetDeviceSetupWarning;

  /// No description provided for @onlineCountStartFreshTitle.
  ///
  /// In en, this message translates to:
  /// **'Start fresh on this device?'**
  String get onlineCountStartFreshTitle;

  /// No description provided for @onlineCountStartFreshConfirm.
  ///
  /// In en, this message translates to:
  /// **'Start Fresh'**
  String get onlineCountStartFreshConfirm;

  /// No description provided for @onlineCountStartFreshWarning.
  ///
  /// In en, this message translates to:
  /// **'This will disconnect this phone from the previous online club.\nOld online test data may remain in the cloud until it expires.\nThe old QR code should no longer be used.\nManual Count data will not be deleted.'**
  String get onlineCountStartFreshWarning;

  /// No description provided for @onlineCountLegacySessionsWarning.
  ///
  /// In en, this message translates to:
  /// **'More than one legacy meeting exists online. The newest meeting is shown.'**
  String get onlineCountLegacySessionsWarning;

  /// No description provided for @onlineCountNoSessionYet.
  ///
  /// In en, this message translates to:
  /// **'Create a meeting before setting candidates or opening voting.'**
  String get onlineCountNoSessionYet;

  /// No description provided for @onlineCountSessionId.
  ///
  /// In en, this message translates to:
  /// **'Meeting ID'**
  String get onlineCountSessionId;

  /// No description provided for @onlineCountSessionStatus.
  ///
  /// In en, this message translates to:
  /// **'Meeting status'**
  String get onlineCountSessionStatus;

  /// No description provided for @onlineCountTechnicalDetails.
  ///
  /// In en, this message translates to:
  /// **'Technical Details'**
  String get onlineCountTechnicalDetails;

  /// No description provided for @onlineCountCandidateHint.
  ///
  /// In en, this message translates to:
  /// **'One candidate per line'**
  String get onlineCountCandidateHint;

  /// No description provided for @onlineCountCandidateSetupHelp.
  ///
  /// In en, this message translates to:
  /// **'Enter one candidate per line for each award.'**
  String get onlineCountCandidateSetupHelp;

  /// No description provided for @onlineCountBestSpeakerCandidateExamples.
  ///
  /// In en, this message translates to:
  /// **'Alice\nBob\nCharlie'**
  String get onlineCountBestSpeakerCandidateExamples;

  /// No description provided for @onlineCountTableTopicsCandidateExamples.
  ///
  /// In en, this message translates to:
  /// **'David\nEva\nFrank'**
  String get onlineCountTableTopicsCandidateExamples;

  /// No description provided for @onlineCountEvaluatorCandidateExamples.
  ///
  /// In en, this message translates to:
  /// **'Grace\nHelen\nIvan'**
  String get onlineCountEvaluatorCandidateExamples;

  /// No description provided for @onlineCountNoResultsYet.
  ///
  /// In en, this message translates to:
  /// **'No results loaded yet.'**
  String get onlineCountNoResultsYet;

  /// No description provided for @onlineCountVotingLinkHelp.
  ///
  /// In en, this message translates to:
  /// **'The same link is used for every award. Open one award voting round at a time.'**
  String get onlineCountVotingLinkHelp;

  /// No description provided for @onlineCountTechnicalSettings.
  ///
  /// In en, this message translates to:
  /// **'Technical Settings'**
  String get onlineCountTechnicalSettings;

  /// No description provided for @onlineCountTechnicalSettingsHelp.
  ///
  /// In en, this message translates to:
  /// **'Only change this if you know which online voting backend to use.'**
  String get onlineCountTechnicalSettingsHelp;

  /// No description provided for @onlineCountSetPresidentContact.
  ///
  /// In en, this message translates to:
  /// **'Set President Contact'**
  String get onlineCountSetPresidentContact;

  /// No description provided for @onlineCountWinner.
  ///
  /// In en, this message translates to:
  /// **'Winner: {name}'**
  String onlineCountWinner(String name);

  /// No description provided for @onlineCountTie.
  ///
  /// In en, this message translates to:
  /// **'Tie: {names}'**
  String onlineCountTie(String names);

  /// No description provided for @onlineCountVotes.
  ///
  /// In en, this message translates to:
  /// **'{votes} votes'**
  String onlineCountVotes(int votes);

  /// No description provided for @onlineCountActionComplete.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get onlineCountActionComplete;

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
