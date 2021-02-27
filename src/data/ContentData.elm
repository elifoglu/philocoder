module ContentData exposing (..)

import Content exposing (Content, ContentDate(..))
import Date exposing (fromCalendarDate)
import Time exposing (Month(..))


allContents =
    [ insanıYargılarken
    , değerÖlçütü
    , değerliİnsan
    , ufakBirNot
    , üstinsan
    , bazıNotlar2
    , düşünceSistemi
    , düşünceYakıtı
    , öz
    , üstinsanınYetileri
    , farkındalık
    , hibritÇalışma
    , beniOkuTxt
    , gunluk1
    , fonkProg101
    , gunluk2
    ]


hibritÇalışma =
    Content "Hibrit Çalışma" (Date (fromCalendarDate 2020 May 6) 1) """
Tek bir işle uğraşıldığı halde birden fazla kazanımın sağlandığı çalışma türünü “hibrit çalışma” olarak adlandırıyorum. Örnek vermek gerekirse;

– Uyumadan önce, önceleri İngilizce geliştirmeyi amaç edinen podcast’leri dinlerken uzun süredir yazılım ile alakalı podcast’leri dinliyorum.
– Herhangi bir konu hakkında okuduğum yazıyı/makaleyi sesli okuyorum.
– Yazılım alanında öğrenmek istediğim yeni bir dil veya teknolojiyi, hayata geçirmek istediğim bir proje üzerinde kullanmaya başlayarak öğreniyorum.

Bunların getirileri ise tahmin edebileceğiniz gibi, sırasıyla şu şekilde:

– İngilizce anlamayı geliştirme + yazılım alanında bir şeyler öğrenme
– İngilizce konuşmayı geliştirme + yazılım alanında bir şeyler öğrenme
– Yazılım alanında bir şeyler öğrenme + bir projeyi hayata geçirme

Beynimi keskin hatlarla ikiye bölüp “sen şununla ilgilen, sen de şununla” demeden, görünürde tek iş yaparak, görüldüğü üzere birden fazla kazanım elde ediyorum hibrit çalışma ile. Verdiğim ilk iki örneğin ikisinde de iki kazanımdan biri yabancı dildi ve bu “hibrit çalışmada kazanımlardan biri illa ki yabancı dil olmalı gibi duruyor” diye düşündürebilirdi; bu sebeple üçüncü örneği ekleme ihtiyacı duydum (yine de kazanımlardan birinin yabancı dil olmasının hibrit çalışma için çok uygun olduğunu belirtmeden geçmemek gerek). İlk iki örnekte, kazanımların her ikisi de “öğrenme” kategorisindeyken, üçüncü örnekte ise sadece biri “öğrenme”, diğeri ise “bir işi tamamlama” kategorisinde. Yani, hibrit çalışmanın kazanımları sadece öğrenim ile sınırlı değil.

Hibrit çalışma dışında, hibrit çalışma kategorisine girmese de getirileri bakımından “hibrit çalışmanın akrabası” diyebileceğim işler yapmayı tercih ediyorum. Örneğin yaklaşık bir ay kadar önce ağırlıklı olarak portfolyoma ekleme adına geliştirdiğim bir uygulama, aynı zamanda hayatımı düzene sokmamı sağlıyor. Bu uygulamayı geliştirme sürecinde sadece bir kazanım (bir işi tamamlama) elde ederken, uygulama hazır hale geldiğinde çok değerli bir kazanımı daha cebime koymuş oldum. Yaptığım işlerin en azından bu kategoriye dahil olmasını oldukça önemsiyorum.
""" [ "tümü", "özgün" ] []


insanıYargılarken =
    Content "İnsanı Yargılarken" (Date (fromCalendarDate 2019 Apr 28) 1) """
İnsan hakkında konuşmaya başlamadan önce insanı neye göre değerlendirmemiz gerektiği konusunda hemfikir olmamız gerekir. Günümüzde insana değer biçilirken kimileri iyi niyete, kimileri ahlaka, kimileri kişinin dünyaya neler kattığına, ve kimileri de belki saydıklarımdan daha da fazlasına belli oranlarda bakar. Ancak bahsi geçen iyilik ve ahlak gibi kavramlar ucu açık, yoğun tartışmalar sonucunda dahi tanımları üzerinde uzlaşmaya varılamayan kavramlardır. Aynı şekilde, bir kişinin dünyaya kattıkları birileri için oldukça dikkate değer iken başka bir kesim için arz etmeyebilir ve hatta zararlı bile bulunabilir.

İnsanların öznel olarak üstte saydığım kriterlerden bazılarını insan değerlemede ön planda tutması anlaşılabilir ancak bu öznel tercihler sonucunda nesnel bir sonuca varmak mümkün olmayacaktır. Benim ulaşmak istediğim, insanları herkesin kabul edebileceği bir yöntem ile değerlemek ve böylece en değerli insanın, yani üstinsanın tanımını yapabilmektir. Bunun için de insanlığın tümünün kabul edebileceği, nesnel bir değer ölçütü bulma ve kullanma ihtiyacı doğar.
""" [ "tümü", "üstinsan" ] []


değerÖlçütü =
    Content "Değer Ölçütü" (Date (fromCalendarDate 2019 May 1) 1) """
İnsanların çoğu eleştirdiği herhangi bir eylemi, eylemi gerçekleştirenin değil, kendi değer yargılarının süzgecinden geçirir. Bu da farklı dünya görüşündeki insanlara ılımlı yaklaşmama, kendisinden olmayanı hakir görme gibi sonuçlar doğurur. Halbuki kendi yaşam tarzına, değer yargılarına uygun davranmadığı için eleştirdiği o insan, kendi içerisinde pek  _tutarlı_, hatta kendisinden çok daha tutarlı bir birey olabilir. Buna paralel olarak, insanın, tutarlılığını sürdürdüğü, düşünce ve eylemlerini kendisiyle çelişmeden açıklayabildiği müddetçe kendisine yöneltilen olumsuz eleştirilerin tümünün önünde bir kalkan oluşturacağı rahatlıkla söylenebilir.

Yazdıklarımdan anlaşılabileceği üzere insanları değerlendirirken kullanacağımız değer ölçütü, iyilik, ahlak gibi kavramların aksine şeffaf, ölçülebilir bir kavram olan _tutarlılık_ olmalıdır.
""" [ "tümü", "üstinsan" ] []


