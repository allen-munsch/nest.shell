// Helper functions and prop passing system
const state = {};
const listeners = {};

function useState(key, initialValue) {
  if (!(key in state)) {
    state[key] = initialValue;
  }
  
  const setValue = (newValue) => {
    state[key] = newValue;
    if (listeners[key]) {
      listeners[key].forEach(callback => callback(newValue));
    }
  };
  
  return [state[key], setValue];
}

function useEffect(callback, dependencies) {
  dependencies.forEach(dep => {
    if (!listeners[dep]) {
      listeners[dep] = [];
    }
    listeners[dep].push(callback);
  });
}

// Initialize widgets
document.querySelectorAll('.widget').forEach(widget => {
  const route = widget.dataset.route;
  if (window[`init${route.replace(/\//g, '_')}`]) {
    window[`init${route.replace(/\//g, '_')}`](widget);
  }
});
