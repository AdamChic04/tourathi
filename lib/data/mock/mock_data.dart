import '../models/models.dart';

class MockData {
  MockData._();

  static const String userAvatar =
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200';
  static const String userName = 'Ahmad Al-Khatib';

  static final List<Place> popularPlaces = [
    const Place(
      id: 'petra',
      name: 'Petra',
      nameAr: 'البتراء',
      description: 'The Rose City, a UNESCO World Heritage site',
      descriptionAr: 'المدينة الوردية، موقع تراث عالمي لليونسكو',
      location: 'Ma\'an, Jordan',
      locationAr: 'معان، الأردن',
      imageUrl:
          'https://images.unsplash.com/photo-1579600654421-bf556c1c1b9c?w=800',
      rating: 4.9,
      distance: '3.2 km',
      price: '50 JOD',
      category: 'heritage',
      historicalStory:
          'Petra was the capital of the Nabataean Kingdom, carved into rose-red sandstone cliffs over 2,000 years ago.',
      historicalStoryAr:
          'كانت البتراء عاصمة المملكة النبطية، منحوتة في منحدرات الحجر الرملي الوردي منذ أكثر من 2000 عام.',
      visitingHours: '6:00 AM - 6:00 PM',
      entryFee: '50 JOD',
      reviewCount: 2847,
    ),
    const Place(
      id: 'jerash',
      name: 'Jerash',
      nameAr: 'جرش',
      description: 'One of the best-preserved Roman cities outside Italy',
      descriptionAr: 'من أفضل المدن الرومانية المحفوظة خارج إيطاليا',
      location: 'Jerash, Jordan',
      locationAr: 'جرش، الأردن',
      imageUrl:
          'https://images.unsplash.com/photo-1586724676337-5a1a8b8e8e8e?w=800',
      rating: 4.8,
      distance: '45 km',
      price: '10 JOD',
      category: 'heritage',
      visitingHours: '8:00 AM - 5:00 PM',
      entryFee: '10 JOD',
      reviewCount: 1523,
    ),
    const Place(
      id: 'wadi-rum',
      name: 'Wadi Rum',
      nameAr: 'وادي رم',
      description: 'The Valley of the Moon, a Martian landscape on Earth',
      descriptionAr: 'وادي القمر، منظر مريخي على الأرض',
      location: 'Aqaba, Jordan',
      locationAr: 'العقبة، الأردن',
      imageUrl:
          'https://images.unsplash.com/photo-1509316785289-025f5b846b35?w=800',
      rating: 4.9,
      distance: '320 km',
      price: '5 JOD',
      category: 'adventure',
      reviewCount: 3102,
    ),
    const Place(
      id: 'dead-sea',
      name: 'Dead Sea',
      nameAr: 'البحر الميت',
      description: 'The lowest point on Earth with therapeutic waters',
      descriptionAr: 'أخفض نقطة على الأرض بمياه علاجية',
      location: 'Dead Sea, Jordan',
      locationAr: 'البحر الميت، الأردن',
      imageUrl:
          'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800',
      rating: 4.7,
      distance: '55 km',
      price: '25 JOD',
      category: 'adventure',
      reviewCount: 1890,
    ),
  ];