değerliİnsan =
    Content "Değerli İnsan" (Date (fromCalendarDate 2019 May 4) 1) """
İnsan değerlemede ihtiyacımız olan, herkes tarafından kabul edilebilir değer ölçütünü belirledikten sonra insanın değerini ölçmek düşünüldüğü gibi çok da zor olmayacaktır.

İnsanı çok sayıda düşünceye sahip bir varlık olarak ele alalım ve insanın sahip olduğu düşüncelerin toplamına o insanın  _düşünce sistemi_  diyelim. İşte insanın değerini belirlemede kullanılan ölçü birimi, bu düşünce sistemindeki çatlakların sayısıdır. Her bir çatlak, düşünce sisteminde bulunan farklı iki düşünce arasındaki tutarsızlığı ifade eder. Kişinin sahip olduğu değer ise düşünce sistemindeki çatlakların sayısıyla ters orantılıdır. Başka bir deyişle, kişi sahip olduğu düşünce sisteminin sağlamlığı kadar değerlidir.
""" [ "tümü", "üstinsan" ] []


ufakBirNot =
    Content "ufak bir not: ‘değerli’ ile kastedilen" (Date (fromCalendarDate 2020 Apr 5) 1) """
Devam etmeden önce araya bir virgül koymanın gerekli olacağını düşündüm.

“İnsanı yargılarken” başlıklı giriş yazısında, insanların, diğerlerini değerlerken öznel kriterlere başvurabileceğini söylemiş; bir kişinin, bir kesim için oldukça önemli ve değerli iken başkaları için tam tersi konumda olabileceğini belirtmiştim.

“Değerli”, kelime anlamı itibarıyla öznelliğin kıyılarında gezen bir sıfat ve bunun yerine nesnelliğe daha fazla göz kırpan “kaliteli” ya da daha uygun bir başka sıfat (üzerinde gerçekten düşünmedim, sebebini ise hemen açıklayacağım) daha tutarlı olabilirdi. En nihayetinde “O benim için değerli çünkü o benim annem” cümlesi gayet makul iken “O benim için kaliteli çünkü o benim annem” gibi bir cümle biraz absürt durmakta; bu da “kaliteli” sıfatının nesnelliğe daha yakın olduğuna dair ufak bir ispat olabilir.

Ben ise burada en başından beri “değerli” sıfatını kullanmakta bir beis görmüyorum, çünkü yazılarımda bahsettiğim ve bahsetmeye devam edeceğim “tutarlı insan” figürü kalitelilik ile bağdaştırılabileceği gibi aynı zamanda da _benim için_ değerli olandır ve insanlık tarafından da aynı şekilde addedilmesini beklediğimdir. Yoksa bittabi, değerliliği sözlük anlamı ile ele alacak olduğumuzda, çoğu insan için aile fertleri diğer insanlardan -tutarlı olanlar da dahil- daha değerli olacaktır.
""" [ "tümü", "üstinsan" ] []


üstinsan =
    Content "Üstinsan" (Date (fromCalendarDate 2020 May 21) 1) """
Değer ölçütü tanımladıktan sonra değerli insanı tanımlamak nasıl zor olmadıysa, üstinsanın -kabaca- tanımını yapmak da elimizde olan değerli insan tanımı olduktan sonra kolay olacaktır.

Üstinsan, düşünce sisteminde hiçbir çatlak olmayan, başka bir deyişle bünyesinde hiçbir tutarsızlık barındırmayan insandır. Bu, üstinsan üzerine yapılabilecek en basit tanımlamadır ve üstinsanın ne olduğu hakkında iyi bir fikir veriyor olsa da etraflıca açıklanmaya muhtaçtır.

En değerli insana “en değerli insan” değil de “üstinsan” demek, insanların ilgisini çekecek, kulağa hoş gelen bir terim kullanma isteği değil; bir ihtiyaçtır. “Bünyesinde hiçbir tutarsızlık barındırmayan” gibi iddialı bir sıfatı taşıyan üstinsan, özü itibarıyla diğer insanlardan farklılık gösterir. Bu “diğer insanlar” topluluğuna, tutarlılık açısından üstinsana en yakın noktada olan insanlar da dahildir. Öyle ki, üstinsan olmayan en tutarlı, yani en değerli insan ile üstinsan arasında tutarlılık açısından bir uçurum vardır ve bu başlı başına, en değerli insanın _üstinsan_ gibi bir tanımlamayı hak ettiğinin bir göstergesidir.

Pratikte hesaplanması mümkün olmayacak bir örnek üzerinden gidip, her insanın düşünce sisteminde 1000 adet farklı düşüncesi olduğunu varsayalım. Bu durumda, üstinsanın sahip olduğu düşüncelerden meydana gelen her _düşünce ikilisinin_ tutarlı olmasını bekleriz; yani 1. ile 2. düşünce aralarında tutarlı, 2. ile 3. düşünce aralarında tutarlı, 1. ile 3. düşünce aralarında tutarlı…, 999. ve 1000. düşünce aralarında tutarlı olmalı. Ufak bir kombinasyon hesabı yaptığımızda, 1000 adet farklı düşünceye sahip kişinin üstinsan addedilebilmesi için, 499500 adet düşünce ikilisini tutarlı kılması gerektiğine şahit oluruz ve bu da az önceki cümle için “iyi ki üç nokta kullanmışım” dememe sebeptir.

Az önce de söylediğim gibi pratikte hesaplanmayacak olsa da, ortalama bir insanın 1000’den çok daha fazla sayıda tekil düşünceye sahip olduğunu düşünmekle beraber, bu sayıyı 1000 ile sınırladığımızda dahi kişinin kendini tamamıyla tutarlı kılabilmesi adına, taşıdığı 499500 adet düşünce ikilisini de tutarlı kılması gerektiğini gördük ki bunu başarmak zannediyorum ki sizce de çok kolay değil. Az önce bahsettiğimiz, üstinsana en yakın konumda olan insan ile devam edelim ve bu kişinin, üstinsana olabileceği en yakın konumda olduğunu düşünelim. Bu durumda, bu kişinin, düşünce sisteminde sadece bir adet çatlağı bulunmasını, kalan 499499 adet düşünce ikilisinin kendi aralarında tutarlı olmasını bekleriz- gerçekten bunu mu bekleriz?

Beklentiniz bu yönde ise maalesef yanıldınız. Düşünce sisteminde sadece bir çatlak bulunduğunu varsaydığımız kişinin, çatlağın sebebi olan düşünce ikilisinden en az birisinin problemli olduğunu kabul etmiş oluruz. Çatlak dışındaki tüm düşünce ikililerin tutarlı olduğunu söylediğimizdeki düştüğümüz yanılgı ise şu şekilde açıklanabilir: Çatlağı oluşturan problemli düşünce, 1000 düşünce barındıran düşünce sisteminde çatlağın kendisini oluşturan düşünce ikilisini bir kenara bıraktığımızda, 998 adet düşünce ikilisinin daha elemanıdır ve bu ikililerin diğer tüm elemanları da problemli bir düşünce ile tutarlı gözüktüklerinden problemli olarak mimlenmelidir. Aynı şekilde, problemli konumuna düşen bu yeni düşünceler de, mensubu oldukları düşünce ikililerinin problemli olarak işaretlenmesine sebep olur ve bu böyle devam eder.

Bu domino etkisi göstermektedir ki, düşünce sisteminde fark edilen tek bir çatlak dahi henüz fark edilmemiş çatlaklar sürüsünün habercisidir ve bu da, mükemmel olarak addedebileceğimiz, tutarsızlık barındırmayan düşünce sistemi ile bu mükemmel sisteme teorik olarak olarak en yakın sayılabilecek düşünce sisteminin sağlamlığı arasında bir uçurum olduğunun ispatıdır. Üstinsan, üstinsan sıfatını bu mükemmel sisteme ulaşabilen olağan dışılığı ile hak etmektedir.
""" [ "tümü", "üstinsan" ] []


