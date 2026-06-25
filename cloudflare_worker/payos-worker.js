const PAYOS_API = 'https://api-merchant.payos.vn';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

class HttpError extends Error {
  constructor(status, message) {
    super(message);
    this.status = status;
  }
}

export default {
  async fetch(request, env) {
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders });
    }

    const url = new URL(request.url);

    try {
      if (request.method === 'POST' && url.pathname === '/create-payment') {
        return await createPayment(request, env);
      }

      if (request.method === 'POST' && url.pathname === '/cancel-payment') {
        return await cancelPayment(request, env);
      }

      if (request.method === 'POST' && url.pathname === '/payos-webhook') {
        return await handlePayosWebhook(request, env);
      }

      if (url.pathname === '/payment-return') {
        return htmlResponse('Payment completed. You can return to the app.');
      }

      if (url.pathname === '/payment-cancel') {
        return htmlResponse('Payment cancelled. You can return to the app.');
      }

      return jsonResponse({ ok: true, service: 'emart-payos-api' });
    } catch (error) {
      return jsonResponse(
        { error: error.message || 'Unexpected server error' },
        error.status || 500,
      );
    }
  },
};

async function createPayment(request, env) {
  requireEnv(env, [
    'PAYOS_CLIENT_ID',
    'PAYOS_API_KEY',
    'PAYOS_CHECKSUM_KEY',
    'FIREBASE_PROJECT_ID',
    'FIREBASE_SERVICE_ACCOUNT',
    'FIREBASE_WEB_API_KEY',
  ]);

  const idToken = getBearerToken(request);
  const firebaseUser = await verifyFirebaseIdToken(env, idToken);
  const body = await request.json();

  const amount = toPositiveInteger(body.amount, 'amount');
  const orderCode = generatePayosOrderCode();
  const description = `DH${String(orderCode).slice(-7)}`;
  const returnUrl = body.returnUrl || new URL('/payment-return', request.url).toString();
  const cancelUrl = body.cancelUrl || new URL('/payment-cancel', request.url).toString();

  const items = Array.isArray(body.items)
    ? body.items.map((item) => ({
        name: String(item.name || 'Product').slice(0, 80),
        quantity: toPositiveInteger(item.quantity || 1, 'item.quantity'),
        price: toPositiveInteger(item.price || 0, 'item.price'),
      }))
    : [];

  const paymentData = {
    orderCode,
    amount,
    description,
    cancelUrl,
    returnUrl,
    items,
    buyerName: String(body.buyerName || firebaseUser.displayName || ''),
    buyerEmail: String(body.buyerEmail || firebaseUser.email || ''),
    buyerPhone: String(body.buyerPhone || ''),
  };
  const orderDetails = {
    buyerStreetAddress: String(body.buyerStreetAddress || ''),
    buyerCity: String(body.buyerCity || ''),
    billingAddress: String(body.billingAddress || ''),
    delivery: {
      type: String(body.deliveryType || ''),
      price: Number.isFinite(Number(body.deliveryPrice)) ? Number(body.deliveryPrice) : 0,
    },
  };

  paymentData.signature = await hmacSha256Hex(
    `amount=${amount}&cancelUrl=${cancelUrl}&description=${description}&orderCode=${orderCode}&returnUrl=${returnUrl}`,
    env.PAYOS_CHECKSUM_KEY,
  );

  const orderId = String(orderCode);
  await writeFirestoreDocument(env, `users/${firebaseUser.localId}/orders/${orderId}`, {
    userId: firebaseUser.localId,
    orderCode,
    amount,
    status: 'PENDING',
    items,
    buyerName: paymentData.buyerName,
    buyerEmail: paymentData.buyerEmail,
    buyerPhone: paymentData.buyerPhone,
    buyerStreetAddress: orderDetails.buyerStreetAddress,
    buyerCity: orderDetails.buyerCity,
    billingAddress: orderDetails.billingAddress,
    delivery: orderDetails.delivery,
    createdAt: new Date().toISOString(),
  });
  await writeFirestoreDocument(env, `payosOrders/${orderId}`, {
    userId: firebaseUser.localId,
    orderCode,
    amount,
    items,
    buyerName: paymentData.buyerName,
    buyerEmail: paymentData.buyerEmail,
    buyerPhone: paymentData.buyerPhone,
    buyerStreetAddress: orderDetails.buyerStreetAddress,
    buyerCity: orderDetails.buyerCity,
    billingAddress: orderDetails.billingAddress,
    delivery: orderDetails.delivery,
    status: 'PENDING',
    createdAt: new Date().toISOString(),
  });

  const payosResponse = await fetch(`${PAYOS_API}/v2/payment-requests`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-client-id': env.PAYOS_CLIENT_ID,
      'x-api-key': env.PAYOS_API_KEY,
      ...(env.PAYOS_PARTNER_CODE ? { 'x-partner-code': env.PAYOS_PARTNER_CODE } : {}),
    },
    body: JSON.stringify(paymentData),
  });

  const payosJson = await payosResponse.json();

  if (!payosResponse.ok || payosJson.code !== '00') {
    await patchFirestoreDocument(env, `users/${firebaseUser.localId}/orders/${orderId}`, {
      status: 'PAYOS_FAILED',
      payosError: payosJson.desc || 'PayOS rejected payment request',
      updatedAt: new Date().toISOString(),
    });

    throw httpError(
      payosResponse.status || 400,
      payosJson.desc || 'Could not create PayOS payment link',
    );
  }

  await patchFirestoreDocument(env, `users/${firebaseUser.localId}/orders/${orderId}`, {
    paymentLinkId: payosJson.data.paymentLinkId,
    checkoutUrl: payosJson.data.checkoutUrl,
    qrCode: payosJson.data.qrCode,
    updatedAt: new Date().toISOString(),
  });

  return jsonResponse({
    orderId,
    orderCode,
    checkoutUrl: payosJson.data.checkoutUrl,
    qrCode: payosJson.data.qrCode,
    status: payosJson.data.status,
  });
}

