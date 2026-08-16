// Real email addresses for notification recipients.
// Names must match what shows up in the chat (derived from auth email local-part).
export const PEOPLE: Record<string, string> = {
  Kevin: 'kevin@example.com',
  Kaitlin: 'kaitlin@example.com',
}

export const PEOPLE_NAMES = Object.keys(PEOPLE) as Array<keyof typeof PEOPLE>
