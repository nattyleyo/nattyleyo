// supabase/functions/send-admin-invite/index.ts
import { createClient } from "npm:@supabase/supabase-js@2.39.3";
import crypto from "node:crypto";
import nodemailer from "npm:nodemailer";
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
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: CORS_HEADERS,
    });
  }
  try {
    const { email, role } = await req.json();
    const role_formated =
      role.charAt(0).toUpperCase() + role.slice(1).toLowerCase();
    if (!email || !role)
      return new Response(
        JSON.stringify({
          error: "Email and role required",
        }),
        {
          status: 400,
          headers: CORS_HEADERS,
        }
      );
    const token = crypto.randomBytes(32).toString("hex");
    const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString();
    const invited_as = role;
    // Insert invite into database
    const { error: insertError } = await supabase
      .from("admin_invitations")
      .insert({
        email,
        invited_as,
        token,
        expires_at: expiresAt,
      });
    if (insertError) throw insertError;
    // Configure SMTP transporter
    // console.log("SMTP_HOST:", Deno.env.get("SMTP_HOST"));
    // console.log("SMTP_USER:", Deno.env.get("SMTP_USER"));
    const transporter = nodemailer.createTransport({
      host: Deno.env.get("SMTP_HOST"),
      port: Number(Deno.env.get("SMTP_PORT")),
      secure: Deno.env.get("SMTP_SECURE") === "true",
      auth: {
        user: Deno.env.get("SMTP_USER"),
        pass: Deno.env.get("SMTP_PASS"),
      },
    });
    const is_Dev_Mode = Deno.env.get("DEV_MODE") === "true";
    console.log("Devmode---", is_Dev_Mode);
    // Build your invite link
    const inviteLink = `${
      is_Dev_Mode ? "http://localhost:5173" : Deno.env.get("APP_URL")
    }/accept-invite?token=${token}`;
    // Send email
    await transporter.sendMail({
      from: `"Bitbricks" <${Deno.env.get("SMTP_FROM")}>`,
      to: email,
      subject: `You are invited as an ${role_formated} on Bitbricks`,
      html: `<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <title>You're Invited to Become an ${role_formated} at Bitbricks</title>
    <style>
      body {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        color: #333;
        background-color: #f5f7fa;
        padding: 20px;
      }
      .email-container {
        background: #ffffff;
        border-radius: 8px;
        padding: 30px;
        max-width: 600px;
        margin: auto;
        box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05);
      }
      .method-section {
        background-color: #fff7ed;
        border-radius: 8px;
        padding: 20px;
        margin: 20px 0;
        border-left: 4px solid #ff6a13;
      }
      .method-title {
        color: #ff6a13;
        font-size: 18px;
        font-weight: 600;
        margin: 0 0 10px 0;
      }
      .otp-code {
        background-color: #ffffff;
        border: 2px dashed #ff6a13;
        border-radius: 6px;
        padding: 15px;
        text-align: center;
        margin: 15px 0;
      }
      .otp-digits {
        font-size: 28px;
        font-weight: 700;
        color: #ff6a13;
        letter-spacing: 3px;
        font-family: 'Courier New', monospace;
      }
      .otp-expiry {
        font-size: 12px;
        color: #666;
        margin-top: 8px;
      }
      .footer {
        margin-top: 30px;
        font-size: 12px;
        color: #999;
        text-align: center;
      }
      a.button {
        display: inline-block;
        background-color: #ff6a13;
        color: white !important;
        padding: 12px 20px;
        border-radius: 6px;
        text-decoration: none;
        font-weight: 600;
        margin-top: 10px;
      }
    </style>
  </head>
  <body>
    <div class="email-container">
      <h2 style="text-align: center;">You're Invited to Join Bitbricks Admin Team!</h2>
      <p>
        Hello,
      </p>
      <p>
        You have been invited to become ${
          role === "Admin" ? "an" : "a"
        } ${role_formated} at <strong>Bitbricks</strong>. To accept this invitation and activate your account, please use the verification code below or click the invitation link.
      </p>

      <!-- OTP Code Section -->
      <div class="method-section">
        <p style="text-align: center;">
        <a href="${inviteLink}" class="button" target="_blank" rel="noopener noreferrer">Accept Invitation</a>
      </p>
      </div>


      <p style="color: #9ca3af; font-size: 14px; margin: 20px 0 0 0;">
        If you did not expect this invitation, please ignore this email or contact us at <a href="mailto:support@bitbricks.ai" style="color:#3b82f6;text-decoration: underline;">support@bitbricks.ai</a>.
      </p>
      
      <div class="footer">
        &copy; 2025 Bitbricks. All rights reserved.
      </div>
    </div>
  </body>
</html>
`,
    });
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
        error: err.message || String(err),
      }),
      {
        status: 500,
        headers: CORS_HEADERS,
      }
    );
  }
});
