# מסע המילים · Word Quest

משחק אוצר מילים באנגלית לכיתה ה׳. שלב 1: Our World (72 מילים), שלב 2: Hobbies (11 מילים).

הכל רץ בדפדפן; ההתקדמות נשמרת במכשיר בלבד.

זמין למשחק כאן:
https://avocacode10.github.io/word-quest/

## טבלת הכיתה (Class leaderboard)

Optional, and only for players who opt in. Only their name, avatar and total score are sent.
The button stays hidden until it's configured.

One-time setup (free Supabase project):
1. Create a project at https://supabase.com.
2. **SQL Editor** → paste and run `supabase/leaderboard.sql`.
3. **Authentication → Sign In / Providers** → turn off **Allow new users to sign up** (the game doesn't use logins).
4. **Project Settings → API Keys** → copy the project URL and the *publishable* (or legacy *anon*) key into
   `const LB={url:"",key:""}` in `index.html`. Never use the *secret* / *service_role* key.

The public key can only call three functions: join or update, read the top list, and leave.
It can't read or write the table directly. Names must be short letters or digits, the avatar must be one of the game's,
and the table is capped at 60 rows. To clear the board, delete the rows in **Table Editor → leaderboard**.
Free projects pause after about a week with no activity. Restore it from the dashboard.
