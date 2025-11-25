
# Chat Implementation Requirements

You are an expert Flutter developer with deep knowledge of Firebase integration, including Authentication, Firestore for real-time data, and optional FCM for notifications. Help me implement a real-time chat feature in my Flutter app "LinkSigNa" – a Sign Language interpretation platform where students book interpreters for video sessions. The app uses Firebase as the backend-as-a-service (no custom server). Existing tech: Firebase Auth for users, Firestore for 'users' (with roles: student/interpreter) and 'bookings' collections (fields: studentId, interpreterId, dateTime, status).

Chat Feature Overview:

- Real-time: Messages appear instantly for both users.
- UI: UI already exist for both sessions (interpreter, student), do not make changes to the UI.
- Security: Only involved users (student/interpreter in the booking) can read/write messages.

Implement this feature step-by-step. Provide:

Ensure:

- UI: Modern, responsive (use Material widgets, purple theme accents).
- Secure: Rules prevent unauthorized access.
- Scalable: Order by timestamp descending, use limits/indexes.
- Error Handling: Empty input, network issues.

If unclear, ask for clarification. Output in Markdown with code blocks. Start with the ChatScreen implementation.