  static final List<Place> hiddenGems = [
    const Place(
      id: 'ottoman-village',
      name: 'Hidden Ottoman Village',
      nameAr: 'القرية العثمانية المخفية',
      description: 'A preserved Ottoman-era village in the hills of Salt',
      descriptionAr: 'قرية عثمانية محفوظة في تلال السلط',
      location: 'As-Salt, Jordan',
      locationAr: 'السلط، الأردن',
      imageUrl:
          'https://images.unsplash.com/photo-1518548419970-58e3b4079ab2?w=800',
      rating: 4.6,
      category: 'heritage',
    ),
    const Place(
      id: 'desert-archaeological',
      name: 'Desert Archaeological Site',
      nameAr: 'موقع أثري صحراوي',
      description: 'Ancient Nabataean trading post in the eastern desert',
      descriptionAr: 'محطة تجارية نبطية قديمة في الصحراء الشرقية',
      location: 'Eastern Desert, Jordan',
      locationAr: 'الصحراء الشرقية، الأردن',
      imageUrl:
          'https://images.unsplash.com/photo-1509316975850-fc29d0d7373b?w=800',
      rating: 4.5,
      category: 'heritage',
    ),
    const Place(
      id: 'craft-town',
      name: 'Traditional Craft Town',
      nameAr: 'مدينة الحرف التقليدية',
      description: 'Artisan workshops preserving Jordanian handicrafts',
      descriptionAr: 'ورش حرفية تحافظ على الحرف الأردنية',
      location: 'Madaba, Jordan',
      locationAr: 'مادبا، الأردن',
      imageUrl:
          'https://images.unsplash.com/photo-1459749411175-04bf5294ceea?w=800',
      rating: 4.7,
      category: 'heritage',
    ),
  ];

  static final List<Event> events = [
    const Event(
      id: 'jerash-festival',
      title: 'Jerash Festival of Culture & Arts',
      titleAr: 'مهرجان جرش للثقافة والفنون',
      date: 'Jul 15-25, 2026',
      location: 'Jerash',
      imageUrl:
          'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?w=800',
    ),
    const Event(
      id: 'petra-by-night',
      title: 'Petra by Night Candle Walk',
      titleAr: 'البتراء ليلاً - مسيرة الشموع',
      date: 'Every Mon & Thu',
      location: 'Petra',
      imageUrl:
          'https://images.unsplash.com/photo-1579600654421-bf556c1c1b9c?w=800',
    ),
    const Event(
      id: 'amman-food-fest',
      title: 'Amman Street Food Festival',
      titleAr: 'مهرجان طعام الشوارع في عمان',
      date: 'Aug 5-7, 2026',
      location: 'Amman',
      imageUrl:
          'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800',
    ),
  ];

  static final List<Activity> activities = [
    Activity(
      id: 'petra-hike',
      title: 'Petra Back Trail Hike',
      titleAr: 'مسار البتراء الخلفي',
      host: 'Jordan Trail Association',
      imageUrl:
          'https://images.unsplash.com/photo-1551632811-561732d1e306?w=800',
      rating: 4.8,
      difficulty: 'Moderate',
      price: '35 JOD',
      date: 'Jun 25, 2026',
      category: 'hiking',
      description:
          'Explore the lesser-known back trails of Petra with expert guides.',
      communityName: 'Ajloun Hikers',
      organizer: 'Omar Al-Rashid',
      destination: 'Petra, Ma\'an',
      historicalSummary:
          'Walk ancient Nabataean paths used by traders over 2,000 years ago.',
      schedule: const [
        ScheduleItem(time: '7:00 AM', activity: 'Departure from Amman'),
        ScheduleItem(time: '9:30 AM', activity: 'Arrival at Petra'),
        ScheduleItem(time: '12:00 PM', activity: 'Lunch at local restaurant'),
        ScheduleItem(time: '4:00 PM', activity: 'Return to Amman'),
      ],
      whatToBring: const [
        'Hiking boots',
        'Sunscreen',
        '2L water',
        'Hat',
        'Camera',
      ],
      safetyInstructions: const [
        'Stay with the group at all times',
        'Inform guide of any medical conditions',
        'Carry emergency contact card',
      ],
      voucherDiscount: 15,
    ),
    Activity(
      id: 'wadi-rum-camp',
      title: 'Wadi Rum Desert Camping',
      titleAr: 'تخييم وادي رم الصحراوي',
      host: 'Bedouin Experience Co.',
      imageUrl:
          'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=800',
      rating: 4.9,
      difficulty: 'Easy',
      price: '65 JOD',
      date: 'Jul 1-2, 2026',
      category: 'camping',
      communityName: 'Bedouin Stargazers',
      organizer: 'Faisal Al-Bedouin',
      destination: 'Wadi Rum',
      voucherDiscount: 10,
    ),
    Activity(
      id: 'petra-photo',
      title: 'Petra Night Photography',
      titleAr: 'تصوير البتراء ليلاً',
      host: 'Lens of Jordan',
      imageUrl:
          'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800',
      rating: 4.7,
      difficulty: 'Moderate',
      price: '45 JOD',
      date: 'Jun 28, 2026',
      category: 'photography',
      communityName: 'Petra Night Photographers',
      organizer: 'Layla Al-Photo',
      destination: 'Petra',
      voucherDiscount: 20,
    ),
    Activity(
      id: 'madaba-food',
      title: 'Madaba Mosaic Food Tour',
      titleAr: 'جولة طعام فسيفساء مادبا',
      host: 'Taste of Jordan',
      imageUrl:
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800',
      rating: 4.6,
      difficulty: 'Easy',
      price: '28 JOD',
      date: 'Jul 3, 2026',
      category: 'food',
      destination: 'Madaba',
    ),
    Activity(
      id: 'jerash-culture',
      title: 'Jerash Roman Heritage Tour',
      titleAr: 'جولة تراث جرش الروماني',
      host: 'Heritage Guides Jordan',
      imageUrl:
          'https://images.unsplash.com/photo-1565008576549-57569a49371d?w=800',
      rating: 4.8,
      difficulty: 'Easy',
      price: '22 JOD',
      date: 'Jul 5, 2026',
      category: 'cultural',
      destination: 'Jerash',
    ),
  ];

