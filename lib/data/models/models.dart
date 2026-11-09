class Place {
  const Place({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.location,
    required this.locationAr,
    required this.imageUrl,
    required this.rating,
    this.distance,
    this.price,
    this.category = 'heritage',
    this.isFavorite = false,
    this.historicalStory,
    this.historicalStoryAr,
    this.visitingHours,
    this.entryFee,
    this.reviewCount = 0,
  });

  final String id;
  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final String location;
  final String locationAr;
  final String imageUrl;
  final double rating;
  final String? distance;
  final String? price;
  final String category;
  final bool isFavorite;
  final String? historicalStory;
  final String? historicalStoryAr;
  final String? visitingHours;
  final String? entryFee;
  final int reviewCount;
}

class Event {
  const Event({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.date,
    required this.location,
    required this.imageUrl,
  });

  final String id;
  final String title;
  final String titleAr;
  final String date;
  final String location;
  final String imageUrl;
}

class Activity {
  const Activity({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.host,
    required this.imageUrl,
    required this.rating,
    required this.difficulty,
    required this.price,
    required this.date,
    required this.category,
    this.description,
    this.schedule,
    this.whatToBring,
    this.safetyInstructions,
    this.communityName,
    this.organizer,
    this.destination,
    this.historicalSummary,
    this.voucherDiscount,
  });

  final String id;
  final String title;
  final String titleAr;
  final String host;
  final String imageUrl;
  final double rating;
  final String difficulty;
  final String price;
  final String date;
  final String category;
  final String? description;
  final List<ScheduleItem>? schedule;
  final List<String>? whatToBring;
  final List<String>? safetyInstructions;
  final String? communityName;
  final String? organizer;
  final String? destination;
  final String? historicalSummary;
  final int? voucherDiscount;
}

class ScheduleItem {
  const ScheduleItem({required this.time, required this.activity});
  final String time;
  final String activity;
}

class Community {
  const Community({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.coverImage,
    required this.logoUrl,
    required this.memberCount,
    required this.rating,
    required this.category,
    required this.isVerified,
    this.achievements,
    this.upcomingTrips,
    this.pastAdventures,
  });

  final String id;
  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final String coverImage;
  final String logoUrl;
  final int memberCount;
  final double rating;
  final String category;
  final bool isVerified;
  final List<String>? achievements;
  final List<Activity>? upcomingTrips;
  final List<String>? pastAdventures;
}

class Ticket {
  const Ticket({
    required this.id,
    required this.tripName,
    required this.tripNameAr,
    required this.date,
    required this.groupName,
    required this.bookingNumber,
    required this.status,
    required this.qrData,
    this.seat,
  });

  final String id;
  final String tripName;
  final String tripNameAr;
  final String date;
  final String groupName;
  final String bookingNumber;
  final TicketStatus status;
  final String qrData;
  final String? seat;
}

enum TicketStatus { upcoming, completed, cancelled }

class Mission {
  const Mission({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.reward,
    required this.icon,
    required this.isCompleted,
  });

  final String id;
  final String title;
  final String titleAr;
  final int reward;
  final String icon;
  final bool isCompleted;
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.price,
    required this.seller,
    required this.imageUrl,
    required this.rating,
    required this.category,
  });

  final String id;
  final String name;
  final String nameAr;
  final String price;
  final String seller;
  final String imageUrl;
  final double rating;
  final String category;
}

class JournalPost {
  const JournalPost({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.location,
    required this.imageUrl,
    required this.caption,
    required this.likes,
    required this.comments,
    required this.timeAgo,
    this.isAiGenerated = false,
  });

  final String id;
  final String userName;
  final String userAvatar;
  final String location;
  final String imageUrl;
  final String caption;
  final int likes;
  final int comments;
  final String timeAgo;
  final bool isAiGenerated;
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.sender,
    required this.message,
    required this.time,
    required this.isMe,
    this.isPinned = false,
    this.isVoice = false,
    this.isLocation = false,
    this.imageUrl,
  });

  final String id;
  final String sender;
  final String message;
  final String time;
  final bool isMe;
  final bool isPinned;
  final bool isVoice;
  final bool isLocation;
  final String? imageUrl;
}

class PassportStamp {
  const PassportStamp({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.isUnlocked,
    required this.icon,
    this.date,
  });

  final String id;
  final String name;
  final String nameAr;
  final bool isUnlocked;
  final String icon;
  final String? date;
}

class EmergencyPlace {
  const EmergencyPlace({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.type,
    required this.distance,
    required this.phone,
  });

  final String id;
  final String name;
  final String nameAr;
  final String type;
  final String distance;
  final String phone;
}

class AiTemplate {
  const AiTemplate({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.imageUrl,
    required this.prompt,
  });

  final String id;
  final String name;
  final String nameAr;
  final String imageUrl;
  final String prompt;
}