bazıNotlar2 =
    Content "bazı notlar #2" (Date (fromCalendarDate 2020 May 21) 2) """
Yazdıkça açıklama ihtiyacı hissettiğim bazı şeyler geliyor aklıma, bu yüzden sık sık böyle ara notlar paylaşacağım sanırım.

– Yazılarımı, aklımdakileri adım adım, soru işareti bırakmayacak şekilde aktarmaya özen göstererek yazmaya gayret ediyorum ancak bazen bu zorlayıcı olabiliyor. Böyle bir soru işareti ile karşılaştığınızda, bunun ileride açıklanacağından, şu an için ise anlaşılmasının ertelenmesinde bir sakınca olmadığından emin olabilirsiniz. Örnek vermek gerekirse, “Üstinsan” başlıklı bölümde “…üstinsan özü itibarıyla diğer insanlardan farklılık gösterir” kısmının akıllara getireceği soru işareti açıklanmaya muhtaç ve sonraki yazılarda detaylıca açıklanacak.

– Yeni yazıya başlamadan önce çoğunlukla önceki yazılara bir göz atıyorum ve bazen anlatmak istediğimi istediğim gibi aktaramadığımı görüyorum. Böyle bir durumu daha önce bir not ile atlatmıştım; bundan sonrası için ise yazı içeriğini güncellemeyi de seçenekler arasına koydum. Sonuçta bu yazılar burada bir nevi taslak formunda ve vakit buldukça yazmayı istikrarla devam ettirebilirsem eğer, basılacak olası bir kitabın ham maddesi olacaklar. Mevcut yazıların içeriğinde büyük bir değişiklik yapacak olduğumda ise yeni versiyonunu okumak isteyenler için yazının güncellediğinde dair bilgilendirme yapabilirim.
""" [ "tümü", "üstinsan" ] []


düşünceSistemi =
    Content "Düşünce Sistemi" (Date (fromCalendarDate 2020 May 26) 1) """
Doğduğu andan bugüne büyük bir bilgi ve düşünce bombardımanına maruz kalan kişi, düşünce sisteminin inşasını başkalarının -bu “başkaları” genellikle ebeveynler olmaktadır- elinden alıp inşa işine kendisi devam etmeye karar verdiğinde, düşünce sisteminin temeli çoktan atılmış olacaktır. Her ne kadar başkası atmış olsa da, kişi bu temelin sağlamlığına güvenerek kendi sistemine zamanla şekil vermeye başlar ve zamanla düşünce sistemindeki çatırdamaları fark eder. Bu kişi için oldukça rahatsızlık vericidir ve çatırdamalar temelden geliyorsa rahatsızlık katsayısı daha da artar. Çatırdamaların zeminden geldiğini kabul etmek çok zordur, çünkü böyle bir durum düşünce sisteminin sil baştan inşasını gerektirir. Bu “çatlaklarla yüzleşme” anında kişinin önüne başlıca iki seçenek çıkar: Bu çatlakları kabul ederek düşünce sistemini ne pahasına olursa olsun yeniden şekillendirmek ya da düşünce sisteminin bu zamana kadar olmaması gereken bir şekilde inşa edildiği reddedilerek fark edilen çatlakların görmezden gelindiği ve gün yüzüne çıkan çatlakların üzerinin çeşitli oyunlarla örtülmeye çalışıldığı bir tutum ile hayata devam etmek. Kişinin bu gibi anlarda yapacağı tercih, kişinin özü hakkında büyük bir fikir verir. Hatta doğrusunu söylemek gerekirse, kişinin bu yoldan hangisini seçeceği özü itibarıyla bellidir.

Üstinsan da her insan gibi doğumundan itibaren çeşitli düşüncelere maruz kalır ve düşünce sistemini maruz kaldığı bu düşünceler üzerine inşa etmeye çalışır. Bu yüzden üstinsanın da hayatının bir bölümünü tutarsızlıklar barındıran bir düşünce sistemi ile geçirmiş olabileceği söylenebilir. Ancak bu durum şu şekilde ele alınmalıdır: Üstinsan ya da herhangi bir insan, düşünce sisteminine dahil ettiği ilk düşüncelerin çoğuna başkalarının empoze etmesiyle, düşünceleri kendi süzgecinden geçiremeyeceği bir dönemde sahip olmuştur. Örneğin, dindar bir aile ve çevreye sahip bir genç, düşünce sistemine tanrının kesinlikle var olduğu ön bilgisini çok küçükken, _elinde olmadan_ eklemiştir. Düşünce sisteminde bulunan bu tür bir ön bilgi, -tanrının varlığının bilinemeyeceğini varsaydığımızda- kişinin tutarsızlığına delalet değildir. Ancak bu ön bilgi zamanla düşünce sisteminde bir çatlağa sebep olduğunda kişi bu çatlağı görmezden gelme eğiliminde ise, kişinin bu noktadan sonra tutarlı olmayı tercih etmediği söylenebilir.

Düşünce sistemi bazı ön bilgiler üzerine inşa edilir ve bu ön bilgilerin doğruluktan uzak olması, kişinin tutarsız olduğunun delili değildir. Kişi bir zaman sonra dış dünyadan edindiği bu bilgiler üzerine düşünce sistemini inşa etmeye başlar ve bazı çatlaklarla karşılaşır. Kişinin tutarlılığı, çatlakla karşılaşma anlarında çatlağa verdiği tepkinin büyüklüğü ve düşünce sistemini yeniden şekillendirme isteği ile doğru orantılıdır. Bu doğrultuda, üstinsanın “tutarsızlık barındırmayan düşünce sistemine sahip kişi”den ziyade “düşünce sisteminin inşasına başladıktan sonra sisteme, sistemi tutarsız kılacak hiçbir düşüncenin girmesine hiçbir şekilde izin vermeyen kişi” olarak tanımlanması daha doğru olur. Ancak pratikte, sahip olduğu yetiler sayesinde düşünce sistemindeki tutarsızlıkları fark edip hızlıca bunları onaracak olan üstinsan için ilk tanımı genelgeçer tanım olarak kullanmak daha kullanışlı olabilir.

Üstinsan, ön bilgilerinin üzerine tutarlı bir şekilde inşa etmeye başladığı düşünce sistemini yine tutarlı bir şekilde inşa etmeyi sürdürmektedir. Düşünme eylemine devam ettikçe, ön bilgilerinden en az birinin sıkıntılı olduğu durumda, sıkıntılı ön bilginin/bilgilerin sistemde çatlaklar oluşturduğunu er ya da geç fark eder. Bu fark etme anı sonrasında ne pahasına olursa olsun düşünce sistemini, sistemin tümünü tutarlı kılacak şekilde yeniden şekillendirir. Bu optimizasyon işlemi karakterinin bir parçası olan üstinsan, zaman geçtikçe düşünce sistemindeki problemli tüm düşünceleri bertaraf edecektir.
""" [ "tümü", "üstinsan" ] []


