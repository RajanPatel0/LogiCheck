console.log('JSCore Module Loaded');

//allow both reassign and redeclare:
var name = "Ranjeet";
console.log(name);
name = 'Patel'
console.log(name);
var name = 'Singh';
console.log(name);

//Preventing redeclare in let
// let name = 'Shruti';
// let name = 'Thakur';
// console.log(name);


//const allowed in object mutation(No reassign/redeclare)
const user={
    name : 'Rajan'
}
user.name = 'Patel';
console.log(user.name);

//this not possible it'll give "TypeError: Assignment to constant variable."
// const name='Ranjeet';
// console.log(name);
// name = 'Singh';
// console.log(name);