  static final List<Community> communities = [
    Community(
      id: 'bedouin-stargazers',
      name: 'Bedouin Stargazers',
      nameAr: 'مراقبو النجوم البدو',
      description:
          'Experience the magic of Wadi Rum under a blanket of stars with fellow astronomy enthusiasts.',
      descriptionAr:
          'استمتع بسحر وادي رم تحت غطاء من النجوم مع عشاق الفلك.',
      coverImage:
          'https://images.unsplash.com/photo-1419242902214-272b3f66ee7a?w=800',
      logoUrl:
          'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=200',
      memberCount: 1247,
      rating: 4.9,
      category: 'camping',
      isVerified: true,
      achievements: const [
        '500+ stargazing events',
        'Top rated community 2025',
        'UNESCO partner',
      ],
      upcomingTrips: [activities[1]],
      pastAdventures: const [
        'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=400',
        'https://images.unsplash.com/photo-1419242902214-272b3f66ee7a?w=400',
        'https://images.unsplash.com/photo-1509316785289-025f5b846b35?w=400',
      ],
    ),
    Community(
      id: 'petra-photographers',
      name: 'Petra Night Photographers',
      nameAr: 'مصورو البتراء الليلية',
      description:
          'Capture the ethereal beauty of Petra illuminated by thousands of candles.',
      descriptionAr: 'التقط الجمال الساحر للبتراء المضاءة بآلاف الشموع.',
      coverImage:
          'https://images.unsplash.com/photo-1579600654421-bf556c1c1b9c?w=800',
      logoUrl:
          'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=200',
      memberCount: 892,
      rating: 4.8,
      category: 'photography',
      isVerified: true,
      achievements: const [
        'Featured in National Geographic',
        '2000+ photos shared',
      ],
      upcomingTrips: [activities[2]],
    ),
    Community(
      id: 'ajloun-hikers',
      name: 'Ajloun Hikers',
      nameAr: 'متسلقو عجلون',
      description:
          'Explore Jordan\'s lush northern forests and historic castle trails.',
      descriptionAr: 'استكشف غابات الأردن الشمالية الخصبة ومسارات القلاع التاريخية.',
      coverImage:
          'https://images.unsplash.com/photo-1551632811-561732d1e306?w=800',
      logoUrl:
          'https://images.unsplash.com/photo-1551632811-561732d1e306?w=200',
      memberCount: 2156,
      rating: 4.7,
      category: 'hiking',
      isVerified: true,
      achievements: const [
        '1000+ hikes completed',
        'Eco-tourism certified',
      ],
      upcomingTrips: [activities[0]],
    ),
  ];