async function cancelPayment(request, env) {
  requireEnv(env, [
    'FIREBASE_PROJECT_ID',
    'FIREBASE_SERVICE_ACCOUNT',
    'FIREBASE_WEB_API_KEY',
  ]);

  const idToken = getBearerToken(request);
  const firebaseUser = await verifyFirebaseIdToken(env, idToken);
  const body = await request.json();
  const orderCode = String(toPositiveInteger(body.orderCode, 'orderCode'));
  const orderIndex = await readFirestoreDocument(env, `payosOrders/${orderCode}`);
  const orderOwner = orderIndex?.fields?.userId?.stringValue;

  if (!orderOwner || orderOwner !== firebaseUser.localId) {
    throw httpError(404, 'Order was not found for this user');
  }

  const orderDocument = await readFirestoreDocument(
    env,
    `users/${firebaseUser.localId}/orders/${orderCode}`,
  );
  const currentStatus = orderDocument?.fields?.status?.stringValue || '';

  if (currentStatus === 'PAID') {
    return jsonResponse({ success: true, status: 'PAID' });
  }

  const update = {
    status: 'CANCELLED',
    payosStatus: 'User cancelled PayOS checkout',
    cancelledAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };

  await patchFirestoreDocument(env, `users/${firebaseUser.localId}/orders/${orderCode}`, update);
  await patchFirestoreDocument(env, `payosOrders/${orderCode}`, {
    status: 'CANCELLED',
    updatedAt: update.updatedAt,
  });

  return jsonResponse({ success: true, status: 'CANCELLED' });
}