düşünceYakıtı =
    Content "Düşünce Yakıtı" (Date (fromCalendarDate 2020 May 30) 1) """
Düşüncenin yakıtı zamandır, üstinsanın karar vermek için kısıtlı bir zamana sahip olduğu durumda hatalı düşünmesi ise olasıdır. “Doğru çıkarımlarla doğru düşünceye ulaşmak için şu kadar süre yeterlidir” demek mümkün değildir; daha doğrusu bu süre hem kişiden kişiye farklılık gösterir, hem de düşünülenin karmaşıklığı ile doğru orantılıdır.

Üstinsan düşünceler üzerinde kısıtlı zamanda karar vermeye meyilli değildir. Sonuca ulaşmasını sağlayacak kadar üzerinde durmadığı bir düşüncenin düşünce sistemine girmesine izin vermez. Böyle bir tutum, düşünce sisteminde oluşabilecek çatlakların önüne geçer.
""" [ "tümü", "üstinsan" ] []


öz =
    Content "Öz" (Date (fromCalendarDate 2020 May 30) 2) """
Her insan, doğumundan ya da daha öncesinden itibaren bir öze sahiptir ve bu öz insanın karakterinin büyük ölçüde belirleyicisidir. Materyalist kimseler, istedikleri takdirde özü genetik ile ilişkilendirebilir ya da daha isabetli olarak “kişinin genetik yapısının karakterine etki eden kısmı” tanımını öz için kullanabilir. Ancak öznel olarak, özün böyle mekanik bir tanımlamadan ziyade daha ruhani bir olgu olarak akıllarda yer edinmesini tercih ederim.

Öz nasıl tanımlanırsa tanımlansın, insan, düşünsel anlamda özünün verdiği ölçüde ilerleyebilir, kendini geliştirebilir. Kişinin yine düşünsel anlamda potansiyeli, ulaşabileceği en üst nokta, özünde saklıdır; tıpkı fiziksel anlamda ulaşabileceği en üst noktanın genetik yapısında saklı olduğu gibi.

Genetik perspektiften bakıldığında her insanın özü diğerinden farklı olacak olsa da, insanların özlerinin niteliği bir grafiğe dökülebilse yoğunluk bir noktada toplanır, dağılım belli bir skala içerisinde kalır, üstinsan ise bu skalanın ötesinde konumlanır. Üstinsan özü itibarıyla diğerlerinden net olarak farklı bir konumdadır ve daha önceden değinmiş olduğumuz, kendisine en yakın noktada bulunan insan ile kendisinin düşünce sisteminin sağlamlığı arasındaki uçurum, belki de bunun en belirgin göstergesidir.
""" [ "tümü", "üstinsan" ] []


üstinsanınYetileri =
    Content "Üstinsanın Yetileri" (Date (fromCalendarDate 2020 Jun 1) 1) """
Üstinsanın özünü farklı kılan nedir, ya da bir başka deyişle, bu farklı öz üstinsana ne gibi yetiler kazandırır?

– Üstinsan her zaman için, düşünce sistemindeki -ön bilgilerinden kaynaklanan- tutarsızlıkları kabul etmeye ve düşünce sistemini onarmaya meyillidir.

– Üstinsan, düşünce sistemini tutarsız hale getirecek hiçbir düşüncenin sisteme girmesine izin vermez. Tefekkür ederek henüz sonuca ulaşamadığı konu ile ilgili katı yargılar oluşturmaz. Gerektiği durumda, mantıksal olarak ispatlayamayacağı bir fikri ancak ve ancak bir açık kapı bırakarak düşünce sistemine sokar ve sistemin sağlamlığını sürdürür: “Bu ve bu çıkarımlarda bulunarak şu sonuca ulaştım ve fikrim bu yönde; ancak çıkarımlarım sırasında bir şeyleri gözden kaçırmış olmam mümkündür”

– Üstinsanın bir konu hakkındaki hissiyatı, konu hakkındaki somut çıkarımı henüz bilinçli olarak yapmamışsa dahi mantıksal açıdan doğrudur. Örneğin, iki karşıt görüş arasından birine daha yakın hissetti ise, mevcut düşünce sistemi ile tutarlı olan, gerçekten yakın hissettiği görüştür. Bu, üstinsanın diğer yetilerine nazaran “doğaüstü” bir yetenekmiş gibi görünse de, aslında olan, bilinçaltının gerekli çıkarımları çoktan tamamlayarak sonuca ulaşmış olmasıdır. Bilinciyle muhakeme etmeye başladığında ise yaptığı şey bilinçaltını gün yüzüne çıkarmak olacaktır.

– Üstinsan, istese de mantığın dışına çıkamayandır. İnsanı tutarlı kılan mantığı temel alışıdır; bu açıdan üstinsan aynı zamanda “en mantıklı insan” sıfatına da layıktır.

– Üstinsan farkındadır.
""" [ "tümü", "üstinsan" ] []


