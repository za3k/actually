async function ajax(method, url) {
    return new Promise((resolve, reject) => {
        const xhr = new XMLHttpRequest();
        xhr.open(method, url);
        xhr.onload = function() {
            resolve(JSON.parse(this.response));
        };
        xhr.onerror = function() {
            reject({
                status: this.status,
                content: xhr.response,
            });
        };
        xhr.send();
    })
}

Set.prototype.difference = function(b) {
    return [...this].filter(x => !b.has(x));
}

function setIntervalAndExecute(f, interval) {
    f();
    return setInterval(f, interval);
}


function maintainCollection(poll, interval, onAdd, onRemove) {
    // onAdd should return an object for the collection if state is needed, like a div
    let knownIds = new Set(); // id -> div mapping
    const divForId = {};
    async function doPoll() {
        const response = await poll();
        const reportedIds = new Set(response);
        reportedIds.difference(knownIds).forEach(id => {
            // Added ids
            divForId[id] = onAdd(id);
        });

        knownIds.difference(reportedIds).forEach(id => {
            // Removed ids
            const div = divForId[id];
            delete divForId[id];
            onRemove(id, div);
        });

        knownIds = reportedIds;
    }
    return setIntervalAndExecute(doPoll, interval);
}

function maintainDivCollection(poll, interval, parentDiv, makeChildDiv, onAdd, onRemove) {
    return maintainCollection(poll, interval,
        (id) => {
            const div = makeChildDiv(id)
            div.appendTo(parentDiv);
            onAdd(id, div);
            return div;
        },
        (id, div) => {
            $(div).remove();
            onRemove(id);
        },
    );
}
