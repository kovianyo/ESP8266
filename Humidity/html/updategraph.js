$(function() {
  $(document.body).append("<h1>Kovi humidity log</h1>");

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
            Humidity: <span id="humidity" style="font-weight: bold;">-</span> %\
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
            \
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
  <h2>Humidity</h2>\
  <div id="humiditygraph" style="width:100%; height:300px;"></div>\
</fieldset>\
\
<fieldset id="fieldsetExport" style="margin-bottom: 12px; display:none;">\
  <legend>Export</legend>\
  <div style="margin-bottom: 10px;">\
    <input tpye="button" id="exportHumidities" value="Export humidities"> \
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

  $("#exportHumidities").click(function(){
    exportHumidities();
  });

  interval = 3000;
  $("#updateInterval").val(3000);
  $("#updateInterval").change(function(){
    interval = this.value;
  });

  humidities = [];
  humidities.push([new Date(), 0]);

  var humidityGraph = new Dygraph(document.getElementById("humiditygraph"), humidities,
  {
    rollPeriod: 1,
    showRoller: true,
    labels: ['Time', 'mA']
  });

  function update(channel) {
   var xhttp = new XMLHttpRequest();
   xhttp.onreadystatechange = function() {
       if (this.readyState == 4) {
         if (this.status == 200) {
          document.getElementById(channel).innerHTML = xhttp.responseText;
          document.getElementById("date").innerHTML = getTime(new Date());

          if (channel == "humidity") {
            var data = [new Date(), xhttp.responseText];
            if (humidities.length == 1 && humidities[0][1] == 0 ) { humidities[0] = data; }
            else { humidities.push(data); }
            updateHumidityGraph();
          }
        }

        if (document.getElementById("updatedata").checked) {
          if (channel == "humidity") {
            setTimeout(function(){ update("humidity"); }, interval);
          }
         }
       }
   };
   xhttp.open("GET", channel, true);
   xhttp.send();
  }

  function updateValues() {
   update("humidity");
  }

  function updateData(start){
   if (start) {
      updateValues();
   }
  }

  function updateHumidityGraph() {
    if (document.getElementById("updategraphs").checked) {
      humidityGraph.updateOptions( { 'file': humidities } );
    }
  }

  function updateGraphs(update){
   if (update) {
       updateHumidityGraph();
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

  function exportHumidities() {
    text = "time, %\n"
    for (var i = 0; i < humidities.length; i++) {
        text += getTime(humidities[i][0]) + ", " + humidities[i][1] + "\n";
    }

    document.getElementById("export").value = text;
  }

  updateValues();
});