farkındalık =
    Content "Farkındalık" (Date (fromCalendarDate 2020 Jun 3) 1) """
Ayıpladığı bir eylemi bir zaman sonra, şartlar olgunlaştığında kendisi de yapan kişi, hem ayıpladığı eylemi gerçekleştirenin içinde bulunduğu koşulların, hem de aynı koşullarda kendisinde de o eylemi yapma potansiyeli olduğunun farkında olamamıştır; bu durumda kişiyi tutarsızlığa itmiş olan sebep, farkındalık düzeyinin düşük oluşudur. Bu kişiye tutarsızlığı söylendiğinde büyük olasılıkla bir kabullenmeme hali ile karşı karşıya kalınır, kişi kendini bir şekilde savunmaya çalışır. Bu kabullenemeyiş, yine çok büyük olasılıkla, tutarsızlığın bilinç seviyesinde fark edilip bencil sebeplerle reddedilmesi ile değil, tutarsızlığın hala farkında olunamaması ile vuku bulur.

Her insan, özü baz alınarak değerlendirildiğinde tutarlı kabul edilebilir; sonuçta insan deterministik bir varlıktır ve her eylemi sebep sonuç ilişkisi içerisinde gerçekleşir. İnsanların seçimleri özünün yordamıyla şekillenir; öz ne derse o olur. Bu da kişinin her seçiminde “özünün izinden gitmek” gibi haklı bir nedeninin olması demektir; “özün o şekilde yönlendirmesi” yapılan seçimi savunmakta oldukça geçerli bir sebeptir fakat insanların ezici çoğunluğu bunu lehinde kullanabilecek yetkinliğe, farkındalığa sahip değildir.

“Zamanında ayıpladığım bir eylemi şimdi kendim de yaptım, çünkü özüm o an için beni buna yönlendirdi” veya “Ben birbiri ile çelişen iki farklı düşünceyi düşünce sistemime dahil ettim, bunun sebebi sahip olduğum özün buna engel olabilecek kadar nitelikli olmamasıydı”, ne kadar mantıklı cümlelerdir, değil mi? İşte bir insan, tutarsız olarak işaretlenebilecek eylemi ile ilgili olarak bu cümlelere paralel bir cümle kurabildiği takdirde otomatikman tutarlı konuma gelir. Evet, zamanında ayıpladığı bir eylemi kendi de yapmıştır ancak bunun ‘farkındadır’ ve böyle bir cümle kurabilmiştir; çelişkisini reddetmez ve bu sebeple tutarlıdır. Evet, düşünce sisteminde çatlaklar bulunmaktadır ancak bunun ‘farkındadır’ ve böyle bir cümle kurabilmiştir; düşünce sisteminin tutarsız olduğunu reddetmez ve bu sebeple düşünce sistemi tutarlı hale gelir (Düşünce sistemine, tutarsızlıklar barındıran bir düşünce sisteminin olduğu düşüncesini içtenlikle koymayı başarabilen kişi, tamamıyla tutarlı bir düşünce sistemine kavuşmuş olur. Tabii bu durumda bu kişinin düşüncelerine itimat edilmemesi gerekir).

Kişinin kendisini tutarlı kılacak bu tarz cümleler kurabilmesi, daha doğrusu cümlelerin içeriğindeki gibi düşünebilmesi için ihtiyacı olan tek şey farkındalıktır ve bu nedenle farkında olmak, tutarlı olmayı beraberinde getirir ve çoğu zaman tutarlılığın ön koşuludur. Farkında olmak tutarlı olmayı beraberinde getirir çünkü birbiriyle çelişkili düşüncelere sahip olduğunu fark eden kişi, çelişkileri ortadan kaldırma yoluna gidecektir.

Bu cümleleri kurabilecek türden bir farkındalığa sahip olmayıp tutarsız davranan insanlar ise kendini bilmeyen, neyi neden yaptığından ve tutarsızlıklarından haberi olmayan insanlardır ve değerli olmaktan oldukça uzak bir konumdadırlar. Bu noktada tutarsızlık güzel bir tanım daha kazanır: tutarsızlığının farkında olmama hali. Tutarsız insan, tutarsızlığının farkına varamayan insandır.

Tutarlılık ile farkındalık etle tırnak gibi olduğundan, farkında olmayan bir üstinsan düşünülemez. Düşünce sisteminde tutarsızlığa izin vermeyen üstinsan, yüksek farkındalığıyla neyi neden yaptığını bilir; kendini bilir. Üstinsanın bu farkındalığının kendisi ile sınırlı kalması için hiçbir sebep yoktur; düşünce düşüncedir ve üstinsan diğer insanların düşünce ve eylemlerindeki tutarsızlıkların da farkındadır. Öyle ki, üstinsan, insanların özünü kendilerinden daha iyi bilebilir.
""" [ "tümü", "üstinsan" ] []


beniOkuTxt =
    Content "beni_oku.txt" NoDate """
**üstinsan**  kategorisinde “üstinsan nedir” sorusu etrafında şekillenen bir düşünceler bütününü kademe kademe anlatma niyetindeyim. bunu uzunca bir süre ileride kitap olarak yayımlatma niyetiyle kendime sakladım ancak buna ayırmam gereken vakte sahip olmayışım ve yolun sonundaki belirsizlik yola çıkmama engel oldu; bu sebeple buraya adım adım yazıp, başarabildiğim takdirde ileride derleyip kitap olarak yayımlatmayı daha uygun gördüm. bu kategorideki yazıların sıralı olarak okunması elzem.

**perspektif**  kategorisinde belirli konular hakkında bakış açımı yansıttığım yazılar olacak.

**özgün**  kategorisinde ilk iki kategoriye ait olmayan çeşitli ve ilk iki kategoride bulunanlar gibi oldukça özgün yazılar yer alacak.

**kod**  kategorisinde ise yazılım ile alakalı yazılar paylaşılacak.

kategori yapısının güncellenmesi durumunda burayı da güncelliyor olacağım.  _takip_  özelliğini kullanarak yeni bir yazının gelip gelmediğini kontrol etme zahmetinden kurtulabilir, destek olma adına ise sitenin varlığından başkalarını haberdar edebilirsiniz.
""" [ "beni_oku.txt" ] []


