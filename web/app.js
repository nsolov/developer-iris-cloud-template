const form = document.querySelector('#todo-form');
const input = document.querySelector('#todo-input');
const addButton = document.querySelector('#add-button');
const list = document.querySelector('#todo-list');
const status = document.querySelector('#status');

function setStatus(message, isError = false) {
  status.textContent = message;
  status.className = isError ? 'error' : '';
}

function render(todos) {
  list.replaceChildren();
  setStatus(todos.length ? `${todos.length} ${todos.length === 1 ? 'task' : 'tasks'}` : '');
  if (!todos.length) {
    const empty = document.createElement('li');
    empty.className = 'empty';
    empty.textContent = 'Nothing here yet. Add your first task above.';
    list.append(empty);
    return;
  }

  for (const todo of todos) {
    const item = document.createElement('li');
    const dot = document.createElement('span');
    dot.className = 'dot';
    const text = document.createElement('span');
    text.className = 'todo-text';
    text.textContent = todo.text;
    const remove = document.createElement('button');
    remove.className = 'delete';
    remove.type = 'button';
    remove.setAttribute('aria-label', `Delete ${todo.text}`);
    remove.textContent = '\u00d7';
    remove.addEventListener('click', () => deleteTodo(todo.id, remove));
    item.append(dot, text, remove);
    list.append(item);
  }
}

async function loadTodos() {
  try {
    const response = await fetch('/api/todos');
    if (!response.ok) throw new Error('Could not load tasks.');
    render(await response.json());
  } catch (error) {
    setStatus(error.message, true);
  }
}

async function deleteTodo(id, button) {
  button.disabled = true;
  try {
    const response = await fetch(`/api/todos/${id}`, { method: 'DELETE' });
    if (!response.ok) throw new Error('Could not delete the task.');
    await loadTodos();
  } catch (error) {
    button.disabled = false;
    setStatus(error.message, true);
  }
}

form.addEventListener('submit', async event => {
  event.preventDefault();
  const text = input.value.trim();
  if (!text) return;
  addButton.disabled = true;
  try {
    const response = await fetch('/api/todos', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ text })
    });
    if (!response.ok) {
      const body = await response.json().catch(() => ({}));
      throw new Error(body.error || 'Could not add the task.');
    }
    input.value = '';
    await loadTodos();
    input.focus();
  } catch (error) {
    setStatus(error.message, true);
  } finally {
    addButton.disabled = false;
  }
});

loadTodos();
