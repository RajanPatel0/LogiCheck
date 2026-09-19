//Module 1: Function.prototype.myBind
//Use Case: React class components (pre-hooks) doing this.handleClick = this.handleClick.bind(this) in constructors — 
//          because event handlers lose this when passed as callbacks. 
//          Also: partial application for logging/config functions (e.g., a logger.bind(null, 'AUTH_MODULE')).

//1. "this" Keyword: The "this" keyword refers to the object that is executing the current function. 
//                 In JavaScript, the value of this is determined by how a function is called. 
//                 When a function is called as a method of an object, "this" refers to **that** object. 
//                 When a function is called as a standalone function, "this" refers to the global object (window in browsers). 
//                 In strict mode, this will be undefined for standalone functions.

//1.1: In a method of an object, this refers to the object itself.

// "use strict";   //it'll show "undefined" for standalone functions instead of window object.
// const user={
//     name:'Rajan',
//     greet(){
//         console.log(this.name);     //or user.name 
//     }
// }//this.name in this user obj. refers to the name property of the user object.
// user.greet()

//1.2: in standalone function, this refers to the global object (window in browsers).
// function show(){
//     console.log(this);     //here "this" used alone but no object passed so it take complete window as a object and print all the properties of window object.
// }
// show();

//1.3: In arrow function, this refers to the surrounding lexical context.
// const user1 = {
//     name:'Rajan',
//     greet:()=>{     //can't use this keyword in arrow function because arrow function doesn't have its own this keyword.
//         console.log(this.name);     //or user.name 
//     }
// }
// user1.greet()   //give blank in console because "arrow function" doesn't have its own this keyword. 
                //It takes this from the surrounding lexical context. 
                // In this case, the surrounding context is the global scope, where this refers to the global object (window in browsers). 
                // Since there is no name property on the global object, it prints undefined.

//1.4: for this of 1 obj refers to another object, we can assign the method of one object to another object and call it.
// const person = {
//     name: "Rajan",
//     greet(){
//         console.log(this.name);     //or person.name
//     }
// }

// const another = {
//     name: "Patel"
// }

// another.say = person.greet; //assigned person.greet to another.say,

// another.say();   //here this.name refers to another obj.


//2: Call: Accepts arguments separately & immediately executes function with a given this value and arguments provided individually.
//2.1: Simple obj passing to another obj using call method.
// function greet(user, city){
//     console.log(user.name, "from", city);
//     console.log(city);
// }
// const user3={
//     name: "Rajan"
// }

// greet(user3, "Ludhiana");

//2.2 if we not call obj in function call then we'll use "this" keyword in function and pass obj in call method.
// function greet(city){
//     console.log(this.name);
//     console.log(city);
// }
// const user3={
//     name: "Rajan"
// }

//**Without call, this would be global. With call, you force this to be user3.

// greet(user3, "Ludhiana");   //without call: not showing city because we not pass city in function call. So, we need to use call method to pass obj and city as argument.
// greet.call(user3, "Ludhiana");   //with call: showing city because we pass obj and city in call method. Here this.name refers to user3 obj.


//3: Apply: if we've to give in array format, we can use "apply" method instead of call method. It immediately executes function with a given this value and arguments provided as an array (or an array-like object).
// function greet(city, age){
//     console.log(this.name, city);
//     console.log(city);
// }
// const user3={
//     name: "Rajan"
// }

// greet.apply(user3, ["Ludhiana", 21]);   //using apply : for showing in array format. Here this.name refers to user3 obj.

//4 bind: return new function not as immediately executes function(which is in call, apply) with a given this value and arguments provided individually.
// function greet(city){
//     console.log(this.name, city);
// }

// const user4={
//     name: "Rajan"
// }

// const newFunction = greet.bind(user4, "Jalandhar");   //using bind: for returning new function. Here this.name refers to user4 obj. and we need to call it with (). 

// newFunction();

//5. Hoisting: it tell us whether a variable or function is declared or not during time of execution
            // Hoisting move declaration to memory before js execution

//5.1: calling a function before its declaration is possible because of hoisting. Function declarations are hoisted to the top of their scope, so they can be called before they are defined in the code.
// console.log(a);
// var a=10;    //with var shows diff from let because **"var is hoisted and initialized with undefined"**. So, it shows undefined in console.
// let a=10;    //with let it shows diff from var because let is hoisted but not initialized. So, it shows ReferenceError: Cannot access 'a' before initialization.

// console.log(b);
// const b=20;    //with const it shows diff from var because const is hoisted but not initialized. So, it shows ReferenceError: Cannot access 'b' before initialization.

//let and const give reference error because they are hoisted but not initialized. They are in a "temporal dead zone" from the start of the block until the declaration is encountered, which means you cannot access them before their declaration.
//but var gives undefined because it is hoisted and initialized with undefined. So, it shows undefined in console.

// greet() //function is also hoisted like var, so we can call it before its declaration. It shows "Hello, World!" in console.

// function greet(){
//     console.log("Hello, World!");
// }

//OR    

greet()
var start= function(){     //means var start = undefined (but hoist in direct passing) and then assign function to it. So, it shows "start is not a function" in console.
    console.log("Hello, World!");
}
//The variable 'start' is hoisted and initialized as undefined. Trying to invoke undefined as a function (start()) results in a TypeError


// this is a custom implementation of the bind method, which allows you to create a new function with a specific this context and optional arguments. 
// The myBind function takes a context and any number of bound arguments, and returns a new function that can be called later with additional arguments. 
// If the new function is called with the new keyword, it ignores the bound context and uses the new instance instead.
Function.prototype.myBind = function (context, ...boundArgs) {  // the myBind function takes a context and any number of bound arguments
  const fn = this; // the original function
  function boundFn(...callArgs) {   // the new function that will be returned
    // if called with `new`, ignore the bound context
    const isNewCall = this instanceof boundFn;  // check if the function is called with new
    return fn.apply(isNewCall ? this : context, [...boundArgs, ...callArgs]);   // call the original function with the appropriate context and arguments
  }
  boundFn.prototype = Object.create(fn.prototype || {});    // set the prototype of the new function to be an object that inherits from the original function's prototype
  return boundFn;   //return the new function
};

//Pre-Bound Logger Function (with module name bound to AUTH)
function log(module, level, message) {
  console.log(`[${module}] [${level}] ${message}`);
}
const authLog = log.myBind(null, 'AUTH');   // bind the module name to 'AUTH' for authentication-related logs
authLog('INFO', 'User logged in');   // [AUTH] [INFO] User logged in
authLog('ERROR', 'Invalid token');   // [AUTH] [ERROR] Invalid token