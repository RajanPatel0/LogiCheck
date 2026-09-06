function promiseAll(promises) {
  return new Promise((resolve, reject) => {
    const results = new Array(promises.length);     //pre-allocate an array of the exact size needed. (i.e. 3 as in notes)
    let completed = 0;
    if (promises.length === 0) return resolve(results); //edge-case: if empty array passed[] -> foreach never runs and -> completed  never increment
                                                        //& promise hangs in pending state forever (customers remains wait at table if they're not ordering)
    promises.forEach((p, i) => {
      Promise.resolve(p).then(value => {    //Wrapping p in Promise.resolve() forces non-promises into immediate promise
                                            //used cuzz maybe if array passed have "number" as element which don't have .then() menthod(on standerd numbers)
        results[i] = value; // order preserved regardless of resolution order
                            //Never use results.push(value) in Promise.all: cuzz maybe any later idx order(say 2) have less prepare time & thus
                            //push results in 2nd idx at first in result 
                            //so we use index i in forEach -> locks preparation as idx wise order
        completed++;
        if (completed === promises.length) resolve(results);
      }).catch(reject); // first rejection short-circuits immediately
    });
  });
}

// promiseAll();

//Use 1: Basic Resolve
function delay(ms, value) {
  return new Promise(resolve => setTimeout(() => resolve(value), ms));
}

promiseAll([
  delay(100, "First"),
  delay(200, "Second"),
  delay(300, "Third")
]).then(results => {
  console.log("All resolved:", results);
}).catch(err => {
  console.error("Rejected:", err);
});
//Notice the order is preserved even though the first finished fastest.


//Use 2: Rejection Short-Circuit
function delay(ms, value, shouldReject = false) {
  return new Promise((resolve, reject) =>
    setTimeout(() => shouldReject ? reject(value) : resolve(value), ms)
  );
}

promiseAll([
  delay(100, "First"),
  delay(200, "Second"), // reject
  delay(300, "Third", true)
]).then(results => {
  console.log("All resolved:", results);
}).catch(err => {
  console.error("Rejected:", err);
});

//output after 300ms 
//The rejection short‑circuits immediately — later promises are ignored.


//Use 3: real World Dashboard Fetch
function fetchUser(id) {
  return new Promise(resolve => setTimeout(() => resolve({ id, name: "Rajan" }), 1000));
}
function fetchTasks(id) {
  return new Promise(resolve => setTimeout(() => resolve(["Task1", "Task2"]), 1500));
}
function fetchStats() {
  return new Promise(resolve => setTimeout(() => resolve({ uptime: "99%" }), 500));
}

(async () => {
  try {
    const [user, tasks, stats] = await promiseAll([
      fetchUser(1),
      fetchTasks(1),
      fetchStats()
    ]);
    console.log("Dashboard ready:", { user, tasks, stats });
  } catch (err) {
    console.error("Failed to load dashboard:", err);
  }
})();

//this resolves in ~1.5 seconds (No waterfall)

