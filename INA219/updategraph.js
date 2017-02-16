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
          currentGraph.updateOptions( { 'file': currents } );
        }

        if (channel == "voltage") {
          var data = [new Date(), xhttp.responseText];
          if (voltages.length == 1 && voltages[0][1] == 0) { voltages[0] = data; }
          else { voltages.push(data); }
          voltageGraph.updateOptions( { 'file': voltages } );
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

updateValues();
