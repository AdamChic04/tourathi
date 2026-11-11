/// Short editorial introductions for the 61 owner-supplied Jordan destinations.
/// These are contextual overviews, not verified opening-hour, route, or fee claims.
class DestinationGuide {
  const DestinationGuide(this.en, this.ar);
  final String en;
  final String ar;
}

class DestinationGuides {
  DestinationGuides._();

  static const Map<String, DestinationGuide> _guides = {
    'amman-roman-theatre': DestinationGuide(
      'A Roman-era theatre in downtown Amman, known for its broad stone seating and central-city setting.',
      'مدرج روماني في وسط عمّان يتميز بمدرجاته الحجرية وموقعه في قلب المدينة.',
    ),
    'amman-citadel': DestinationGuide(
      'A hilltop archaeological area overlooking central Amman, with remains that reflect several periods of the city\'s history.',
      'منطقة أثرية فوق تلة تطل على وسط عمّان وتضم بقايا من فترات متعددة من تاريخ المدينة.',
    ),
    'amman-jordan-museum': DestinationGuide(
      'A museum dedicated to Jordan\'s archaeological and cultural story, featuring collections from across the country.',
      'متحف يعرض جوانب من تاريخ الأردن الأثري والثقافي عبر مجموعات من مناطق مختلفة.',
    ),
    'amman-darat-funun': DestinationGuide(
      'A cultural destination for art and exhibitions in Amman, combining creative spaces with a historic urban setting.',
      'وجهة ثقافية للفنون والمعارض في عمّان تجمع بين المساحات الإبداعية والطابع العمراني التاريخي.',
    ),
    'amman-al-balad-markets': DestinationGuide(
      'Walk the shopping streets of downtown Amman and discover traditional markets, everyday food, and local businesses.',
      'تجول في أسواق وسط عمّان واكتشف المحلات الشعبية والمأكولات المحلية والحياة اليومية.',
    ),
    'amman-jabal-luweibdeh': DestinationGuide(
      'Explore a walkable Amman neighborhood known for its creative atmosphere, cafes, and artistic spaces.',
      'اكتشف حياً في عمّان يتميز بأجوائه الفنية ومقاهيه ومساحاته الإبداعية.',
    ),
    'amman-iraq-al-amir': DestinationGuide(
      'Discover the heritage of Iraq Al Amir and the surrounding countryside, with historic remains and local community experiences.',
      'تعرّف على تراث عراق الأمير والريف المحيط بها، بما فيه الآثار والتجارب المجتمعية المحلية.',
    ),
    'balqa-as-salt': DestinationGuide(
      'A heritage-rich hillside city known for its historic streets, traditional stone buildings, and community life.',
      'مدينة تراثية على التلال تشتهر بشوارعها التاريخية ومبانيها الحجرية وحياتها المجتمعية.',
    ),
    'balqa-abu-jaber-museum': DestinationGuide(
      'A historic house museum in As-Salt that offers a window into the city\'s architecture and heritage.',
      'متحف في بيت تاريخي بمدينة السلط يعرّف الزائر على عمارتها وتراثها.',
    ),
    'balqa-wadi-shuaib': DestinationGuide(
      'A valley landscape near As-Salt with changing scenery and seasonal conditions; verify access before setting out.',
      'وادي شعيب قرب السلط منطقة طبيعية تتغير أحوالها مع الفصول؛ تحقق من إمكانية الزيارة مسبقاً.',
    ),
    'balqa-iraq-al-amir': DestinationGuide(
      'Learn about local handicrafts and community initiatives connected with the women of Iraq Al Amir; arrange visits ahead.',
      'تعرّف على الحرف المحلية والمبادرات المجتمعية لنساء عراق الأمير، مع تنسيق الزيارة مسبقاً.',
    ),
    'zarqa-azraq-wetland': DestinationGuide(
      'A wetland conservation area in eastern Jordan, valued for its oasis habitat and visiting birdlife.',
      'محمية مائية في شرق الأردن تتميز ببيئتها الواحية والطيور التي تزورها.',
    ),
    'zarqa-shawmari': DestinationGuide(
      'A wildlife reserve in Jordan\'s eastern desert focused on protecting native animals and their habitat.',
      'محمية للحياة البرية في الصحراء الشرقية تُعنى بحماية الحيوانات وموائلها الطبيعية.',
    ),
    'zarqa-qasr-amra': DestinationGuide(
      'An early Islamic desert monument celebrated for its historic wall paintings and distinctive architecture.',
      'معلم صحراوي من العصر الإسلامي المبكر معروف برسوماته الجدارية وعماراته المميزة.',
    ),
    'zarqa-qasr-kharana': DestinationGuide(
      'A striking historic desert structure with imposing stone walls, best explored with background on its early Islamic context.',
      'مبنى صحراوي تاريخي ذو جدران حجرية مميزة، وتزداد متعة زيارته بمعرفة خلفيته التاريخية.',
    ),
    'zarqa-qasr-azraq': DestinationGuide(
      'A historic fortress built largely from dark basalt stone in the oasis town of Azraq.',
      'قلعة تاريخية بُنيت إلى حد كبير من حجر البازلت الداكن في بلدة الأزرق.',
    ),
    'irbid-umm-qais': DestinationGuide(
      'Explore the remains of ancient Gadara and enjoy wide views across the landscapes of northern Jordan.',
      'اكتشف بقايا مدينة جدارا القديمة واستمتع بإطلالات واسعة على طبيعة شمال الأردن.',
    ),
    'irbid-pella': DestinationGuide(
      'An archaeological landscape at Tabaqat Fahl with traces of multiple historical periods in the Jordan Valley.',
      'منطقة أثرية في طبقة فحل تضم آثاراً من عصور تاريخية متعددة في وادي الأردن.',
    ),
    'irbid-dar-saraya': DestinationGuide(
      'A museum in Irbid presenting aspects of the region\'s history and archaeological heritage.',
      'متحف في إربد يعرّف بجوانب من تاريخ المنطقة وتراثها الأثري.',
    ),
    'irbid-beit-arar': DestinationGuide(
      'A cultural house-museum associated with Jordanian poetry and literary heritage.',
      'بيت ثقافي يرتبط بالشعر الأردني والتراث الأدبي.',
    ),
    'irbid-yarmouk-reserve': DestinationGuide(
      'A northern Jordan nature reserve with wooded terrain and habitats that vary with the seasons.',
      'محمية طبيعية شمال الأردن تضم مناطق مشجرة وموائل تتغير مع الفصول.',
    ),
    'irbid-wadi-ziglab': DestinationGuide(
      'A northern Jordan valley landscape suited to nature exploration after checking route and seasonal conditions.',
      'وادي زقلاب من المناظر الطبيعية في الشمال، وتحتاج زيارته إلى التحقق من الطريق والظروف الموسمية.',
    ),
    'jerash-roman-city': DestinationGuide(
      'One of Jordan\'s best-known archaeological destinations, with colonnaded streets, plazas, theatres, and Roman-era monuments.',
      'من أشهر المواقع الأثرية في الأردن، ويضم شوارع ذات أعمدة وساحات ومسارح ومعالم رومانية.',
    ),
    'jerash-dibbeen': DestinationGuide(
      'A forest reserve in Jerash known for its woodland landscape and opportunities to enjoy nature.',
      'محمية غابات في جرش تتميز بطبيعتها المشجرة وفرص الاستمتاع بالبيئة الطبيعية.',
    ),
    'jerash-souf': DestinationGuide(
      'A green landscape near Souf in Jerash Governorate; check which areas and trails are open before traveling.',
      'منطقة خضراء قرب سوف في محافظة جرش؛ تحقق من المناطق والمسارات المتاحة قبل الزيارة.',
    ),
    'jerash-sakib': DestinationGuide(
      'A rural village in Jerash Governorate where countryside scenery and community experiences are the focus.',
      'قرية ريفية في محافظة جرش تتميز بمشاهدها الطبيعية وتجاربها المجتمعية.',
    ),
    'ajloun-castle': DestinationGuide(
      'A medieval hilltop castle overlooking the landscapes of Ajloun, with historic stone architecture.',
      'قلعة تاريخية من العصور الوسطى تطل على طبيعة عجلون وتتميز بعمارتها الحجرية.',
    ),
    'ajloun-forest-reserve': DestinationGuide(
      'A protected wooded landscape in Ajloun where visitors can discover forest scenery and designated activities.',
      'منطقة غابات محمية في عجلون تتيح التعرف على الطبيعة والمسارات والأنشطة المعتمدة.',
    ),
    'ajloun-mar-elias': DestinationGuide(
      'An archaeological and religious heritage site associated by tradition with the prophet Elijah.',
      'موقع أثري وديني يرتبط في التقاليد بالنبي إيليا.',
    ),
    'ajloun-rajeb': DestinationGuide(
      'A valley known for its scenery and seasonal waterfalls; trail safety and water conditions can change.',
      'وادي يتميز بطبيعته وشلالاته الموسمية، وتتغير ظروف المسارات والمياه فيه.',
    ),
    'ajloun-rason': DestinationGuide(
      'A village in the Ajloun highlands where local life and countryside scenery offer a quieter experience.',
      'قرية في مرتفعات عجلون تتيح تجربة هادئة للطبيعة والحياة المحلية.',
    ),
    'mafraq-umm-al-jimal': DestinationGuide(
      'An archaeological settlement in northeastern Jordan, known for buildings made from black basalt.',
      'مستوطنة أثرية في شمال شرق الأردن تشتهر بمبانيها المصنوعة من البازلت الأسود.',
    ),
    'mafraq-rehab': DestinationGuide(
      'Archaeological church sites in the Mafraq area, associated with the region\'s early Christian heritage.',
      'مواقع كنائس أثرية في منطقة المفرق ترتبط بالتراث المسيحي القديم فيها.',
    ),
    'mafraq-umm-qutayn': DestinationGuide(
      'An archaeological heritage stop in Mafraq\'s eastern landscape; confirm site access and local guidance.',
      'موقع تراثي أثري في شرق المفرق؛ يُنصح بالتحقق من إمكانية الوصول والإرشاد المحلي.',
    ),
    'mafraq-dayr-al-kahf': DestinationGuide(
      'A lesser-known archaeological area in Mafraq where access and visitor facilities should be confirmed in advance.',
      'منطقة أثرية أقل شهرة في المفرق تستلزم التحقق مسبقاً من الوصول والخدمات المتاحة.',
    ),
    'madaba-mosaic-map': DestinationGuide(
      'A celebrated Byzantine mosaic map preserved in Madaba, offering a remarkable view of historic geography.',
      'خريطة فسيفسائية بيزنطية شهيرة في مادبا تُظهر تصوراً تاريخياً مميزاً للجغرافيا.',
    ),
    'madaba-mount-nebo': DestinationGuide(
      'A religious and historic hilltop destination associated with biblical tradition and broad valley views.',
      'موقع ديني وتاريخي على مرتفع يرتبط بالتقاليد الدينية ويتميز بإطلالاته الواسعة.',
    ),
    'madaba-umm-ar-rasas': DestinationGuide(
      'An archaeological site noted for its historic ruins and intricate mosaic heritage.',
      'موقع أثري معروف ببقاياه التاريخية وتراثه المميز من الفسيفساء.',
    ),
    'madaba-mukawir': DestinationGuide(
      'A dramatic hilltop archaeological site associated with ancient Machaerus and wide surrounding views.',
      'موقع أثري مرتفع يرتبط بقلعة مكاور القديمة ويتميز بإطلالات واسعة.',
    ),
    'madaba-ma-in': DestinationGuide(
      'A hot-springs destination near Madaba; check current facility operations, admission rules, and access.',
      'وجهة للينابيع الحارة قرب مادبا؛ تحقق من تشغيل المرافق وشروط الدخول والوصول.',
    ),
    'madaba-mosaic-workshops': DestinationGuide(
      'Discover Madaba\'s mosaic-making tradition through local craft workshops; contact hosts to arrange a visit.',
      'اكتشف تقاليد صناعة الفسيفساء في مادبا من خلال الورش المحلية مع تنسيق الزيارة مسبقاً.',
    ),
    'karak-castle': DestinationGuide(
      'A large medieval fortress overlooking Karak, with imposing stone structures and layered regional history.',
      'قلعة كبيرة من العصور الوسطى تطل على الكرك وتتميز بمبانيها الحجرية وتاريخها العريق.',
    ),
    'karak-wadi-bin-hammad': DestinationGuide(
      'A scenic canyon landscape with water and rock formations; verify hiking conditions and access before visiting.',
      'وادٍ ذو مناظر خلابة وتشكيلات صخرية ومياه؛ تحقق من ظروف المشي والوصول قبل الزيارة.',
    ),
    'karak-dhiban': DestinationGuide(
      'An archaeological area connected with the ancient settlement history of Dhiban; confirm the correct location before routing.',
      'منطقة أثرية ترتبط بتاريخ ذيبان القديم؛ تحقق من الموقع الصحيح قبل تحديد المسار.',
    ),
    'karak-ghor-safi': DestinationGuide(
      'A cultural and landscape destination in the southern Dead Sea region, with a local museum to explore.',
      'وجهة ثقافية وطبيعية في منطقة جنوب البحر الميت تضم متحفاً محلياً.',
    ),
    'tafilah-dana': DestinationGuide(
      'A protected landscape of mountains and valleys known for its biodiversity and hiking routes; some trails require guides.',
      'منطقة طبيعية محمية تضم جبالاً وأودية وتنوعاً حيوياً ومسارات مشي، وقد تتطلب بعض المسارات مرشدين.',
    ),
    'tafilah-afra': DestinationGuide(
      'A mineral hot-springs location in Tafilah; confirm whether facilities are operating before departure.',
      'موقع للينابيع المعدنية الحارة في الطفيلة؛ تحقق من تشغيل المرافق قبل الانطلاق.',
    ),
    'tafilah-busaira': DestinationGuide(
      'An archaeological landscape around Busaira with evidence of historical settlement in southern Jordan.',
      'منطقة أثرية حول بصيرا تحمل شواهد على الاستيطان التاريخي في جنوب الأردن.',
    ),
    'tafilah-wadi-hasa': DestinationGuide(
      'A long valley landscape with varied terrain; routes and water conditions require local verification.',
      'وادي طويل ذو تضاريس متنوعة؛ تحتاج مساراته وظروف المياه فيه إلى تحقق محلي.',
    ),
    'tafilah-qadisiyah': DestinationGuide(
      'A highland landscape in Tafilah offering mountain scenery and rural views; confirm access points before visiting.',
      'مرتفعات في الطفيلة تتميز بالمشاهد الجبلية والريفية؛ تحقق من نقاط الوصول قبل الزيارة.',
    ),
    'maan-petra': DestinationGuide(
      'A renowned Nabataean archaeological city carved into rose-colored sandstone, with monumental facades and winding passages.',
      'مدينة أثرية نبطية شهيرة منحوتة في الحجر الرملي الوردي وتضم واجهات ضخمة وممرات متعرجة.',
    ),
    'maan-little-petra': DestinationGuide(
      'A smaller Nabataean site near Petra with rock-cut spaces and a narrow canyon setting.',
      'موقع نبطي أصغر قرب البتراء يضم فراغات منحوتة في الصخر وممراً ضيقاً.',
    ),
    'maan-shobak-castle': DestinationGuide(
      'A historic hilltop fortress in southern Jordan with stone walls and panoramic views.',
      'قلعة تاريخية على مرتفع في جنوب الأردن تتميز بأسوارها الحجرية وإطلالاتها الواسعة.',
    ),
    'maan-jabal-haroun': DestinationGuide(
      'A mountain destination associated with religious heritage near Petra; seek local guidance for the hike.',
      'جبل يرتبط بتراث ديني قرب البتراء، ويُنصح بالحصول على إرشاد محلي للمشي إليه.',
    ),
    'maan-diseh': DestinationGuide(
      'A village-and-farms experience in the Disi area, where local host arrangements may be necessary.',
      'تجربة ريفية في منطقة الديسة ومزارعها، وقد تتطلب تنسيقاً مسبقاً مع المضيفين.',
    ),
    'maan-wadi-rum': DestinationGuide(
      'A protected desert landscape of dramatic sandstone mountains and open valleys, with visits often arranged through licensed operators.',
      'منطقة صحراوية محمية تتميز بالجبال الرملية والأودية الواسعة، وغالباً ما تُنظم زياراتها عبر مشغلين مرخصين.',
    ),
    'aqaba-marine-reserve': DestinationGuide(
      'A protected Red Sea coastal environment with coral and marine life; follow designated access and conservation rules.',
      'بيئة بحرية محمية على البحر الأحمر تتميز بالشعاب والحياة البحرية، مع الالتزام بمناطق الوصول وقواعد الحماية.',
    ),
    'aqaba-fort': DestinationGuide(
      'A historic fort near Aqaba\'s coast, connected with the city\'s maritime and regional heritage.',
      'قلعة تاريخية قرب ساحل العقبة ترتبط بالتراث البحري والمحلي للمدينة.',
    ),
    'aqaba-bird-observatory': DestinationGuide(
      'A birdwatching destination near Aqaba where seasonal migration and local habitats shape what visitors may see.',
      'وجهة لمراقبة الطيور قرب العقبة تتأثر مشاهداتها بالهجرة الموسمية والموائل الطبيعية.',
    ),
    'aqaba-south-beaches': DestinationGuide(
      'A coastal area of Aqaba known for beaches and nearby reefs; use marked access and follow marine guidance.',
      'منطقة ساحلية في العقبة تتميز بالشواطئ والشعاب القريبة، مع الالتزام بمناطق الدخول والإرشادات البحرية.',
    ),
    'aqaba-boat-trips': DestinationGuide(
      'Explore the Red Sea through boat or snorkeling excursions operated by licensed local providers; confirm availability.',
      'اكتشف البحر الأحمر عبر رحلات القوارب أو الغطس مع مشغلين محليين مرخصين، بعد التأكد من التوفر.',
    ),
  };

  static DestinationGuide? forId(String id) => _guides[id];
  static int get count => _guides.length;
}