  static final List<Ticket> tickets = [
    const Ticket(
      id: 't1',
      tripName: 'Petra Back Trail Hike',
      tripNameAr: 'مسار البتراء الخلفي',
      date: 'Jun 25, 2026',
      groupName: 'Ajloun Hikers',
      bookingNumber: 'TR-2026-0847',
      status: TicketStatus.upcoming,
      qrData: 'TR-2026-0847-PETRA',
      seat: 'A-12',
    ),
    const Ticket(
      id: 't2',
      tripName: 'Wadi Rum Desert Camping',
      tripNameAr: 'تخييم وادي رم الصحراوي',
      date: 'Jul 1-2, 2026',
      groupName: 'Bedouin Stargazers',
      bookingNumber: 'TR-2026-0912',
      status: TicketStatus.upcoming,
      qrData: 'TR-2026-0912-WADI',
      seat: 'B-05',
    ),
    const Ticket(
      id: 't3',
      tripName: 'Jerash Roman Heritage Tour',
      tripNameAr: 'جولة تراث جرش الروماني',
      date: 'May 15, 2026',
      groupName: 'Heritage Guides',
      bookingNumber: 'TR-2026-0634',
      status: TicketStatus.completed,
      qrData: 'TR-2026-0634-JERASH',
    ),
    const Ticket(
      id: 't4',
      tripName: 'Madaba Food Tour',
      tripNameAr: 'جولة طعام مادبا',
      date: 'Apr 20, 2026',
      groupName: 'Taste of Jordan',
      bookingNumber: 'TR-2026-0512',
      status: TicketStatus.cancelled,
      qrData: 'TR-2026-0512-MADABA',
    ),
  ];

  static final List<Mission> missions = [
    const Mission(
      id: 'm1',
      title: 'Petra Capture Challenge',
      titleAr: 'تحدي تصوير البتراء',
      reward: 200,
      icon: '📸',
      isCompleted: false,
    ),
    const Mission(
      id: 'm2',
      title: 'Visit Heritage Site',
      titleAr: 'زيارة موقع تراثي',
      reward: 150,
      icon: '🏛️',
      isCompleted: true,
    ),
    const Mission(
      id: 'm3',
      title: 'Join Community Trip',
      titleAr: 'انضم لرحلة مجتمعية',
      reward: 300,
      icon: '👥',
      isCompleted: false,
    ),
    const Mission(
      id: 'm4',
      title: 'Post Travel Journal',
      titleAr: 'انشر يوميات السفر',
      reward: 100,
      icon: '📝',
      isCompleted: true,
    ),
    const Mission(
      id: 'm5',
      title: 'Complete AR Experience',
      titleAr: 'أكمل تجربة الواقع المعزز',
      reward: 250,
      icon: '🥽',
      isCompleted: false,
    ),
  ];

  static final List<Product> products = [
    const Product(
      id: 'p1',
      name: 'Silver Nabataean Pendant',
      nameAr: 'قلادة نبطية فضية',
      price: '45 JOD',
      seller: 'Petra Artisan Co.',
      imageUrl:
          'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=400',
      rating: 4.8,
      category: 'jewelry',
    ),
    const Product(
      id: 'p2',
      name: 'Hand-painted Madaba Pottery',
      nameAr: 'فخار مادبا المرسوم يدوياً',
      price: '28 JOD',
      seller: 'Madaba Crafts',
      imageUrl:
          'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?w=400',
      rating: 4.6,
      category: 'pottery',
    ),
    const Product(
      id: 'p3',
      name: 'Bedouin Woven Textile',
      nameAr: 'نسيج بدوي منسوج',
      price: '65 JOD',
      seller: 'Desert Weavers',
      imageUrl:
          'https://images.unsplash.com/photo-1558171813-4c088753af8f?w=400',
      rating: 4.9,
      category: 'textiles',
    ),
    const Product(
      id: 'p4',
      name: 'Olive Wood Carving',
      nameAr: 'نحت خشب الزيتون',
      price: '35 JOD',
      seller: 'Bethlehem Crafts',
      imageUrl:
          'https://images.unsplash.com/photo-1454110736117-2aa5649fedd8?w=400',
      rating: 4.7,
      category: 'handicrafts',
    ),
    const Product(
      id: 'p5',
      name: 'Petra Sand Bottle Art',
      nameAr: 'فن زجاجة رمال البتراء',
      price: '15 JOD',
      seller: 'Souvenir Palace',
      imageUrl:
          'https://images.unsplash.com/photo-1513885535751-8b7238b69120?w=400',
      rating: 4.5,
      category: 'souvenirs',
    ),
  ];

