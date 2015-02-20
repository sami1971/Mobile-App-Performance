//
//  Copyright (c) 2015 Harry Cheung
//

function Track(json) {
  this.start = null;
  this.gates = [];
  var jsonTrack = json["track"];
  var jsonGates = jsonTrack["gates"];
  var length = jsonGates.length;
  for (var i = 0; i < length; i++) {
    var jsonGate = jsonGates[i];
    var gate = new Gate(jsonGate["gate_type"],
      parseInt(jsonGate["split_number"]),
      parseFloat(jsonGate["latitude"]),
      parseFloat(jsonGate["longitude"]),
      parseFloat(jsonGate["bearing"]));
    if (gate.type == GateType.START_FINISH || gate.type == GateType.START) {
      this.start = gate;
    }
    this.gates.push(gate);
  }
  this.id = parseInt(jsonTrack["id"]);
  this.name = jsonTrack["name"];
}

Track.prototype.numSplits = function() {
  return this.gates.length;
};