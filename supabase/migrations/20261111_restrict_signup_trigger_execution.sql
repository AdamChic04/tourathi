-- Prevent clients from executing the privileged user-creation trigger via RPC.
-- PostgreSQL can still invoke it as an auth.users trigger.
revoke execute on function public.tourathi_create_user_profile()
from public, anon, authenticated;
