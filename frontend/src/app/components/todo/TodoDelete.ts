export default async function TodoDelete(id:string) {
  await fetch(`http://localhost:3000/todos/${id}`, {
    method: 'DELETE',
  }); 
}
