const nodemailer = require('nodemailer');

function getTransporter() {
  if (!process.env.SMTP_USER || !process.env.SMTP_PASS) return null;
  return nodemailer.createTransport({
    service: 'gmail',
    auth: { user: process.env.SMTP_USER, pass: process.env.SMTP_PASS },
  });
}

async function sendBookingConfirmation({ to, name, referenceCode, startDate, endDate, guestCount, totalAmount }) {
  const transporter = getTransporter();
  if (!transporter) return;
  try {
    await transporter.sendMail({
      from: `"Spoony Travel" <${process.env.SMTP_USER}>`,
      to,
      subject: `Booking Confirmed — ${referenceCode}`,
      html: `
        <div style="font-family:sans-serif;max-width:600px;margin:0 auto">
          <div style="background:#006994;padding:24px;text-align:center;border-radius:8px 8px 0 0">
            <h1 style="color:white;margin:0;font-size:24px">Spoony Travel</h1>
            <p style="color:rgba(255,255,255,0.8);margin:4px 0 0">Cebu, Philippines</p>
          </div>
          <div style="padding:32px;border:1px solid #E8EDEF;border-top:none;border-radius:0 0 8px 8px">
            <h2 style="color:#006994;margin-top:0">Booking Confirmed!</h2>
            <p style="color:#5D6D7A">Hi ${name || 'Traveler'},</p>
            <p style="color:#5D6D7A">Your Cebu adventure is confirmed. Here are your booking details:</p>
            <div style="background:#E0F7FA;border-radius:12px;padding:20px;margin:20px 0">
              <p style="margin:0 0 8px;color:#8B99A6;font-size:13px;font-weight:600">BOOKING REFERENCE</p>
              <p style="margin:0 0 16px;color:#00BCD4;font-size:28px;font-weight:800;letter-spacing:2px">${referenceCode}</p>
              <table style="width:100%;border-collapse:collapse">
                <tr><td style="color:#8B99A6;font-size:13px;padding:4px 0">Dates</td><td style="color:#00314F;font-weight:600;font-size:13px">${startDate} → ${endDate}</td></tr>
                <tr><td style="color:#8B99A6;font-size:13px;padding:4px 0">Guests</td><td style="color:#00314F;font-weight:600;font-size:13px">${guestCount} Adult(s)</td></tr>
                <tr><td style="color:#8B99A6;font-size:13px;padding:4px 0">Total</td><td style="color:#50C878;font-weight:800;font-size:16px">₱${totalAmount}</td></tr>
              </table>
            </div>
            <p style="color:#5D6D7A">Present your booking reference at the tour departure point. Our team will confirm your booking within 24 hours.</p>
            <div style="margin-top:32px;padding-top:24px;border-top:1px solid #E8EDEF">
              <p style="color:#8B99A6;font-size:12px;margin:0">© 2026 Spoony Travel and Tours · Cebu, Philippines</p>
            </div>
          </div>
        </div>
      `,
    });
  } catch (err) {
    console.error('Email send failed:', err.message);
  }
}

module.exports = { sendBookingConfirmation };
