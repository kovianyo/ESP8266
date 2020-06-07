function runCommand() {
    var xmlhttp = new XMLHttpRequest();

    xmlhttp.onreadystatechange = function() {
        if (xmlhttp.readyState == XMLHttpRequest.DONE) {   // XMLHttpRequest.DONE == 4
           if (xmlhttp.status == 200) {
               console.log(xmlhttp.responseText);
               document.getElementById("resultDiv").innerText = xmlhttp.responseText;
           }
           else {
              alert('xmlhttp error: ' + xmlhttp.status);
           }
        }
    };

    var command = document.getElementById("command").value
    xmlhttp.open("POST", "terminal");
    xmlhttp.send(command);
}
