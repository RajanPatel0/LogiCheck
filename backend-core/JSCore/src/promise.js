//Promise:
//Every fetch, every DB driver, every async lirary use dup in node build on this shape
//Understanding this make us -> "Why did my .then not fired"

class MyPromise{    //
    constructor(executor){  //main promise method as constructor 
        //promise is just a state machine[in starts 'pending] || on resolve/reject state changes to fullfilled/rejected
        this.state = 'pending';
        this.value = 'undefined';   //for data to be locked on state changes
        this.callback = []; //  executor works asynchronously, so ".then()" executes before db finishes-> cuzz state is pending
                            //  so promise takes our pending ".then() instructions" & park in callback array
                            //  when db finally triggers with resolve()/reject() -> then loops through that array and executes waiting instructions of .then()

                //imp. in resovle -> if already rejected then that need reject in itself too in catch 
        const resolve = (value) =>{     //resolve required value for fulfill proimse return 
            if(this.state !== 'pending') return;    //if already fulfilled then return 
            this.state = 'fulfilled';
            this.value = value;     //most imp.
            this.callback.forEach(cb => cb.onFulfilled(value));
        };

        //imp. in reject -> if already rejected then that rejection is resolve in itself too in try 
        const reject = (reason)=>{
            if(this.state !== 'pending') return;    //if already fulfilled with reject mark then resolve already
            this.state = 'rejected';
            this.value = reason;    //most imp.
            this.callback.forEach(cb => cb.onRejected(reason));
        };

        try{
            executor(resolve, reject);
        }catch(err){
            reject(err);
        }
    }

    //How does .then().then().then() work?
    then(onFulfilled, onRejected){  //every time ".then()" called -> it doesn't return original Promise
                                    //it returns new MyPromise instance -> then value returned by 1st .then() is passed to resolve of 2nd .then()
        return new MyPromise((resolve, reject)=>{
            const handleFulfilled=(value)=>{
                try{
                    // resolve(onFulfilled ? onFulfilled(value): value);
                    //OR
                    if(onFulfilled) resolve(onFulfilled(value));
                    else resolve(value)
                }catch(err){
                    reject(err);
                }
            };

            const handleRejected=(reason)=>{
                try{
                    if(onRejected) resolve(onRejected(reason));
                    else reject(reason);
                }catch(err){
                    reject(err);
                }
            };

            if(this.state == 'fulfilled') handleFulfilled(this.value);
            else if(this.state ==='rejected') handleRejected(this.value);
            else this.callback.push({ 
                onFulfilled: handleFulfilled,
                onRejected: handleRejected
            });
        });
    }
}

//Use 0: real-world simulation:
function fakeDBQuery(query) {
  return new MyPromise((resolve, reject) => {
    setTimeout(() => {
      if (query === "SELECT * FROM users") {
        resolve([{ id: 1, name: "Rajan" }]);
      } else {
        reject("Invalid query");
      }
    }, 1000);
  });
}

fakeDBQuery("SELECT * FROM users")
  .then((rows) => { //it runs 1st cuzz .then() as sync
    console.log("Got rows:", rows);
    return rows[0].name;
  })
  .then((name) => {
    console.log("First user name:", name);
  })
  .then(() => {
    console.log("Query chain complete!");
  })
  .then(() => {     //again it goes in pending as async & next .then runs & it's output lastly passes to that next as reason of error
    throw new Error("Oops in chain");
  })
  .then(null, (err) => {
    console.log("Caught error:", err.message);
  });


//Use 1: Basic Resolve
// const p1 = new MyPromise((resolve, reject) => {
//   setTimeout(() => {
//     resolve("Data loaded successfully!");
//   }, 1000);
// });

// p1.then((value) => {
//   console.log("First then:", value);
//   return "Passing to next then";
// }).then((value) => {    //first above then resolve return is passed as value to this below resolve 
//   console.log("Second then:", value);
// });


//Use 2: Reject Example:
const p2 = new MyPromise((resolve, reject) => {
  setTimeout(() => {
    reject("Something went wrong!");
  }, 1000);
});

p2.then(
  (value) => console.log("Resolved:", value),
  (err) => console.log("Caught error:", err)
);
//as reject make the value in error oin .then()'s


//Use 3: chaining Multiple:
const p3 = new MyPromise((resolve, reject) => {
  setTimeout(() => {
    resolve(10);
  }, 500);
});

p3.then((num) => {
  console.log("Step 1:", num);
  return num * 2;
}).then((num) => {
  console.log("Step 2:", num);
  return num + 5;
}).then((num) => {
  console.log("Step 3:", num);
});
