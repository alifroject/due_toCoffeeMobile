import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import axios from 'axios';
import { onDocumentUpdated } from 'firebase-functions/v2/firestore';
import * as dotenv from 'dotenv';
dotenv.config();
admin.initializeApp();

const MIDTRANS_SERVER_KEY = process.env.MIDTRANS_SERVER_KEY;
const MIDTRANS_API_URL = process.env.MIDTRANS_API_URL || 'https://api.sandbox.midtrans.com/v2';
const MIDTRANS_SNAP_URL = process.env.MIDTRANS_SNAP_URL || 'https://app.sandbox.midtrans.com/snap/v1/transactions';

const XENDIT_API_KEY = process.env.XENDIT_API_KEY || '';
const XENDIT_API_URL = process.env.XENDIT_API_URL || 'https://api.xendit.co/v2/invoices';

interface XenditInvoiceResponse {
  id: string;
  invoice_url: string;
  status: string;
  external_id: string;
  // bisa ditambah properti lain kalau perlu
}
interface XenditInvoiceStatusResponse {
  id: string;
  external_id: string;
  status: string; // e.g. "PAID", "EXPIRED", "PENDING"
  amount: number;
  payer_email: string;
  invoice_url: string;
  created: string;
  updated: string;
  // bisa tambah properti lain sesuai response Xendit
}

interface PaymentItem {
  productId: string;
  quantity: number;
  name: string;
  price: number;
  type?: string;
}

interface PaymentRequestData {
  order_id: string;
  amount: number;
  userName: string;
  userId: string;
  userPhone: string;
  userEmail: string;
  items: PaymentItem[];
}

interface SnapResponse {
  token: string;
  redirect_url: string;
}

interface MidtransTransactionStatus {
  order_id: string;
  transaction_id: string;
  transaction_status: 'pending' | 'settlement' | 'capture' | 'deny' | 'cancel' | 'expire' | 'failure';
  payment_type: string;
  gross_amount: string;
  transaction_time: string;
  settlement_time?: string;
  va_numbers?: Array<{
    bank: string;
    va_number: string;
  }>;
  // Add other fields you expect from Midtrans
}

// ========================
// 1. Create Payment URL
// ========================
export const createPaymentURL = functions.https.onCall(async (request) => {
  try {
    const data = request.data as PaymentRequestData;

    // Validate input
    if (!data?.order_id || !data?.amount || !data?.items?.length ||
      !data?.userName || !data?.userPhone || !data?.userEmail || !data?.userId) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Missing required fields'
      );
    }

    // Save to Firestore FIRST (including email, items, and location)
    const location = request.data.location; // Get location data from request

    await admin.firestore().collection('transactions').doc(data.order_id).set({
      order_id: data.order_id,
      user_id: data.userId,  // Ensure userId is defined
      user_email: data.userEmail,
      user_name: data.userName,
      user_phone: data.userPhone,
      item_details: data.items.map(item => ({
        id: item.productId,
        name: item.name,
        price: item.price,
        quantity: item.quantity,
        type: item.type || null

      })),
      gross_amount: data.amount,
      status: 'pending',
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      location: location, // Add location to Firestore document
    });

    // Prepare Midtrans payload
    const payload = {
      transaction_details: {
        order_id: data.order_id,
        gross_amount: data.amount,
      },
      customer_details: {
        first_name: data.userName,
        phone: data.userPhone,
        email: data.userEmail,
      },
      item_details: data.items.map(item => ({
        id: item.productId,
        name: item.name,
        price: item.price,
        quantity: item.quantity
      })),
      credit_card: { secure: true }
    };

    // Call Midtrans API
    const response = await axios.post<SnapResponse>(MIDTRANS_SNAP_URL, payload, {
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': `Basic ${Buffer.from(MIDTRANS_SERVER_KEY + ':').toString('base64')}`,
      },
    });

    return {
      paymentUrl: response.data.redirect_url,
      orderId: data.order_id
    };

  } catch (error: any) {
    console.error('Error:', error);
    throw new functions.https.HttpsError(
      'internal',
      error.message || 'Payment URL creation failed'
    );
  }
});



