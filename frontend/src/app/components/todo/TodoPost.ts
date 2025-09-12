export default async function TodoPost(title: string) {
	const apiUrl = process.env.NEXT_PUBLIC_API_URL;
	const response = await fetch(`${apiUrl}/todos`, {
		method: 'POST',
		headers: {
			'Content-Type': 'application/json',
		},
		body: JSON.stringify({ title: title, done: false }),
	});
	return response;
}
