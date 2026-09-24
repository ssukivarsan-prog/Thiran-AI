import assert from 'assert';
import http from 'http';
import app from '../src/server';

const PORT = 4099;
let server: http.Server;

function makeRequest(path: string, method = 'GET', body?: any): Promise<{ status: number; body: any }> {
  return new Promise((resolve, reject) => {
    const data = body ? JSON.stringify(body) : null;
    const req = http.request(
      {
        hostname: 'localhost',
        port: PORT,
        path,
        method,
        headers: {
          'Content-Type': 'application/json',
          ...(data ? { 'Content-Length': Buffer.byteLength(data) } : {})
        }
      },
      res => {
        let resData = '';
        res.on('data', chunk => (resData += chunk));
        res.on('end', () => {
          try {
            resolve({ status: res.statusCode || 500, body: JSON.parse(resData) });
          } catch (e) {
            resolve({ status: res.statusCode || 500, body: resData });
          }
        });
      }
    );
    req.on('error', reject);
    if (data) req.write(data);
    req.end();
  });
}

async function runTests() {
  console.log('Starting Backend API Verification Tests...');

  server = app.listen(PORT, async () => {
    try {
      // 1. Health check
      const health = await makeRequest('/health');
      assert.strictEqual(health.status, 200);
      assert.strictEqual(health.body.status, 'HEALTHY');
      console.log('✓ GET /health PASSED');

      // 2. Readiness check
      const ready = await makeRequest('/ready');
      assert.strictEqual(ready.status, 200);
      assert.strictEqual(ready.body.records.beneficiaries >= 20, true);
      console.log('✓ GET /ready PASSED (Synthetic records verified >= 20)');

      // 3. Opportunities listing
      const opps = await makeRequest('/api/opportunities');
      assert.strictEqual(opps.status, 200);
      assert.strictEqual(opps.body.data.length >= 15, true);
      console.log('✓ GET /api/opportunities PASSED (15+ opportunities verified)');

      // 4. Mentors listing
      const mentors = await makeRequest('/api/mentors');
      assert.strictEqual(mentors.status, 200);
      assert.strictEqual(mentors.body.data.length >= 10, true);
      console.log('✓ GET /api/mentors PASSED (10+ mentors verified)');

      // 5. Training listing
      const training = await makeRequest('/api/training');
      assert.strictEqual(training.status, 200);
      assert.strictEqual(training.body.data.length >= 10, true);
      console.log('✓ GET /api/training PASSED (10+ courses verified)');

      // 6. Direct Auth login test
      const login = await makeRequest('/api/auth/login', 'POST', { role: 'BENEFICIARY' });
      assert.strictEqual(login.status, 200);
      assert.strictEqual(typeof login.body.data.token, 'string');
      console.log('✓ POST /api/auth/login PASSED');

      // 7. IVR webhook start
      const ivrStart = await makeRequest('/api/webhooks/ivr/call-start', 'POST', { CallSid: 'test-call-1', From: '+919840112301' });
      assert.strictEqual(ivrStart.status, 200);
      assert.strictEqual(ivrStart.body.responseType, 'PLAY_AND_GATHER');
      console.log('✓ POST /api/webhooks/ivr/call-start PASSED');

      // 8. WhatsApp webhook simulation
      const wa = await makeRequest('/api/webhooks/whatsapp', 'POST', { from: '+919840112301', message: 'வணக்கம், எனக்கு சோலார் வேலை வேண்டும்.' });
      assert.strictEqual(wa.status, 200);
      assert.strictEqual(wa.body.status, 'DELIVERED');
      console.log('✓ POST /api/webhooks/whatsapp PASSED');

      console.log('\n🎉 ALL BACKEND API TESTS PASSED SUCCESSFULLY!');
      server.close();
      process.exit(0);
    } catch (err) {
      console.error('Test failed:', err);
      server.close();
      process.exit(1);
    }
  });
}

runTests();