async function handlePayosWebhook(request, env) {
  requireEnv(env, ['PAYOS_CHECKSUM_KEY', 'FIREBASE_PROJECT_ID', 'FIREBASE_SERVICE_ACCOUNT']);

  const webhook = await request.json();
  const isValid = await verifyPayosSignature(
    webhook.data,
    webhook.signature,
    env.PAYOS_CHECKSUM_KEY,
  );

  if (!isValid) {
    throw httpError(401, 'Invalid payOS signature');
  }

  const orderCode = String(webhook.data.orderCode);
  const orderOwner = await findOrderOwnerByOrderCode(env, orderCode);

  if (orderOwner) {
    await patchFirestoreDocument(env, `users/${orderOwner}/orders/${orderCode}`, {
      status: webhook.success && webhook.data.code === '00' ? 'PAID' : 'FAILED',
      payosStatus: webhook.data.desc || webhook.desc || '',
      paymentLinkId: webhook.data.paymentLinkId || '',
      transactionReference: webhook.data.reference || '',
      paidAt: webhook.success ? new Date().toISOString() : '',
      webhookData: webhook.data,
      updatedAt: new Date().toISOString(),
    });

    await patchFirestoreDocument(env, `payosOrders/${orderCode}`, {
      status: webhook.success && webhook.data.code === '00' ? 'PAID' : 'FAILED',
      updatedAt: new Date().toISOString(),
    });

    if (webhook.success && webhook.data.code === '00') {
      await patchFirestoreDocument(env, `users/${orderOwner}/cart/active`, {
        items: [],
        updatedAt: new Date().toISOString(),
      });
    }
  }

  return jsonResponse({ success: true });
}

async function verifyPayosSignature(data, signature, checksumKey) {
  if (!data || !signature) return false;
  const sorted = Object.keys(data).sort().reduce((result, key) => {
    result[key] = data[key];
    return result;
  }, {});

  const query = Object.keys(sorted)
    .filter((key) => sorted[key] !== undefined)
    .map((key) => {
      let value = sorted[key];
      if (Array.isArray(value)) {
        value = JSON.stringify(value.map(sortObjectByKey));
      }
      if ([null, undefined, 'undefined', 'null'].includes(value)) {
        value = '';
      }
      return `${key}=${value}`;
    })
    .join('&');

  return timingSafeEqual(await hmacSha256Hex(query, checksumKey), signature);
}

function sortObjectByKey(object) {
  return Object.keys(object).sort().reduce((result, key) => {
    result[key] = object[key];
    return result;
  }, {});
}

async function verifyFirebaseIdToken(env, idToken) {
  if (!idToken) throw httpError(401, 'Missing Firebase ID token');

  const response = await fetch(
    `https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=${env.FIREBASE_WEB_API_KEY}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ idToken }),
    },
  );

  const json = await response.json();
  const user = json.users && json.users[0];

  if (!response.ok || !user) {
    throw httpError(401, 'Invalid Firebase ID token');
  }

  return user;
}

async function writeFirestoreDocument(env, documentPath, data) {
  const url = firestoreDocumentUrl(env, documentPath);
  const token = await getGoogleAccessToken(env);

  const response = await fetch(url, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ fields: firestoreFields(data) }),
  });

  if (!response.ok) {
    throw httpError(response.status, `Firestore write failed: ${await response.text()}`);
  }
}

async function patchFirestoreDocument(env, documentPath, data) {
  const url = firestoreDocumentUrl(env, documentPath, Object.keys(data));
  const token = await getGoogleAccessToken(env);

  const response = await fetch(url, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ fields: firestoreFields(data) }),
  });

  if (!response.ok) {
    throw httpError(response.status, `Firestore patch failed: ${await response.text()}`);
  }
}

async function findOrderOwnerByOrderCode(env, orderCode) {
  const orderIndex = await readFirestoreDocument(env, `payosOrders/${orderCode}`);
  return orderIndex?.fields?.userId?.stringValue || null;
}

async function readFirestoreDocument(env, documentPath) {
  const token = await getGoogleAccessToken(env);
  const response = await fetch(firestoreDocumentUrl(env, documentPath), {
    headers: { Authorization: `Bearer ${token}` },
  });

  if (response.status === 404) return null;
  if (!response.ok) {
    throw httpError(response.status, `Firestore read failed: ${await response.text()}`);
  }

  return response.json();
}

function firestoreDocumentUrl(env, documentPath, updateMaskFieldPaths = []) {
  const url = new URL(
    `https://firestore.googleapis.com/v1/projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents/${documentPath}`,
  );

  updateMaskFieldPaths.forEach((fieldPath) => {
    url.searchParams.append('updateMask.fieldPaths', fieldPath);
  });

  return url.toString();
}

function firestoreFields(data) {
  return Object.fromEntries(
    Object.entries(data).map(([key, value]) => [key, firestoreValue(value)]),
  );
}

