function createWebSocket(path) {
    var host = window.location.hostname;
    if(host == '') host = 'localhost';
    var uri = 'ws://' + host + ':9160' + path;

    var Socket = "MozWebSocket" in window ? MozWebSocket : WebSocket;
    return new Socket(uri);
}

function sendGameState(ws, state) {
    ws.send(JSON.stringify(state));
}

var div = document.getElementById('elmclient');
var elmClient = Elm.embed(Elm.TetrisAttack, div, {});

$(document).ready(function () {
    var ws = createWebSocket('/master');

    ws.onopen = function() {
        var elmStateCallback = sendGameState.bind(undefined, ws);

        elmClient.ports.gameStateOut.subscribe(elmStateCallback);

        ws.onclose = function () {
            elmClient.ports.gameStateOut.unsubscribe(elmStateCallback);
        };
    };
});
