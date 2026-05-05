# Firebase Cleanup Tools

These scripts are **destructive**. Use only for test/staging projects.

## Delete all Firebase Auth users

1. Download a **service account key JSON**:
   Firebase Console → Project Settings → Service accounts → *Generate new private key*

2. Install dependencies:

```bash
cd tools/firebase_cleanup
npm install
```

3. (Optional) Dry run:

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS = "C:\path\to\service-account.json"
node .\delete_auth_users.js --project smartchat-4e580 --dry-run
```

4. Delete all users:

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS = "C:\path\to\service-account.json"
node .\delete_auth_users.js --project smartchat-4e580
```
