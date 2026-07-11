/**
 * The default HTTP method for fetch is GET.
 * 
 */

type Todo = {
  userId: number,
  id: number,
  title: string,
  completed: boolean
}

async function getAllTodos(): Promise<Todo[]> {
  const response = await fetch('https://jsonplaceholder.typicode.com/todos')
  if (!response.ok) {
    throw new Error(`Response status: ${response.status}`)
  }
  const todos: Todo[] = await response.json()
  return todos
}

async function getTodoById(id: number): Promise<Todo> {
  const response = await fetch(`https://jsonplaceholder.typicode.com/todos/${id}`)
  if (!response.ok) {
    throw new Error(`Response status: ${response.status}`)
  }
  const todo: Todo = await response.json()
  return todo
}

async function postTodo(todo: Todo) {
  const response = await fetch('https://jsonplaceholder.typicode.com/todos', {
    method: 'POST',
    headers: {
      'Content-type': 'application/json'
    },
    body: JSON.stringify(todo)
  })
  if (!response.ok) {
    throw new Error(`Response status: ${response.status}`)
  }
  const createdTodo: Todo = await response.json()
  console.log(`Todo with id: ${createdTodo.id} successfully created.`)
}

getTodoById(2).then((todo) => {
  console.log('Todo by id: ')
  console.log(todo)
})

getAllTodos().then((todos) => {
  console.log('All todos: ')
  console.table(todos)
})

const newTodo: Todo = {
  userId: 1,
  id: 201,
  title: "New Task",
  completed: false
}

postTodo(newTodo)