import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

const SENDGRID_API_KEY = Deno.env.get('SENDGRID_API_KEY') ?? ''

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const {
      driverEmail,
      driverName,
      reference,
      guestEmail,
      startDate,
      endDate,
      itinerary,
      tourType,
      guestCount,
    } = await req.json()

    // Build itinerary rows
    const itineraryLines: string[] = (itinerary ?? '').split('\n').filter((l: string) => l.trim())
    const itineraryRows = itineraryLines.length > 0
      ? itineraryLines.map((line: string) => {
          const m = line.trim().match(/^Day (\d+): (.+)$/)
          const dayNum = m ? m[1] : '—'
          const content = m ? m[2] : line.trim()
          return `
            <tr>
              <td style="padding:12px 16px;border-bottom:1px solid #F1F5F9;white-space:nowrap;">
                <span style="background:#0EA5E9;color:#fff;font-size:10px;font-weight:700;padding:3px 8px;border-radius:10px;">Day ${dayNum}</span>
              </td>
              <td style="padding:12px 16px;border-bottom:1px solid #F1F5F9;font-size:13px;color:#0F172A;font-weight:500;">${content}</td>
            </tr>`
        }).join('')
      : `<tr><td colspan="2" style="padding:16px;color:#94A3B8;font-size:13px;">No itinerary provided yet.</td></tr>`

    const htmlContent = `
<!DOCTYPE html>
<html>
<head><meta charset="utf-8" /><meta name="viewport" content="width=device-width, initial-scale=1.0" /></head>
<body style="margin:0;padding:0;background:#F8FAFC;font-family:'Segoe UI',Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#F8FAFC;padding:40px 0;">
    <tr>
      <td align="center">
        <table width="600" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.08);">
          <tr>
            <td style="background:linear-gradient(135deg,#0EA5E9,#14B8A6);padding:36px 40px;text-align:center;">
              <p style="margin:0 0 6px;font-size:26px;font-weight:800;color:#ffffff;">🥄 Spoony Travel</p>
              <p style="margin:0;font-size:13px;color:rgba(255,255,255,0.85);letter-spacing:1px;text-transform:uppercase;">Trip Assignment Notice</p>
            </td>
          </tr>
          <tr>
            <td style="padding:36px 40px;">
              <p style="margin:0 0 6px;font-size:20px;font-weight:700;color:#0F172A;">Hi ${driverName}, you have a new trip! 🚗</p>
              <p style="margin:0 0 24px;font-size:14px;color:#64748B;line-height:1.6;">
                You've been assigned to the following booking. Please review the details and itinerary below.
              </p>

              <!-- Reference -->
              <table width="100%" cellpadding="0" cellspacing="0" style="margin-bottom:24px;">
                <tr>
                  <td style="background:#F0F9FF;border:1.5px solid #BAE6FD;border-radius:12px;padding:18px;text-align:center;">
                    <p style="margin:0 0 4px;font-size:11px;color:#0EA5E9;font-weight:700;letter-spacing:1px;text-transform:uppercase;">Booking Reference</p>
                    <p style="margin:0;font-size:24px;font-weight:800;color:#0F172A;letter-spacing:2px;">${reference}</p>
                  </td>
                </tr>
              </table>

              <!-- Booking details -->
              <table width="100%" cellpadding="0" cellspacing="0" style="margin-bottom:24px;border:1.5px solid #E2E8F0;border-radius:12px;overflow:hidden;">
                <tr style="background:#F8FAFC;">
                  <td style="padding:12px 16px;font-size:11px;font-weight:700;color:#64748B;text-transform:uppercase;border-bottom:1px solid #E2E8F0;">Detail</td>
                  <td style="padding:12px 16px;font-size:11px;font-weight:700;color:#64748B;text-transform:uppercase;border-bottom:1px solid #E2E8F0;">Info</td>
                </tr>
                <tr><td style="padding:12px 16px;font-size:13px;color:#64748B;border-bottom:1px solid #F1F5F9;">Tour Type</td><td style="padding:12px 16px;font-size:13px;font-weight:600;color:#0F172A;border-bottom:1px solid #F1F5F9;">${tourType}</td></tr>
                <tr style="background:#FAFBFC;"><td style="padding:12px 16px;font-size:13px;color:#64748B;border-bottom:1px solid #F1F5F9;">Guest Email</td><td style="padding:12px 16px;font-size:13px;font-weight:600;color:#0F172A;border-bottom:1px solid #F1F5F9;">${guestEmail}</td></tr>
                <tr><td style="padding:12px 16px;font-size:13px;color:#64748B;border-bottom:1px solid #F1F5F9;">Start Date</td><td style="padding:12px 16px;font-size:13px;font-weight:600;color:#0F172A;border-bottom:1px solid #F1F5F9;">${startDate}</td></tr>
                <tr style="background:#FAFBFC;"><td style="padding:12px 16px;font-size:13px;color:#64748B;border-bottom:1px solid #F1F5F9;">End Date</td><td style="padding:12px 16px;font-size:13px;font-weight:600;color:#0F172A;border-bottom:1px solid #F1F5F9;">${endDate}</td></tr>
                <tr><td style="padding:12px 16px;font-size:13px;color:#64748B;">Guests</td><td style="padding:12px 16px;font-size:13px;font-weight:600;color:#0F172A;">${guestCount} guest${guestCount !== 1 ? 's' : ''}</td></tr>
              </table>

              <!-- Itinerary -->
              <p style="margin:0 0 10px;font-size:14px;font-weight:700;color:#0F172A;">Full Itinerary</p>
              <table width="100%" cellpadding="0" cellspacing="0" style="border:1.5px solid #E2E8F0;border-radius:12px;overflow:hidden;margin-bottom:28px;">
                <tr style="background:#F8FAFC;">
                  <td style="padding:10px 16px;font-size:11px;font-weight:700;color:#64748B;text-transform:uppercase;border-bottom:1px solid #E2E8F0;">Day</td>
                  <td style="padding:10px 16px;font-size:11px;font-weight:700;color:#64748B;text-transform:uppercase;border-bottom:1px solid #E2E8F0;">Plan</td>
                </tr>
                ${itineraryRows}
              </table>

              <p style="margin:0;font-size:13px;color:#64748B;line-height:1.6;">
                Log in to your <strong>Driver Portal</strong> to view full guest details and check in guests on arrival. If you have questions, contact the Spoony admin team.
              </p>
            </td>
          </tr>
          <tr>
            <td style="background:#F8FAFC;padding:20px 40px;text-align:center;border-top:1px solid #E2E8F0;">
              <p style="margin:0;font-size:12px;color:#94A3B8;">© 2026 Spoony Travel and Tours · Cebu, Philippines</p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>`

    const sgRes = await fetch('https://api.sendgrid.com/v3/mail/send', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${SENDGRID_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        personalizations: [{ to: [{ email: driverEmail }] }],
        from: { email: 'spoonytraveltours@gmail.com', name: 'Spoony Travel and Tours' },
        subject: `New Trip Assigned – ${reference} 🚗`,
        content: [{ type: 'text/html', value: htmlContent }],
      }),
    })

    console.log('SendGrid status:', sgRes.status)
    return new Response(JSON.stringify({ success: true, status: sgRes.status }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  } catch (err) {
    console.log('Email error:', String(err))
    return new Response(JSON.stringify({ error: String(err) }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
