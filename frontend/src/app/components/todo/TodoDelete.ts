export default async function TodoDelete(id:string) {
  const apiUrl = process.env.NEXT_PUBLIC_API_URL;

  await fetch(`${apiUrl}/todos/${id}`, {
    method: 'DELETE',
  }); 
}
