function setProgress(bar, percent, status) {
    $(bar).find(".cssProgress-bar").css("width", percent + "%").attr("data-percent", percent).find(".cssProgress-label").text(percent + "%");
    for (let x of ["done", "notstarted", "error", "paused", "active", "retryactive"]) {
        $(bar).find(".cssProgress-bar").toggleClass("cssProgress-"+x, status == x);
    }
}

function updateProgress(bar) {
	console.log("Hello from progress");
	const xhttp = new XMLHttpRequest();
	const id = $(bar).attr("data-source-id");
	xhttp.onreadystatechange = function() {
		if (this.readyState == 4 && this.status == 200) {
			var resp = JSON.parse(this.responseText);
			setProgress(bar, resp.percentDone, resp.status);
		}
	};
	xhttp.open("GET", "/status/" + id, true);
	xhttp.send();
}

function registerCheckers() {
	$(".cssProgress").each(function(x, bar) {
		updateProgress(bar);
		setInterval(updateProgress.bind(null, bar), 1000);
	});
}

document.addEventListener("DOMContentLoaded", registerCheckers);
