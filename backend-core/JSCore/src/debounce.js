function debounce(func, delay){
  let timer=null;

  return function(...args){
    clearTimeout(timer);
    timer = setTimeout(()=>
        func(...args), delay
    );
  };
};

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