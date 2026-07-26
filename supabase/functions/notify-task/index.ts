// supabase/functions/notify-task/index.ts

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { create, getNumericDate } from "https://deno.land/x/djwt@v2.8/mod.ts";

const FCM_PROJECT_ID = Deno.env.get("FCM_PROJECT_ID")!;
const FCM_CLIENT_EMAIL = Deno.env.get("FCM_CLIENT_EMAIL")!;
const FCM_PRIVATE_KEY = Deno.env.get("FCM_PRIVATE_KEY")!.replace(/\\n/g, "\n");

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

// =========================
// TRANSLATIONS
// =========================
const translations = {
  en: {
    task_assigned_title: (adminName: string) => `Task assigned by ${adminName}`,
    task_assigned_body: (workType: string, priority: string) =>
      `${workType} - ${priority}`,
    ring_only_title: (adminName: string) => `${adminName} is calling you`,
    ring_only_body: "Please come to the office now",
    task_status_updated_title: "Task Status Updated",
    task_status_updated_body: (employeeName: string, status: string) =>
      `${employeeName} marked task as ${status}`,
    ring_again_title: "🔔 Reminder: Task Pending",
    ring_again_body: (workType: string, priority: string) =>
      `${workType} - ${priority}`,
    default_work_type: "New task",
    default_admin_name: "Admin",
    default_employee_name: "An employee",
  },
  ne: {
    task_assigned_title: (adminName: string) => `${adminName} ले कार्य तोक्नुभयो`,
    task_assigned_body: (workType: string, priority: string) =>
      `${workType} - ${priority}`,
    ring_only_title: (adminName: string) => `${adminName} ले तपाईंलाई बोलाउँदैछन्`,
    ring_only_body: "कृपया अहिले नै कार्यालयमा आउनुहोस्",
    task_status_updated_title: "कार्य स्थिति अपडेट भयो",
    task_status_updated_body: (employeeName: string, status: string) =>
      `${employeeName} ले कार्यलाई ${status} भनी चिन्ह लगाउनुभयो`,
    ring_again_title: "🔔 सम्झना: कार्य बाँकी छ",
    ring_again_body: (workType: string, priority: string) =>
      `${workType} - ${priority}`,
    default_work_type: "नयाँ कार्य",
    default_admin_name: "एडमिन",
    default_employee_name: "कर्मचारी",
  },
};

type Lang = "en" | "ne";

function resolveLang(preferredLanguage?: string | null): Lang {
  return preferredLanguage === "ne" ? "ne" : "en"; // default English अब
}

async function getAccessToken(): Promise<string> {
  const keyData = FCM_PRIVATE_KEY
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\s/g, "");

  const binaryKey = Uint8Array.from(atob(keyData), (c) => c.charCodeAt(0));

  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    binaryKey.buffer,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );

  const jwt = await create(
    { alg: "RS256", typ: "JWT" },
    {
      iss: FCM_CLIENT_EMAIL,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
      aud: "https://oauth2.googleapis.com/token",
      exp: getNumericDate(60 * 60),
      iat: getNumericDate(0),
    },
    cryptoKey,
  );

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });

  const data = await res.json();

  if (!data.access_token) {
    throw new Error(
      "Failed to get access token: " + JSON.stringify(data),
    );
  }

  return data.access_token;
}

// data-only push — OS le auto notification/sound show gardaina
async function sendRingAgainPush(
  accessToken: string,
  token: string,
  title: string,
  body: string,
) {
  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${FCM_PROJECT_ID}/messages:send`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${accessToken}`,
      },
      body: JSON.stringify({
        message: {
          token,
          data: {
            type: "ring_again",
            title,
            body,
          },
          android: {
            priority: "high",
          },
        },
      }),
    },
  );
  return res.json();
}

// channelId / soundName optional parameters thapiyo — default naya sound
async function sendPush(
  accessToken: string,
  token: string,
  title: string,
  body: string,
  tag?: string,
  channelId: string = "task_channel_v2",
  soundName?: string,           // ← default undefined, task assign ko lagi explicit pass garne
) {
  const androidNotification: Record<string, unknown> = {
    channel_id: channelId,
    tag: tag ?? `ring_${Date.now()}`,
  };

  // soundName diyeko bhaye matra field add garne, natra Android default sound use huncha
  if (soundName) {
    androidNotification.sound = soundName;
  }

  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${FCM_PROJECT_ID}/messages:send`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${accessToken}`,
      },
      body: JSON.stringify({
        message: {
          token,
          notification: { title, body },
          android: {
            priority: "high",
            notification: androidNotification,
          },
        },
      }),
    },
  );
  return res.json();
}

async function fetchRows(table: string, filter: string) {
  const res = await fetch(
    `${SUPABASE_URL}/rest/v1/${table}?${filter}`,
    {
      headers: {
        apikey: SERVICE_ROLE_KEY,
        Authorization: `Bearer ${SERVICE_ROLE_KEY}`,
      },
    },
  );

  return res.json();
}

