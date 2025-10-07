import 'dart:async';
import 'package:flutter/material.dart';
import 'package:home_page/notifications.dart';
import 'package:home_page/screens/events/diger.dart';
import 'package:home_page/screens/events/konferans.dart';
import 'package:home_page/screens/events/gezi.dart';
import 'package:home_page/utilts/models/Store.dart';
import 'package:home_page/utilts/models/events.dart';

class EventsCard extends StatefulWidget {
  @override
  _EventsCardState createState() => _EventsCardState();
}

class _EventsCardState extends State<EventsCard> {
  // final EventsApi eventsApi = EventsApi();
  // late List<Events> _eventList = [];
  // late List<Speaker> _speakerList = [];
  // late List<Trip> _tripList = [];
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  // final eventsService = EventsService(baseUrlEvents);
  final _eventList = EventsStore.instance.eventListNotifier;
  final _speakerList = EventsStore.instance.speakerListNotifier;
  final _tripList = EventsStore.instance.tripListNotifier;

  @override
  void initState() {
    super.initState();
    // Veriyi burada bir kere çekiyoruz
    // _loadDataForEvents();
    // _loadDataForSpeakers();
    // _loadDataForTrip();
    _startAutoSlide();

    // _loadEvents();
  }

  // Otomatik sayfa kaydırma işlemi
  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_eventList.value.isNotEmpty) {
        setState(() {
          _currentPage = (_currentPage + 1) % _eventList.value.length;
        });

        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.12,
      width: screenWidth * 0.95,
      // padding: EdgeInsets.all(2.0),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          // decoration: const BoxDecoration(
          //     color: Colors.white,
          //     // gradient: LinearGradient(
          //     //     colors: [Colors.white, Colors.amberAccent, Colors.white],
          //     //     begin: Alignment.topLeft,
          //     //     end: Alignment.bottomRight),
          //     borderRadius: BorderRadius.only(
          //         topLeft: Radius.circular(2),
          //         topRight: Radius.circular(20),
          //         bottomLeft: Radius.circular(20),
          //         bottomRight: Radius.circular(20)),
          //     border: Border(
          //       // top: BorderSide(width: 1.5, color: Colors.black),
          //       // left: BorderSide(width: 1.5, color: Colors.black),
          //       bottom: BorderSide(width: 6.0, color: Colors.black45),
          //       right: BorderSide(width: 6.0, color: Colors.black45),
          //     )),
          child: Center(
            child: SizedBox(
              height: screenHeight * 0.23, // Yükseklik ekranın %25'i
              width: screenWidth * 0.95, // Genişlik ekranın %85'i
              child: _eventList.value.isEmpty
                  ? const Center(
                      child:
                          CircularProgressIndicator()) // Veri yüklenene kadar gösterilecek widget
                  : Stack(
                      children: [
                        // PageView ile fotoğraflar arasında kaydırma
                        PageView.builder(
                          controller: _pageController,
                          itemCount: _eventList.value.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            var current_event = _eventList.value[index];
                            return GestureDetector(
                              onTap: () {
                                callRelatedPage(index);
                                // callEventDetailPage(context, current_event);
                              },
                              child: Card(
                                color: Colors.transparent,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                elevation: 8,
                                // shape: RoundedRectangleBorder(
                                //   borderRadius: BorderRadius.circular(12),
                                // ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    current_event.uygulama_ici_resim!,
                                    // width: double.infinity,
                                    // height: 200,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        // Dots Gösterge (Sayfa göstergeleri)
                        Positioned(
                          bottom: 15,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:
                                List.generate(_eventList.value.length, (index) {
                              return GestureDetector(
                                onTap: () {
                                  _pageController.animateToPage(
                                    index,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  width: 9,
                                  height: 9,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentPage == index
                                        ? Colors.white
                                        : Colors.grey,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> callEventDetailPage(
      BuildContext context, Events current_event) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailPage(event: current_event),
      ),
    );
  }

  Future<dynamic> callConferencePage(
      BuildContext context, Speaker current_speakers) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConferencePage(speaker: current_speakers),
      ),
    );
  }

  Future<dynamic> callGeziPage(BuildContext context, Trip current_trip) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GeziPage(
          trip: current_trip,
        ),
      ),
    );
  }

  callRelatedPage(index) {
    if (_eventList.value[index].etkinlik_turu == 'diger') {
      callEventDetailPage(context, _eventList.value[index]);
      return;
    }
    if (_eventList.value[index].etkinlik_turu == 'konferans') {
      int i = 0;
      while (_eventList.value[index].etkinlik_adi !=
          _speakerList.value[i].etkinlik_adi) {
        i++;
      }
      callConferencePage(context, _speakerList.value[i]);
      // for (int i = 0; i < _eventList.length; i++) {
      //   for (int j = 0; j < _speakerList.length; j++) {
      //     if (_eventList[i].etkinlik_adi == _speakerList[j].etkinlik_adi) {
      //       callConferencePage(context, _speakerList[j]);
      //       return;
      //     }
      //   }
      // }
      // callConferencePage(context, _speakerList[index]);
    }
    if (_eventList.value[index].etkinlik_turu == 'gezi') {
      int k = 0;
      while (_eventList.value[index].etkinlik_adi !=
          _tripList.value[k].etkinlik_adi) {
        printColored("ETKİNLİK ADI: ${_tripList.value[k].etkinlik_adi}", "32");
        k++;
      }
      callGeziPage(context, _tripList.value[k]);
    }
  }
}

// enum callPage {diger, konferans, gezi}
