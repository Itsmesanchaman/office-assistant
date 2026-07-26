// supabase/functions/login-employee/index.ts
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

serve(async (req) => {
  try {
    const { mobile_no, password } = await req.json();

    const res = await fetch(
      `${SUPABASE_URL}/rest/v1/employees?mobile_no=eq.${mobile_no}&select=*`,
      {
        headers: {
          apikey: SERVICE_ROLE_KEY,
          Authorization: `Bearer ${SERVICE_ROLE_KEY}`,
        },
      },
    );
    const rows = await res.json();
    const employee = rows?.[0];

    if (!employee || employee.password !== password) {
      return new Response(JSON.stringify({ error: "Invalid credentials" }), { status: 401 });
    }

    delete employee.password; // never send password back to client
    return new Response(JSON.stringify({ employee }), { status: 200 });
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), { status: 500 });
  }
});