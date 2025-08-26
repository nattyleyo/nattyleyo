// supabase/functions/send-admin-invite/index.ts
import { createClient } from "npm:@supabase/supabase-js@2.39.3";
const supabase = createClient(
  Deno.env.get("SUPABASE_URL"),
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")
);
const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
};
Deno.serve(async (req) => {
  // Handle preflight OPTIONS request
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: CORS_HEADERS,
    });
  }
  // Only allow POST
  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({
        error: "Method not allowed",
      }),
      {
        status: 405,
        headers: CORS_HEADERS,
      }
    );
  }
  try {
    const { email, id } = await req.json();
    if (!email || !id) {
      return new Response(
        JSON.stringify({
          error: "Email and Id required",
        }),
        {
          status: 400,
          headers: CORS_HEADERS,
        }
      );
    }
    // 1. Delete user from Supabase Auth
    const { error: deleteAuthErr } = await supabase.auth.admin.deleteUser(id);
    if (deleteAuthErr) throw deleteAuthErr;
    // 2. Delete from admins table
    const { error: adminErr } = await supabase
      .from("admins")
      .delete()
      .eq("id", id);
    if (adminErr) throw adminErr;
    // 3. Delete from admin_invitations table
    const { error: inviteErr } = await supabase
      .from("admin_invitations")
      .delete()
      .eq("email", email);
    if (inviteErr) throw inviteErr;
    return new Response(
      JSON.stringify({
        success: true,
      }),
      {
        status: 200,
        headers: CORS_HEADERS,
      }
    );
  } catch (err) {
    return new Response(
      JSON.stringify({
        error: err.message,
      }),
      {
        status: 500,
        headers: CORS_HEADERS,
      }
    );
  }
});
