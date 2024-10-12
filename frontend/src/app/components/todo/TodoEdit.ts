export default async function TodoEdit(id:string, editTitle:string) {
  const apiUrl = process.env.NEXT_PUBLIC_API_URL;

  const response = await fetch(`${apiUrl}/todos/${id}`, {
    method: 'PATCH', // または 'PUT'
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ todo: { title: editTitle } }),
  });
}