fonkProg101 =
    Content "Fonksiyonel Programlama 101" (Date (fromCalendarDate 2020 Jun 19) 1) """
Öğretmenin öğrencilerine ödevler verip notlandırma yapabildiği bir sistem tasarlıyor olalım. Öğrenci sınıfımız oldukça basit:

    public class Student {

        public Integer id;
        public String name;

        public Student(int id, String name) {
            this.id = id;
            this.name = name;
        }

        public void assignHomework() {
            System.out.println("A new homework assigned to " + name);
        }
    }

Sonrasında, öğrenci bilgilerine erişebileceğimiz bir map oluşturalım:

    Map<Integer, Student> studentMap = new HashMap<>();
    Student ali = new Student(1, "ali");
    Student veli = new Student(2, "veli");
    studentMap.put(ali.id, ali);
    studentMap.put(veli.id, veli);

Öğretmen, öğrenciye arayüz üzerinden öğrencinin numarasını girerek yeni ödev atayabiliyor olsun. Bu özelliği şu kod ile kolayca sağlayabiliriz:

    Student selected = studentMap.get(1);
    selected.assignHomework();

Öğrenci numarası 1 olan Ali’ye yeni ödev ataması yapıldı, hiçbir sorun yok. Şimdi ise öğretmenin Ali’nin öğrenci numarasını yanlış girdiği durumu ele alalım:

    Student selected = studentMap.get(11);
    selected.assignHomework(); //throws NullPointerException

Map’imizde key’i 11 olan bir entry olmadığından get() metodu null döndü, null olan selected objesinin assignHomework metodunu çağırmaya çalıştığımız için de NullPointerException ile karşılaştık.

Bu durumu kod yazarken genelde şu şekilde handle ediyoruz:

    Student selected = studentMap.get(11);
    if (selected != null) {
        selected.assignHomework();
    }

Bu noktada, “burada null kontrolü yapmam gerek” düşüncesi ile, programın ana akışını bir kenara bırakarak dikkatimizi istenmeyen bazı durumlarla baş etmeye vermiş oluyoruz. Bu istenmeyen durumun esas kaynağı ise Map’imizin get() metodunun bize null döndürebilecek olması, ve kodlama esnasında bu null değerini handle etmemiz için hiçbir uyaranın olmaması. Böyle bir yaklaşımla, objelerin null olabilme durumunu sürekli dikkate almalı ve kesinlikle handle etmeliyiz. Bu da kod yazımı esnasında beyni sürekli kurcalayan, aklımızın bir köşesinde devamlı tutmamız gereken ekstra bir iş demek.

Java 8 ile gelen Optional sınıfı, bizi bu kafa yorma eyleminden bir nebze olsun kurtarmakta. Bilmeyenler için, Optional iki state’i olan bir sınıf: içerisinde bir obje muhafaza edilebilir (Optional.of(value)) ya da içi boş olabilir (Optional.empty()). Optional kullanırken bu iki durumu da göz ardı etmeden kodumuzu yazmamız gerekir.

Kodumuzu Optional kullanarak refactor edelim:

    Optional<Student> selectedOpt = Optional.ofNullable(studentMap.get(11));
    if(selectedOpt.isPresent()) {
        selectedOpt.get().assignHomework();
    }

Optional.ofNullable(), aldığı değer null ise Optional.empty(), değil ise Optional.of(value) döndürmekte; bu sebeple get() metodundan gelen null, Optional.ofNullable() ile çevrelendiğinde empty bir Optional<Student> elde etmiş olduk. Bunun sonucunda, NullPointerException fırlatacak selectedOpt.assignHomework() gibi bir kullanım artık mümkün değil, zira elimizde artık Student yerine Optional<Student> nesnesi var ve Optional ile çevrelenmiş olan Student nesnesinin assignHomework() metodunu çağırabilmek için öncelikle Student nesnesine erişmeliyiz; bu da üstteki kod örneğindeki gibi Optional’ın get() metodu ile yapılabilir. Bu arada, selectedOpt’un get() metodunu, içerisinde gerçekten bir obje muhafaza edildiğini isPresent() metodu ile kontrol ettiğimiz bir kod bloğunun içerisinde çağırmalıyız; aksi takdirde IDE’nizde ‘Optional.get() without isPresent() check’ şeklinde bir uyarı görebilirsiniz.

Gördüğünüz gibi yavaş yavaş null object kontrolleri üzerinde kafa yorma eylemini üzerimizden atıp başka mecralara devretmeye başladık;

    Student selected = studentMap.get(11);
    selected.assignHomework(); //throws NullPointerException

Kodumuzun bu versiyonunda hiçbir uyarı olmaksızın NullPointerException alırken,

    Optional<Student> selectedOpt = Optional.ofNullable(studentMap.get(11));
    selectedOpt.get().assignHomework();

Bu versiyonda IDE’miz “isPresent() kullanmadan get() kullandın, NullPointerException alabilirsin” şeklinde bizi uyarıyor. Göz sağlığımız yerinde olduğu sürece bu belirgin uyarıyı görüp kodumuzu olması gerektiği gibi refactor edebiliriz. Kaldı ki, kullandığımız kod analiz araçları da böyle bir koda müsaade etmeyecek.

Optional kullanarak kodumuzun kalitesini arttırdığımız şüphesiz, ancak kafamızı tam anlamıyla rahatlatmış değiliz. Artık kodumuzu, objenin null olup olmadığının katı bir şekilde kontrolünü yaparak yazmaktan kurtulduk ancak şimdi de null olma ihtimali olan objeleri Optional ile çevrelememeyi unutmamalıyız. Bu da, en az null kontrolleri kadar dikkat edilmesi gereken, zihnin bir kısmını sürekli işgal edecek bir iş. Peki bizi Optional kullanmaya iten neydi?

Bizi Optional kullanmaya iten, Map’in get() metodunun null döndürebilir olmasıydı. Bu metodun null dönmesi demek, Map’te aradığımız elemanın olmaması demek. Map’te aradığımız elemanın olmadığı bilgisini null ile haber vererek aslında hafızamızda tutmamız ve sürekli dikkat etmemiz gereken ekstra bir lojik yaratmış oluyoruz: “null geliyorsa Map’te ilgili eleman yok demektir”. Halbuki bu bilgiyi gayet basit bir şekilde get() metodunun dönüş tipinde belirterek bu yüklerden tamamen kurtulabilir ve get()’in implementasyon detayları ile hiçbir şekilde ilgilenmek zorunda kalmazdık. Ancak mevcut durumda kodumuza, bambaşka bir kodun implementasyon detayı yüzünden kontroller eklemek, kodu güncellemek zorunda kaldık.

Java’da mevcut olmasa da, dönüş tipi Optional<T>, yani bizim örneğimiz için Optional<Student> olan, getOptional() adında bir metoda sahip bir Map implementasyonu kullandığımızı düşünerek kodumuzu güncelleyelim:

    Optional<Student> selectedOpt = studentMap.getOptional(11);
    if (selectedOpt.isPresent()) {
        selectedOpt.get().assignHomework();
    }

Artık getOptional()’ın sadece dönüş tipi ile ilgilenmemiz gereken bir noktaya geldik; getOptional() metodunun implementasyonuna gitmemize, sayfa değiştirmemize bile gerek kalmadı. Bu sayede kafamızı meşgul eden hiçbir dış etken olmadan kodumuzu yazmak gibi mükemmel bir kazanım elde ettik. Önceden zihnimizi işgal eden durumları artık düşünmemek bir yana, kullandığımız metotların dönüş tipi bizi nasıl yazmamız gerektiği konusunda yönlendirmeye başladı. Öğretmenin öğrenci numarasını yanlış girme ihtimali artık kod akışının doğal parçası ve bu ihtimali aklımızın bir köşesinde tutmak zorunda değiliz.

Bu türden kazanımları kod yazma rutinimizin tümüne yaymak için yapmamız gerekenler elbette null’lardan kurtulmak ile sınırlı değil. Örneğin, getOptional() metodumuz, görevi olan “istenilen objeyi Optional ile çevreleyip verme”nin dışında başka bir iş de yapıyor olsaydı ki ne yaptığı hiç önemli değil, hala bu metodun implementasyonu ile ilgilenmek zorunda kalır, gönül rahatlığı ile kullanamazdık ([side effect](https://en.wikipedia.org/wiki/Side_effect_(computer_science)). Aynı şekilde, a parametresiyle x sonucunu veren bir fonksiyonumuz, biz yine x sonucunu beklerken bir süre sonra aynı a parametresiyle y sonucunu verseydi bu bizim için hiç hoş olmazdı ([pure function](https://en.wikipedia.org/wiki/Pure_function)).

Scala’nın mucidi Martin Odersky’nin “gördüğüm en açık ‘neden fonksiyonel programlama’ anlatımlarından biri” diyerek paylaştığı [yazıda](https://www.inner-product.com/posts/fp-what-and-why/) fonksiyonel programlamanın iki hedefinden dem vuruluyor: yerel muhakeme (local reasoning) ve kompozisyon (composition). Kendi bağlamında tamamıyla anlamlı olan (yerel muhakeme) kod parçacıklarını doğru şekilde birleştirdiğimizde (kompozisyon), ortaya çıkan bileşime dair anlayışımız hiçbir şekilde değişmez ve bu sayede oldukça anlaşılır bir codebase’e sahip olmak gibi, veya bir kod parçacığının ne işe yaradığını anlayabilmek için codebase’de dolanarak zamanımızı tüketmek zorunda kalmamak gibi değerli kazanımlar elde ederiz. Bizim yaptığımız da bunun en basit örneklerinden idi: yazdığımız kod parçacığını diğerinin implementasyonuna bağımlı olmaktan kurtarıp yerel muhakeme özelliği kazandırmak ve doğru kod parçacığı ile kompozisyona sokmak.
""" [ "tümü", "kod" ] []


