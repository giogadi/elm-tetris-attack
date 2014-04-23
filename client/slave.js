function createWebSocket(path) {
    var host = window.location.hostname;
    if(host == '') host = 'localhost';
    var uri = 'ws://' + host + ':9160' + path;

    var Socket = "MozWebSocket" in window ? MozWebSocket : WebSocket;
    return new Socket(uri);
}

var div = document.getElementById('elmclient');
var elmClient = null;

$(document).ready(function () {
    var ws = createWebSocket('/slave');

    ws.onopen = function() {
        console.log('OPENED');
        ws.onerror = function(error) {
            console.log('ERROR: ' + error);
        };
        ws.onclose = function() {
            console.log('CLOSED');
        };
        ws.onmessage = function(e) {
            var object = JSON.parse(e.data);
            if (elmClient === null) {
                elmClient = Elm.embed(Elm.Slave, div, { gameStateIn: object });
            }
            else {
                elmClient.ports.gameStateIn.send(object);
            }
        };
    };
});
