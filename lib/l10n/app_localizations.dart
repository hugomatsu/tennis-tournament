import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

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
    Locale('pt'),
  ];

  /// O título principal da aplicação
  ///
  /// In pt, this message translates to:
  /// **'Torneios de Tênis'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get home;

  /// No description provided for @schedule.
  ///
  /// In pt, this message translates to:
  /// **'Agenda'**
  String get schedule;

  /// No description provided for @tournaments.
  ///
  /// In pt, this message translates to:
  /// **'Torneios'**
  String get tournaments;

  /// No description provided for @matches.
  ///
  /// In pt, this message translates to:
  /// **'Jogos'**
  String get matches;

  /// No description provided for @noMatchesScheduled.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum jogo agendado ainda.'**
  String get noMatchesScheduled;

  /// No description provided for @locationTBD.
  ///
  /// In pt, this message translates to:
  /// **'Local a definir'**
  String get locationTBD;

  /// No description provided for @youSuffix.
  ///
  /// In pt, this message translates to:
  /// **' (Você)'**
  String get youSuffix;

  /// No description provided for @profile.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get profile;

  /// No description provided for @mySchedule.
  ///
  /// In pt, this message translates to:
  /// **'Minha Agenda'**
  String get mySchedule;

  /// No description provided for @statusPreparing.
  ///
  /// In pt, this message translates to:
  /// **'Preparando'**
  String get statusPreparing;

  /// No description provided for @statusScheduled.
  ///
  /// In pt, this message translates to:
  /// **'Agendado'**
  String get statusScheduled;

  /// No description provided for @statusConfirmed.
  ///
  /// In pt, this message translates to:
  /// **'Confirmado'**
  String get statusConfirmed;

  /// No description provided for @statusStarted.
  ///
  /// In pt, this message translates to:
  /// **'Iniciado'**
  String get statusStarted;

  /// No description provided for @statusFinished.
  ///
  /// In pt, this message translates to:
  /// **'Finalizado'**
  String get statusFinished;

  /// No description provided for @statusCompleted.
  ///
  /// In pt, this message translates to:
  /// **'Concluído'**
  String get statusCompleted;

  /// No description provided for @matchDetails.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes do Jogo'**
  String get matchDetails;

  /// No description provided for @adminControls.
  ///
  /// In pt, this message translates to:
  /// **'Controles de Admin'**
  String get adminControls;

  /// No description provided for @confirmAttendance.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar Presença'**
  String get confirmAttendance;

  /// No description provided for @decline.
  ///
  /// In pt, this message translates to:
  /// **'Recusar'**
  String get decline;

  /// No description provided for @confirm.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @reschedule.
  ///
  /// In pt, this message translates to:
  /// **'Reagendar'**
  String get reschedule;

  /// No description provided for @score.
  ///
  /// In pt, this message translates to:
  /// **'Placar'**
  String get score;

  /// No description provided for @winner.
  ///
  /// In pt, this message translates to:
  /// **'Vencedor'**
  String get winner;

  /// No description provided for @saveChanges.
  ///
  /// In pt, this message translates to:
  /// **'Salvar Alterações'**
  String get saveChanges;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get delete;

  /// No description provided for @player1Present.
  ///
  /// In pt, this message translates to:
  /// **'Jogador 1 Presente'**
  String get player1Present;

  /// No description provided for @player2Present.
  ///
  /// In pt, this message translates to:
  /// **'Jogador 2 Presente'**
  String get player2Present;

  /// No description provided for @youHaveConfirmed.
  ///
  /// In pt, this message translates to:
  /// **'Você confirmou presença.'**
  String get youHaveConfirmed;

  /// No description provided for @pleaseConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Por favor confirme sua presença.'**
  String get pleaseConfirm;

  /// No description provided for @editProfile.
  ///
  /// In pt, this message translates to:
  /// **'Editar Perfil'**
  String get editProfile;

  /// No description provided for @changePhoto.
  ///
  /// In pt, this message translates to:
  /// **'Alterar Foto'**
  String get changePhoto;

  /// No description provided for @name.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get name;

  /// No description provided for @title.
  ///
  /// In pt, this message translates to:
  /// **'Título'**
  String get title;

  /// No description provided for @bio.
  ///
  /// In pt, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @category.
  ///
  /// In pt, this message translates to:
  /// **'Categoria'**
  String get category;

  /// No description provided for @playingSince.
  ///
  /// In pt, this message translates to:
  /// **'Joga Desde'**
  String get playingSince;

  /// No description provided for @saveProfile.
  ///
  /// In pt, this message translates to:
  /// **'Salvar Perfil'**
  String get saveProfile;

  /// No description provided for @bracket.
  ///
  /// In pt, this message translates to:
  /// **'Chave'**
  String get bracket;

  /// No description provided for @calendar.
  ///
  /// In pt, this message translates to:
  /// **'Calendário'**
  String get calendar;

  /// No description provided for @participants.
  ///
  /// In pt, this message translates to:
  /// **'Participantes'**
  String get participants;

  /// No description provided for @info.
  ///
  /// In pt, this message translates to:
  /// **'Informações'**
  String get info;

  /// No description provided for @generateBracket.
  ///
  /// In pt, this message translates to:
  /// **'Gerar Chave'**
  String get generateBracket;

  /// No description provided for @automatic.
  ///
  /// In pt, this message translates to:
  /// **'Automático'**
  String get automatic;

  /// No description provided for @manual.
  ///
  /// In pt, this message translates to:
  /// **'Manual'**
  String get manual;

  /// No description provided for @generationMethod.
  ///
  /// In pt, this message translates to:
  /// **'Método de Geração'**
  String get generationMethod;

  /// No description provided for @randomlyShuffle.
  ///
  /// In pt, this message translates to:
  /// **'Embaralhar aleatoriamente'**
  String get randomlyShuffle;

  /// No description provided for @reorderManually.
  ///
  /// In pt, this message translates to:
  /// **'Reordenar manualmente'**
  String get reorderManually;

  /// No description provided for @deleteBracket.
  ///
  /// In pt, this message translates to:
  /// **'Excluir Chave'**
  String get deleteBracket;

  /// No description provided for @deleteBracketConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Tem certeza que deseja excluir a chave? Isso apagará todos os jogos gerados.'**
  String get deleteBracketConfirm;

  /// No description provided for @managePlayers.
  ///
  /// In pt, this message translates to:
  /// **'Gerenciar Jogadores'**
  String get managePlayers;

  /// No description provided for @pendingRequests.
  ///
  /// In pt, this message translates to:
  /// **'Solicitações Pendentes'**
  String get pendingRequests;

  /// No description provided for @approvedPlayers.
  ///
  /// In pt, this message translates to:
  /// **'Jogadores Aprovados'**
  String get approvedPlayers;

  /// No description provided for @noApprovedPlayers.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum jogador aprovado ainda.'**
  String get noApprovedPlayers;

  /// No description provided for @addParticipant.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar Participante'**
  String get addParticipant;

  /// No description provided for @myMediaLibrary.
  ///
  /// In pt, this message translates to:
  /// **'Minha Biblioteca de Mídia'**
  String get myMediaLibrary;

  /// No description provided for @myLibrary.
  ///
  /// In pt, this message translates to:
  /// **'Minha Biblioteca'**
  String get myLibrary;

  /// No description provided for @storageUsed.
  ///
  /// In pt, this message translates to:
  /// **'Armazenamento usado'**
  String get storageUsed;

  /// No description provided for @upload.
  ///
  /// In pt, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @noImages.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma imagem na biblioteca'**
  String get noImages;

  /// No description provided for @pleaseLogIn.
  ///
  /// In pt, this message translates to:
  /// **'Por favor, faça login'**
  String get pleaseLogIn;

  /// No description provided for @joined.
  ///
  /// In pt, this message translates to:
  /// **'Entrou'**
  String get joined;

  /// No description provided for @accept.
  ///
  /// In pt, this message translates to:
  /// **'Aceitar'**
  String get accept;

  /// No description provided for @deny.
  ///
  /// In pt, this message translates to:
  /// **'Recusar'**
  String get deny;

  /// No description provided for @remove.
  ///
  /// In pt, this message translates to:
  /// **'Remover'**
  String get remove;

  /// No description provided for @add.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar'**
  String get add;

  /// No description provided for @close.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get close;

  /// No description provided for @fileName.
  ///
  /// In pt, this message translates to:
  /// **'Nome do Arquivo'**
  String get fileName;

  /// No description provided for @uploadedAt.
  ///
  /// In pt, this message translates to:
  /// **'Enviado em'**
  String get uploadedAt;

  /// No description provided for @size.
  ///
  /// In pt, this message translates to:
  /// **'Tamanho'**
  String get size;
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
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
