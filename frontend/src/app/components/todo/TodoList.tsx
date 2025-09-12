'use client'

import React, { useEffect, useState } from 'react';
import { fetchTodos, addTodo, updateTodo, deleteTodo as deleteTodoApi } from './api';

// Todoの型定義
type Todo = {
  id: number;
  title: string;
  done: boolean;
};

const TodoComponent = () => {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [title, setTitle] = useState('');
  const [editTitle, setEditTitle] = useState(''); // 編集用のタイトル
  const [editId, setEditId] = useState<number | null>(null);

  // Todoリストを取得
  useEffect(() => {
    fetchTodos().then(data => {
      setTodos(Array.isArray(data) ? data : []);
    });
  }, []);

  // Todoを追加する処理
  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    try {
      const newTodo = await addTodo(title);
      setTodos([...todos, newTodo]); // Todoリストを更新
      setTitle('');
    } catch (error) {
      console.error('Failed to create todo:', error);
    }
  };

  // Todoを削除する処理
  const deleteTodo = async (id: number) => {
    try {
      await deleteTodoApi(id);
      setTodos(todos.filter(todo => todo.id !== id)); // UIからも削除
    } catch (error) {
      console.error('Failed to delete todo:', error);
    }
  } 

  // Todo編集処理
  const editTodo = async (id: number) => {
    try {
      const updated = await updateTodo({ id, title: editTitle, done: false });
      setTodos(todos.map(todo => todo.id === id ? updated : todo));
      setEditId(null);
      setEditTitle(''); // 編集フォームのリセット
    } catch (error) {
      console.error('Failed to edit todo:', error);
    }
  } 

  return (
    <div className="container mx-auto p-4">
      <form onSubmit={handleSubmit} className="mb-4">
	<input
	  type="text"
	  value={title}
	  onChange={(e) => setTitle(e.target.value)}
	  placeholder="Add a new task"
	  className="shadow appearance-none border rounded py-2 px-3 text-grey-darker mr-2"
	/>
	<button type="submit" className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
	  Add Task
	</button>
      </form>
      <ul className="list-disc pl-5">
      {todos.map(todo => (
          <li key={todo.id} className="mb-2">
            {editId === todo.id ? (
              <input
                type="text"
                value={editTitle}
                onChange={(e) => setEditTitle(e.target.value)}
              />
            ) : (
              <span className="text-grey-darker">{todo.title}</span>
            )}
            <button onClick={() => { setEditId(todo.id); setEditTitle(todo.title); }} className="bg-yellow-500 hover:bg-yellow-700 text-white font-bold py-1 px-2 rounded ml-2">
              Edit
            </button>
            <button onClick={() => deleteTodo(todo.id)} className="bg-red-500 hover:bg-red-700 text-white font-bold py-1 px-2 rounded ml-2">
              Delete
            </button>
            {editId === todo.id && (
              <button onClick={() => editTodo(todo.id)} className="bg-green-500 hover:bg-green-700 text-white font-bold py-1 px-2 rounded ml-2">
                Save
              </button>
            )}
          </li>
        ))}
      </ul>
    </div>
  );
}

export default TodoComponent;
