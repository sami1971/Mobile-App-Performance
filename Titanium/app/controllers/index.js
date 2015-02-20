Ti.include('physics.js');
Ti.include('point.js');
Ti.include('gate.js');
Ti.include('track.js');
Ti.include('lap.js');
Ti.include('session.js');
Ti.include('session_manager.js');

var trackJSON = ""
+ "{"
+   "\"track\": {"
+     "\"id\": \"1000\","
+     "\"name\": \"Test Raceway\","
+     "\"gates\": ["
+       "{"
+       "\"gate_type\": \"SPLIT\","
+       "\"split_number\": \"1\","
+       "\"latitude\": \"37.451775\","
+       "\"longitude\": \"-122.203657\","
+       "\"bearing\": \"136\""
+       "},"
+       "{"
+       "\"gate_type\": \"SPLIT\","
+       "\"split_number\": \"2\","
+       "\"latitude\": \"37.450127\","
+       "\"longitude\": \"-122.205499\","
+       "\"bearing\": \"326\""
+       "},"
+       "{"
+       "\"gate_type\": \"START_FINISH\","
+       "\"split_number\": \"3\","
+       "\"latitude\": \"37.452602\","
+       "\"longitude\": \"-122.207069\","
+       "\"bearing\": \"32\""
+       "}"
+     "]"
+   "}"
+ "}";
var track = new Track(JSON.parse(trackJSON));
var file = Titanium.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, 'multi_lap_session.csv');
var contents = file.read().text;
var points = [];
var lines = contents.split('\n');
var linesLength = lines.length;
for (var i = 0; i < linesLength; i++) {
  var line = lines[i];
  var parts = line.split(',');
  points.push(new Point(parseFloat(parts[0]), parseFloat(parts[1]), false,
    parseFloat(parts[2]), parseFloat(parts[3]), 5.0, 5.0, 0));
}

function run1000(e) {
  $.label1000.text = "" + run(1000);
}

function run10000(e) {
  $.label10000.text = "" + run(10000);
}

function run(count) {
  var start = (new Date()).getTime() / 1000.0;
  var timestamp = start;
  while (count--) {
    SessionManager.instance().startSession(track);
    var pointsLength = points.length;
    for (var i = 0; i < pointsLength; i++) {
    var point = points[i];
      SessionManager.instance().gps(point.latitudeDegrees(), point.longitudeDegrees(), 
        point.speed, point.bearing, point.hAccuracy, point.vAccuracy, timestamp++);
    }
    SessionManager.instance().endSession();
  }
  return (new Date()).getTime() / 1000.0 - start;
}
$.index.open();
