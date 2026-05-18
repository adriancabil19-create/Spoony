import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import nodemailer from 'npm:nodemailer'

const GMAIL_USER = Deno.env.get('GMAIL_USER')!
const GMAIL_APP_PASSWORD = Deno.env.get('GMAIL_APP_PASSWORD')!

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
      email,
      reference,
      guestCount,
      startDate,
      endDate,
      accommodation,
      transport,
      totalAmount,
      tourType,
    } = await req.json()

    const formattedTotal = '₱' + Number(totalAmount).toLocaleString('en-PH', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    })

    const html = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Booking Confirmation</title>
</head>
<body style="margin:0;padding:0;background:#F8FAFC;font-family:'Segoe UI',Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#F8FAFC;padding:40px 0;">
    <tr>
      <td align="center">
        <table width="600" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.08);">

          <!-- Header -->
          <tr>
            <td style="background:linear-gradient(135deg,#0EA5E9,#14B8A6);padding:40px 40px 32px;text-align:center;">
              <p style="margin:0 0 8px;font-size:28px;font-weight:800;color:#ffffff;letter-spacing:-0.5px;">🥄 Spoony</p>
              <p style="margin:0;font-size:14px;color:rgba(255,255,255,0.85);letter-spacing:1px;text-transform:uppercase;">Booking Confirmed</p>
            </td>
          </tr>

          <!-- Body -->
          <tr>
            <td style="padding:40px;">

              <p style="margin:0 0 8px;font-size:22px;font-weight:700;color:#0F172A;">Your adventure is booked! 🎉</p>
              <p style="margin:0 0 28px;font-size:14px;color:#64748B;line-height:1.6;">
                Thank you for choosing Spoony. Your booking is confirmed and pending final confirmation from our team. Here are your details:
              </p>

              <!-- Reference badge -->
              <table width="100%" cellpadding="0" cellspacing="0" style="margin-bottom:28px;">
                <tr>
                  <td style="background:#F0F9FF;border:1.5px solid #BAE6FD;border-radius:12px;padding:20px;text-align:center;">
                    <p style="margin:0 0 4px;font-size:12px;color:#0EA5E9;font-weight:600;letter-spacing:1px;text-transform:uppercase;">Booking Reference</p>
                    <p style="margin:0;font-size:26px;font-weight:800;color:#0F172A;letter-spacing:2px;">${reference}</p>
                  </td>
                </tr>
              </table>

              <!-- Details table -->
              <table width="100%" cellpadding="0" cellspacing="0" style="margin-bottom:28px;border:1.5px solid #E2E8F0;border-radius:12px;overflow:hidden;">
                <tr style="background:#F8FAFC;">
                  <td style="padding:14px 20px;font-size:12px;font-weight:700;color:#64748B;text-transform:uppercase;letter-spacing:0.5px;border-bottom:1px solid #E2E8F0;">Detail</td>
                  <td style="padding:14px 20px;font-size:12px;font-weight:700;color:#64748B;text-transform:uppercase;letter-spacing:0.5px;border-bottom:1px solid #E2E8F0;">Info</td>
                </tr>
                <tr>
                  <td style="padding:14px 20px;font-size:13px;color:#64748B;border-bottom:1px solid #F1F5F9;">Tour</td>
                  <td style="padding:14px 20px;font-size:13px;font-weight:600;color:#0F172A;border-bottom:1px solid #F1F5F9;">${tourType}</td>
                </tr>
                <tr style="background:#FAFBFC;">
                  <td style="padding:14px 20px;font-size:13px;color:#64748B;border-bottom:1px solid #F1F5F9;">Check-in</td>
                  <td style="padding:14px 20px;font-size:13px;font-weight:600;color:#0F172A;border-bottom:1px solid #F1F5F9;">${startDate}</td>
                </tr>
                <tr>
                  <td style="padding:14px 20px;font-size:13px;color:#64748B;border-bottom:1px solid #F1F5F9;">Check-out</td>
                  <td style="padding:14px 20px;font-size:13px;font-weight:600;color:#0F172A;border-bottom:1px solid #F1F5F9;">${endDate}</td>
                </tr>
                <tr style="background:#FAFBFC;">
                  <td style="padding:14px 20px;font-size:13px;color:#64748B;border-bottom:1px solid #F1F5F9;">Guests</td>
                  <td style="padding:14px 20px;font-size:13px;font-weight:600;color:#0F172A;border-bottom:1px solid #F1F5F9;">${guestCount} guest${guestCount !== 1 ? 's' : ''}</td>
                </tr>
                <tr>
                  <td style="padding:14px 20px;font-size:13px;color:#64748B;border-bottom:1px solid #F1F5F9;">Accommodation</td>
                  <td style="padding:14px 20px;font-size:13px;font-weight:600;color:#0F172A;border-bottom:1px solid #F1F5F9;">${accommodation}</td>
                </tr>
                <tr style="background:#FAFBFC;">
                  <td style="padding:14px 20px;font-size:13px;color:#64748B;">Transport</td>
                  <td style="padding:14px 20px;font-size:13px;font-weight:600;color:#0F172A;">${transport}</td>
                </tr>
              </table>

              <!-- Total -->
              <table width="100%" cellpadding="0" cellspacing="0" style="margin-bottom:32px;background:linear-gradient(135deg,#0EA5E9,#14B8A6);border-radius:12px;">
                <tr>
                  <td style="padding:20px 24px;">
                    <p style="margin:0;font-size:13px;color:rgba(255,255,255,0.85);">Total Amount</p>
                    <p style="margin:4px 0 0;font-size:28px;font-weight:800;color:#ffffff;">${formattedTotal}</p>
                  </td>
                </tr>
              </table>

              <p style="margin:0 0 6px;font-size:13px;color:#64748B;line-height:1.6;">
                Our team will reach out to you shortly to confirm your itinerary. Keep this email for your records — your reference number is your booking ID.
              </p>
              <p style="margin:0;font-size:13px;color:#64748B;line-height:1.6;">
                Questions? Reply to this email and we'll be happy to help.
              </p>

            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background:#F8FAFC;padding:24px 40px;text-align:center;border-top:1px solid #E2E8F0;">
              <p style="margin:0;font-size:12px;color:#94A3B8;">© 2025 Spoony Tours · Cebu, Philippines</p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>`

    const transporter = nodemailer.createTransport({
      host: 'smtp.gmail.com',
      port: 587,
      secure: false,
      auth: {
        user: GMAIL_USER,
        pass: GMAIL_APP_PASSWORD,
      },
    })

    await transporter.sendMail({
      from: `Spoony Tours <${GMAIL_USER}>`,
      to: email,
      subject: `Booking Confirmed – ${reference} 🥄`,
      html,
    })

    return new Response(JSON.stringify({ success: true }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    })
  }
})
