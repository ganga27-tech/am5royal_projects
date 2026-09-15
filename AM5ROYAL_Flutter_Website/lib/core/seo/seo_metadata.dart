class SeoMetadata {
  const SeoMetadata({
    required this.title,
    required this.description,
    required this.path,
    this.keywords,
    this.imageUrl = 'https://am5royal.com/favicon.png',
    this.imageAlt = 'AM5 ROYAL - Home Services Platform',
  });

  static const String siteName = 'AM5 ROYAL';
  static const String baseUrl = 'https://am5royal.com';
  static const String locale = 'en_IN';

  final String title;
  final String description;
  final String path;
  final String? keywords;
  final String imageUrl;
  final String imageAlt;

  String get canonicalUrl => '$baseUrl$path';

  static const SeoMetadata home = SeoMetadata(
    title: 'AM5 ROYAL | Trusted Home Services Across India',
    description:
        'AM5 ROYAL is a trusted home services platform connecting customers with verified professionals for cleaning, plumbing, electrical, painting, pest control, appliance repair, carpentry and other services across India.',
    path: '/',
    keywords: 'AM5 ROYAL, home services India, home service platform India, '
        'home cleaning services, deep cleaning services, plumbing services, '
        'electrical services, painting services, pest control services, '
        'appliance repair, carpentry services, verified professionals, '
        'home maintenance services',
  );

  static const SeoMetadata services = SeoMetadata(
    title: 'Our Services | AM5 ROYAL',
    description:
        'Explore home services offered by AM5 ROYAL including cleaning, '
        'plumbing, electrical work, painting, pest control, appliance repair, '
        'carpentry and more across India.',
    path: '/services',
    keywords: 'AM5 ROYAL services, book home services, cleaning services, '
        'plumbing, electrical, painting, pest control',
  );

  static const SeoMetadata vendor = SeoMetadata(
    title: 'Become a Partner | AM5 ROYAL',
    description: 'Join AM5 ROYAL as a trusted service partner and connect with '
        'customers looking for reliable home service professionals across India.',
    path: '/vendor',
    keywords: 'AM5 ROYAL vendor, AM5 ROYAL partner, become a service partner, '
        'home service partner India, vendor registration',
  );

  static const SeoMetadata customer = SeoMetadata(
    title: 'For Customers | AM5 ROYAL',
    description:
        'Book trusted home service professionals with AM5 ROYAL. Easy booking, '
        'verified vendors, and reliable service across India.',
    path: '/customer',
  );

  static const SeoMetadata freelancer = SeoMetadata(
    title: 'For Freelancers | AM5 ROYAL',
    description:
        'Join AM5 ROYAL as a freelancer partner and grow your home services '
        'business with verified leads and platform support.',
    path: '/freelancer',
  );

  static const SeoMetadata careers = SeoMetadata(
    title: 'Careers | AM5 ROYAL',
    description:
        'Explore career opportunities at AM5 ROYAL and help build India\'s '
        'trusted home services platform.',
    path: '/careers',
  );

  static const SeoMetadata contact = SeoMetadata(
    title: 'Contact Us | AM5 ROYAL',
    description:
        'Get in touch with AM5 ROYAL for customer support, partnerships, '
        'and home service enquiries across India.',
    path: '/contact',
  );

  static const SeoMetadata howItWorks = SeoMetadata(
    title: 'How It Works | AM5 ROYAL',
    description:
        'Learn how AM5 ROYAL connects customers with verified home service '
        'professionals for quick and reliable bookings.',
    path: '/how-it-works',
  );

  static const SeoMetadata faqs = SeoMetadata(
    title: 'FAQs | AM5 ROYAL',
    description:
        'Find answers to frequently asked questions about booking, payments, '
        'vendors, and services on AM5 ROYAL.',
    path: '/faqs',
  );

  static const SeoMetadata privacyPolicy = SeoMetadata(
    title: 'Privacy Policy | AM5 ROYAL',
    description:
        'Read the AM5 ROYAL privacy policy to understand how we collect, '
        'use, and protect your personal information.',
    path: '/privacy-policy',
  );

  static const SeoMetadata termsConditions = SeoMetadata(
    title: 'Terms & Conditions | AM5 ROYAL',
    description:
        'Review the terms and conditions for using AM5 ROYAL home services '
        'platform and booking services.',
    path: '/terms-conditions',
  );

  static const SeoMetadata booking = SeoMetadata(
    title: 'Book a Service | AM5 ROYAL',
    description:
        'Book home services with verified AM5 ROYAL professionals. Select '
        'your service, vendor, and schedule in a few steps.',
    path: '/book',
  );

  static List<SeoMetadata> get allPages => [
        home,
        services,
        vendor,
        customer,
        freelancer,
        careers,
        contact,
        howItWorks,
        faqs,
        privacyPolicy,
        termsConditions,
      ];
}
