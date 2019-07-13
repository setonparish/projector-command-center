function updateProjectorState(event) {
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

document.addEventListener("DOMContentLoaded", function (event) {
  power = document.getElementById("power-checkbox");
  power.addEventListener("change", updateProjectorState)
});