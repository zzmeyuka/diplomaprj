import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_ru.dart';

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
    Locale('kk'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'SmartFly'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In ru, this message translates to:
  /// **'Умный поиск авиабилетов'**
  String get appTagline;

  /// No description provided for @search.
  ///
  /// In ru, this message translates to:
  /// **'Поиск'**
  String get search;

  /// No description provided for @favorites.
  ///
  /// In ru, this message translates to:
  /// **'Избранное'**
  String get favorites;

  /// No description provided for @bookings.
  ///
  /// In ru, this message translates to:
  /// **'Бронирования'**
  String get bookings;

  /// No description provided for @profile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settings;

  /// No description provided for @login.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get login;

  /// No description provided for @register.
  ///
  /// In ru, this message translates to:
  /// **'Регистрация'**
  String get register;

  /// No description provided for @welcomeBack.
  ///
  /// In ru, this message translates to:
  /// **'Добро пожаловать!'**
  String get welcomeBack;

  /// No description provided for @emailOrPhone.
  ///
  /// In ru, this message translates to:
  /// **'Email или телефон'**
  String get emailOrPhone;

  /// No description provided for @password.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In ru, this message translates to:
  /// **'Забыли пароль?'**
  String get forgotPassword;

  /// No description provided for @noAccount.
  ///
  /// In ru, this message translates to:
  /// **'Нет аккаунта?'**
  String get noAccount;

  /// No description provided for @hasAccount.
  ///
  /// In ru, this message translates to:
  /// **'Уже есть аккаунт?'**
  String get hasAccount;

  /// No description provided for @skip.
  ///
  /// In ru, this message translates to:
  /// **'Пропустить'**
  String get skip;

  /// No description provided for @startSearch.
  ///
  /// In ru, this message translates to:
  /// **'Начать поиск'**
  String get startSearch;

  /// No description provided for @fullName.
  ///
  /// In ru, this message translates to:
  /// **'ФИО'**
  String get fullName;

  /// No description provided for @phone.
  ///
  /// In ru, this message translates to:
  /// **'Телефон'**
  String get phone;

  /// No description provided for @confirmPassword.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердите пароль'**
  String get confirmPassword;

  /// No description provided for @getStarted.
  ///
  /// In ru, this message translates to:
  /// **'Начать'**
  String get getStarted;

  /// No description provided for @roundTrip.
  ///
  /// In ru, this message translates to:
  /// **'Туда-обратно'**
  String get roundTrip;

  /// No description provided for @oneWay.
  ///
  /// In ru, this message translates to:
  /// **'В одну сторону'**
  String get oneWay;

  /// No description provided for @from.
  ///
  /// In ru, this message translates to:
  /// **'Откуда'**
  String get from;

  /// No description provided for @to.
  ///
  /// In ru, this message translates to:
  /// **'Куда'**
  String get to;

  /// No description provided for @departureDate.
  ///
  /// In ru, this message translates to:
  /// **'Дата вылета'**
  String get departureDate;

  /// No description provided for @returnDate.
  ///
  /// In ru, this message translates to:
  /// **'Дата обратно'**
  String get returnDate;

  /// No description provided for @passengersAndClass.
  ///
  /// In ru, this message translates to:
  /// **'Пассажиры и класс'**
  String get passengersAndClass;

  /// No description provided for @date.
  ///
  /// In ru, this message translates to:
  /// **'Дата'**
  String get date;

  /// No description provided for @passengers.
  ///
  /// In ru, this message translates to:
  /// **'Пассажиры'**
  String get passengers;

  /// No description provided for @cabinClass.
  ///
  /// In ru, this message translates to:
  /// **'Класс'**
  String get cabinClass;

  /// No description provided for @economy.
  ///
  /// In ru, this message translates to:
  /// **'Эконом'**
  String get economy;

  /// No description provided for @comfort.
  ///
  /// In ru, this message translates to:
  /// **'Комфорт'**
  String get comfort;

  /// No description provided for @business.
  ///
  /// In ru, this message translates to:
  /// **'Бизнес'**
  String get business;

  /// No description provided for @searchFlights.
  ///
  /// In ru, this message translates to:
  /// **'Найти билеты'**
  String get searchFlights;

  /// No description provided for @popularDestinations.
  ///
  /// In ru, this message translates to:
  /// **'Популярные направления'**
  String get popularDestinations;

  /// No description provided for @personalizedDestinations.
  ///
  /// In ru, this message translates to:
  /// **'Для вас'**
  String get personalizedDestinations;

  /// No description provided for @bookThisFlight.
  ///
  /// In ru, this message translates to:
  /// **'Забронировать этот рейс'**
  String get bookThisFlight;

  /// No description provided for @fromPrice.
  ///
  /// In ru, this message translates to:
  /// **'от {price} ₸'**
  String fromPrice(String price);

  /// No description provided for @cheapest.
  ///
  /// In ru, this message translates to:
  /// **'Лучшая цена'**
  String get cheapest;

  /// No description provided for @bestOption.
  ///
  /// In ru, this message translates to:
  /// **'Лучший вариант'**
  String get bestOption;

  /// No description provided for @select.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать'**
  String get select;

  /// No description provided for @filters.
  ///
  /// In ru, this message translates to:
  /// **'Фильтры'**
  String get filters;

  /// No description provided for @sorting.
  ///
  /// In ru, this message translates to:
  /// **'Сортировка'**
  String get sorting;

  /// No description provided for @apply.
  ///
  /// In ru, this message translates to:
  /// **'Применить'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить'**
  String get reset;

  /// No description provided for @book.
  ///
  /// In ru, this message translates to:
  /// **'Забронировать'**
  String get book;

  /// No description provided for @continueBtn.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get continueBtn;

  /// No description provided for @noHiddenFees.
  ///
  /// In ru, this message translates to:
  /// **'Без скрытых комиссий'**
  String get noHiddenFees;

  /// No description provided for @flightDetails.
  ///
  /// In ru, this message translates to:
  /// **'Детали рейса'**
  String get flightDetails;

  /// No description provided for @bookingTitle.
  ///
  /// In ru, this message translates to:
  /// **'Бронирование'**
  String get bookingTitle;

  /// No description provided for @pricePerPassenger.
  ///
  /// In ru, this message translates to:
  /// **'Цена за 1 пассажира'**
  String get pricePerPassenger;

  /// No description provided for @saveFavorite.
  ///
  /// In ru, this message translates to:
  /// **'В избранное'**
  String get saveFavorite;

  /// No description provided for @askAi.
  ///
  /// In ru, this message translates to:
  /// **'Спросить AI'**
  String get askAi;

  /// No description provided for @recommendations.
  ///
  /// In ru, this message translates to:
  /// **'Рекомендации'**
  String get recommendations;

  /// No description provided for @recommendationsHint.
  ///
  /// In ru, this message translates to:
  /// **'На основе ваших поисков'**
  String get recommendationsHint;

  /// No description provided for @chatbot.
  ///
  /// In ru, this message translates to:
  /// **'AI Ассистент'**
  String get chatbot;

  /// No description provided for @send.
  ///
  /// In ru, this message translates to:
  /// **'Отправить'**
  String get send;

  /// No description provided for @theme.
  ///
  /// In ru, this message translates to:
  /// **'Тема'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get language;

  /// No description provided for @logout.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get logout;

  /// No description provided for @adminPanel.
  ///
  /// In ru, this message translates to:
  /// **'Панель администратора'**
  String get adminPanel;

  /// No description provided for @lightMode.
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная'**
  String get darkMode;

  /// No description provided for @loading.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка'**
  String get error;

  /// No description provided for @empty.
  ///
  /// In ru, this message translates to:
  /// **'Нет данных'**
  String get empty;

  /// No description provided for @bookingSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Бронирование успешно'**
  String get bookingSuccess;

  /// No description provided for @viewBookings.
  ///
  /// In ru, this message translates to:
  /// **'Мои бронирования'**
  String get viewBookings;

  /// No description provided for @backHome.
  ///
  /// In ru, this message translates to:
  /// **'На главную'**
  String get backHome;

  /// No description provided for @continueKaspi.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить с Kaspi Travel'**
  String get continueKaspi;

  /// No description provided for @sortCheapest.
  ///
  /// In ru, this message translates to:
  /// **'Сначала дешевле'**
  String get sortCheapest;

  /// No description provided for @sortEarliest.
  ///
  /// In ru, this message translates to:
  /// **'Раньше вылет'**
  String get sortEarliest;

  /// No description provided for @sortShortest.
  ///
  /// In ru, this message translates to:
  /// **'Короче в пути'**
  String get sortShortest;

  /// No description provided for @baggageIncluded.
  ///
  /// In ru, this message translates to:
  /// **'Багаж включён'**
  String get baggageIncluded;

  /// No description provided for @baggageKg.
  ///
  /// In ru, this message translates to:
  /// **'Багаж: 23 кг'**
  String get baggageKg;

  /// No description provided for @handLuggage.
  ///
  /// In ru, this message translates to:
  /// **'Ручная кладь: 8 кг'**
  String get handLuggage;

  /// No description provided for @refundable.
  ///
  /// In ru, this message translates to:
  /// **'Возврат и обмен'**
  String get refundable;

  /// No description provided for @directFlight.
  ///
  /// In ru, this message translates to:
  /// **'Прямой рейс'**
  String get directFlight;

  /// No description provided for @seatsLeft.
  ///
  /// In ru, this message translates to:
  /// **'Мест осталось'**
  String get seatsLeft;

  /// No description provided for @totalPrice.
  ///
  /// In ru, this message translates to:
  /// **'Итого'**
  String get totalPrice;

  /// No description provided for @perPassenger.
  ///
  /// In ru, this message translates to:
  /// **'за пассажира'**
  String get perPassenger;

  /// No description provided for @guestContinue.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить как гость'**
  String get guestContinue;

  /// No description provided for @onboarding1Title.
  ///
  /// In ru, this message translates to:
  /// **'Сравнение цен'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Body.
  ///
  /// In ru, this message translates to:
  /// **'Kaspi Travel, Freedom Travel, Tickets.kz и Trip'**
  String get onboarding1Body;

  /// No description provided for @onboarding2Title.
  ///
  /// In ru, this message translates to:
  /// **'500k+ направлений'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Body.
  ///
  /// In ru, this message translates to:
  /// **'Актуальные предложения на лето 2026'**
  String get onboarding2Body;

  /// No description provided for @onboarding3Title.
  ///
  /// In ru, this message translates to:
  /// **'AI-ассистент'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Body.
  ///
  /// In ru, this message translates to:
  /// **'Поможет выбрать лучший билет'**
  String get onboarding3Body;

  /// No description provided for @backToWelcome.
  ///
  /// In ru, this message translates to:
  /// **'На приветственный экран'**
  String get backToWelcome;

  /// No description provided for @searchCity.
  ///
  /// In ru, this message translates to:
  /// **'Введите город'**
  String get searchCity;

  /// No description provided for @notifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In ru, this message translates to:
  /// **'Нет уведомлений'**
  String get noNotifications;

  /// No description provided for @markAllRead.
  ///
  /// In ru, this message translates to:
  /// **'Прочитать все'**
  String get markAllRead;

  /// No description provided for @newChat.
  ///
  /// In ru, this message translates to:
  /// **'Новый чат'**
  String get newChat;

  /// No description provided for @chatHistory.
  ///
  /// In ru, this message translates to:
  /// **'История чатов'**
  String get chatHistory;

  /// No description provided for @noChatHistory.
  ///
  /// In ru, this message translates to:
  /// **'История пуста. Начните новый чат.'**
  String get noChatHistory;
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
      <String>['en', 'kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kk':
      return AppLocalizationsKk();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
