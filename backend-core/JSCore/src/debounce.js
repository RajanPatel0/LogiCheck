function debounce(func, delay){     //debounce function to limit the rate of API calls
  let timer=null;                   //timer variable to hold the timeout ID 

  return function(...args){         //return a new function that will be called when the input event is triggered
    clearTimeout(timer);            //clear the previous timeout to reset the debounce timer
    timer = setTimeout(()=>         //set a new timeout to call the original function after the specified delay
        func(...args), delay        //call the original function with the provided arguments after the delay
    );
  };
};

//Use 1: Basic Debouncing Printing
// const debounceFunc = debounce((msg)=>{
//     console.log("Debounced", msg);
// }, 2000);

// debounceFunc("Hello");
// debounceFunc("World");
//only "World" will print after 2 seconds, because the second call cancels the first.


//Use 2: Debouncing a complex function with multiple arguments
// const debouncedComplex = debounce((user, action) => {
//   console.log(`User: ${user.name}, Action: ${action.type}`);
// }, 1500);

// debouncedComplex({ name: "Rajan" }, { type: "LOGIN" });
// debouncedComplex({ name: "Rajan" }, { type: "CLICK_BUTTON" });
//After 1.5 seconds, only the last call (CLICK_BUTTON) will print.


//Use 3: search input debouncing in a React component
function fakeApiCall(query) {
  console.log("API called with query:", query);
}

const debouncedSearch = debounce(fakeApiCall, 1000);

// Simulating typing:
debouncedSearch("a");
debouncedSearch("ap");
debouncedSearch("app");
debouncedSearch("appl");
debouncedSearch("apple");
//After 1 second, only the last call (apple) will trigger the API call.