gunluk1 =
    Content "#1" (Date (fromCalendarDate 2020 Nov 21) 1) """
yaklaşık iki sene önce işe girdim, kendimi hızlıca geliştirerek iki ay önce de bir buçuk sene deneyime sahip bir yazılımcıya göre gayet iyi maaşlı bir işe transfer oldum. kendimi hızlıca geliştirmeye çalışırken gözleri de hafiften bozdum, gözlük kullanmaya başladım. kendimi hızlıca geliştirmek istememin sebebi finansal özgürlüğe sahip olmaktı; onu başardım sanırım ama normal özgürlük elden gitti. bu, yazıdaki “kendini hızlıca geliştirme” tamlamasının geçtiği son cümle.

ütopik gözükse de “iki sene çalış bir sene ara ver” gibi bir planım vardı uzun süredir. bu plan hala aklımı kurcalıyor ama daha iyi maaş almak için o kadar emekten sonra, iyi maaşlı işte başladıktan birkaç ay sonra istifa etmek pek akıl kârı değil gibi. bunu yapmazsam da koskoca haftada yapmak istediklerime efektif olarak ayırabildiğim zaman anca bir gün kadar oluyor.

haftada beş çalışma günü ve iki “tatil” adı altında “bir sonraki beş güne mental olarak hazırlanmaya çalışma” günü, başkalarının da dillendirdiği gibi resmen modern kölelik ve buna boyun eğiyor olmak beni rahatsız ediyor. bu oran 5-2 yerine 4-3 olsaydı, “modern” insan için bir hafta içinde kendine vakit ayırabileceği mükemmel bir boşluk oluşurdu ve bu da yapmak istediklerime zaman ayıramamaktan rahatsızlık duymadığım bir yaşam sürmek için oldukça yeterli olurdu. rahatsızlık duymak bir kenara, bunun en ideal oran olduğunu düşünüyorum zaten. modern kölelik ve ideal çalışma süresi arasındaki mesafenin sadece bir gün olması çok enteresan. her neyse; bir sonraki işim için dört gün çalışma teklifimi kabul edecek bir şirket bulmak da “iki sene çalış bir sene ara ver” gibi, uzun süredir aklımda olan bir başka planım kısacası. hatta bu olduğu sürece ilkine gerek bile kalmayabilir. ya da kalabilir.

bu iki plandan örneğin ilkini gerçekleştirdiğim ve bir beyaz yakalıya yakışacak şekilde bu kararımı linkedin üzerinde paylaşıp yeterli etkileşimi aldığım durumda belirli bir kesim bu fikre sempati duyacak, sempati duyan bu kişiler arasından da bunu göze alabilen ya da böyle bir şeye gerçekten benim gibi ihtiyaç duyan birkaç kişi de benim yaptığımı deneyimlemeye çalışacak. bu noktada aklıma şu geliyor: eğer daha öncesinde böyle bir kararı verip uygulamaya koymuş sadece bir iki kişiye dahi tanık olsaydım, bu kararı almak benim için daha kolay olurdu. uygulamaya koyanlar birkaç kişiyle sınırlı olmasaydı da, sektördeki insanların azımsanamayacak bir kısmı bu kararı vermiş olsaydı bu sefer çok çok daha kolay olurdu. benim için bir karar bile olmazdı ortada; yapardım.

yaşam kalitemi kökünden etkileyeceğini düşündüğüm bir tercihin sosyal etkenlere bu denli bağlı olması beni rahatsız ediyor ve bu gibi düşünceler sonrasında maalesef benim de ucundan sosyal bir hayvan olduğum gerçeğini hatırlıyorum. zaten öyle olmasam bu yazı da olmazdı.
""" [ "tümü", "günlük" ] []