  static final List<JournalPost> journalPosts = [
    const JournalPost(
      id: 'j1',
      userName: 'Layla Al-Hassan',
      userAvatar:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
      location: 'Petra, Jordan',
      imageUrl:
          'https://images.unsplash.com/photo-1579600654421-bf556c1c1b9c?w=800',
      caption:
          'Standing before the Treasury at sunrise — a moment I\'ll never forget. Jordan\'s magic is real. ✨',
      likes: 342,
      comments: 28,
      timeAgo: '2h ago',
    ),
    const JournalPost(
      id: 'j2',
      userName: 'Omar Al-Rashid',
      userAvatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
      location: 'Wadi Rum',
      imageUrl:
          'https://images.unsplash.com/photo-1509316785289-025f5b846b35?w=800',
      caption: 'Desert nights under a million stars. The Bedouin hospitality here is unmatched.',
      likes: 567,
      comments: 45,
      timeAgo: '5h ago',
      isAiGenerated: true,
    ),
    const JournalPost(
      id: 'j3',
      userName: 'Sara Al-Masri',
      userAvatar:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100',
      location: 'Jerash',
      imageUrl:
          'https://images.unsplash.com/photo-1565008576549-57569a49371d?w=800',
      caption: 'Walking through 2,000 years of history in Jerash. Every stone tells a story.',
      likes: 198,
      comments: 12,
      timeAgo: '1d ago',
    ),
  ];

  static final List<ChatMessage> chatMessages = [
    const ChatMessage(
      id: 'c1',
      sender: 'Omar',
      message: 'Welcome to Ajloun Hikers! Our next trip is June 25th.',
      time: '10:00 AM',
      isMe: false,
      isPinned: true,
    ),
    const ChatMessage(
      id: 'c2',
      sender: 'Layla',
      message: 'Can\'t wait! What should we bring?',
      time: '10:15 AM',
      isMe: false,
    ),
    const ChatMessage(
      id: 'c3',
      sender: 'You',
      message: 'I\'ll bring extra water bottles for the group.',
      time: '10:20 AM',
      isMe: true,
    ),
    const ChatMessage(
      id: 'c4',
      sender: 'Omar',
      message: '',
      time: '10:25 AM',
      isMe: false,
      imageUrl:
          'https://images.unsplash.com/photo-1551632811-561732d1e306?w=400',
    ),
    const ChatMessage(
      id: 'c5',
      sender: 'Faisal',
      message: 'Meeting point: Amman City Mall parking',
      time: '10:30 AM',
      isMe: false,
      isLocation: true,
    ),
    const ChatMessage(
      id: 'c6',
      sender: 'You',
      message: 'Voice message (0:32)',
      time: '10:35 AM',
      isMe: true,
      isVoice: true,
    ),
  ];

