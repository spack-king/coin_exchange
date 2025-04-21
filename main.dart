import 'dart:async';
import 'dart:convert';
import 'package:animated_background/animated_background.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glass/glass.dart';
import 'package:untitled/web_main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chris Coin Exchange | Buy, Sell, Swap Crypto Currencies',
      theme: ThemeData(
        //
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF000080)),
      ),
      home: MediaQuery.of(context).size.width > 600
        ? WebPage(title: 'Chris Coin Exchange')
      :MyHomePage(title: 'Chris Coin Exchange'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {

// List to hold the cryptocurrency data
  List<Map<String, dynamic>> cryptoList = [];

// RegExp to format numbers with commas
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  String Function(Match) mathAFunction = (Match match) => '${match[1]},';

// Colors
  Color blue = Color(0xFF000080);
  Color textColor = Colors.white;
  Color bgClor = Color(0xFF000080);

// Scroll controller
  ScrollController controller = ScrollController();

// Services list
  List<AService> _service = <AService>[];

// Image asset list
  final List<String> _image = [
    'assets/invest.png',
    'assets/coin.png',
    'assets/sell.png',
    'assets/the_bg.png',
  ];

// State management
  int current_index = 0;
  Timer? _timer;

// Scaffold key
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

// Pages list
  late List<Widget> pages;

  @override
  void initState() {
    fetchCryptoData();
    addServices();
    pages = [
      INTRO(),
      SERVICES(),
      ABOUT(),
      FOOTER(),
    ];
    _timer = Timer.periodic(Duration(seconds: 5), (timer){
      fetchCryptoData();
      setState(() {
        current_index = (current_index + 1) % _image.length;
      });

    });

    setState(() {

    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _timer?.cancel();
    super.dispose();
  }

  void addServices(){
    _service..add(AService(name: 'Buy', image: 'assets/coin.png', description: 'Easily purchase a wide range of cryptocurrencies using a preferred payment method'))
      ..add(AService(name: 'Sell', image: 'assets/sell.png', description: 'Convert your cryptocurrencies into local currencies'))
      ..add(AService(name: 'Invest', image: 'assets/invest.png', description: 'Grow your digital portfolio with our \"Invest\" Services'));
  }

  Future<void> fetchCryptoData() async {
    const url =
        'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=10&page=1';

    // Send GET request to fetch data
    final response = await http.get(Uri.parse(url));

    // Check if the request was successful (status code 200)
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('loadaed crypto data: ${response.statusCode}');

      // Update the state with the fetched data
      setState(() {
        cryptoList = List<Map<String, dynamic>>.from(data);
      });
    } else {
      // If the request failed, show an error message
      print('Failed to load crypto data: ${response.statusCode}');
    }
  }
  bool lastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgClor,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   foregroundColor: textColor,
      //   title: Text(widget.title),
      //   leading: Icon(Icons.home_filled, color: textColor,),
      // ),
      endDrawer: Drawer(
        backgroundColor: Colors.transparent,
        child: MyDrawer()
      ),
     body:  AnimatedBackground(
       vsync: this,
       behaviour: RandomParticleBehaviour(
           options: ParticleOptions(
             //image:   Image.asset('assets/cake.png', width: 40,),
               baseColor: Colors.blue,
               particleCount: 10,
               spawnMaxSpeed: 50,
               spawnMinSpeed: 10,
             spawnMaxRadius: 70
           )
       ),
       child: SafeArea(
         child: Stack(
           children: [
             ListView.builder(
               controller: controller,
               itemCount: pages.length,
                 itemBuilder: (context, index){
                   return pages[index];
                 }),

             Align(
               alignment: Alignment.topLeft,
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Row(
                     children: [
                       const SizedBox(width: 10,),
                       SizedBox(
                           height: 30,
                           width: 30,
                           child: Image.asset('assets/chris_logo_no_bg.png',)
                               .animate(delay: Duration(seconds: 2)).rotate(duration: Duration(milliseconds: 400), )
                       ),

                       const SizedBox(width: 5,),
                       Text(widget.title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold),),
                     ],
                   ),
                   IconButton(
                       onPressed: (){
                         print('here');
                         _scaffoldKey.currentState?.openEndDrawer();
                         //Scaffold.of(context).openDrawer();
                       }, icon: Icon(CupertinoIcons.line_horizontal_3_decrease, color: Colors.white, )),
                 ],
               ).asGlass(
                 enabled: true,
                 tintColor: bgClor,
                 //clipBorderRadius: BorderRadius.circular(15.0),
               ),
             ),
           ],
         ),
       ),
     ),
     floatingActionButton: Container(
       margin: EdgeInsets.only(bottom: 25),
       child: FloatingActionButton(
         onPressed: () async {
           String uri = "https://wa.me/+2349015963158";
           //var urr_launchable = await //;
           if(await canLaunchUrl(Uri.parse(uri))){
             await launch(uri);
           }
         },

         tooltip: 'Live support',
         backgroundColor: Colors.white,
         hoverColor: Colors.green,
         foregroundColor: Colors.black,
         elevation: 5,
         child: Icon(CupertinoIcons.chat_bubble_text_fill),
         shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.all(Radius.circular(50),)
         ),
       ),
     ),
     // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  //intro
  Widget INTRO(){
    return  IntrinsicHeight(
      child: Container(
      //color: blue,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 150,),
            //body
            Expanded(
              child: Stack(
                children: [
                  Align(
                      child: Opacity(
                        opacity: 0.3,
                          child:  AnimatedSwitcher(
                              duration: const Duration(seconds: 5),
                          child: Image.asset(_image[current_index]),
                          key: ValueKey<String>(_image[current_index]),)
                          //Image.asset('assets/invest.png')
                      ),
                    alignment: Alignment.center,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      SizedBox(
                        height: 70,
                        child: AnimatedTextKit(
                          //totalRepeatCount: 1,
                            repeatForever: true,
                            //pause: const Duration(seconds: 2),
                            animatedTexts: [
                              TypewriterAnimatedText('Buy',
                               speed: const Duration(milliseconds: 200),
                                textStyle: TextStyle(color: Colors.green,
                                  fontFamily: 'Horizon',
                                  fontSize: 50, fontWeight: FontWeight.bold, ),),
                              TypewriterAnimatedText('Sell',
                               speed: const Duration(milliseconds: 200),
                                textStyle: TextStyle(color: Colors.red,
                                  fontFamily: 'Horizon',
                                  fontSize: 50, fontWeight: FontWeight.bold),),
                              TypewriterAnimatedText('Trade your',
                                speed: const Duration(milliseconds: 200),
                                textStyle: TextStyle(color: Colors.yellow,
                                  fontFamily: 'Horizon',
                                  fontSize: 50, fontWeight: FontWeight.bold),),
                            ]),
                      ),
                      Flexible(
                        child: Text( ' Crypto Currencies',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: textColor,
                              height: 1,
                              fontFamily: 'Horizon',
                              fontSize: 50, fontWeight: FontWeight.bold),),
                      ),
                      Container(
                        margin: EdgeInsets.all(20),
                        child: Text( '#1 secure and user-friendly cryptocurrency exchange platform for buying, selling and trading digital assets',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: textColor,
                              height: 1,
                              fontFamily: 'Horizon', fontSize: 20),),
                      ),
                      InkWell(

                        onTap: () async {
                          //TODO
                          String uri = "https://github.com/spack-king/coin_exchange/raw/refs/heads/main/chriscoin_exchange.apk";
                          //var urr_launchable = await //;
                          if(await canLaunchUrl(Uri.parse(uri))){
                            await launch(uri);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.all(20),
                          alignment: Alignment.center,
                          decoration:const ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(50),)
                            ),

                          ),
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text('Get Started',
                              style: TextStyle( color: blue, fontWeight: FontWeight.bold, fontSize: 20),),
                          ),
                        ),
                      ),
                    ].animate().slideY(duration: const Duration(seconds: 2)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30,),
            cryptoList.isEmpty
            //if empty show CarouselSlider
                ? Container(
              color: Colors.black,
                  child: CarouselSlider(
                  options: CarouselOptions(
                    aspectRatio:3,
                    viewportFraction: 0.9,
                    initialPage: 0,
                    // enableInfiniteScroll: true,
                    reverse: false,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 7),
                    autoPlayAnimationDuration: Duration(seconds: 7),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    enlargeFactor: 0.3,
                    // scrollDirection: MediaQuery.of(context).size.width > webScreenSize
                    //     ? Axis.horizontal : Axis.vertical,
                  ),
                  items: [
                    Container(child: Center(child: Text('Failed to load market prices!', style: TextStyle(color: Colors.white),)),)
                  ]),
                )
            // Center(child: CircularProgressIndicator()) // Show a loading indicator
                :Container(
              color: Colors.black,
                  child: CarouselSlider(
                  options: CarouselOptions(

                    aspectRatio:4,
                    viewportFraction: 0.9,
                    initialPage: 0,
                    // enableInfiniteScroll: true,
                    reverse: false,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 7),
                    autoPlayAnimationDuration: Duration(seconds: 7),
                    autoPlayCurve: Curves.linear,
                    // enlargeCenterPage: true,
                    enlargeFactor: 0.3,
                    // scrollDirection: MediaQuery.of(context).size.width > webScreenSize
                    //     ? Axis.horizontal : Axis.vertical,
                  ),
                  items: cryptoList.map((coin) {
                    return Builder(
                      builder: (BuildContext context) {
                        double price_change = coin['price_change_percentage_24h'];
                        int market_cap = coin['market_cap'];

                        return IntrinsicHeight(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const SizedBox(width: 10,),
                                  CircleAvatar(
                                    backgroundColor: Colors.blue,
                                    child: Text(
                                      coin['symbol'].toString().toUpperCase(),
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white ,),
                                    ),
                                  ),
                                  const SizedBox(width: 5,),
                                  Expanded(child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(coin['name'], style: TextStyle(color: Colors.white ,), ),
                                      Text('\$${coin['current_price'].toString().replaceAllMapped(reg, mathAFunction)}',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),),
                                      Text('Market Cap: \$${market_cap.toString().replaceAllMapped(reg, mathAFunction)}',
                                        style: TextStyle(fontSize: 10, color: Colors.white),),
                                    ],
                                  )),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(price_change >= 0
                                          ?Icons.trending_up
                                          :Icons.trending_down,
                                        color: price_change >= 0
                                            ? Colors.green : Colors.red,),
                                      Text(price_change >= 0
                                          ?'+${price_change.toStringAsFixed(2)}%'
                                          :'${price_change.toStringAsFixed(2)}%',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: price_change >= 0
                                                ? Colors.green : Colors.red
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(width: 10,),
                                  // trailing: Column(
                                  //   crossAxisAlignment: CrossAxisAlignment.end,
                                  //   children: [
                                  //     Text('Market Cap: \$${coin['market_cap']}'),
                                  //     Text('24h Change: ${coin['price_change_percentage_24h'].toStringAsFixed(2)}%'),
                                  //   ],
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList()),
                ),
          ],
        ),
      ),
    );
  }

