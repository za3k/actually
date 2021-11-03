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
