export default async function getData() {
  const response = await fetch('http://localhost:3000/todos');
  if (!response.ok) {
    throw new Error('Failed to fetch data');
  }
  return await response.json();
}
