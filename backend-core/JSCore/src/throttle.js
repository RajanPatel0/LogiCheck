function throttle(fn , limit){      // throttle function to limit the rate of function execution
    let inThrottle = false;         // Flag to indicate whether the function is currently in the throttle period.
    return function(...args){       // Return a new function that will be called when the event is triggered
        if(inThrottle) return;      // If the function is already in the throttle period, exit early without executing the function.
        fn(...args);                // Call the original function with the provided arguments.
        inThrottle = true;          // Set the throttle flag to true, indicating that the function is now in the throttle period.
        setTimeout(()=> (           // Set a timeout to reset the throttle flag after the specified limit.
            inThrottle = false  
        ), limit);
    };
};

throttle();

//use 1: Basic Throttling Example
const throttleFunc = throttle((msg)=>{
    console.log("Throttled", msg);
}, 2000);

throttleFunc("Hello");
throttleFunc("World");
throttleFunc("Again");
//only "Hello" will print immediately, and "next 2 calls" will be ignored because it was called within the 2-second throttle period.


//Use 2: Throttling a complex function with multiple arguments
const throttleComplex = throttle((user, action)=>{
    console.log(`User: ${user.name}, Action: ${action.type}`);
}, 1500);

throttleComplex({ name: "Rajan" }, { type: "LOGIN" });
throttleComplex({ name: "Rajan" }, { type: "CLICK_BUTTON" });
//After 1.5 seconds, only the first call (LOGIN) will print, and the second call (CLICK_BUTTON) will be ignored because it was called within the 1.5-second throttle period.


//Use 3: Throttling a "scroll event / window resize" in a React component
function handleResize(){
    console.log("Window resized", new Date().toLocaleTimeString());
}

const throttleResize = throttle(handleResize, 1000); // Throttle the resize handler to execute at most once every 1 second.

window.addEventListener('resize', throttleResize); // Attach the throttled resize handler to the window resize event.