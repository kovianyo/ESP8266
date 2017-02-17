$(function() {
  $(document.body).append("<h1>Kovi voltage log</h1>");

  var html = 'Current: <span id="current"></span> mA<br>\
Voltage: <span id="voltage"></span> mV<br>\
Last update: <span id="date"></span><br>\
<input type="checkbox" id="updatedata" onclick="updateData(this.checked);" checked=""> update data<br>\
<input type="checkbox" id="updategraphs" onclick="updateGraphs(this.checked);" checked=""> update graphs<br>\
\
<h2>Current</h2>\
<div id="currentgraph" style="width:100%; height:300px;"></div>\
<h2>Voltage</h2>\
<div id="voltagegraph" style="width:100%; height:300px;"></div>\
\
<br>\
<input tpye="button" value="Export currents" onclick="exportCurrents();"> &nbsp;\
<input tpye="button" value="Export voltages" onclick="exportVoltages();"> <br><br>\
<textarea id="export" style="margin: 0px; width: 459px; height: 142px;"></textarea>\
';

  $(document.body).append(html);

  currents = [];
  currents.push([new Date(), 0]);

  var currentGraph = new Dygraph(document.getElementById("currentgraph"), currents,
  {
    rollPeriod: 1,
    showRoller: true,
    labels: ['Time', 'mA']
  });

  voltages = [];
  voltages.push([new Date(), 0]);

  var voltageGraph = new Dygraph(document.getElementById("voltagegraph"), currents,
  {
    rollPeriod: 1,
    showRoller: true,
    labels: ['Time', 'V']
  });

  function update(channel) {
   var xhttp = new XMLHttpRequest();
   xhttp.onreadystatechange = function() {
       if (this.readyState == 4) {
         if (this.status == 200) {
          document.getElementById(channel).innerHTML = xhttp.responseText;
          document.getElementById("date").innerHTML = new Date().toString();

          if (channel == "current") {
            var data = [new Date(), xhttp.responseText];
            if (currents.length == 1 && currents[0][1] == 0 ) { currents[0] = data; }
            else { currents.push(data); }
            updateCurrentGraph();
          }

          if (channel == "voltage") {
            var data = [new Date(), xhttp.responseText];
            if (voltages.length == 1 && voltages[0][1] == 0) { voltages[0] = data; }
            else { voltages.push(data); }
            updateVoltageGraph();
          }
        }

        if (document.getElementById("updatedata").checked) {
          if (channel == "current") {
            setTimeout(function(){ update("voltage"); }, 3000);
          }

          if (channel == "voltage") {
            setTimeout(function(){ update("current"); }, 3000);
          }
         }
       }
   };
   xhttp.open("GET", channel, true);
   xhttp.send();
  }

  function updateValues() {
   update("voltage");
  }

  function updateData(start){
   if (start) {
      updateValues();
   }
  }

  function updateCurrentGraph() {
    if (document.getElementById("updategraphs").checked) {
      currentGraph.updateOptions( { 'file': currents } );
    }
  }

  function updateVoltageGraph() {
    if (document.getElementById("updategraphs").checked) {
      voltageGraph.updateOptions( { 'file': voltages } );
    }
  }

  function updateGraphs(update){
   if (update) {
       updateCurrentGraph();
       updateVoltageGraph();
   }
  }

  function getTime(date) {
    var text = date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds(); // + ":" + date.getMilliseconds());
    return text;
  }

  function exportCurrents() {
    text = "time, mA\n"
    for (var i = 0; i < currents.length; i++) {
        text += getTime(currents[i][0]) + ", " + currents[i][1] + "\n";
    }

    document.getElementById("export").value = text;
  }

  function exportVoltages() {
    text = "time, V\n"
    for (var i = 0; i < voltages.length; i++) {
        text += getTime(voltages[i][0]) + ", " + voltages[i][1] + "\n";
    }

    document.getElementById("export").value = text;
  }

  updateValues();
});
