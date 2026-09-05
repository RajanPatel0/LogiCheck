//Currying is a functional programming technique in JavaScript that transforms a function with multiple arguments into a sequence of functions, each taking a single argument. This approach enhances modularity, reusability, and readability of code.

// The curried function takes any number of arguments and checks if the number of provided arguments is greater than or equal to the original function's expected parameters (fn.length). 
// If so, it invokes the original function with the provided arguments using fn.apply(this, args). 
// Otherwise, it returns a new function that collects additional arguments until the required number is reached. 
// This allows for partial application of functions, enabling developers to create specialized versions of functions by pre-filling some of their arguments.
function curry(fn) {
  return function curried(...args) {
    if (args.length >= fn.length) return fn.apply(this, args);  //.length property of the function object returns the number of parameters expected by the function. also checking in this line if the number of provided arguments is greater than or equal to the original function's expected parameters (fn.length).
    return (...next) => curried.apply(this, [...args, ...next]);
  };
}
module.exports = curry;


// Use Case 1: Express.js Role-Based Middleware (Node.js)
//Checking user permission function instead of repititive function 
// Generic curried authorization function
const authorize = curry((role, req, res, next) => {
  if (req.user.role === role) return next();
  return res.status(403).json({ error: 'Forbidden' });
});

// 1. You "pre-load" the role argument. 
// It returns a standard Express middleware signature: (req, res, next)
const requireAdmin = authorize('admin');
const requireEditor = authorize('editor');

// 2. Use it cleanly in your routes
app.delete('/users/:id', requireAdmin, deleteUser);
app.put('/posts/:id', requireEditor, updatePost);


//Use Case 2: Configurable API Fetchers (React / Frontend)
//When building frontend services, we often hit the same base URL or endpoints. Currying lets us lock in the configuration step-by-step.
const apiRequest = curry(async (baseUrl, headers, endpoint, body) => {
  const response = await fetch(`${baseUrl}${endpoint}`, {
    method: body ? 'POST' : 'GET',
    headers,
    body: body ? JSON.stringify(body) : null
  });
  return response.json();
});

// Step 1: Lock in the base URL
const myApi = apiRequest('https://api.myapp.com');

// Step 2: Lock in the headers for authenticated requests
const authApi = myApi({ 'Authorization': 'Bearer token123' });

// Step 3: Use it in our React components cleanly!
// Now we only need to pass the endpoint and body.
const fetchDashboard = () => authApi('/dashboard', null);
const updateProfile = (data) => authApi('/profile', data);