function firestoreValue(value) {
  if (value === null || value === undefined) return { nullValue: null };
  if (typeof value === 'boolean') return { booleanValue: value };
  if (typeof value === 'number' && Number.isInteger(value)) return { integerValue: String(value) };
  if (typeof value === 'number') return { doubleValue: value };
  if (typeof value === 'string') return { stringValue: value };
  if (Array.isArray(value)) return { arrayValue: { values: value.map(firestoreValue) } };
  return { mapValue: { fields: firestoreFields(value) } };
}

async function getGoogleAccessToken(env) {
  const serviceAccount =
    typeof env.FIREBASE_SERVICE_ACCOUNT === 'string'
      ? JSON.parse(env.FIREBASE_SERVICE_ACCOUNT)
      : env.FIREBASE_SERVICE_ACCOUNT;

  const now = Math.floor(Date.now() / 1000);
  const jwtHeader = { alg: 'RS256', typ: 'JWT' };
  const jwtClaim = {
    iss: serviceAccount.client_email,
    scope: 'https://www.googleapis.com/auth/datastore',
    aud: 'https://oauth2.googleapis.com/token',
    exp: now + 3600,
    iat: now,
  };

  const unsignedJwt = `${base64Url(JSON.stringify(jwtHeader))}.${base64Url(JSON.stringify(jwtClaim))}`;
  const privateKey = await importPrivateKey(serviceAccount.private_key);
  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    privateKey,
    new TextEncoder().encode(unsignedJwt),
  );

  const assertion = `${unsignedJwt}.${base64Url(signature)}`;
  const response = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion,
    }),
  });

  const json = await response.json();
  if (!response.ok) {
    throw httpError(response.status, `Google OAuth failed: ${json.error_description || json.error}`);
  }

  return json.access_token;
}

async function importPrivateKey(pem) {
  const pemContents = pem
    .replace('-----BEGIN PRIVATE KEY-----', '')
    .replace('-----END PRIVATE KEY-----', '')
    .replace(/\s/g, '');
  const binary = Uint8Array.from(atob(pemContents), (char) => char.charCodeAt(0));

  return crypto.subtle.importKey(
    'pkcs8',
    binary,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  );
}

async function hmacSha256Hex(message, secret) {
  const key = await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  const signature = await crypto.subtle.sign('HMAC', key, new TextEncoder().encode(message));
  return [...new Uint8Array(signature)].map((byte) => byte.toString(16).padStart(2, '0')).join('');
}

function base64Url(value) {
  const bytes =
    typeof value === 'string'
      ? new TextEncoder().encode(value)
      : new Uint8Array(value);
  let binary = '';
  bytes.forEach((byte) => {
    binary += String.fromCharCode(byte);
  });
  return btoa(binary).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

function getBearerToken(request) {
  const authorization = request.headers.get('Authorization') || '';
  return authorization.startsWith('Bearer ') ? authorization.slice(7) : '';
}

function generatePayosOrderCode() {
  const timePart = String(Date.now()).slice(-8);
  const randomPart = String(Math.floor(Math.random() * 90) + 10);
  return Number(`${timePart}${randomPart}`);
}

function toPositiveInteger(value, fieldName) {
  const number = Number(value);
  if (!Number.isInteger(number) || number <= 0) {
    throw httpError(400, `${fieldName} must be a positive integer`);
  }
  return number;
}

function timingSafeEqual(a, b) {
  if (a.length !== b.length) return false;
  let result = 0;
  for (let index = 0; index < a.length; index += 1) {
    result |= a.charCodeAt(index) ^ b.charCodeAt(index);
  }
  return result === 0;
}

function requireEnv(env, keys) {
  const missing = keys.filter((key) => !env[key]);
  if (missing.length) {
    throw httpError(500, `Missing Worker secret(s): ${missing.join(', ')}`);
  }
}

function httpError(status, message) {
  return new HttpError(status, message);
}

function jsonResponse(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json',
    },
  });
}

function htmlResponse(message) {
  return new Response(`<html><body><h2>${message}</h2></body></html>`, {
    headers: { 'Content-Type': 'text/html; charset=utf-8' },
  });
}
