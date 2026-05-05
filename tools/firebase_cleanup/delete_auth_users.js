/*
  Deletes ALL Firebase Auth users for a given project.

  Requirements:
    - A service-account key JSON downloaded from Firebase Console
    - Set env var GOOGLE_APPLICATION_CREDENTIALS to the JSON path

  Usage (PowerShell):
    $env:GOOGLE_APPLICATION_CREDENTIALS = "C:\\path\\to\\service-account.json"
    node delete_auth_users.js --project smartchat-4e580

  Optional:
    --dry-run   Lists how many users would be deleted, but does not delete.
*/

const admin = require('firebase-admin');

function parseArgs(argv) {
  const args = { projectId: null, dryRun: false };
  for (let i = 2; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--project' || a === '-p') {
      args.projectId = argv[i + 1];
      i++;
    } else if (a === '--dry-run') {
      args.dryRun = true;
    }
  }
  return args;
}

function chunk(array, size) {
  const out = [];
  for (let i = 0; i < array.length; i += size) out.push(array.slice(i, i + size));
  return out;
}

async function listAllUids() {
  const uids = [];
  let pageToken = undefined;

  // listUsers supports up to 1000 per call
  for (;;) {
    const res = await admin.auth().listUsers(1000, pageToken);
    for (const user of res.users) {
      if (user.uid) uids.push(user.uid);
    }

    if (!res.pageToken) break;
    pageToken = res.pageToken;
  }

  return uids;
}

async function main() {
  const { projectId, dryRun } = parseArgs(process.argv);

  if (!projectId) {
    throw new Error('Missing required --project <projectId> argument.');
  }

  if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    throw new Error(
      'Missing GOOGLE_APPLICATION_CREDENTIALS env var (path to service-account JSON).'
    );
  }

  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
    projectId,
  });

  console.log(`Project: ${projectId}`);
  console.log(`Mode: ${dryRun ? 'DRY RUN' : 'DELETE'}`);

  const uids = await listAllUids();
  console.log(`Found ${uids.length} Auth users.`);

  if (dryRun) {
    console.log('Dry run complete. No users were deleted.');
    return;
  }

  const batches = chunk(uids, 1000);
  let deleted = 0;
  let failures = 0;

  for (let i = 0; i < batches.length; i++) {
    const batch = batches[i];
    const res = await admin.auth().deleteUsers(batch);
    deleted += res.successCount;
    failures += res.failureCount;

    console.log(
      `Batch ${i + 1}/${batches.length}: deleted ${res.successCount}, failed ${res.failureCount}`
    );

    if (res.errors && res.errors.length) {
      // Print a small sample to avoid huge logs
      const sample = res.errors.slice(0, 5).map((e) => ({
        index: e.index,
        uid: batch[e.index],
        code: e.error && e.error.code,
        message: e.error && e.error.message,
      }));
      console.log('Sample errors:', sample);
    }
  }

  console.log(`Done. Deleted: ${deleted}. Failed: ${failures}.`);
}

main().catch((err) => {
  console.error('ERROR:', err && err.message ? err.message : err);
  process.exitCode = 1;
});
