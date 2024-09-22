export default async function TodoPost(title:string) {
  const response = await fetch('http://localhost:3000/todos', {
	method: 'POST',
	headers: {
	  'Content-Type': 'application/json',
	},
	body: JSON.stringify({ todo: { title: title, completed: false } }),
      });
  return response
}
