$(function() {
  $(document.body).append("<h1>Kovi voltage log</h1>");

  var html = '\
<div>\
  <fieldset style="margin-bottom: 12px;">\
    <legend>Basic</legend>\
      <table>\
        <col width="120">\
        <col width="140">\
        <col width="180">\
        <tr>\
          <td>\
            Current: <span id="current" style="font-weight: bold;">-</span> mA\
          </td>\
          <td>\
            <input type="checkbox" id="updatedata" checked=""> update data\
          </td>\
          <td>\
            <input type="checkbox" id="showexport" style="margin-left: 0px;"> <span>show export</span>\
          </td>\
          <td>\
            Update interval: <input type="number" id="updateInterval" min="0" style="width: 60px; text-align: right;"> milliseconds\
          </td>\
        </tr>\
        <tr>\
          <td>\
            Voltage: <span id="voltage" style="font-weight: bold;">-</span> mV\
          </td>\
          <td>\
            <input type="checkbox" id="updategraphs" checked=""> update graphs\
          </td>\
          <td>\
            Last update: <span id="date"></span><br>\
          </td>\
        </tr>\
      </table>\
  </fieldset>\
</div>\
\
<fieldset style="margin-bottom: 12px;">\
  <legend>Graphs</legend>\
  <h2>Current</h2>\
  <div id="currentgraph" style="width:100%; height:300px;"></div>\
  <h2>Voltage</h2>\
  <div id="voltagegraph" style="width:100%; height:300px;"></div>\
</fieldset>\
\
<fieldset id="fieldsetExport" style="margin-bottom: 12px; display:none;">\
  <legend>Export</legend>\
  <div style="margin-bottom: 10px;">\
    <input tpye="button" id="exportCurrents" value="Export currents"> &nbsp;\
    <input tpye="button" id="exportVoltages" value="Export voltages">\
  </div>\
  <div>\
    <textarea id="export" style="margin: 0px; width: 459px; height: 142px;"></textarea>\
  </div>\
</fieldset>\
';

  $(document.body).append(html);

  $("#updatedata").click(function(){
    updateData(this.checked);
  });

  $("#updategraphs").click(function(){
    updateGraphs(this.checked);
  });

  $("#showexport").click(function(){
    $("#fieldsetExport").toggle(this.checked);
  });

  $("#exportCurrents").click(function(){
    exportCurrents();
  });

  $("#exportVoltages").click(function(){
    exportVoltages();
  });

  interval = 3000;
  $("#updateInterval").val(3000);
  $("#updateInterval").change(function(){
    interval = this.value;
  });

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
          document.getElementById("date").innerHTML = getTime(new Date());

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
            setTimeout(function(){ update("voltage"); }, interval);
          }

          if (channel == "voltage") {
            setTimeout(function(){ update("current"); }, interval);
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

  function pad(n, width, z) {
    z = z || '0';
    n = n + '';
    return n.length >= width ? n : new Array(width - n.length + 1).join(z) + n;
  }
    function getTime(date) {
    var text = pad(date.getHours(), 2) + ":" + pad(date.getMinutes(), 2) + ":" + pad(date.getSeconds(), 2); // + ":" + date.getMilliseconds());
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
