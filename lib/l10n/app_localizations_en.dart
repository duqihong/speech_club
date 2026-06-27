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
  String get navSpeaker => 'Flashcards';

  @override
  String get navTopicSelection => 'Topic Selection';

  @override
  String get navTableTopics => 'Table Topics';

  @override
  String get navRoleAssistant => 'Role Assistants';

  @override
  String get navCommittees => 'Committees';

  @override
  String get navPathways => 'Pathways';

  @override
  String get navVoteBests => 'Vote Bests';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsProSubtitle => 'Online voting subscription';

  @override
  String get proTitle => 'Speech Club Pro';

  @override
  String get proSubtitle =>
      'Run live online voting with one permanent club QR.';

  @override
  String get proBody =>
      'Speech Club Pro helps your club collect votes from members’ phones, show a live vote count, and send final results to the meeting officer.';

  @override
  String get proIncludedTitle => 'Included';

  @override
  String get proFeatureOnlineCount => 'Online Count';

  @override
  String get proFeaturePermanentClubQr => 'Permanent club QR';

  @override
  String get proFeatureQrSharing => 'QR sharing';

  @override
  String get proFeatureLiveVoteCounter => 'Live vote counter';

  @override
  String get proFeatureSendResultsByWhatsApp => 'Send results by WhatsApp';

  @override
  String get proFeatureFutureOnlineTools => 'Future online meeting tools';

  @override
  String get proPriceLine =>
      'First 3 months free. Then S\$14.98 per year. Cancel anytime.';

  @override
  String get proStartTrialButton => 'Start 3-Month Free Trial';

  @override
  String get proUseManualCountButton => 'Use Manual Count for Free';

  @override
  String get proManualCountFreeNote =>
      'Manual Count and all offline tools remain free.';

  @override
  String get proPurchaseComingSoon =>
      'Purchase will be enabled in a later test phase.';

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
  String get flashcardsMySpeech => 'Speech Flashcards';

  @override
  String get flashcardsMySpeeches => 'Speech Flashcards';

  @override
  String get flashcardsAddCard => 'Add Card';

  @override
  String get flashcardsEditCard => 'Edit Card';

  @override
  String get flashcardsPasteMultipleCards => 'Paste Multiple Cards';

  @override
  String get flashcardsEditMySpeech => 'Edit Speech Flashcards';

  @override
  String get flashcardsEditCards => 'Edit Flashcards';

  @override
  String get flashcardsStartPresentation => 'Start Practice';

  @override
  String get flashcardsIntro =>
      'Create simple cards to guide your prepared speech.';

  @override
  String get flashcardsNoCardsYet =>
      'No flashcards yet. Tap Edit Flashcards to add your first card.';

  @override
  String get flashcardsEmptyState =>
      'No flashcards yet.\nTap \"Add Card\" to create your first one.';

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
  String get onlineCountClubReadyTitle => 'Online Club Ready';

  @override
  String get onlineCountCheckOnlineStatus => 'Check Online Status';

  @override
  String get onlineCountCheckOnlineStatusHelp =>
      'Use this only if the screen looks out of sync with online voting.';

  @override
  String get onlineCountDeleteOnlineClub => 'Delete Online Club';

  @override
  String get onlineCountResetDeviceSetup => 'Reset Online Count on This Device';

  @override
  String get onlineCountStartFreshDevice => 'Start Fresh on This Device';

  @override
  String get onlineCountDangerZone => 'Manage & Reset';

  @override
  String get onlineCountDangerZoneHelp =>
      'Use these options only if setup is wrong or you need to reset online voting.';

  @override
  String get onlineCountSlugHelp =>
      'Used in the permanent voting link. Use lowercase letters, numbers, and hyphens.';

  @override
  String get onlineCountSaveSetup => 'Save Setup';

  @override
  String get onlineCountSetupPurpose =>
      'Enter your club name. The app will create a permanent online voting QR code for this club.';

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
  String get onlineCountAdvancedSettingsHelp =>
      'Use this only if online setup is stuck or this device already has an old online club.';

  @override
  String get onlineCountBackendUrlHelp =>
      'Normal club officers should not need to edit the Backend URL. It is mainly for testing or future backend changes.';

  @override
  String get onlineCountOnlineClubLabel => 'Club';

  @override
  String get onlineCountClubCodeLabel => 'Club code';

  @override
  String get onlineCountVotingLinkAvailableBelow => 'Voting QR is ready below.';

  @override
  String get onlineCountLinkReadyAfterCreate =>
      'Permanent voting link is ready after the club is created.';

  @override
  String get onlineCountClubReady => 'Online club is ready.';

  @override
  String get onlineCountCurrentStatus => 'Current Status';

  @override
  String get onlineCountCurrentMeeting => 'Current Meeting';

  @override
  String get onlineCountMeetingOpenTitle => 'Meeting Open';

  @override
  String get onlineCountMeetingClosedTitle => 'Meeting Closed';

  @override
  String get onlineCountNextStep => 'Next step';

  @override
  String get onlineCountNextStepAddCandidatesShort => 'Add candidates';

  @override
  String get onlineCountCurrentVote => 'Current vote';

  @override
  String get onlineCountNotCreated => 'Not created';

  @override
  String get onlineCountNotOpened => 'Not opened';

  @override
  String get onlineCountResultsAreFinal => 'Results are final';

  @override
  String get onlineCountNextStepAddCandidates =>
      'Add candidates, then open meeting';

  @override
  String get onlineCountNextStepCloseVoting => 'Close voting when ready';

  @override
  String get onlineCountNextStepOpenNextVotingRound =>
      'Open the next voting round';

  @override
  String get onlineCountNextStepRefreshAndSendResults =>
      'Refresh and send results';

  @override
  String get onlineCountNextStepSendOrDelete =>
      'Send results or delete meeting';

  @override
  String get onlineCountAllVotingRoundsClosed =>
      'All voting rounds are closed.';

  @override
  String get onlineCountAllVotingRoundsClosedFinalize =>
      'All voting rounds are closed. Close the voting session to finalize results.';

  @override
  String get onlineCountMeetingExplanation =>
      'Each meeting has its own voting session. Create a meeting, open it, then open one award vote at a time.';

  @override
  String get onlineCountMeetingStep1Title => 'Step 1: Create Meeting';

  @override
  String get onlineCountMeetingStep1Body => 'Prepare today’s voting session.';

  @override
  String get onlineCountMeetingStep2Title => 'Step 2: Open Voting Session';

  @override
  String get onlineCountMeetingStep2Body =>
      'Allow award voting rounds to start.';

  @override
  String get onlineCountMeetingStep3Title =>
      'Step 3: Open one award voting round';

  @override
  String get onlineCountMeetingStep3Body => 'Members vote using the same link.';

  @override
  String get onlineCountMeetingStep4Title => 'Step 4: Close Voting Session';

  @override
  String get onlineCountMeetingStep4Body =>
      'Finish voting and make results final.';

  @override
  String get onlineCountMeetingTitle => 'Meeting Title';

  @override
  String get onlineCountDefaultMeetingTitle => 'Regular Meeting';

  @override
  String get onlineCountMeetingDate => 'Meeting Date';

  @override
  String get onlineCountCreateMeeting => 'Create Meeting';

  @override
  String get onlineCountCreateCurrentMeeting => 'Create Current Meeting';

  @override
  String get onlineCountNoCurrentMeeting => 'No current meeting';

  @override
  String get onlineCountNoMeetingHelper =>
      'Create a meeting before adding candidates or opening voting.';

  @override
  String get onlineCountDraftMeetingHelper =>
      'Add candidates, then open the meeting.';

  @override
  String get onlineCountOpenMeetingHelper =>
      'Open one award voting round at a time. Close the voting session when all voting is finished.';

  @override
  String get onlineCountClosedMeetingHelper =>
      'Results are final. Send or copy results before deleting the meeting.';

  @override
  String get onlineCountReadyToStartVoting => 'Ready for award voting?';

  @override
  String get onlineCountAddAllCandidatesBeforeOpening =>
      'Save candidates for all awards before opening the voting session.';

  @override
  String get onlineCountDeleteCurrentMeeting => 'Delete Current Meeting';

  @override
  String get onlineCountOpenMeeting => 'Open Voting Session';

  @override
  String get onlineCountCloseMeeting => 'Close Voting Session';

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
  String get onlineCountBestSpeakerCandidatesSaved =>
      'Best Speaker Candidates Saved';

  @override
  String get onlineCountTableTopicsCandidatesSaved =>
      'Table Topics Candidates Saved';

  @override
  String get onlineCountEvaluatorCandidatesSaved =>
      'Evaluator Candidates Saved';

  @override
  String get onlineCountVotingRound => 'Voting Round';

  @override
  String get onlineCountOpenVoting => 'Open Voting';

  @override
  String get onlineCountCloseVoting => 'Close Voting';

  @override
  String get onlineCountVotesReceived => 'Votes received';

  @override
  String get onlineCountFinalVotes => 'Final votes';

  @override
  String get onlineCountAwardStatusLabel => 'Status';

  @override
  String get onlineCountRefreshVoteCount => 'Refresh Vote Count';

  @override
  String get onlineCountVoteCountsAutoRefresh =>
      'Vote counts auto-refresh every 5 seconds.';

  @override
  String get onlineCountVoteCountsLastUpdated => 'Last updated: just now';

  @override
  String get onlineCountOpenVotingRoundToReceiveVotes =>
      'Open a voting round to start receiving votes.';

  @override
  String get onlineCountVoteCountingComplete =>
      'Vote counting is complete for all rounds.';

  @override
  String get onlineCountCouldNotRefreshVoteCount =>
      'Could not refresh vote count.';

  @override
  String get onlineCountVotingLink => 'Voting Link';

  @override
  String get onlineCountPermanentVotingQr => 'Permanent Voting QR';

  @override
  String get onlineCountPermanentVotingQrHelp => 'Reusable for every meeting.';

  @override
  String get onlineCountQrScheduleShareHelp =>
      'The voting page follows each voter’s phone language.';

  @override
  String get onlineCountQrLifecycleReminder =>
      'Deleting a meeting keeps this QR. Deleting the club or starting fresh makes it unusable.';

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
  String get onlineCountCopyQrLink => 'Copy Voting Link';

  @override
  String get onlineCountShareQrCode => 'Share QR Code';

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
  String get onlineCountRefreshResultsFirst => 'Please refresh results first.';

  @override
  String get onlineCountRefreshResultsThenCheckFinal =>
      'Tap Refresh Results first, then check the final results.';

  @override
  String get onlineCountCopyResults => 'Copy Results';

  @override
  String get onlineCountDraft => 'Draft';

  @override
  String get onlineCountPreparing => 'Preparing';

  @override
  String get onlineCountOpen => 'Open';

  @override
  String get onlineCountClosed => 'Voting Session Closed';

  @override
  String get onlineCountSessionOpen => 'Voting Session Open';

  @override
  String get onlineCountDraftHelp =>
      'Meeting is prepared, but voting is not open yet.';

  @override
  String get onlineCountOpenHelp =>
      'Meeting is open. Open one award voting round when ready.';

  @override
  String get onlineCountClosedHelp =>
      'Voting session is closed. Results are final.';

  @override
  String get onlineCountFinalResults => 'Final Results';

  @override
  String get onlineCountFinalResultsReady => 'Final results are ready.';

  @override
  String get onlineCountResultsNotFinal => 'Results are not final yet';

  @override
  String get onlineCountSaved => 'Saved';

  @override
  String get onlineCountCandidatesSaved => 'Candidates saved.';

  @override
  String get onlineCountCopied => 'Copied.';

  @override
  String get onlineCountQrReadyToShare => 'QR code is ready to share.';

  @override
  String get onlineCountCouldNotShareQr => 'Could not share QR code.';

  @override
  String get onlineCountOnlineStatusUpdated => 'Online status updated.';

  @override
  String get onlineCountNoCurrentMeetingFound => 'No current meeting found.';

  @override
  String get onlineCountCouldNotCheckStatus => 'Could not check online status.';

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
  String get onlineCountOpenMeetingFirst =>
      'Please open the voting session first.';

  @override
  String get onlineCountAddCandidatesFirst =>
      'Please add candidates before opening this vote.';

  @override
  String get onlineCountClubMayExist =>
      'Online club may already exist. Try another club code or continue with the saved setup.';

  @override
  String get onlineCountOwnerAlreadyHasClub =>
      'This device already has an active online club in the cloud. Use Start Fresh only if you want to abandon the old online club and create a new one.';

  @override
  String get onlineCountClubSlugExists =>
      'This club code is already used. Please choose another club code.';

  @override
  String get onlineCountCurrentMeetingExists =>
      'A current meeting already exists. Delete the current meeting before creating a new one.';

  @override
  String get onlineCountOwnerOrAdminInvalid =>
      'Owner token or admin PIN is invalid.';

  @override
  String get onlineCountCurrentMeetingDeleted => 'Current meeting deleted.';

  @override
  String get onlineCountOnlineClubDeleted => 'Online club deleted.';

  @override
  String get onlineCountDeviceSetupReset =>
      'Online Count setup reset on this device.';

  @override
  String get onlineCountStartedFresh =>
      'Online Count started fresh on this device.';

  @override
  String get onlineCountDeleteCurrentMeetingTitle => 'Delete current meeting?';

  @override
  String get onlineCountDeleteCurrentMeetingWarning =>
      'This will delete this meeting’s candidates, votes, and results.\nPlease send or copy results before deleting this meeting.\nDeleting this meeting will not change the QR code.\nManual Count data will not be deleted.';

  @override
  String get onlineCountDeleteOnlineClubTitle => 'Delete online club?';

  @override
  String get onlineCountDeleteOnlineClubWarning =>
      'This will delete the online club, current meeting, candidates, votes, and results from the cloud.\nThe old QR code will no longer be usable.\nManual Count data will not be deleted.';

  @override
  String get onlineCountResetDeviceSetupWarning =>
      'This will clear local Online Count setup on this phone.\nCloud data will not be deleted.\nManual Count data will not be deleted.';

  @override
  String get onlineCountStartFreshTitle => 'Start fresh on this device?';

  @override
  String get onlineCountStartFreshConfirm => 'Start Fresh';

  @override
  String get onlineCountStartFreshWarning =>
      'This will disconnect this phone from the previous online club.\nOld online test data may remain in the cloud until it expires.\nThe old QR code should no longer be used.\nManual Count data will not be deleted.';

  @override
  String get onlineCountLegacySessionsWarning =>
      'More than one legacy meeting exists online. The newest meeting is shown.';

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
  String get onlineCountCandidateSetupHelp =>
      'Enter one candidate per line for each award.';

  @override
  String get onlineCountBestSpeakerCandidateExamples => 'Alice\nBob\nCharlie';

  @override
  String get onlineCountTableTopicsCandidateExamples => 'David\nEva\nFrank';

  @override
  String get onlineCountEvaluatorCandidateExamples => 'Grace\nHelen\nIvan';

  @override
  String get onlineCountNoResultsYet => 'No results loaded yet.';

  @override
  String get onlineCountVotingLinkHelp =>
      'The same link is used for every award. Open one award voting round at a time.';

  @override
  String get onlineCountTechnicalSettings => 'Technical Settings';

  @override
  String get onlineCountTechnicalSettingsHelp =>
      'Only change this if you know which online voting backend to use.';

  @override
  String get onlineCountSetPresidentContact => 'Set President Contact';

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
