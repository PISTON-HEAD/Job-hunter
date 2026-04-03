# 🛠️ N8N Job Hunting Co-Pilot - Setup Guide

**Complete step-by-step installation and configuration**

---

## Table of Contents

1. [Install N8N](#1-install-n8n)
2. [Configure API Credentials](#2-configure-api-credentials)
3. [Import Workflow](#3-import-workflow)
4. [Set Environment Variables](#4-set-environment-variables)
5. [Test Components](#5-test-components)
6. [Deploy & Schedule](#6-deploy--schedule)

---

## 1. Install N8N

### Option A: Docker (Recommended)

**Prerequisites:**

- Docker Desktop installed
- 4GB RAM available

**Steps:**

```powershell
# Pull N8N image
docker pull n8nio/n8n

# Create persistent volume for data
docker volume create n8n_data

# Run N8N
docker run -it --rm --name n8n `
  -p 5678:5678 `
  -v n8n_data:/home/node/.n8n `
  -e N8N_BASIC_AUTH_ACTIVE=true `
  -e N8N_BASIC_AUTH_USER=admin `
  -e N8N_BASIC_AUTH_PASSWORD=your_secure_password_here `
  n8nio/n8n
```

**Access:** Open browser to http://localhost:5678

---

### Option B: NPM (Local Development)

**Prerequisites:**

- Node.js 18+ installed

```powershell
# Install N8N globally
npm install n8n -g

# Start N8N
n8n start
```

**Access:** Open browser to http://localhost:5678

---

### Option C: N8N Cloud (Easiest, Paid)

1. Go to https://n8n.io/cloud
2. Sign up for account ($20-300/month depending on executions)
3. No installation needed
4. Import workflow directly

---

## 2. Configure API Credentials

### 2.1 OpenAI API Key

**Purpose:** AI job evaluation and cover letter generation

**Steps:**

1. Go to https://platform.openai.com/api-keys
2. Sign in or create account
3. Click "Create new secret key"
4. Copy key (starts with `sk-...`)
5. Add $20 credit: https://platform.openai.com/account/billing

**In N8N:**

1. Go to **Credentials** (left sidebar)
2. Click **Add Credential**
3. Search for "OpenAI"
4. Paste API key
5. Name it: `OpenAI - Job Copilot`
6. Click **Save**

**Test:**

```javascript
// In N8N, add a test OpenAI node
Model: gpt-4o
Prompt: "Say 'test successful' in 3 words"
Expected output: "Test was successful" or similar
```

---

### 2.2 Indeed Publisher API

**Purpose:** Fetch Indeed job listings

**Steps:**

1. Go to https://ads.indeed.com/jobroll/xmlfeed
2. Fill out publisher program application
3. Wait for approval (usually 1-2 days)
4. Receive Publisher ID via email

**In N8N:**

- No credential needed, just add Publisher ID to workflow URL parameters
- Store as environment variable: `INDEED_PUBLISHER_ID`

**Test URL:**

```
http://api.indeed.com/ads/apisearch?publisher=YOUR_ID_HERE&q=java&l=remote&format=json&v=2&limit=1
```

Open in browser - should return JSON with jobs

---

### 2.3 Adzuna API

**Purpose:** Fetch jobs from Adzuna (covers US, UK, EU, AU)

**Steps:**

1. Go to https://developer.adzuna.com/
2. Click "Register for API Access"
3. Fill form (free account)
4. Receive App ID and App Key via email

**In N8N:**

- Store as environment variables:
  - `ADZUNA_APP_ID`
  - `ADZUNA_APP_KEY`

**Test URL:**

```
https://api.adzuna.com/v1/api/jobs/us/search/1?app_id=YOUR_APP_ID&app_key=YOUR_APP_KEY&results_per_page=1&what=java
```

---

### 2.4 Gmail (For Email Notifications)

**Purpose:** Send daily digest to your email

**Steps:**

1. **Enable Gmail API:**
   - Go to https://console.cloud.google.com/
   - Create new project: "Job Copilot"
   - Enable Gmail API
2. **Create OAuth2 Credentials:**
   - APIs & Services → Credentials
   - Create OAuth Client ID
   - Application Type: Web Application
   - Authorized redirect URIs: `http://localhost:5678/rest/oauth2-credential/callback`
   - Copy Client ID and Client Secret

3. **In N8N:**
   - Credentials → Add Credential → Gmail OAuth2
   - Paste Client ID and Client Secret
   - Click "Connect my account"
   - Authorize access
   - Save as: `Gmail - Personal`

**Test:** Send yourself a test email through N8N

---

### 2.5 Slack (Alternative Notification)

**Purpose:** Post daily digest to Slack channel

**Steps:**

1. Go to https://api.slack.com/apps
2. Click "Create New App"
3. Choose "From scratch"
4. App Name: "Job Copilot Bot"
5. Select workspace
6. Go to "OAuth & Permissions"
7. Add Bot Token Scopes:
   - `chat:write`
   - `chat:write.public`
8. Click "Install to Workspace"
9. Copy "Bot User OAuth Token"

**In N8N:**

- Credentials → Add Credential → Slack OAuth2
- Paste Bot Token
- Save as: `Slack - Job Alerts`

---

### 2.6 Telegram (Alternative Notification)

**Purpose:** Send daily digest via Telegram

**Steps:**

1. Open Telegram
2. Search for `@BotFather`
3. Send `/newbot`
4. Follow prompts (name: "Job Copilot Bot")
5. Copy HTTP API token

**Get Your Chat ID:**

```powershell
# Send a message to your bot first, then:
curl https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates
# Look for "chat":{"id":123456789}
```

**In N8N:**

- Credentials → Add Credential → Telegram
- Paste Token
- Save as: `Telegram - Personal`
- In workflow, set Chat ID to your ID

---

## 3. Import Workflow

### Steps:

1. **Download Workflow JSON:**
   - Open `job-hunting-copilot-workflow.json` from this folder

2. **In N8N:**
   - Click **Workflows** (top left)
   - Click **Import from File**
   - Select the JSON file
   - Click **Import**

3. **Workflow Should Load:**
   - You'll see all nodes connected
   - Red nodes indicate missing credentials (normal)

4. **Fix Credentials:**
   - Click each node with red outline
   - Select the credentials you created above
   - Save node

---

## 4. Set Environment Variables

### In N8N Docker:

Stop container, restart with variables:

```powershell
docker run -it --rm --name n8n `
  -p 5678:5678 `
  -v n8n_data:/home/node/.n8n `
  -e N8N_BASIC_AUTH_ACTIVE=true `
  -e N8N_BASIC_AUTH_USER=admin `
  -e N8N_BASIC_AUTH_PASSWORD=your_password `
  -e INDEED_PUBLISHER_ID=your_indeed_id `
  -e ADZUNA_APP_ID=your_adzuna_app_id `
  -e ADZUNA_APP_KEY=your_adzuna_app_key `
  -e YOUR_NAME="John Doe" `
  -e YOUR_EMAIL="john@example.com" `
  -e YOUR_GITHUB="github.com/yourusername" `
  n8nio/n8n
```

### In N8N NPM:

Create `.env` file in N8N data directory:

```bash
# Windows: C:\Users\<username>\.n8n\.env
INDEED_PUBLISHER_ID=your_indeed_id
ADZUNA_APP_ID=your_adzuna_app_id
ADZUNA_APP_KEY=your_adzuna_app_key
YOUR_NAME=John Doe
YOUR_EMAIL=john@example.com
YOUR_GITHUB=github.com/yourusername
```

### Access in Workflow:

```javascript
const indeedId = $env.INDEED_PUBLISHER_ID;
const yourName = $env.YOUR_NAME;
```

---

## 5. Test Components

### 5.1 Test Individual Job Sources

**Test LinkedIn RSS:**

1. Find "LinkedIn Jobs RSS" node
2. Click "Execute Node"
3. Should return 20-50 jobs
4. Check output format

**Test Indeed API:**

1. Find "Indeed API" node
2. Update Publisher ID in URL
3. Execute node
4. Should return jobs array

**Test Adzuna API:**

1. Find "Adzuna API" node
2. Update app_id and app_key in URL
3. Execute node
4. Should return jobs array

---

### 5.2 Test AI Evaluation

1. **Find "AI Job Scorer" node**
2. **Manually trigger with sample job:**

   Add this test data:

   ```json
   {
     "title": "Senior Java Developer",
     "company": "Test Corp",
     "description": "Looking for experienced Java Spring Boot developer with AWS experience. Must know JPA, Docker, and microservices.",
     "url": "https://example.com/job",
     "source": "test"
   }
   ```

3. **Execute node**
4. **Expected output:**
   ```json
   {
     "match_score": 85,
     "reasoning": "Strong match: requires Spring Boot, JPA, AWS, Docker - all present in profile",
     "matched_skills": ["Java", "Spring Boot", "JPA", "AWS", "Docker"],
     "missing_skills": [],
     "recommendation": "apply"
   }
   ```

---

### 5.3 Test Cover Letter Generation

1. **Use output from AI Evaluation**
2. **Find "Cover Letter Generator" node**
3. **Execute node**
4. **Review generated cover letter:**
   - Should be 3 paragraphs
   - Should mention specific skills from job
   - Should include GitHub link
   - Should sound professional but personable

---

### 5.4 Test Notification Delivery

**Gmail Test:**

1. Find "Send Email Digest" node
2. Execute node
3. Check your inbox
4. Verify HTML formatting looks good

**Slack Test:**

1. Find "Post to Slack" node
2. Execute node
3. Check your Slack channel
4. Verify message formatting

---

## 6. Deploy & Schedule

### 6.1 Set Schedule Trigger

1. **Find "Schedule Trigger" node (first node)**
2. **Click to edit**
3. **Configuration:**
   - Mode: `Days of Week`
   - Days: `Monday, Tuesday, Wednesday, Thursday, Friday`
   - Time: `08:00` (or your preferred time)
   - Timezone: Select your timezone
4. **Save**

### 6.2 Activate Workflow

1. **Click toggle switch at top:** "Inactive" → "Active"
2. **Status should show:** "Active"
3. **Workflow will now run automatically**

---

### 6.3 Monitor Execution

**View Execution History:**

1. Go to **Executions** (left sidebar)
2. See all past runs
3. Click any execution to see detailed logs
4. Check for errors

**Set Up Alerts:**

1. Workflow Settings → Error Workflow
2. Create simple error notification workflow:
   ```
   If main workflow fails → Send alert to Slack/Email
   ```

---

## 7. Advanced Configuration

### 7.1 Database Storage (Optional)

If you want persistent storage beyond N8N's internal database:

**PostgreSQL Setup:**

```powershell
# Run PostgreSQL in Docker
docker run --name postgres-jobs `
  -e POSTGRES_PASSWORD=your_password `
  -e POSTGRES_DB=job_copilot `
  -p 5432:5432 `
  -d postgres:15
```

**In N8N:**

1. Add "Postgres" credential
2. Add database nodes after AI evaluation
3. Store job data for long-term analytics

---

### 7.2 Google Sheets Integration

**Purpose:** Track all jobs in a spreadsheet

**Setup:**

1. Create Google Sheet: "Job Applications 2026"
2. Columns: `Date | Title | Company | Source | Match Score | Status | URL`
3. In N8N:
   - Add credential: Google Sheets OAuth2
   - Add "Google Sheets" node after AI evaluation
   - Action: "Append Row"
   - Select your sheet

---

### 7.3 Custom Domain (If Self-Hosted)

**Using N8N webhooks for external triggers:**

1. Get domain (e.g., jobs.yourdomain.com)
2. Point to your server IP
3. Set up reverse proxy (Nginx):

```nginx
server {
  listen 80;
  server_name jobs.yourdomain.com;

  location / {
    proxy_pass http://localhost:5678;
    proxy_set_header Host $host;
  }
}
```

4. Add SSL with Let's Encrypt:

```bash
certbot --nginx -d jobs.yourdomain.com
```

---

## 8. Maintenance Checklist

### Weekly:

- [ ] Check execution logs for errors
- [ ] Review match score accuracy (adjust threshold if needed)
- [ ] Verify all API sources still working
- [ ] Check API usage/costs

### Monthly:

- [ ] Update your skills profile (if you learned something new)
- [ ] Refine AI prompts based on quality
- [ ] Review cover letter templates
- [ ] Analyze which sources yield best results
- [ ] Check for N8N updates: `docker pull n8nio/n8n`

---

## 9. Troubleshooting Quick Reference

**Workflow not triggering:**

- Check if workflow is "Active" (toggle at top)
- Verify schedule trigger time & timezone
- Check N8N logs: `docker logs n8n`

**No jobs found:**

- Test each API source individually
- Check if API keys are valid
- Verify search parameters (keywords, location)
- Check API rate limits

**AI evaluation failing:**

- Verify OpenAI API key is valid
- Check API credit balance
- Review prompt for JSON formatting issues
- Check token limits (increase max_tokens if needed)

**Email not sending:**

- Re-authenticate Gmail OAuth
- Check spam folder
- Verify recipient email is correct
- Test with simple N8N email node first

---

## 10. Cost Optimization Tips

**Reduce OpenAI costs:**

- Use `gpt-4o-mini` instead of `gpt-4o` (10x cheaper)
- Reduce max_tokens to 300 for scoring, 500 for cover letters
- Cache common evaluations

**Reduce executions:**

- Run workflow every other day instead of daily
- Filter out jobs older than 24 hours before AI evaluation
- Only evaluate jobs above basic keyword threshold

**Free alternatives:**

- Use Anthropic Claude (new accounts get free credits)
- Use local LLMs (Ollama + Llama 3) - free but requires good PC

---

## 11. Security Best Practices

1. **Never commit API keys to Git**
2. **Use environment variables for all secrets**
3. **Enable N8N basic auth (username/password)**
4. **Run N8N behind firewall if self-hosted**
5. **Regularly rotate API keys (every 90 days)**
6. **Use separate email for job applications**
7. **Review N8N access logs monthly**

---

## 12. Next Steps

- [ ] Complete setup checklist above
- [ ] Run manual test execution
- [ ] Review first daily digest
- [ ] Adjust match score threshold (start at 75)
- [ ] Customize cover letter style
- [ ] Set up Google Sheets tracking (optional)
- [ ] Create "Applied Jobs" tracking system

---

**Setup Support:**

- N8N Community: https://community.n8n.io
- Documentation: https://docs.n8n.io
- Video tutorials: https://www.youtube.com/@n8n-io

---

**Estimated Setup Time:** 2-3 hours for first-time setup, 30 minutes if experienced with N8N.

Good luck! 🚀