gunluk2 =
    Content "#2" (Date (fromCalendarDate 2021 Jan 9) 1) """
yılbaşı gecesinde televizyona bir miktar maruz kaldım.

büyük ihtimalle "yılbaşı gecesinin en çok izlenilen programı" sıfatını kazanacak olan o ses türkiye, benim için oldukça rahatsızlık vericiydi.

bu programın daha öncesinde bir bütünlüğe sahip olduğunu hatırlayabiliyorum. yani, art arda eklenen videolar bütünü gibi değildi; ortada bir akış vardı. bu yılbaşı gecesi programının izlediğim kısmı ise bu akıştan, bütünlükten tamamen uzaktı. şarkı söylemeye gelen ünlülerin sahne kayıtları ve jürilerin reklam kayıtları birbirinden habersiz kesitler halinde art arda eklenmiş durumdaydı. şarkı söyleyip giden her ünlünün arkasından birer ikişer reklam kaydı veriliyordu. program, yılbaşında insanların eğlenmesi için değil de, gerekli tanıtım ve reklamların yapılabilmesi için gerekli bir mecra yaratmak adına hazırlanmış gibiydi. elbette bu tarz programların amacının gerçekten insanları eğlendirmek olduğunu düşünmek fazla iyimser bir davranış olur. demek istediğim, bu yaşıma dek izlediğim ya da denk geldiğim programların tümü öyle ya da böyle, bu "izleyiciyi önemseme" hissiyatını ucundan da olsa verebilirdi. bu yılbaşı programı ise böyle bir kaygıdan tamamen uzaktı.

söylediklerim programın içeriği/kalitesi değil de kurgusu/bütünlüğü ile alakalıydı. insanların büyük çoğunluğunun kalitesiz içeriğe yöneldiğinin zaten bilincinde olmakla beraber, kalitesiz içeriğin sunulması hakkında da şunları dikkate alıyorum:

- bir içerik her ne kadar kalitesiz de olsa, insanlara gerçekten iyi niyetli (ya da kötü niyet barındırmayan) duygularla sunulabilir.

(bu noktada benim adıma rahatsız edici bir durum pek bulunmuyor)

- içerik sağlayıcısı, kendi çıkarları doğrultusunda izleyiciyi manipüle ederek kazanç sağlamaya çalışabilir.

(çıkar peşinde olan insanların ve kolay manipüle edilebilir insanların varlığından da haberdar olduğumdan yine benim için fazla rahatsızlık verici bir durum yok)

televizyonda şimdiye kadar izlemiş olduğum programların içerik sağlayıcı profillerini tümünü bu iki madde altında kategorilendirebilirdim. bu program ise benim için yeni bir madde ihtiyacı doğurdu:

- içerik sağlayıcısı, içeriği tamamen kişisel çıkarlarına uygun şekilde, izleyiciyi *yok sayarak* hazırlayabilir.

programı izlediğim sırada işte beni bu kadar rahatsız eden, izleyicisini tamamen yok sayarak, insan aklıyla dalga geçercesine hazırlandığını gördüğüm bu programı, aklıyla dalga geçilen o insanların o an pürdikkat izledikleri bilgisinin kendisini gün yüzüne çıkarması oldu. bu potansiyelde olan ülkede milyonlarca, dünyada milyarlarca insanın varlığını düşünmek, lafta değil, ciddi anlamda distopik bir çağda olma hissiyatı ile beraber büyük bir rahatsızlığı da beraberinde getirdi. yani, *sanki* bir anda kendimi *insan*ların tümünün televizyona, ekrana bağımlı yaşadığı o distopik yapımlardan birinin içerisinde buldum.

bu anlattığım, benim için yılbaşı gecesindeki "bir distopyanın içerisindeymişim" gibi hissettiren en büyük unsur olsa da destekleyici unsurları da yok değildi;

- bir zap anında denk geldiğim ibo show yılbaşı programı (konuklar: bülent ersoy, seda sayan, serdar ortaç ve diğerleri)

- bir zap anında çok güzel hareketler 2'ye denk gelmemle birlikte "bir başkadır" dizisi ile popüler olan "aşkımı bir sır gibi" şarkısının koro halinde söyleniyor olması

(bunların beni rahatsız etmelerindeki temel nedeni ayrıca açıklamaya gerek duymuyorum; açıklamak zorunda olmak maruz kalmaktan daha fazla rahatsızlık verici olur sanırım benim için)

yine o ses türkiye'den devam edeyim.

- programdaki safi yapmacıklık (program, bu açıdan da eskiden bu seviyede değildi)

- programa çıkan ünlüler (önceleri aleyna tilki, cemal can canseven gibi ünlüler yerine daha düzgün insanlar görebilirdik ekranda. aslında cemal can canseven'in nasıl biri pek olduğunu bilmiyorum, sadece danla bilic'in yakın arkadaşı olduğunu biliyorum. cemal can seven ile danla bilic'in arkadaş olduğunu neden, nereden, nasıl öğrendiğimi bilmiyorum. danla bilic ile değil arkadaş olmak, kendisini arada bir takip ediyor olmanın bile sağlıklı insan davranışı olmadığımı düşündüğümden onu da aleyna tilki'nin yanına ekleyebildim)

--

aleyna tilki, cemal can canseven, danla bilic. yılbaşında mevzubahis programa maruz kalmaktan kaçınmak zor olmazdı ama hiçbirini isteğim dahilinde tanımadığım bu isimler, bu seviye, her an bir yerden karşıma çıkabilir durumda ve etraftaki her şeyin, her anlamda bu veya buna yakın bir seviyede kalitesizlik barındırmasından dolayı bir boğulma halindeyim. örneklerimi toplumun alt kesiminin izlediği, kalitesi ortada olan bir program üzerinden vermiş olsam da hissettiklerim *üst kesim* seviyesinde de farklı değil. yapay, ucuz, ahlaktan yoksun olduğu ilk intibada belli olan bazı insanların gerçek yüzünü göremeyip amansızca takibe devam etmelerine neden olan bu farkında olmama durumlarına tanık olduğumda yine aynı şeyi hissediyorum. satın alınan her bir robot süpürge sonrası yine aynı şeyi hissediyorum. netflix'in fabrikasyon ürünlerini tüketerek yaşayan insan kitleleri sebebiyle yine aynı şeyi hissediyorum. (netflix demişken, u dönüşü ile yine alt kesime geçiş yapmak durumundayım) exxen adlı platformda yayınlanacak belki de tüm programların platformu doldurma amaçlı sipariş işler, yapay ürünler olacağı bariz bir şekilde ortadayken insanların bunun farkında olmadıklarını ve hatta bunun farkında olabilme ihtimalini barındıran bir farkındalık düzeyiyle uzaktan yakından ilişkileri olmadığını düşündüğümde yine aynı şeyi hissediyorum. ekşi sözlük'e sadece gündemden haberdar olma amaçlı girerken ve dikkat dağıtıcı başlıkları en aza indirgemek adına çeşitli uygulamalar, eklentiler yazmışken her girişimde exxen ile ilgili bir başlığa maruz kaldığımda ve bu sayede insanların gündemde ne varsa onun hakkında haftalarca konuşmayı borç bilen varlıklar olduğunu hatırladığımda yine aynı şeyi hissediyorum. exxen'e her maruz kalışım sonrası, sadece "exxen" adının bayağılığından dolayı yine aynı şeyi hissediyorum. youtube'da bir zamanlar kaliteli işler yaptığını bildiğim bir kişinin artık twitch'te kendisine bağış yapanlara, onları önemsememesine rağmen önemsiyormuş gibi yaparak teşekkür etmesine şahit olduğumda ve benim 5 saniyelik bir kesit izleyerek (twitch izlemiyorum ve evet, bu kesite de istemeden denk geldim) farkına vardığım bu yapay tavrın farkına binlerce takipçisinin hiçbir şekilde varmayıp kendisine bağış yapmayı devam ettirdiğini düşündüğümde yine aynı şeyi hissediyorum. o kişinin hayatını idame ettirebilmesi için belki de artık bu yapmacıklığa mecbur kalması gerektiğini düşündüğümde, hayatta kalmak için rol yapmanın ne kadar önemli olduğu aklıma her düştüğünde yine aynı şeyi hissediyorum. vasıfsız insanlara akan paranın büyük ihtimalle eksponansiyel olarak arttığını ve buna büyük oranda parasızlıktan şikayet eden ya da edecek diğer vasıfsız insanların sebep olduğunu düşündükçe yine aynı şeyi hissediyorum.

bu kalitesizlikten, bayağılıktan, distopik ortamdan kurtulma adına da dış dünyadan gittikçe soyutlanıyorum.
""" [ "tümü", "günlük" ] []


templateContent =
    Content "Another Content" (Date (fromCalendarDate 2020 Oct 10) 1) """
It is a long established fact that a reader will be distracted by the readable content of a page
when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal
distribution of letters, as opposed to using 'Content here, content here', making it look like
readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as
their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their
infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose
(injected humour and the like).
""" [ "tümü" ] []
