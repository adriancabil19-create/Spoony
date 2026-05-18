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
    const { guestEmail, reference, tourType, startDate, endDate, guestCount } = await req.json()

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
            <td style="background:linear-gradient(135deg,#0EA5E9,#14B8A6);padding:40px;text-align:center;">
              <p style="margin:0 0 8px;font-size:28px;font-weight:800;color:#ffffff;">🥄 Spoony Travel</p>
              <p style="margin:0;font-size:14px;color:rgba(255,255,255,0.85);letter-spacing:1px;text-transform:uppercase;">Trip Completed</p>
            </td>
          </tr>
          <tr>
            <td style="padding:40px;">
              <p style="margin:0 0 8px;font-size:22px;font-weight:700;color:#0F172A;">Your trip is complete! 🎉</p>
              <p style="margin:0 0 28px;font-size:14px;color:#64748B;line-height:1.6;">
                Thank you for choosing Spoony Travel. We hope you had an amazing experience exploring Cebu. We'd love to hear your feedback!
              </p>

              <table width="100%" cellpadding="0" cellspacing="0" style="margin-bottom:28px;">
                <tr>
                  <td style="background:#F0F9FF;border:1.5px solid #BAE6FD;border-radius:12px;padding:20px;text-align:center;">
                    <p style="margin:0 0 4px;font-size:12px;color:#0EA5E9;font-weight:600;letter-spacing:1px;text-transform:uppercase;">Booking Reference</p>
                    <p style="margin:0;font-size:26px;font-weight:800;color:#0F172A;letter-spacing:2px;">${reference}</p>
                  </td>
                </tr>
              </table>

              <table width="100%" cellpadding="0" cellspacing="0" style="margin-bottom:28px;border:1.5px solid #E2E8F0;border-radius:12px;overflow:hidden;">
                <tr style="background:#F8FAFC;">
                  <td style="padding:14px 20px;font-size:12px;font-weight:700;color:#64748B;text-transform:uppercase;border-bottom:1px solid #E2E8F0;">Detail</td>
                  <td style="padding:14px 20px;font-size:12px;font-weight:700;color:#64748B;text-transform:uppercase;border-bottom:1px solid #E2E8F0;">Info</td>
                </tr>
                <tr><td style="padding:14px 20px;font-size:13px;color:#64748B;border-bottom:1px solid #F1F5F9;">Tour</td><td style="padding:14px 20px;font-size:13px;font-weight:600;color:#0F172A;border-bottom:1px solid #F1F5F9;">${tourType}</td></tr>
                <tr style="background:#FAFBFC;"><td style="padding:14px 20px;font-size:13px;color:#64748B;border-bottom:1px solid #F1F5F9;">Start Date</td><td style="padding:14px 20px;font-size:13px;font-weight:600;color:#0F172A;border-bottom:1px solid #F1F5F9;">${startDate}</td></tr>
                <tr><td style="padding:14px 20px;font-size:13px;color:#64748B;border-bottom:1px solid #F1F5F9;">End Date</td><td style="padding:14px 20px;font-size:13px;font-weight:600;color:#0F172A;border-bottom:1px solid #F1F5F9;">${endDate}</td></tr>
                <tr style="background:#FAFBFC;"><td style="padding:14px 20px;font-size:13px;color:#64748B;">Guests</td><td style="padding:14px 20px;font-size:13px;font-weight:600;color:#0F172A;">${guestCount} guest${guestCount !== 1 ? 's' : ''}</td></tr>
              </table>

              <table width="100%" cellpadding="0" cellspacing="0" style="margin-bottom:32px;background:linear-gradient(135deg,#0EA5E9,#14B8A6);border-radius:12px;">
                <tr>
                  <td style="padding:24px 28px;text-align:center;">
                    <p style="margin:0 0 4px;font-size:13px;color:rgba(255,255,255,0.85);">We hope to see you again soon!</p>
                    <p style="margin:0;font-size:18px;font-weight:800;color:#ffffff;">Book your next Cebu adventure with Spoony 🌊</p>
                  </td>
                </tr>
              </table>

              <p style="margin:0;font-size:13px;color:#64748B;line-height:1.6;">
                Questions or feedback? Reply to this email — we'd love to hear from you.
              </p>
            </td>
          </tr>
          <tr>
            <td style="background:#F8FAFC;padding:24px 40px;text-align:center;border-top:1px solid #E2E8F0;">
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
        personalizations: [{
          to: [{ email: guestEmail }],
          cc: [{ email: 'spoonytraveltours@gmail.com' }],
        }],
        from: { email: 'spoonytraveltours@gmail.com', name: 'Spoony Travel and Tours' },
        subject: `Your Spoony trip is complete – ${reference} 🎉`,
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