//services
  Widget SERVICES(){
    return Container(
      padding: EdgeInsets.all(5),
      color: Colors.grey.shade300,
      child: Column(
        //mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100,),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Text('OUR SERVICES',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black,
                  height: 1,
                  fontSize: 50, fontWeight: FontWeight.bold, letterSpacing: 0.1, wordSpacing: 0.1),),
          ),
          Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Text('#1 Reliable Crypto Currency eXchange Platform')),
          const SizedBox(height: 10,),
          CarouselSlider(
              options: CarouselOptions(
                  height: 400,
                  aspectRatio: 16/9,
                  viewportFraction: 0.82,
                  initialPage: 0,
                  // enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                  enlargeFactor: 0.3,
                  scrollDirection: Axis.horizontal
              ),
              items: _service.map((service) {
                return Builder(
                  builder: (BuildContext context) {
                    return Card(
                      color: blue,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [

                            //profile pics
                            Expanded(child: Image.asset(service.image)),
                            Text(service.name,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),),
                            const SizedBox(height: 10,),

                            Text(service.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontSize: 16),),
                            const SizedBox(height: 5,),

                            //message
                            InkWell(

                              onTap: () async {
                                //TODO
                                String uri = "https://github.com/spack-king/coin_exchange/raw/refs/heads/main/chriscoin_exchange.apk";
                                //var urr_launchable = await //;
                                if(await canLaunchUrl(Uri.parse(uri))){
                                  await launch(uri);
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                                width: double.infinity,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                decoration:const ShapeDecoration(shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(50),)
                                ),
                                    color: Colors.white
                                ),
                                child: Text('${service.name} now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }).toList()),
          const SizedBox(height: 20,),
        ],
      ),
      //: Colors.grey.shade300,
    );
  }

  //about
  Widget ABOUT(){
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100,),
          Container(margin: EdgeInsets.all(20),
            child: Text('ABOUT US',
              textAlign: TextAlign.center,
              style: TextStyle(color: blue,
                  height: 1,
                  fontSize: 50, fontWeight: FontWeight.bold, letterSpacing: 0.1, wordSpacing: 0.1),),
          ),

          SizedBox(
              height: 150,
              width: 150,
              child: Image.asset('assets/flyer.png',)

          ),
          Container(margin: EdgeInsets.all(20),
            child: Column(
              children: [
                Text('At Chris Coin Exchange',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: blue,
                    fontSize: 20, fontWeight: FontWeight.bold, ),),
                Text('Our cryptocurrencies exchange platform provides a secure cryptocurrencies, reliable and efficient environment for buying, selling and trading a wide range of digital assets. Designed and advanced security protocols, real-time market data and intuitive user interfaces. We serve both individual and institutional investors seeking seamless access to the global crypto market. Whether you\'re a beginner or an experienced trader, our platform ensures a compliant, transparent and robust trading experience.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16 ),),
              ],
            ),
          ),

          const SizedBox(height: 50,),

        ].animate()
            .slideX(duration: const Duration(seconds: 1), delay: Duration(milliseconds: 400), )
            .fadeIn(delay: Duration(seconds: 1),duration: Duration(seconds: 1)),
      ),);
  }

  //FOOTER
  Widget FOOTER(){
    return Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100,),
          const SizedBox(width: 10,),
          Container(margin: EdgeInsets.only(left: 20, right: 20),
            child: Text('HOURS',
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor,
                  height: 1,
                  fontSize: 50, fontWeight: FontWeight.bold, letterSpacing: 0.1, wordSpacing: 0.1),),
          ),
          Container(margin: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.circle, color: Colors.green, size: 20,),
                Text('We Are Active 24/7', textAlign: TextAlign.center,
                  style: TextStyle( fontWeight: FontWeight.bold, color: Colors.grey.shade300,
                      fontSize: 16 ),),
              ],
            ),
          ),

          const SizedBox(height: 50,),
          Text('CONTACT US',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white,
                height: 1,
                fontSize: 50, fontWeight: FontWeight.bold, letterSpacing: 0.1, wordSpacing: 0.1),),

          Container(margin: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //telegram
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(20),
                  alignment: Alignment.center,
                  decoration:const ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50),)
                    ),

                  ),
                  child: ListTile(

                    onTap: () async {
                      //TODO
                      String uri = "https://t.me/jujuchris";
                      //var urr_launchable = await //;
                      if(await canLaunchUrl(Uri.parse(uri))){
                        await launch(uri);
                      }
                    },
                    leading: Icon(Icons.telegram, color: blue,),
                    title: Text('Chat us on Telegram',
                      style: TextStyle( color: blue, fontSize: 16),),

                  ),
                ),
                //fb
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  alignment: Alignment.center,
                  decoration:const ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50),)
                    ),

                  ),
                  child: ListTile(

                    onTap: () async {

                      String uri = "https://facebook.com/jujuchrisexchange";
                      //var urr_launchable = await //;
                      if(await canLaunchUrl(Uri.parse(uri))){
                        await launch(uri);
                      }
                    },
                    leading: Icon(Icons.facebook, color: blue,),
                    title: Text('Follow us on Facebook',
                      style: TextStyle( color: blue, fontSize: 16),),

                  ),
                ),
                //wa
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  alignment: Alignment.center,
                  decoration:const ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50),)
                    ),

                  ),
                  child: ListTile(

                    onTap: () async {
                      String uri = "https://wa.me/+2349015963158";
                      //var urr_launchable = await //;
                      if(await canLaunchUrl(Uri.parse(uri))){
                        await launch(uri);
                      }
                    },
                    leading: Icon(CupertinoIcons.phone_circle_fill, color: blue,),
                    title: Text('DM us on WhatsApp',
                      style: TextStyle( color: blue, fontSize: 16),),

                  ),
                ),
                //Call
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  alignment: Alignment.center,
                  decoration:const ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50),)
                    ),

                  ),
                  child: ListTile(

                    onTap: () async {
                      String uri = "tel:+2349015963158";
                      //var urr_launchable = await //;
                      if(await canLaunchUrl(Uri.parse(uri))){
                        await launch(uri);
                      }
                    },
                    leading: Icon(CupertinoIcons.phone_down_circle_fill, color: blue,),
                    title: Text('Call us on Phone',
                      style: TextStyle( color: blue,  fontSize: 16),),

                  ),
                ),

               
              ],
            ),
          ),

          //real footer
          IntrinsicHeight(
            child: Container(
              color: Colors.transparent,
              padding: EdgeInsets.all(10),
              child: Center(child: Text('© 2025 Chris Coin Exchange | Proudly Powered by Spack KIng',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey),)),
            ),
          )
        ]
      ),);
  }

  MyDrawer() {
   return Drawer(
      backgroundColor: Colors.transparent,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  //  const SizedBox(height: 10,),
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.close, color: Colors.white,)),
                  ),
                  //home
                  Container(
                    width: double.infinity,
                    child: ListTile(
                      onTap: (){
                        Navigator.pop(context);
                        controller.animateTo(0 * MediaQuery.of(context).size.height,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut);
                      },
                      leading: Icon(Icons.home, color: Colors.white,),
                      title: const Text('Home', style: TextStyle(color: Colors.white),),
                    ),
                    margin: EdgeInsets.only(left: 40, right: 40, top: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white,
                      ),
                    ),
                  ),
                  //services
                  Container(
                    width: double.infinity,
                    child: ListTile(
                      onTap: (){
                        Navigator.pop(context);
                        controller.animateTo(1 * MediaQuery.of(context).size.height,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut);
                      },
                      leading: Icon(Icons.miscellaneous_services_rounded, color: Colors.white,),
                      title: const Text('Our Services', style: TextStyle(color: Colors.white),),
                    ),
                    margin: EdgeInsets.only(left: 40, right: 40, top: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white,
                      ),
                    ),
                  ),
                  //about
                  Container(
                    width: double.infinity,
                    child: ListTile(
                      onTap: (){
                        Navigator.pop(context);
                        controller.animateTo(2 * MediaQuery.of(context).size.height,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut);
                      },
                      leading: Icon(Icons.info, color: Colors.white,),
                      title: const Text('About Us', style: TextStyle(color: Colors.white),),
                    ),
                    margin: EdgeInsets.only(left: 40, right: 40, top: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white,
                      ),
                    ),
                  ),
                  //contact
                  Container(
                    width: double.infinity,
                    child: ListTile(
                      onTap: (){
                        Navigator.pop(context);
                        controller.animateTo(3 * MediaQuery.of(context).size.height,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut);
                      },
                      leading: Icon(Icons.contact_page, color: Colors.white,),
                      title: const Text('Contact Us', style: TextStyle(color: Colors.white),),
                    ),
                    margin: EdgeInsets.only(left: 40, right: 40, top: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              width: double.infinity,
              margin: EdgeInsets.only(left: 40, right: 40, top: 50),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),

                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade500,
                      blurRadius: 15,
                      offset: const Offset(4,4),
                    ),
                    BoxShadow(
                      color:  Colors.white,
                      blurRadius: 15,
                      offset: const Offset(-4,-4),
                    ),
                  ]
              ),
              child: ListTile(

                onTap: () async {
                  //TODO
                  String uri = "https://github.com/spack-king/coin_exchange/raw/refs/heads/main/chriscoin_exchange.apk";
                  //var urr_launchable = await //;
                  if(await canLaunchUrl(Uri.parse(uri))){
                    await launch(uri);
                  }
                },
                leading: Icon(Icons.get_app, color: Colors.black,),
                title: const Text('Get our App', style: TextStyle(color: Colors.black),),
              ),
            ),
            const SizedBox(height: 10,),

            InkWell(
              onTap: () async {
                String uri = "https://instagram.com/spack__king";
                //var urr_launchable = await //;
                if(await canLaunchUrl(Uri.parse(uri))){
                  await launch(uri);
                }
              },
              child: Container(
                color: Colors.grey.shade800,
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Powered by Spack KIng', style: TextStyle( fontSize: 12, color: Colors.white),),
                      const SizedBox(width: 5,),
                      const Icon(CupertinoIcons.share, color: Colors.white, size: 14,)
                    ],
                  )),
            )
          ],
        ),
      ),
    ).asGlass(
      enabled: true,
      tintColor: Colors.black,
      //clipBorderRadius: BorderRadius.circular(15.0),
    );
  }
}

class AService{
  String name;
  String image;
  String description;

  AService({required this.name, required this.image, required this.description,});

}
