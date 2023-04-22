import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project2/models/connection.dart';
import 'package:project2/models/data.dart';
import 'package:flutter/cupertino.dart';
import 'package:project2/widgets/grid.dart';


class marketplace extends StatefulWidget {
  const marketplace({Key? key}) : super(key: key);

  @override
  State<marketplace> createState() => _marketplaceState();
}

class _marketplaceState extends State<marketplace> with TickerProviderStateMixin {

  bool isScrolled = true;
  var bookdata;
  var selldata;
  var userSellings;

  @override
  void initState() {
    bookdata= MongoDatabase.fetchbooks();
    selldata= MongoDatabase.fetchBuybooks();
    userSellings = MongoDatabase.fetchUserSellings();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TabController _tabController = TabController(length: 2, vsync: this);

    return Scaffold(
      // extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (){Navigator.pushNamed(context, "/sellSearch");},
        isExtended: isScrolled,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
        label: const Text('Sell Books'),
        icon:const Icon(Icons.add),


      ),

      body: RefreshIndicator(
        onRefresh: () async
        {
          var x= MongoDatabase.fetchBuybooks();
          setState(()
          {
            selldata = x;
          });
        },
        child: NotificationListener<UserScrollNotification>(
          onNotification: (notification){
            if(notification.direction==ScrollDirection.forward){
              setState(() {
                isScrolled=true;

              });
              print('hello');
            }
            else if(notification.direction==ScrollDirection.reverse){
              setState(() {
                isScrolled=false;

              });
              print(isScrolled);
            }
            return true;
          },
          child: SingleChildScrollView(

            child: Column(

              // crossAxisAlignment: CrossAxisAlignment.start,

              children:
              [

                Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),

                    child: Text("Marketplace",
                      style: GoogleFonts.montserrat(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                      ),)


                ),



                //TABS (NEW AND TRENDING)

                Container(
                  padding: EdgeInsets.only(left: 20),
                  child: Align(

                    alignment: Alignment.centerLeft,

                    child: TabBar(

                        controller: _tabController,
                        labelColor: Colors.black,
                        isScrollable: true,
                        indicatorSize: TabBarIndicatorSize.label,
                        indicator: UnderlineTabIndicator(borderSide: BorderSide(
                            color: Color(0xffDE6077), width: 3.5),),
                        unselectedLabelColor: Color(0xff969696),
                        tabs:
                        [
                          Tab(text: "Buy",),
                          Tab(text: "Sell",),
                        ]),
                  ),
                ),

                SizedBox(height: 0,),

                //TAB BAR VIEW (TAB AREAS)
                Container(
                  width: double.maxFinite,
                  height: double.maxFinite,
                  // color: Colors.black,
                  child: TabBarView(
                      controller: _tabController,
                      children:
                      [


                        futurebuygrid(selldata),
                        userSellGrid(userSellings),
                      ]
                  ),

                )
              ],
            ),
          ),
        ),
      ),

    );
  }
}