import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agu_mobile/shared/services/notification_service.dart';
import 'package:agu_mobile/features/events/presentation/pages/diger_page.dart';
import 'package:agu_mobile/features/events/presentation/pages/konferans_page.dart';
import 'package:agu_mobile/features/events/presentation/pages/gezi_page.dart';
import 'package:agu_mobile/features/events/data/models/store.dart';
import 'package:agu_mobile/features/events/data/models/events.dart';

class EventsCard extends StatefulWidget {
  @override
  _EventsCardState createState() => _EventsCardState();
}

class _EventsCardState extends State<EventsCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final _eventList = EventsStore.instance.eventListNotifier;
  final _speakerList = EventsStore.instance.speakerListNotifier;
  final _tripList = EventsStore.instance.tripListNotifier;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
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

    return ValueListenableBuilder<List<Events>>(
      valueListenable: _eventList,
      builder: (context, events, _) {
        return Container(
          height: screenHeight * 0.12,
          width: screenWidth * 0.95,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Container(
              child: Center(
                child: SizedBox(
                  height: screenHeight * 0.23,
                  width: screenWidth * 0.95,
                  child: events.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : Stack(
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              itemCount: events.length,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPage = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                var current_event = events[index];
                                return GestureDetector(
                                  onTap: () {
                                    callRelatedPage(index, events);
                                  },
                                  child: Card(
                                    color: Colors.transparent,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    elevation: 8,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        current_event.uygulama_ici_resim!,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              bottom: 15,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(events.length, (index) {
                                  return GestureDetector(
                                    onTap: () {
                                      _pageController.animateToPage(
                                        index,
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 5),
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
      },
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

  void callRelatedPage(int index, List<Events> events) {
    if (index < 0 || index >= events.length) return;
    final ev = events[index];
    if (ev.etkinlik_turu == 'diger') {
      callEventDetailPage(context, ev);
      return;
    }
    if (ev.etkinlik_turu == 'konferans') {
      final speakers = _speakerList.value;
      int i = 0;
      while (i < speakers.length && ev.etkinlik_adi != speakers[i].etkinlik_adi) {
        i++;
      }
      if (i < speakers.length) {
        callConferencePage(context, speakers[i]);
      }
      return;
    }
    if (ev.etkinlik_turu == 'gezi') {
      final trips = _tripList.value;
      int k = 0;
      while (k < trips.length && ev.etkinlik_adi != trips[k].etkinlik_adi) {
        printColored("ETKİNLİK ADI: ${trips[k].etkinlik_adi}", "32");
        k++;
      }
      if (k < trips.length) {
        callGeziPage(context, trips[k]);
      }
    }
  }
}

// enum callPage {diger, konferans, gezi}
