export default async function getData() {
  const apiUrl = process.env.NEXT_PUBLIC_API_URL;

  const response = await fetch(`${apiUrl}/todos`);
  if (!response.ok) {
    throw new Error('Failed to fetch data');
  }
  return await response.json();
}
