function init_home(widget) {
  const [count, setCount] = useState('homeCount', 0);
  const counterElement = widget.querySelector('#counter');
  
  function updateCounter() {
    counterElement.textContent = `Count: ${count}`;
  }
  
  useEffect(updateCounter, ['homeCount']);
  
  const incrementButton = document.createElement('button');
  incrementButton.textContent = 'Increment';
  incrementButton.addEventListener('click', () => setCount(count + 1));
  
  widget.appendChild(incrementButton);
  updateCounter();
}