  static final List<PassportStamp> passportStamps = [
    const PassportStamp(
      id: 's1',
      name: 'Petra',
      nameAr: 'البتراء',
      isUnlocked: true,
      icon: '🏛️',
      date: 'Mar 15, 2026',
    ),
    const PassportStamp(
      id: 's2',
      name: 'Jerash',
      nameAr: 'جرش',
      isUnlocked: true,
      icon: '🏟️',
      date: 'May 15, 2026',
    ),
    const PassportStamp(
      id: 's3',
      name: 'Wadi Rum',
      nameAr: 'وادي رم',
      isUnlocked: true,
      icon: '🏜️',
      date: 'Apr 2, 2026',
    ),
    const PassportStamp(
      id: 's4',
      name: 'Amman Citadel',
      nameAr: 'قلعة عمان',
      isUnlocked: false,
      icon: '🏰',
    ),
    const PassportStamp(
      id: 's5',
      name: 'Dead Sea',
      nameAr: 'البحر الميت',
      isUnlocked: false,
      icon: '🌊',
    ),
    const PassportStamp(
      id: 's6',
      name: 'Ajloun Castle',
      nameAr: 'قلعة عجلون',
      isUnlocked: false,
      icon: '⚔️',
    ),
  ];

  static final List<EmergencyPlace> emergencyPlaces = [
    const EmergencyPlace(
      id: 'e1',
      name: 'Jordan University Hospital',
      nameAr: 'مستشفى الجامعة الأردنية',
      type: 'hospital',
      distance: '2.3 km',
      phone: '065300303',
    ),
    const EmergencyPlace(
      id: 'e2',
      name: 'Al-Hussein Medical Center',
      nameAr: 'مركز الحسين الطبي',
      type: 'hospital',
      distance: '4.1 km',
      phone: '065344000',
    ),
    const EmergencyPlace(
      id: 'e3',
      name: 'City Pharmacy',
      nameAr: 'صيدلية المدينة',
      type: 'pharmacy',
      distance: '0.8 km',
      phone: '065551234',
    ),
    const EmergencyPlace(
      id: 'e4',
      name: 'Abdali Police Station',
      nameAr: 'مركز شرطة العبدلي',
      type: 'police',
      distance: '1.5 km',
      phone: '065001234',
    ),
    const EmergencyPlace(
      id: 'e5',
      name: 'Tourist Police - Amman',
      nameAr: 'شرطة السياحة - عمان',
      type: 'tourist_police',
      distance: '2.0 km',
      phone: '065001911',
    ),
  ];

  static final List<AiTemplate> aiTemplates = [
    const AiTemplate(
      id: 't1',
      name: 'Bedouin Warrior',
      nameAr: 'محارب بدوي',
      imageUrl:
          'https://images.unsplash.com/photo-1509316785289-025f5b846b35?w=400',
      prompt: 'Transform into a noble Bedouin warrior in the desert',
    ),
    const AiTemplate(
      id: 't2',
      name: 'Nabataean Royalty',
      nameAr: 'ملكية نبطية',
      imageUrl:
          'https://images.unsplash.com/photo-1579600654421-bf556c1c1b9c?w=400',
      prompt: 'Become Nabataean royalty in the rose city of Petra',
    ),
    const AiTemplate(
      id: 't3',
      name: 'Ancient Petra Merchant',
      nameAr: 'تاجر بتراء قديم',
      imageUrl:
          'https://images.unsplash.com/photo-1518548419970-58e3b4079ab2?w=400',
      prompt: 'Step into the shoes of an ancient Petra spice merchant',
    ),
    const AiTemplate(
      id: 't4',
      name: 'Desert Explorer',
      nameAr: 'مستكشف الصحراء',
      imageUrl:
          'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=400',
      prompt: 'Become a legendary desert explorer of Wadi Rum',
    ),
    const AiTemplate(
      id: 't5',
      name: 'Roman Citizen of Jerash',
      nameAr: 'مواطن روماني في جرش',
      imageUrl:
          'https://images.unsplash.com/photo-1565008576549-57569a49371d?w=400',
      prompt: 'Walk the streets of ancient Jerash as a Roman citizen',
    ),
  ];

  static final List<String> exploreCategories = [
    'heritage',
    'hiking',
    'food',
    'museums',
    'religious',
    'adventure',
  ];

  static final List<String> arSites = ['petra', 'jerash', 'amman-citadel'];
}
