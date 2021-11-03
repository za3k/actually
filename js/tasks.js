function setProgress(bar, percent, status) {
    $(bar).find(".cssProgress-bar").css("width", percent + "%").attr("data-percent", percent).find(".cssProgress-label").text(percent + "%");
    for (let x of ["done", "notstarted", "error", "paused", "active", "retryactive"]) {
        $(bar).find(".cssProgress-bar").toggleClass("cssProgress-"+x, status == x);
    }
}

function makeTaskbar(taskId) {
    return $(`<div class="cssProgress">\n	${taskId}<div class="progress-medium">\n		<div class="cssProgress-bar" data-percent="0" style="width: 0%;">\n			<span class="cssProgress-label">0%</span>\n		</div>\n	</div>\n</div>`, {
        "data-source-id": taskId,
    });
}

let knownTasks = new Set(); // task id -> div mapping
const taskDivForId = {};
async function getTasks(tasksDiv) {
    const response = await ajax("GET", "/api/tasks");
    const reportedTasks = new Set(response.tasks);

    reportedTasks.difference(knownTasks).forEach(taskId => {
        // Added tasks
        taskDivForId[taskId] = onTaskAdded(tasksDiv, taskId);
    });

    knownTasks.difference(reportedTasks).forEach(taskId => {
        // Removed tasks
        onTaskRemoved(taskDivForId[taskId], taskId);
        delete taskDivForId[taskId];
    });

    knownTasks = reportedTasks;
}

async function updateProgress(taskDiv, taskId) {
	const response = await ajax("GET", `/api/tasks/${taskId}/status`);
	setProgress(taskDiv, response.percentDone, response.status);
    taskDiv.show();
}

function onLoaded() {
    const tasksDiv = $(".tasks").first();
    getTasks(tasksDiv);
    setInterval(getTasks.bind(null, tasksDiv), 10000);
}

const taskUpdaters = {};
function onTaskAdded(parentDiv, taskId) {
    const taskDiv = makeTaskbar(taskId);
    taskDiv.hide();
    taskDiv.appendTo(parentDiv);
    updateProgress(taskDiv, taskId);
    taskUpdaters[taskId] = setInterval(updateProgress.bind(null, taskDiv, taskId), 1000);
    return taskDiv;
}

function onTaskRemoved(taskDiv, taskId) {
    clearInterval(taskUpdaters[taskId]);
    delete taskUpdaters[taskId];
    $(taskDiv).remove();
}

document.addEventListener("DOMContentLoaded", onLoaded);
