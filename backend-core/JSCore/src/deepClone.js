function deepClone(obj, visited = new WeakMap()) {
  if (obj === null || typeof obj !== 'object') return obj;  //base-case: primitives(strings, numbers, booleans) are passed by value(not references)
                                                            //so we just return it exactly as it is
  if (obj instanceof Date) return new Date(obj);    //need a new Date object passed in original's value cuzz can't just iterate over it's keys
  if (visited.has(obj)) return visited.get(obj); // circular reference guard

  const clone = Array.isArray(obj) ? [] : {};   //arrays are technically objects in js we need correctly initialize the correct empty container before recursively filling it
  visited.set(obj, clone);
  for (const key in obj) {
    if (Object.prototype.hasOwnProperty.call(obj, key)) {
      clone[key] = deepClone(obj[key], visited);
    }
  }
  return clone;
}

// deepClone();

// *WeakMap*: used to delete memory if cloned obj is no longer needed everywhere in app


//Use 1:Basic Object
const original = { name: "Rajan", age: 25 };
const cloned = deepClone(original);

cloned.name = "Changed";

console.log("Original:", original); // { name: "Rajan", age: 25 }
console.log("Cloned:", cloned);     // { name: "Changed", age: 25 }


//Use 2: Nested Object
const original1 = {
  user: {
    name: "Rajan",
    cart: { items: ["Book", "Pen"] }
  }
};

const cloned1 = deepClone(original1);
cloned1.user.cart.items.push("Notebook");

console.log("Original:", original1.user.cart.items); // ["Book", "Pen"]
console.log("Cloned:", cloned1.user.cart.items);     // ["Book", "Pen", "Notebook"]
//With a shallow copy ({ ...original }), both arrays would mutate together. With deepClone, they’re independent.


//Use 3: Circular Reference
const obj = { name: "Circular" };
obj.self = obj; // circular reference

const cloned2 = deepClone(obj);
console.log(cloned2.name); // "Circular"
console.log(cloned2.self === cloned2); // true