// ========================
// 2. Check Payment Status
// ========================
export const getPaymentStatus = functions.https.onCall(async (request) => {
  try {
    const orderId = request.data?.order_id;
    if (!orderId) {
      throw new functions.https.HttpsError('invalid-argument', 'Missing order_id');
    }

    // 1. Fetch transaction status from Midtrans
    const response = await axios.get(`${MIDTRANS_API_URL}/${orderId}/status`, {
      headers: {
        'Authorization': `Basic ${Buffer.from(MIDTRANS_SERVER_KEY + ':').toString('base64')}`,
        'Accept': 'application/json',
      },
    });

    const midtransData = response.data as MidtransTransactionStatus;

    // 2. Update Firestore document for this order
    const docRef = admin.firestore().collection('transactions').doc(orderId);

    await docRef.set({
      transaction_id: midtransData.transaction_id,
      transaction_status: midtransData.transaction_status,
      status: midtransData.transaction_status, // ✅ also update the main status field
      payment_type: midtransData.payment_type,
      settlement_time: midtransData.settlement_time || null,
      gross_amount: midtransData.gross_amount,
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    return {
      status: midtransData.transaction_status,
      data: midtransData,
    };

  } catch (error: any) {
    console.error('Error fetching payment status:', error);
    throw new functions.https.HttpsError(
      'internal',
      error.message || 'Failed to check payment status'
    );
  }
});

export const midtransWebhook = functions.https.onRequest(async (req, res) => {
  try {
    // Get the data from Midtrans webhook
    const midtransData = req.body;

    // Extract order ID and transaction status from the data
    const { order_id, transaction_status, transaction_id } = midtransData;

    // Check if the order_id and transaction_status are valid
    if (!order_id || !transaction_status) {
      res.status(400).send('Invalid request');
      return;
    }

    // Get reference to the Firestore document for this order
    const docRef = admin.firestore().collection('transactions').doc(order_id);

    // Update the Firestore document with the new status
    await docRef.set({
      transaction_id: transaction_id,
      transaction_status: transaction_status,
      status: transaction_status,  // Updating the status field
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    // Respond with a 200 status to acknowledge receipt of the webhook
    res.status(200).send('OK');
  } catch (error) {
    console.error('Webhook error:', error);
    res.status(500).send('Error');
  }
});


export const sendTransactionNotification = onDocumentUpdated(
  {
    document: 'transactions/{orderId}',
  },
  async (event) => {
    console.log('📦 Triggered sendTransactionNotification');

    const before = event.data?.before?.data();
    const after = event.data?.after?.data();

    if (!before || !after) {
      console.log('❌ No before/after data.');
      return;
    }

    console.log('🔁 Before:', before);
    console.log('🔁 After:', after);

    const queueStatusChanged =
      before.queue_status?.accepted !== after.queue_status?.accepted ||
      before.queue_status?.in_progress !== after.queue_status?.in_progress ||
      before.queue_status?.almost_ready !== after.queue_status?.almost_ready ||
      before.queue_status?.ready_for_pickup !== after.queue_status?.ready_for_pickup;

    const customNoteChanged = before.custom_note !== after.custom_note;

    if (!queueStatusChanged && !customNoteChanged) {
      console.log('🛑 No relevant changes detected, skipping notification.');
      return;
    }

    const userId = after.userId;
    const orderId = after.order_id;
    const customNote = after.custom_note || 'Your order has been updated.';

    if (!userId) {
      console.warn(`⚠️ Missing user_id for transaction ${orderId}`);
      return;
    }

    try {
      const userSnap = await admin.firestore().collection('users').doc(userId).get();

      if (!userSnap.exists) {
        console.warn(`⚠️ User document ${userId} not found in Firestore`);
        return;
      }

      const userData = userSnap.data();
      console.log("📥 Retrieved user data:", userData);

      if (!userData?.fcmToken) {
        console.warn(`⚠️ No FCM token for user ${userId}`);
        return;
      }

      const payload: admin.messaging.Message = {
        token: userData.fcmToken,
        notification: {
          title: `Order ${orderId} Update`,
          body: customNote || 'Tap to view order status.',
        },
        data: {
          order_id: orderId || '',
          status: after.status || '',
          userId: userId || '',
          action: 'open_order_status', // 🔥 this triggers the tab navigation
          click_action: 'FLUTTER_NOTIFICATION_CLICK', // ✅ required for foreground & background tap on Android
        },
      };


      const response = await admin.messaging().send(payload);
      console.log(`✅ Notification sent to user ${userId}:`, response);
    } catch (err) {
      console.error(`❌ Error sending notification to ${userId}:`, err);
    }

  }
);





//Xendit

export const createXenditInvoice = functions.https.onCall(async (request) => {
  try {
    const data = request.data;

    if (!data.order_id || !data.amount || !data.userEmail || !data.location) {
      throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
    }

    // Save initial transaction including location
    await admin.firestore().collection('transactions').doc(data.order_id).set({
      order_id: data.order_id,
      user_email: data.userEmail,
      amount: data.amount,
      status: 'pending',
      location: data.location, // ✅ Save location here
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Call Xendit API
    const payload = {
      external_id: data.order_id,
      amount: data.amount,
      payer_email: data.userEmail,
      description: 'Payment for order ' + data.order_id,
    };

    const response = await axios.post<XenditInvoiceResponse>(XENDIT_API_URL, payload, {
      auth: {
        username: XENDIT_API_KEY,
        password: '',
      }
    });

    const invoice = response.data;

    // Merge extra data (location, user info, etc.) into document
    await admin.firestore().collection('transactions').doc(data.order_id).set({
      invoice_url: invoice.invoice_url,
      xendit_invoice_id: invoice.id,
      xendit_status: invoice.status,
      ...data, // include other fields from client, e.g., userName, items, location again just in case
    }, { merge: true });

    return {
      invoiceUrl: invoice.invoice_url,
      invoiceId: invoice.id,
      orderId: data.order_id,
    };
  } catch (error: any) {
    console.error('Error creating Xendit invoice:', error);
    throw new functions.https.HttpsError('internal', error.message || 'Failed to create invoice');
  }
});



export const getXenditInvoiceStatus = functions.https.onCall(async (request) => {
  try {
    const { invoiceId } = request.data;
    if (!invoiceId) {
      throw new functions.https.HttpsError('invalid-argument', 'Missing invoiceId');
    }

    const url = `${XENDIT_API_URL}/${invoiceId}`;
    const response = await axios.get<XenditInvoiceStatusResponse>(url, {
      auth: {
        username: XENDIT_API_KEY,
        password: '',
      }
    });

    const invoiceStatus = response.data;

    // Optional: update status di Firestore juga
    await admin.firestore().collection('transactions').doc(invoiceStatus.external_id).set({
      status: invoiceStatus.status.toLowerCase(),
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    return {
      status: invoiceStatus.status,
      data: invoiceStatus,
    };
  } catch (error: any) {
    console.error('Error getting Xendit invoice status:', error);
    throw new functions.https.HttpsError('internal', error.message || 'Failed to get invoice status');
  }
});


export const xenditWebhook = functions.https.onRequest(async (req, res) => {
  try {
    // Biasanya Xendit kirim webhook POST dengan body JSON invoice update
    const data = req.body;

    if (!data.id || !data.status || !data.external_id) {
      res.status(400).send('Invalid webhook payload');
      return;
    }

    // Update status transaksi di Firestore berdasarkan external_id
    await admin.firestore().collection('transactions').doc(data.external_id).set({
      status: data.status.toLowerCase(),  // contoh: "PAID" -> "paid"
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
      xendit_invoice_id: data.id,
      raw_webhook: data, // optional, simpan payload webhook lengkap
    }, { merge: true });

    res.status(200).send('OK');
  } catch (error) {
    console.error('Xendit webhook error:', error);
    res.status(500).send('Internal Server Error');
  }
});