serve(async (req) => {
  try {
    const payload = await req.json();

    console.log("FULL PAYLOAD:", JSON.stringify(payload));
    console.log("Event type:", payload.type);

    const record = payload.record;
    const eventType = payload.type;

    const accessToken = await getAccessToken();
    const results: unknown[] = [];

    // =========================
    // RING ONLY
    // =========================
    if (eventType === "ring_only") {
      const employeeId = payload.employee_id;

      console.log("RING_ONLY for employee_id:", employeeId);

      if (!employeeId) {
        return new Response(
          JSON.stringify({ error: "employee_id is required" }),
          { status: 400 },
        );
      }

      const employees = await fetchRows(
        "employees",
        `employee_id=eq.${employeeId}&select=fcm_token,preferred_language`,
      );

      const fcmToken = employees?.[0]?.fcm_token;
      const lang = resolveLang(employees?.[0]?.preferred_language);
      const t = translations[lang];

      const adminName = payload.admin_name || t.default_admin_name;

      if (!fcmToken) {
        return new Response(
          JSON.stringify({ error: "No FCM token found for employee" }),
          { status: 400 },
        );
      }

      // Task-assign wala channel/sound (naya) — yo unchanged
      // RING_ONLY block भित्र:
// RING_ONLY block भित्र:
const result = await sendPush(
  accessToken,
  fcmToken,
  payload.title ?? t.ring_only_title(adminName),
  payload.body ?? t.ring_only_body,
  `ring_only-${Date.now()}`,
  "task_channel_v2",
  "task_ring",          // ← explicit sound
);

      console.log("Ring only result:", JSON.stringify(result));
      results.push(result);

      return new Response(
        JSON.stringify({ success: true, results }),
        { status: 200 },
      );
    }

    // =========================
    // INSERT — task assign (naya sound)
    // =========================
    else if (eventType === "INSERT") {
      const employeeId = record.employee?.employee_id;

      const employees = await fetchRows(
        "employees",
        `employee_id=eq.${employeeId}&select=fcm_token,preferred_language`,
      );

      const fcmToken = employees?.[0]?.fcm_token;
      const lang = resolveLang(employees?.[0]?.preferred_language);
      const t = translations[lang];

      const adminName = record.assigned_by_name ?? t.default_admin_name;
      const workType = record.work_type ?? t.default_work_type;
      const priority = record.priority ?? "";

      if (fcmToken) {
// INSERT block भित्र:
const result = await sendPush(
  accessToken,
  fcmToken,
  t.task_assigned_title(adminName),
  t.task_assigned_body(workType, priority),
  `task-${record.id ?? Date.now()}`,
  "task_channel_v2",
  "task_ring",          // ← explicit sound
);

        console.log("FCM send result:", JSON.stringify(result));
        results.push(result);
      }
    }

    // =========================
    // UPDATE — employee status update (PURANO sound)
    // =========================
    else if (eventType === "UPDATE") {
      const admins = await fetchRows("admins", "select=fcm_token,preferred_language");

      for (const admin of admins) {
        if (!admin.fcm_token) continue;

        const lang = resolveLang(admin.preferred_language);
        const t = translations[lang];

        const employeeName = record.employee?.name ?? t.default_employee_name;

        // UPDATE block भित्र — status update, default sound चाहिने ठाउँ:
// UPDATE block भित्र — status update, default sound चाहिने ठाउँ:
const result = await sendPush(
  accessToken,
  admin.fcm_token,
  t.task_status_updated_title,
  t.task_status_updated_body(employeeName, record.status),
  undefined,
  "task_status_channel_default",   // ← naya channel, custom sound nabhako
  // soundName omit गरियो → default Android sound बज्छ
);

        results.push(result);
      }
    }

    // =========================
    // RING AGAIN (data-only, unchanged)
    // =========================
    else if (eventType === "RING_AGAIN") {
      const employeeId = record.employee?.employee_id;

      console.log("RING_AGAIN for employee_id:", employeeId);

      const employees = await fetchRows(
        "employees",
        `employee_id=eq.${employeeId}&select=fcm_token,preferred_language`,
      );

      const fcmToken = employees?.[0]?.fcm_token;
      const lang = resolveLang(employees?.[0]?.preferred_language);
      const t = translations[lang];

      const workType = record.work_type ?? t.default_work_type;
      const priority = record.priority ?? "";

      if (fcmToken) {
        const result = await sendRingAgainPush(
          accessToken,
          fcmToken,
          t.ring_again_title,
          t.ring_again_body(workType, priority),
        );

        console.log("Ring again (data-only) result:", JSON.stringify(result));
        results.push(result);
      }
    }

    return new Response(
      JSON.stringify({ success: true, results }),
      { status: 200 },
    );
  } catch (err) {
    return new Response(
      JSON.stringify({ error: String(err) }),
      { status: 500 },
    );
  }
});