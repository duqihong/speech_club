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
  String get navVoteBests => 'Vote Bests';

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
  String get tableTopicsCategoryCommunication => 'Communication';

  @override
  String get tableTopicsCategoryDailyLife => 'Daily Life';

  @override
  String get tableTopicsCategoryEducation => 'Education';

  @override
  String get tableTopicsCategoryTravel => 'Travel';

  @override
  String get tableTopicsCategoryWorkCareer => 'Work & Career';

  @override
  String get tableTopicsCategoryEnglishOriginExpressions =>
      'English-Origin Expressions';

  @override
  String get tableTopicsCategoryFood => 'Food';

  @override
  String get tableTopicsCategoryHealthExercise => 'Health & Exercise';

  @override
  String get tableTopicsCategoryChineseIdioms => 'Chinese Idioms';

  @override
  String get tableTopicsCategoryClassicalPoetryLines =>
      'Classical Poetry Lines';

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
  String get voteBestsTitle => 'Vote Bests';

  @override
  String get voteBestsModeIntro =>
      'Choose how you want to count meeting award votes.';

  @override
  String get voteBestsManualCount => 'Manual Count';

  @override
  String get voteBestsManualCountSubtitle =>
      'Count votes locally on this device.';

  @override
  String get voteBestsOnlineCount => 'Online Count';

  @override
  String get voteBestsOnlineCountSubtitle =>
      'Create cloud voting rounds and collect online votes.';

  @override
  String get voteBestsOnlineDescription =>
      'Create a cloud meeting, open one award round at a time, and share the voting link.';

  @override
  String get voteBestsOnlineNote => 'For now, please use Manual Count.';

  @override
  String get voteBestsGoToManualCount => 'Go to Manual Count';

  @override
  String get voteBestsSendResultsToPresident => 'Send Results to President';

  @override
  String get voteBestsCopyResults => 'Copy Results';

  @override
  String get voteBestsPresidentContact => 'President Contact';

  @override
  String get voteBestsContactNotSet => 'Not set';

  @override
  String get voteBestsPresidentName => 'President name';

  @override
  String get voteBestsPhoneNumber => 'Phone number';

  @override
  String get voteBestsPresidentNameError => 'Please enter president name.';

  @override
  String get voteBestsPhoneNumberError => 'Please enter phone number.';

  @override
  String get voteBestsMissingContactMessage =>
      'President contact is not set. Please add president name and phone number first.';

  @override
  String get voteBestsMissingPresidentPhoneNumber =>
      'Please set the president phone number first.';

  @override
  String get voteBestsSetNow => 'Set Now';

  @override
  String get voteBestsResultsCopied =>
      'Results copied. You can paste them into SMS or WhatsApp.';

  @override
  String get voteBestsWhatsAppOpened =>
      'WhatsApp opened. Please review and send the results.';

  @override
  String get voteBestsWhatsAppOpenFailedCopied =>
      'Could not open WhatsApp. Results copied instead.';

  @override
  String get voteBestsIntro =>
      'Use this as a simple local tally tool for meeting awards. It does not collect online votes.';

  @override
  String voteBestsAwardSummary(int candidateCount, int voteCount) {
    return '$candidateCount candidates · $voteCount votes';
  }

  @override
  String get voteBestsResetMeetingVotes => 'Reset Meeting Votes';

  @override
  String get voteBestsResetConfirmMessage =>
      'Reset all candidates and votes for this meeting?';

  @override
  String get voteBestsDetailHelp =>
      'Add candidates, then tap +1 when a vote is counted.';

  @override
  String get voteBestsCandidates => 'Candidates';

  @override
  String get voteBestsResults => 'Current Results';

  @override
  String get voteBestsAddCandidate => 'Add Candidate';

  @override
  String get voteBestsCandidateName => 'Candidate name';

  @override
  String get voteBestsPleaseEnterName => 'Please enter a name.';

  @override
  String get voteBestsDuplicateName => 'This name already exists.';

  @override
  String get voteBestsRemoveCandidateMessage => 'Remove this candidate?';

  @override
  String voteBestsVotesLabel(int votes) {
    return 'Votes: $votes';
  }

  @override
  String get voteBestsNoCandidatesYet => 'No candidates yet.';

  @override
  String get voteBestsNoVotesYet => 'No votes counted yet.';

  @override
  String voteBestsCurrentLeader(String name) {
    return 'Current leader: $name';
  }

  @override
  String get voteBestsCurrentTie => 'Current tie';

  @override
  String get onlineCountCloudSetup => 'Online Club Setup';

  @override
  String get onlineCountBackendUrl => 'Backend URL';

  @override
  String get onlineCountClubName => 'Club Name';

  @override
  String get onlineCountClubSlug => 'Club Code';

  @override
  String get onlineCountAdminPin => 'Admin PIN';

  @override
  String get onlineCountCreateClub => 'Create Online Club';

  @override
  String get onlineCountSlugHelp =>
      'Used in the permanent voting link. Use lowercase letters, numbers, and hyphens.';

  @override
  String get onlineCountSaveSetup => 'Save Setup';

  @override
  String get onlineCountSetupPurpose =>
      'Set up the permanent online club identity and voting link.';

  @override
  String get onlineCountAdminPinHelp =>
      'Admin PIN is used by club officers to manage online voting. Do not share it with voters.';

  @override
  String get onlineCountAdminPinVoterNote => 'Voters do not need this PIN.';

  @override
  String get onlineCountSetupButtonHelp =>
      'Save Setup stores these details on this device.\nCreate Online Club creates the club in the online voting service.';

  @override
  String get onlineCountAdvancedSettings => 'Advanced Settings';

  @override
  String get onlineCountBackendUrlHelp =>
      'Normal club officers should not need to edit the Backend URL. It is mainly for testing or future backend changes.';

  @override
  String get onlineCountOnlineClubLabel => 'Online club';

  @override
  String get onlineCountClubCodeLabel => 'Club code';

  @override
  String get onlineCountLinkReadyAfterCreate =>
      'Permanent voting link is ready after the club is created.';

  @override
  String get onlineCountClubReady => 'Online club is ready.';

  @override
  String get onlineCountCurrentMeeting => 'Current Meeting';

  @override
  String get onlineCountMeetingExplanation =>
      'Each meeting has its own voting session. Create a meeting, open it, then open one award vote at a time.';

  @override
  String get onlineCountMeetingStep1Title => 'Step 1: Create Meeting';

  @override
  String get onlineCountMeetingStep1Body => 'Prepare today’s voting session.';

  @override
  String get onlineCountMeetingStep2Title => 'Step 2: Open Meeting';

  @override
  String get onlineCountMeetingStep2Body =>
      'Allow award voting rounds to start.';

  @override
  String get onlineCountMeetingStep3Title =>
      'Step 3: Open one award voting round';

  @override
  String get onlineCountMeetingStep3Body => 'Members vote using the same link.';

  @override
  String get onlineCountMeetingStep4Title => 'Step 4: Close Meeting';

  @override
  String get onlineCountMeetingStep4Body =>
      'Finish voting and make results final.';

  @override
  String get onlineCountMeetingTitle => 'Meeting Title';

  @override
  String get onlineCountMeetingDate => 'Meeting Date';

  @override
  String get onlineCountCreateMeeting => 'Create Meeting';

  @override
  String get onlineCountOpenMeeting => 'Open Meeting';

  @override
  String get onlineCountCloseMeeting => 'Close Meeting';

  @override
  String get onlineCountCandidateSetup => 'Candidate Setup';

  @override
  String get onlineCountSaveBestSpeakerCandidates =>
      'Save Best Speaker Candidates';

  @override
  String get onlineCountSaveTableTopicsCandidates =>
      'Save Table Topics Candidates';

  @override
  String get onlineCountSaveEvaluatorCandidates => 'Save Evaluator Candidates';

  @override
  String get onlineCountVotingRound => 'Voting Round';

  @override
  String get onlineCountOpenVoting => 'Open Voting';

  @override
  String get onlineCountCloseVoting => 'Close Voting';

  @override
  String get onlineCountVotingLink => 'Voting Link';

  @override
  String get onlineCountPermanentVotingQr => 'Permanent Voting QR';

  @override
  String get onlineCountPermanentVotingQrHelp =>
      'Use the same QR code for every meeting. The voting page will show only the award currently open for voting.';

  @override
  String get onlineCountChineseVotingPage => 'Chinese voting page';

  @override
  String get onlineCountEnglishVotingPage => 'English voting page';

  @override
  String get onlineCountAutoLanguage => 'Auto language';

  @override
  String get onlineCountQrChinese => '中文';

  @override
  String get onlineCountQrEnglish => 'English';

  @override
  String get onlineCountQrAuto => 'Auto';

  @override
  String get onlineCountCopyQrLink => 'Copy QR Link';

  @override
  String get onlineCountCopyPrintText => 'Copy Print Text';

  @override
  String get onlineCountEnterClubCodeFirst =>
      'Enter and save a club code first.';

  @override
  String get onlineCountCompleteSetupFirst =>
      'Please complete online club setup first.';

  @override
  String get onlineCountCopyChineseLink => 'Copy Chinese Link';

  @override
  String get onlineCountCopyEnglishLink => 'Copy English Link';

  @override
  String get onlineCountCopyAutoLink => 'Copy Auto Link';

  @override
  String get onlineCountResults => 'Results';

  @override
  String get onlineCountRefreshResults => 'Refresh Results';

  @override
  String get onlineCountCopyResults => 'Copy Results';

  @override
  String get onlineCountDraft => 'Draft';

  @override
  String get onlineCountOpen => 'Open';

  @override
  String get onlineCountClosed => 'Closed';

  @override
  String get onlineCountSessionOpen => 'Open';

  @override
  String get onlineCountDraftHelp =>
      'Meeting is prepared, but voting is not open yet.';

  @override
  String get onlineCountOpenHelp =>
      'Meeting is open. Open one award voting round when ready.';

  @override
  String get onlineCountClosedHelp => 'Meeting is closed. Results are final.';

  @override
  String get onlineCountFinalResults => 'Final results';

  @override
  String get onlineCountResultsNotFinal => 'Results are not final yet';

  @override
  String get onlineCountSaved => 'Saved';

  @override
  String get onlineCountCopied => 'Copied.';

  @override
  String get onlineCountPleaseCompleteSetup => 'Please complete setup first';

  @override
  String get onlineCountCouldNotConnect =>
      'Could not connect to online voting service';

  @override
  String get onlineCountAnotherAwardOpen =>
      'Another award voting round is already open';

  @override
  String get onlineCountCreateMeetingFirst => 'Please create a meeting first.';

  @override
  String get onlineCountOpenMeetingFirst => 'Please open the meeting first.';

  @override
  String get onlineCountAddCandidatesFirst =>
      'Please add candidates before opening this vote.';

  @override
  String get onlineCountClubMayExist =>
      'Online club may already exist. Try another club code or continue with the saved setup.';

  @override
  String get onlineCountNoSessionYet =>
      'Create a meeting before setting candidates or opening voting.';

  @override
  String get onlineCountSessionId => 'Meeting ID';

  @override
  String get onlineCountSessionStatus => 'Meeting status';

  @override
  String get onlineCountTechnicalDetails => 'Technical Details';

  @override
  String get onlineCountCandidateHint => 'One candidate per line';

  @override
  String get onlineCountNoResultsYet => 'No results loaded yet.';

  @override
  String get onlineCountVotingLinkHelp =>
      'The same link is used for every award. Open one award voting round at a time.';

  @override
  String onlineCountWinner(String name) {
    return 'Winner: $name';
  }

  @override
  String onlineCountTie(String names) {
    return 'Tie: $names';
  }

  @override
  String onlineCountVotes(int votes) {
    return '$votes votes';
  }

  @override
  String get onlineCountActionComplete => 'Done';

  @override
  String get languageMenuLabel => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSimplifiedChinese => 'Simplified Chinese';
}
