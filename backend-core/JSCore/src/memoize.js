//React useMemo is conceptually simialr to memeization.
//Memoization is an optimization technique that involves caching the results of expensive function calls and returning the cached result when the same inputs occur again. This can significantly improve performance, especially for functions that are called frequently with the same arguments.

//The memoize function takes a function fn as an argument and returns a new function that wraps the original function. It uses a Map object as a cache to store the results of previous function calls based on their arguments. When the returned function is called, it checks if the result for the given arguments is already cached. If it is, it returns the cached result; otherwise, it computes the result by calling the original function, stores it in the cache, and then returns it.
function memoize(fn){ 
    const cache = new Map(); // Create a cache to store results of previous function calls
     return function (...args){     // Return a new function that will be called with the provided arguments[index card label]
        const key = JSON.stringify(args); // Create a unique key based on the function arguments[strigify cuzz 2 separate array not same in JS]
        if(cache.has(key)){     // Check if the result for the given arguments is already cached
            console.log("Returning Cached result for:", key); // Log a message indicating a cache hit
            return cache.get(key); // If the result is already cached, return it
        }

        const result = fn(...args);     // Call the original function with the provided arguments and store the result
        cache.set(key, result); // Store the result in the cache for future calls
        console.log("Computed new result for:", key); // Log a message indicating that the result was computed and cached
        return result; // Return the computed result
     };
}

memoize();


//Use 1: Basic Memoization Example
function slowSquare(n){
    for(let i=0; i<1e8; i++){
        return n*n;
    }
}

const memoizedSquare = memoize(slowSquare);

console.log(memoizedSquare(5)); //computes
console.log(memoizedSquare(5)); //cached


//Use 2: Complex Arguments:
function addUsers(user, role){
    return `${user.name} has ${role}`;
}

const memoizedAddUser = memoize(addUsers);

console.log(memoizedAddUser({name: "rajan"}, "admin"));     //computes
console.log(memoizedAddUser({name: "rajan"}, "admin"));     //cached


//Use 3: API calls or expensive calculations

function fibonacci(n){
    if(n<=1) return n;
    return memoizedFibonacci(n-1) + memoizedFibonacci(n-2);
}

const memoizedFibonacci = memoize(fibonacci);

console.log(memoizedFibonacci(35)); //computed
console.log(memoizedFibonacci(35)); //cached

//Without memoization, recursive Fibonacci is painfully slow. With memoization, repeated calls are fast.