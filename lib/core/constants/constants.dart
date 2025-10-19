//EKRANA UYGUN SIZE ALMAK İÇİN GLOBAL SABİT DEĞİŞKENLER

// double screenWidth = 0;
// double screenHeight = 0;

import 'package:home_page/models/events.dart';

List<Events> _eventList = [];

const String apiRefectory =
    "AKfycbwc8Fyp-QFheX7u4F2KBt1vfE8roUknaMXEx36GQi2yPeTcHhpWooXkJqi6w_6H8ZH06Q";
// "AKfycbxO5kYXlc1GBlyHv6sYfZB42wAGjZZwlcS2nkAZWbHHhCJLp_nfrrZWyJ2LOZ2ckR7U";
const String baseUrlRefectory =
    "https://script.google.com/macros/s/AKfycbwc8Fyp-QFheX7u4F2KBt1vfE8roUknaMXEx36GQi2yPeTcHhpWooXkJqi6w_6H8ZH06Q/exec";
// "https://script.google.com/macros/s/AKfycbxO5kYXlc1GBlyHv6sYfZB42wAGjZZwlcS2nkAZWbHHhCJLp_nfrrZWyJ2LOZ2ckR7U/exec";

const String apiAcademic =
    "AKfycbwC4E0xDzain5eut77UL6gwFIdBW9fWHXu7ASFYnCylOu52E4EGrgk1WYt0Dz860YRA";

const String baseUrlAcademic =
    "https://script.google.com/macros/s/AKfycbwC4E0xDzain5eut77UL6gwFIdBW9fWHXu7ASFYnCylOu52E4EGrgk1WYt0Dz860YRA/exec";

const String apiEvents =
    "AKfycbzYKFOXFEse3yKHunZeoJgcLnZ4nSiP1yrMQBkVXbPNNF5Tus4hEV0NpsadhBtiV4cm";
// "AKfycbx0JQ-nsZV_hDmcc1ZNloz2Fptwq1viiEUqNTb_8wkhsdll1w5rE0CEEpaGojq70d3Q";

const String baseUrlEvents =
    "https://script.google.com/macros/s/AKfycbzYKFOXFEse3yKHunZeoJgcLnZ4nSiP1yrMQBkVXbPNNF5Tus4hEV0NpsadhBtiV4cm/exec";
// "https://script.google.com/macros/s/AKfycbx0JQ-nsZV_hDmcc1ZNloz2Fptwq1viiEUqNTb_8wkhsdll1w5rE0CEEpaGojq70d3Q/exec";

const String apiSpeakers =
    "AKfycbz6t5ipxhC5EkbN-nNwbklC6zPJLhpdDH16D2NbjODHxrr-ZMD4UpCh_p3XMA9MAVSQ";

const String baseUrlSpeakers =
    "https://script.google.com/macros/s/AKfycbz6t5ipxhC5EkbN-nNwbklC6zPJLhpdDH16D2NbjODHxrr-ZMD4UpCh_p3XMA9MAVSQ/exec";

const String apiTrip =
    "AKfycbzNdkx2I7f4HTDIk09cSKwdXbxSrAco2hCCFCpuApvSiZBm2p3KrY6nJAmM_EFZKvxXLQ";

const String baseUrlTrip =
    "https://script.google.com/macros/s/AKfycbzNdkx2I7f4HTDIk09cSKwdXbxSrAco2hCCFCpuApvSiZBm2p3KrY6nJAmM_EFZKvxXLQ/exec";

const String apiSisLessons =
    "AKfycbzG6OxVmgv2a8V3gfPVz0F0lxBgXBbGlRRWmfJQaMjpwb9Av6cr93r_PhoTDZxgHzgo";

const String baseUrlSisLessons =
    "https://script.google.com/macros/s/AKfycbzG6OxVmgv2a8V3gfPVz0F0lxBgXBbGlRRWmfJQaMjpwb9Av6cr93r_PhoTDZxgHzgo/exec";
