import 'package:flutter/material.dart';

/// Lightweight bilingual strings for Module 2 (en / hi).
class LivoraStrings {
  LivoraStrings(this.locale);

  final Locale locale;

  static LivoraStrings of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return LivoraStrings(locale);
  }

  bool get _hi => locale.languageCode.toLowerCase() == 'hi';

  String get appName => 'LIVORA';
  String get tagline => _hi ? 'घर आए देखभाल' : 'Care that comes home';
  String get settings => _hi ? 'सेटिंग्स' : 'Settings';
  String get profile => _hi ? 'प्रोफ़ाइल' : 'Profile';
  String get editProfile => _hi ? 'प्रोफ़ाइल संपादित करें' : 'Edit profile';
  String get save => _hi ? 'सहेजें' : 'Save';
  String get cancel => _hi ? 'रद्द करें' : 'Cancel';
  String get appearance => _hi ? 'दिखावट' : 'Appearance';
  String get settingsAppearanceHint => _hi
      ? 'ऐप की थीम चुनें।'
      : 'Choose how LIVORA looks on this device.';
  String get settingsLanguageHint => _hi
      ? 'ऐप की भाषा चुनें।'
      : 'Choose your preferred app language.';
  String get language => _hi ? 'भाषा' : 'Language';

  String get themeSystem => _hi ? 'सिस्टम' : 'System';
  String get themeLight => _hi ? 'लाइट' : 'Light';
  String get themeDark => _hi ? 'डार्क' : 'Dark';
  String get notifications => _hi ? 'सूचनाएँ' : 'Notifications';
  String get pushNotifications => _hi ? 'पुश सूचनाएँ' : 'Push notifications';
  String get emailNotifications => _hi ? 'ईमेल सूचनाएँ' : 'Email notifications';
  String get smsNotifications => _hi ? 'एसएमएस सूचनाएँ' : 'SMS notifications';
  String get marketing => _hi ? 'ऑफ़र और अपडेट' : 'Offers & updates';
  String get security => _hi ? 'सुरक्षा' : 'Security';
  String get changePassword => _hi ? 'पासवर्ड बदलें' : 'Change password';
  String get signOut => _hi ? 'साइन आउट' : 'Sign out';
  String get deleteAccount => _hi ? 'खाता हटाएँ' : 'Delete account';
  String get account => _hi ? 'खाता' : 'Account';
  String get fullName => _hi ? 'पूरा नाम' : 'Full name';
  String get displayName => _hi ? 'प्रदर्शित नाम' : 'Display name';
  String get phone => _hi ? 'फ़ोन' : 'Phone';
  String get city => _hi ? 'शहर' : 'City';
  String get bio => _hi ? 'बायो' : 'Bio';
  String get english => 'English';
  String get hindi => 'हिन्दी';
  String get saved => _hi ? 'सहेजा गया' : 'Saved';
  String get retry => _hi ? 'फिर से कोशिश करें' : 'Retry';
  String get loading => _hi ? 'लोड हो रहा है…' : 'Loading…';
  String get offlineHint =>
      _hi ? 'आप ऑफ़लाइन लगते हैं। पुनः प्रयास करें।' : 'You appear offline. Please retry.';
  String get sessions => _hi ? 'डिवाइस सत्र' : 'Device sessions';
  String get currentPassword => _hi ? 'वर्तमान पासवर्ड' : 'Current password';
  String get newPassword => _hi ? 'नया पासवर्ड' : 'New password';
  String get confirmDelete =>
      _hi ? 'खाता हटाने की पुष्टि करें?' : 'Confirm account deletion?';
  String get deleteWarning => _hi
      ? 'आपका खाता निष्क्रिय हो जाएगा। यह कार्रवाई गंभीर है।'
      : 'Your account will be deactivated. This action is serious.';
  String get homeGreeting => _hi ? 'नमस्ते' : 'Hello';
  String get homePrompt =>
      _hi ? 'आज आपको किस चीज़ में मदद चाहिए?' : 'What would you like help with today?';
  String get homeLocationFallback => _hi ? 'आपके पास' : 'Near you';
  String get heroEyebrow =>
      _hi ? 'पेशेवर और विश्वसनीय' : 'PROFESSIONAL & TRUSTED';
  String get badgeBestseller => _hi ? 'बेस्टसेलर' : 'Bestseller';
  String get badgeTopRated => _hi ? 'टॉप रेटेड' : 'Top rated';
  String get exploreCategory => _hi ? 'देखें' : 'Explore';
  String get navHome => _hi ? 'होम' : 'Home';
  String get navExplore => _hi ? 'खोजें' : 'Explore';
  String get navShop => _hi ? 'शॉप' : 'Shop';
  String get navBookings => _hi ? 'बुकिंग' : 'Bookings';
  String get navOffers => _hi ? 'ऑफ़र' : 'Offers';
  String get navProfile => _hi ? 'प्रोफ़ाइल' : 'Profile';
  String get navJobs => _hi ? 'जॉब्स' : 'Jobs';
  String get navWallet => _hi ? 'वॉलेट' : 'Wallet';
  String get navAttendance => _hi ? 'हाज़िरी' : 'Attendance';
  String get navPerformance => _hi ? 'प्रदर्शन' : 'Performance';
  String get navMore => _hi ? 'और' : 'More';
  String get partnerConfirmJob => _hi ? 'पुष्टि' : 'Confirm';
  String get partnerStartJob => _hi ? 'शुरू' : 'Start';
  String get partnerCompleteJob => _hi ? 'पूर्ण' : 'Done';
  String get partnerTools => _hi ? 'टूल्स' : 'Tools';
  String get partnerNoJobs =>
      _hi ? 'इस फ़िल्टर में कोई जॉब नहीं।' : 'No jobs in this filter.';
  String get trustVerifiedPros =>
      _hi ? 'सत्यापित पेशेवर' : 'Verified professionals';
  String get trustSecurePayments =>
      _hi ? 'सुरक्षित भुगतान' : 'Secure payments';
  String get trustServiceGuarantee =>
      _hi ? 'सेवा गारंटी' : 'Service guarantee';
  String get categories => _hi ? 'श्रेणियाँ' : 'Categories';
  String get categoryServicesCount =>
      _hi ? '{n} सेवाएँ' : '{n} services';
  String get featuredServices => _hi ? 'विशेष सेवाएँ' : 'Featured services';
  String get viewAll => _hi ? 'सभी देखें' : 'View all';
  String get viewDetails => _hi ? 'विवरण देखें' : 'View details';
  String get serviceDetails => _hi ? 'सेवा विवरण' : 'Service details';
  String get duration => _hi ? 'अवधि' : 'Duration';
  String get fromPrice => _hi ? 'शुरूआती मूल्य' : 'Starting at';
  String get minutes => _hi ? 'मिनट' : 'min';
  String get catalogEmpty => _hi ? 'अभी कोई सेवा उपलब्ध नहीं है।' : 'No services available yet.';
  String get banners => _hi ? 'बैनर' : 'Banners';
  String get cms => _hi ? 'CMS' : 'CMS';
  String get addCategory => _hi ? 'श्रेणी जोड़ें' : 'Add category';
  String get addService => _hi ? 'सेवा जोड़ें' : 'Add service';
  String get addBanner => _hi ? 'बैनर जोड़ें' : 'Add banner';
  String get moduleTwoReady => _hi
      ? 'प्रोफ़ाइल और सेटिंग्स तैयार हैं।'
      : 'Profile and settings are ready.';
  String get exploreCatalog => _hi ? 'सेवा कैटलॉग देखें' : 'Explore the service catalog';
  String get search => _hi ? 'खोजें' : 'Search';
  String get searchHint => _hi
      ? 'सेवाएँ, पेशेवर खोजें…'
      : 'Search for services, professionals...';
  String get filters => _hi ? 'फ़िल्टर' : 'Filters';
  String get searching => _hi ? 'खोज जारी है…' : 'Searching…';
  String get searchEmpty => _hi ? 'कोई परिणाम नहीं मिला।' : 'No results found.';
  String get popularSearches => _hi ? 'लोकप्रिय खोजें' : 'Popular searches';
  String get recentSearches => _hi ? 'हाल की खोजें' : 'Recent searches';
  String get noRecentSearches => _hi ? 'अभी कोई हाल की खोज नहीं।' : 'No recent searches yet.';
  String get clearHistory => _hi ? 'इतिहास साफ़ करें' : 'Clear history';
  String get trendingServices => _hi ? 'ट्रेंडिंग सेवाएँ' : 'Trending services';
  String get recentlyViewed => _hi ? 'हाल ही में देखी गई' : 'Recently viewed';
  String get sortRelevance => _hi ? 'प्रासंगिकता' : 'Relevance';
  String get sortPopular => _hi ? 'लोकप्रिय' : 'Popular';
  String get sortPriceAsc => _hi ? 'मूल्य ↑' : 'Price ↑';
  String get sortPriceDesc => _hi ? 'मूल्य ↓' : 'Price ↓';
  String get sortNewest => _hi ? 'नवीनतम' : 'Newest';
  String get addresses => _hi ? 'पते' : 'Addresses';
  String get addAddress => _hi ? 'पता जोड़ें' : 'Add address';
  String get editAddress => _hi ? 'पता संपादित करें' : 'Edit address';
  String get deleteAddress => _hi ? 'पता हटाएँ' : 'Delete address';
  String get confirmDeleteAddress =>
      _hi ? 'क्या आप इस पते को हटाना चाहते हैं?' : 'Delete this address?';
  String get addressesEmpty =>
      _hi ? 'अभी कोई पता सहेजा नहीं है।' : 'No saved addresses yet.';
  String get addressDeleted => _hi ? 'पता हटा दिया गया' : 'Address deleted';
  String get defaultAddress => _hi ? 'डिफ़ॉल्ट' : 'Default';
  String get setDefault => _hi ? 'डिफ़ॉल्ट बनाएँ' : 'Set as default';
  String get addressLabel => _hi ? 'लेबल' : 'Label';
  String get labelHome => _hi ? 'घर' : 'Home';
  String get labelWork => _hi ? 'कार्यालय' : 'Work';
  String get labelOther => _hi ? 'अन्य' : 'Other';
  String get customLabel => _hi ? 'कस्टम लेबल' : 'Custom label';
  String get addressLine1 => _hi ? 'पता पंक्ति 1' : 'Address line 1';
  String get addressLine2 => _hi ? 'पता पंक्ति 2' : 'Address line 2';
  String get landmark => _hi ? 'लैंडमार्क' : 'Landmark';
  String get stateProvince => _hi ? 'राज्य' : 'State';
  String get postalCode => _hi ? 'पिन कोड' : 'Postal code';
  String get checkServiceability => _hi ? 'सेवा उपलब्धता जाँचें' : 'Check serviceability';
  String get serviceable => _hi ? 'सेवा उपलब्ध है' : 'Service available';
  String get notServiceable => _hi ? 'सेवा उपलब्ध नहीं' : 'Not serviceable yet';
  String get serviceCities => _hi ? 'सेवा शहर' : 'Service cities';
  String get serviceCitiesHint => _hi
      ? 'LIVORA वर्तमान में इन शहरों में उपलब्ध है।'
      : 'LIVORA currently serves these cities.';
  String get savedAddresses => _hi ? 'सहेजे गए पते' : 'Saved addresses';
  String get requiredField => _hi ? 'आवश्यक' : 'Required';
  String get professionals => _hi ? 'पेशेवर' : 'Professionals';
  String get searchProfessionals => _hi ? 'पेशेवर खोजें…' : 'Search professionals…';
  String get filterByCity => _hi ? 'शहर से फ़िल्टर' : 'Filter by city';
  String get professionalsEmpty =>
      _hi ? 'कोई पेशेवर नहीं मिला।' : 'No professionals found.';
  String get sortByRating => _hi ? 'रेटिंग' : 'Rating';
  String get sortByExperience => _hi ? 'अनुभव' : 'Experience';
  String get sortByJobs => _hi ? 'जॉब्स' : 'Jobs';
  String get skills => _hi ? 'कौशल' : 'Skills';
  String get reviews => _hi ? 'समीक्षाएँ' : 'Reviews';
  String get noReviews => _hi ? 'अभी कोई समीक्षा नहीं।' : 'No reviews yet.';
  String get writeReview => _hi ? 'समीक्षा लिखें' : 'Write a review';
  String get reviewTitle => _hi ? 'शीर्षक' : 'Title';
  String get reviewBody => _hi ? 'आपका अनुभव' : 'Your experience';
  String get submitReview => _hi ? 'समीक्षा भेजें' : 'Submit review';
  String get reviewSubmitted => _hi ? 'समीक्षा सहेजी गई' : 'Review submitted';
  String get yearsExp => _hi ? 'वर्ष अनुभव' : 'yrs exp';
  String get jobsCompleted => _hi ? 'जॉब पूरे' : 'jobs done';
  String get viewProfessionals => _hi ? 'पेशेवर देखें' : 'View professionals';
  String get verified => _hi ? 'सत्यापित' : 'Verified';
  String get notVerified => _hi ? 'सत्यापन लंबित' : 'Verification pending';
  String get myBookings => _hi ? 'मेरी बुकिंग' : 'My bookings';
  String get bookingsUpcoming => _hi ? 'आगामी' : 'Upcoming';
  String get bookingsInProgress => _hi ? 'चल रही' : 'In progress';
  String get bookingsCompleted => _hi ? 'पूर्ण' : 'Completed';
  String get bookingsCancelled => _hi ? 'रद्द' : 'Cancelled';
  String get bookingsFilterAll => _hi ? 'सभी' : 'All';
  String get bookingsFilterEmpty =>
      _hi ? 'इस फ़िल्टर में कोई बुकिंग नहीं।' : 'No bookings in this filter.';
  String get bookingsShowAll => _hi ? 'सभी दिखाएँ' : 'Show all';
  String get bookingStatusPending => _hi ? 'लंबित' : 'Pending';
  String get bookingStatusConfirmed => _hi ? 'पुष्टि' : 'Confirmed';
  String get bookingStatusInProgress => _hi ? 'चल रही' : 'In progress';
  String get bookingStatusCompleted => _hi ? 'पूर्ण' : 'Completed';
  String get bookingStatusCancelled => _hi ? 'रद्द' : 'Cancelled';
  String get bookService => _hi ? 'सेवा बुक करें' : 'Book service';
  String get bookingsEmpty => _hi ? 'अभी कोई बुकिंग नहीं।' : 'No bookings yet.';
  String get cancelBooking => _hi ? 'रद्द करें' : 'Cancel';
  String get bookingCancelled => _hi ? 'बुकिंग रद्द हुई' : 'Booking cancelled';
  String get bookingCreated => _hi ? 'बुकिंग बनाई गई' : 'Booking created';
  String get selectDate => _hi ? 'तारीख चुनें' : 'Select date';
  String get selectSlot => _hi ? 'समय चुनें' : 'Select time slot';
  String get selectAddress => _hi ? 'पता चुनें' : 'Select address';
  String get noSlots => _hi ? 'इस दिन कोई स्लॉट नहीं।' : 'No slots on this day.';
  String get bookingNotes => _hi ? 'नोट्स' : 'Notes';
  String get confirmBooking => _hi ? 'बुकिंग पुष्टि करें' : 'Confirm booking';
  String get partnerJobs => _hi ? 'जॉब्स' : 'Jobs';
  String get setAvailability => _hi ? 'उपलब्धता सेट करें' : 'Set availability';
  String get wallet => _hi ? 'वॉलेट' : 'Wallet';
  String get walletBalance => _hi ? 'शेष राशि' : 'Balance';
  String get walletHint =>
      _hi ? 'वॉलेट बैलेंस बुकिंग भुगतान में इस्तेमाल करें।' : 'Use wallet balance toward booking payments.';
  String get walletHowItWorks => _hi ? 'यह कैसे काम करता है' : 'How it works';
  String get walletTipPay => _hi ? 'बुकिंग पर भुगतान' : 'Pay on bookings';
  String get walletTipPayBody => _hi
      ? 'चेकआउट पर वॉलेट बैलेंस अपने आप लागू कर सकते हैं।'
      : 'Apply your balance at checkout when you pay for a booking.';
  String get walletTipMembership => _hi ? 'सदस्यता क्रेडिट' : 'Membership credit';
  String get walletTipMembershipBody => _hi
      ? 'प्लान सब्सक्राइब करने पर वॉलेट क्रेडिट मिल सकता है।'
      : 'Subscribing to a plan may add wallet credit to your account.';
  String get walletTipSecure => _hi ? 'सुरक्षित बैलेंस' : 'Secure balance';
  String get walletTipSecureBody => _hi
      ? 'आपका वॉलेट आपके LIVORA खाते से जुड़ा और सुरक्षित है।'
      : 'Your wallet is tied to your LIVORA account and kept secure.';
  String get walletQuickActions => _hi ? 'त्वरित क्रियाएँ' : 'Quick actions';
  String get payNow => _hi ? 'अभी भुगतान करें' : 'Pay now';
  String get couponCode => _hi ? 'कूपन कोड' : 'Coupon code';
  String get discount => _hi ? 'छूट' : 'Discount';
  String get useWallet => _hi ? 'वॉलेट उपयोग करें' : 'Use wallet';
  String get confirmPayment => _hi ? 'भुगतान पुष्टि करें' : 'Confirm payment';
  String get paymentSuccess => _hi ? 'भुगतान सफल' : 'Payment successful';
  String get unpaid => _hi ? 'अवैतनिक' : 'Unpaid';
  String get paid => _hi ? 'भुगतान हुआ' : 'Paid';
  String get trackLive => _hi ? 'लाइव ट्रैक' : 'Track live';
  String get liveTracking => _hi ? 'लाइव ट्रैकिंग' : 'Live tracking';
  String get etaLabel => _hi ? 'अनुमानित समय' : 'ETA';
  String get distanceLabel => _hi ? 'दूरी' : 'Distance';
  String get enRoute => _hi ? 'रास्ते में' : 'En route';
  String get arrived => _hi ? 'पहुँच गए' : 'Arrived';
  String get shareLocation => _hi ? 'लोकेशन साझा करें' : 'Share location';
  String get navigateJob => _hi ? 'नेविगेट' : 'Navigate';
  String get markArrived => _hi ? 'पहुँचा चिह्नित करें' : 'Mark arrived';
  String get endTracking => _hi ? 'ट्रैकिंग बंद करें' : 'End tracking';
  String get pickOnMap => _hi ? 'मानचित्र पर चुनें' : 'Pick on map';
  String get trackingUnavailable =>
      _hi ? 'ट्रैकिंग अभी उपलब्ध नहीं।' : 'Tracking not available yet.';
  String get trackingEmpty =>
      _hi ? 'पेशेवर का लोकेशन अपडेट प्रतीक्षित।' : 'Waiting for professional location.';
  String get chat => _hi ? 'चैट' : 'Chat';
  String get messages => _hi ? 'संदेश' : 'Messages';
  String get typeMessage => _hi ? 'संदेश लिखें' : 'Type a message';
  String get send => _hi ? 'भेजें' : 'Send';
  String get voiceCall => _hi ? 'वॉइस कॉल' : 'Voice call';
  String get callConnecting => _hi ? 'कनेक्ट हो रहा है…' : 'Connecting…';
  String get callActive => _hi ? 'कॉल सक्रिय' : 'Call active';
  String get endCall => _hi ? 'कॉल समाप्त' : 'End call';
  String get answerCall => _hi ? 'उत्तर दें' : 'Answer';
  String get notificationsEmpty => _hi ? 'कोई सूचना नहीं।' : 'No notifications yet.';
  String get markAllRead => _hi ? 'सभी पढ़ीं' : 'Mark all read';
  String get chatsEmpty => _hi ? 'अभी कोई चैट नहीं।' : 'No chats yet.';
  String get kyc => _hi ? 'केवाईसी' : 'KYC';
  String get kycStatus => _hi ? 'केवाईसी स्थिति' : 'KYC status';
  String get submitDocument => _hi ? 'दस्तावेज़ जमा करें' : 'Submit document';
  String get kycDocuments => _hi ? 'दस्तावेज़' : 'Documents';
  String get kycUpload => _hi ? 'दस्तावेज़ अपलोड' : 'Upload document';
  String get kycDocumentUrl => _hi ? 'दस्तावेज़ URL' : 'Document URL';
  String get kycDocType => _hi ? 'दस्तावेज़ प्रकार' : 'Document type';
  String get kycRequired => _hi ? 'आवश्यक' : 'Required';
  String get kycMissing => _hi ? 'बाकी' : 'Missing';
  String get kycVerified => _hi ? 'सत्यापित' : 'Verified';
  String get kycNotVerified => _hi ? 'असत्यापित' : 'Not verified';
  String get kycDocIdProof => _hi ? 'आईडी प्रूफ' : 'ID proof';
  String get kycDocAddress => _hi ? 'पता प्रूफ' : 'Address proof';
  String get kycDocSelfie => _hi ? 'सेल्फी' : 'Selfie';
  String get kycDocCertificate => _hi ? 'प्रमाणपत्र' : 'Certificate';
  String get kycNoDocuments =>
      _hi ? 'अभी कोई दस्तावेज़ जमा नहीं।' : 'No documents submitted yet.';
  String get availabilityEditor => _hi ? 'उपलब्धता' : 'Availability';
  String get availabilityHeroTitle =>
      _hi ? 'अपने काम के दिन सेट करें' : 'Set your working days';
  String get availabilityHeroSubtitle => _hi
      ? 'ग्राहक इन्हीं स्लॉट्स में बुकिंग कर सकेंगे।'
      : 'Customers can book you in these slots.';
  String get availabilityActiveDays => _hi ? 'सक्रिय दिन' : 'Active days';
  String get availabilityHours => _hi ? 'कार्य घंटे' : 'Working hours';
  String get availabilityStart => _hi ? 'शुरुआत (HH:MM)' : 'Start (HH:MM)';
  String get availabilityEnd => _hi ? 'समाप्ति (HH:MM)' : 'End (HH:MM)';
  String get availabilityDaysOn =>
      _hi ? '{n} दिन सक्रिय' : '{n} days active';
  String get dayMon => _hi ? 'सोम' : 'Mon';
  String get dayTue => _hi ? 'मंगल' : 'Tue';
  String get dayWed => _hi ? 'बुध' : 'Wed';
  String get dayThu => _hi ? 'गुरु' : 'Thu';
  String get dayFri => _hi ? 'शुक्र' : 'Fri';
  String get daySat => _hi ? 'शनि' : 'Sat';
  String get daySun => _hi ? 'रवि' : 'Sun';
  String get timeOff => _hi ? 'छुट्टी' : 'Time off';
  String get addTimeOff => _hi ? 'छुट्टी जोड़ें' : 'Add time off';
  String get timeOffHeroTitle =>
      _hi ? 'छुट्टियाँ मैनेज करें' : 'Manage your time off';
  String get timeOffHeroSubtitle => _hi
      ? 'इन दिनों ग्राहक आपको बुक नहीं कर सकेंगे।'
      : 'Customers won’t be able to book you on these days.';
  String get timeOffUpcoming => _hi ? 'आगामी छुट्टियाँ' : 'Upcoming time off';
  String get timeOffEmpty =>
      _hi ? 'अभी कोई छुट्टी नहीं जोड़ी गई।' : 'No time off added yet.';
  String get timeOffNotes => _hi ? 'कारण / नोट्स' : 'Reason / notes';
  String get timeOffAddHint => _hi
      ? 'कल के लिए एक दिन की छुट्टी जोड़ता है।'
      : 'Adds one full day off starting tomorrow.';
  String get rejectJob => _hi ? 'अस्वीकार करें' : 'Reject';
  String get jobsFilter => _hi ? 'फ़िल्टर' : 'Filter';
  String get kycRequiredHint =>
      _hi ? 'जॉब स्वीकार करने से पहले केवाईसी पूरा करें।' : 'Complete KYC before accepting jobs.';
  String get partnerWallet => _hi ? 'पार्टनर वॉलेट' : 'Partner wallet';
  String get withdraw => _hi ? 'निकासी' : 'Withdraw';
  String get partnerWalletHint => _hi
      ? 'जॉब कमाई यहाँ जमा होती है। ₹100 से निकासी करें।'
      : 'Job earnings land here. Withdraw from ₹100.';
  String get partnerWithdrawMin =>
      _hi ? 'निकासी के लिए कम से कम ₹100 चाहिए।' : 'Need at least ₹100 to withdraw.';
  String get partnerLedgerEmpty =>
      _hi ? 'अभी कोई लेनदेन नहीं।' : 'No transactions yet.';
  String get partnerWithdrawals => _hi ? 'निकासी अनुरोध' : 'Withdrawals';
  String get attendance => _hi ? 'हाज़िरी' : 'Attendance';
  String get checkIn => _hi ? 'चेक-इन' : 'Check in';
  String get checkOut => _hi ? 'चेक-आउट' : 'Check out';
  String get attendanceHeroTitle =>
      _hi ? 'आज की हाज़िरी' : 'Today’s attendance';
  String get attendanceHeroSubtitle => _hi
      ? 'शिफ्ट शुरू और खत्म करने के लिए चेक-इन/आउट करें।'
      : 'Check in and out to mark your shift.';
  String get attendanceHistory => _hi ? 'इतिहास' : 'History';
  String get attendanceEmpty =>
      _hi ? 'अभी कोई हाज़िरी रिकॉर्ड नहीं।' : 'No attendance records yet.';
  String get attendanceCheckedIn => _hi ? 'चेक-इन' : 'Checked in';
  String get attendanceCheckedOut => _hi ? 'चेक-आउट' : 'Checked out';
  String get attendanceOpen => _hi ? 'शिफ्ट खुली' : 'Shift open';
  String get attendanceNotStarted => _hi ? 'शुरू नहीं' : 'Not started';
  String get performance => _hi ? 'प्रदर्शन' : 'Performance';
  String get earnings => _hi ? 'कमाई' : 'Earnings';
  String get onTimeRate => _hi ? 'समय पर पहुँच' : 'On-time rate';
  String get performanceHeroSubtitle => _hi
      ? 'आपके स्कोर और पिछले 30 दिनों का सार।'
      : 'Your scores and last 30 days at a glance.';
  String get performanceLast30d => _hi ? 'पिछले 30 दिन' : 'Last 30 days';
  String get coupons => _hi ? 'कूपन' : 'Coupons';
  String get pricing => _hi ? 'मूल्य निर्धारण' : 'Pricing';
  String get roles => _hi ? 'भूमिकाएँ' : 'Roles';
  String get addCoupon => _hi ? 'कूपन जोड़ें' : 'Add coupon';
  String get addPriceOverride => _hi ? 'शहर मूल्य जोड़ें' : 'Add city price';
  String get deactivate => _hi ? 'निष्क्रिय' : 'Deactivate';
  String get assignRole => _hi ? 'भूमिका असाइन' : 'Assign role';
  String get verification => _hi ? 'सत्यापन' : 'Verification';
  String get dispatch => _hi ? 'डिस्पैच' : 'Dispatch';
  String get escalations => _hi ? 'एस्केलेशन' : 'Escalations';
  String get reassign => _hi ? 'पुनः असाइन' : 'Reassign';
  String get autoAssign => _hi ? 'ऑटो असाइन' : 'Auto-assign';
  String get resolve => _hi ? 'हल करें' : 'Resolve';
  String get createEscalation => _hi ? 'एस्केलेशन बनाएँ' : 'Create escalation';
  String get support => _hi ? 'सहायता' : 'Support';
  String get createTicket => _hi ? 'टिकट बनाएँ' : 'Create ticket';
  String get createTicketHint => _hi
      ? 'हम जल्द ही आपको जवाब देंगे।'
      : 'Tell us what you need help with. We’ll get back soon.';
  String get ticketSubject => _hi ? 'विषय' : 'Subject';
  String get ticketSubjectHint =>
      _hi ? 'संक्षेप में समस्या बताएँ' : 'Briefly describe the issue';
  String get ticketMessage => _hi ? 'संदेश' : 'Message';
  String get ticketMessageHint =>
      _hi ? 'अधिक विवरण लिखें…' : 'Add more details…';
  String get submitTicket => _hi ? 'भेजें' : 'Submit';
  String get ticketCreated => _hi ? 'टिकट बना दिया गया' : 'Ticket created';
  String get supportEmpty =>
      _hi ? 'अभी कोई सहायता टिकट नहीं।' : 'No support tickets yet.';
  String get ticketConversation => _hi ? 'बातचीत' : 'Conversation';
  String get ticketYou => _hi ? 'आप' : 'You';
  String get membership => _hi ? 'सदस्यता' : 'Membership';
  String get membershipHeroTitle =>
      _hi ? 'घर की देखभाल, सदस्य लाभों के साथ' : 'Home care, with member perks';
  String get membershipHeroSubtitle => _hi
      ? 'छूट, वॉलेट क्रेडिट और प्राथमिकता सेवाएँ।'
      : 'Discounts, wallet credit, and priority care.';
  String get membershipInactive =>
      _hi ? 'कोई सक्रिय सदस्यता नहीं' : 'No active membership';
  String get membershipActiveUntil => _hi ? 'सक्रिय · {plan} · {date} तक' : 'Active · {plan} until {date}';
  String get membershipDays => _hi ? '{n} दिन' : '{n} days';
  String get membershipDiscount => _hi ? '{n}% छूट' : '{n}% off';
  String get membershipCredit => _hi ? '₹{n} क्रेडिट' : '₹{n} credit';
  String get membershipCurrentPlan => _hi ? 'वर्तमान योजना' : 'Current plan';
  String get membershipEmptyPlans =>
      _hi ? 'अभी कोई योजना उपलब्ध नहीं।' : 'No plans available right now.';
  String get membershipChoosePlan =>
      _hi ? 'योजना चुनें' : 'Choose a plan';
  String get referral => _hi ? 'रेफ़रल' : 'Referral';
  String get referralEyebrow => _hi ? 'दोस्तों के साथ साझा करें' : 'SHARE WITH FRIENDS';
  String get referralHeroTitle =>
      _hi ? 'दोनों को मिलता है क्रेडिट' : 'You both get credit';
  String get referralHeroSubtitle => _hi
      ? 'अपना कोड शेयर करें और वॉलेट क्रेडिट पाएँ।'
      : 'Share your code and earn wallet credit together.';
  String get referralYourCode => _hi ? 'आपका कोड' : 'Your code';
  String get referralYouEarn => _hi ? 'आप पाते हैं' : 'You earn';
  String get referralFriendEarns => _hi ? 'मित्र पाता है' : 'Friend earns';
  String get referralRedeemed => _hi ? 'रिडीम हुए' : 'Redeemed';
  String get referralCopied => _hi ? 'कोड कॉपी हो गया' : 'Code copied';
  String get invoices => _hi ? 'इनवॉइस' : 'Invoices';
  String get subscribe => _hi ? 'सब्सक्राइब' : 'Subscribe';
  String get copyCode => _hi ? 'कोड कॉपी करें' : 'Copy code';
  String get analytics => _hi ? 'एनालिटिक्स' : 'Analytics';
  String get auditLog => _hi ? 'ऑडिट लॉग' : 'Audit log';
  String get fraudQueue => _hi ? 'धोखाधड़ी कतार' : 'Fraud queue';
  String get dismiss => _hi ? 'खारिज' : 'Dismiss';
  String get confirmFraud => _hi ? 'पुष्टि' : 'Confirm';
  String get systemHealth => _hi ? 'सिस्टम स्वास्थ्य' : 'System health';
}

class LivoraStringsDelegate extends LocalizationsDelegate<LivoraStrings> {
  const LivoraStringsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'hi'].contains(locale.languageCode);

  @override
  Future<LivoraStrings> load(Locale locale) async => LivoraStrings(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<LivoraStrings> old) => false;
}
