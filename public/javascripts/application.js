/*
  Toggle button lookups
*/
let radioButtons = {
  "power": "power-checkbox"
}

function getRadio(id) {
  return document.getElementById(radioButtons[id]);
}


/*
  Setup page
*/
document.addEventListener("DOMContentLoaded", function (event) {
  power = getRadio("power");
  power.addEventListener("change", sendProjectorState);

  // listen to sse stream from server to update toggles
  stream('/stream');
});


/*
  Send new state value to projectors
*/
function sendProjectorState(event) {
  let target = event.srcElement;
  let url = target.checked ? target.dataset.checked : target.dataset.unchecked;
  call(url);
}

function call(url) {
  var xhr = new XMLHttpRequest();
  xhr.open("POST", '/' + url, true);
  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
  xhr.send();
}


/*
  Refresh toggles with latest projector state
*/
function refreshProjector(data) {
  power = getRadio("power");
  power.checked = data.powered_on;
}

function stream(url) {
  var evtSource = new EventSource("/stream");

  evtSource.onmessage = function (event) {
    let data = JSON.parse(event.data);
    refreshProjector(data);
  };

  evtSource.onerror = function (e) {
    console.error("Streaming connection error");
  };
}