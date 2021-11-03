function makeTaskbar(taskId) {
    const div = $(`<div class="cssProgress">\n	${taskId}<div class="progress-medium">\n		<div class="cssProgress-bar" data-percent="0" style="width: 0%;">\n			<span class="cssProgress-label">0%</span>\n		</div>\n	</div>\n</div>`, {
        "data-source-id": taskId,
    });
    div.hide();
    return div;
}

function setProgress(bar, percent, status) {
    $(bar).find(".cssProgress-bar").css("width", percent + "%").attr("data-percent", percent).find(".cssProgress-label").text(percent + "%");
    for (let x of ["done", "notstarted", "error", "paused", "active", "retryactive"]) {
        $(bar).find(".cssProgress-bar").toggleClass("cssProgress-"+x, status == x);
    }
}

async function fetchTasks() {
    return await ajax("GET", "/api/tasks");
}

async function updateProgress(taskId, taskDiv) {
	const response = await ajax("GET", `/api/tasks/${taskId}/status`);
	setProgress(taskDiv, response.percentDone, response.status);
    taskDiv.show();
}

function onLoaded() {
    const tasksDiv = $(".tasks").first();
    maintainDivCollection(fetchTasks, 10000, tasksDiv, makeTaskbar, onTaskAdded, onTaskRemoved);
}

const taskUpdaters = {};
function onTaskAdded(taskId, taskDiv) {
    taskUpdaters[taskId] = setIntervalAndExecute(updateProgress.bind(null, taskId, taskDiv), 1000)
}
function onTaskRemoved(taskId) {
    clearInterval(taskUpdaters[taskId]);
    delete taskUpdaters[taskId];
}

document.addEventListener("DOMContentLoaded", onLoaded);
