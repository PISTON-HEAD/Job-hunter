# 🔧 Troubleshooting Guide

**Common issues and solutions for the Job Hunting Co-Pilot workflow**

---

## Table of Contents

1. [Workflow Not Running](#1-workflow-not-running)
2. [No Jobs Found](#2-no-jobs-found)
3. [API Errors](#3-api-errors)
4. [AI Evaluation Issues](#4-ai-evaluation-issues)
5. [Email/Notification Failures](#5-emailnotification-failures)
6. [Performance Problems](#6-performance-problems)
7. [Cost Issues](#7-cost-issues)
8. [Data Quality Problems](#8-data-quality-problems)

---

## 1. Workflow Not Running

### Symptom: Workflow never triggers automatically

**Check 1: Is workflow activated?**

- Look for toggle at top of workflow
- Should say "Active" (green), not "Inactive" (gray)
- **Fix:** Click toggle to activate

**Check 2: Schedule trigger configured correctly?**

- Click Schedule Trigger node
- Verify time and timezone are correct
- Common mistake: Wrong timezone (UTC vs local)
- **Fix:** Change to your local timezone

**Check 3: N8N running?**

```powershell
# Check if Docker container is running
docker ps | Select-String "n8n"

# If not running
docker start n8n

# Check logs
docker logs n8n --tail 50
```

**Check 4: Execution history**

- Go to "Executions" in left sidebar
- Look for errors in past runs
- Click failed execution to see error details

---

### Symptom: Workflow runs but stops immediately

**Diagnosis:**

- Check execution logs
- Look for error in first few nodes

**Common Causes:**

**1. Missing environment variables:**

```
Error: Cannot read property 'INDEED_PUBLISHER_ID' of undefined
```

**Fix:**

```powershell
# Restart N8N with environment variables
docker run -e INDEED_PUBLISHER_ID=your_id ...
```

**2. Network issues:**

```
Error: ETIMEDOUT connecting to api.indeed.com
```

**Fix:**

- Check internet connection
- Verify firewall isn't blocking N8N
- Try manual curl to test API:

```powershell
curl "http://api.indeed.com/ads/apisearch?publisher=test&q=java&format=json&v=2&limit=1"
```

---

## 2. No Jobs Found

### Symptom: Workflow runs but returns 0 jobs

**Check 1: Are searches too narrow?**

**Problem:** Search terms too specific

```
keywords: "Senior Staff Principal Java Spring Boot Architect"
```

**Fix:** Broaden search

```
keywords: "Java Spring Boot"
# or
keywords: "Java Developer"
```

**Check 2: Location too restrictive?**

**Problem:**

```
location: "Smallville, KS"
```

**Fix:**

```
location: "Remote"
# or
location: "United States"
```

**Check 3: Date filter too strict?**

**Problem:**

```
fromage: 1  # Only last 24 hours
```

**Fix:**

```
fromage: 7  # Last week
```

**Check 4: Are APIs returning data?**

**Test Each Source Individually:**

1. Click "LinkedIn Jobs RSS" node
2. Click "Execute Node" (play button)
3. Check output tab
4. Should see job listings

**If no data:**

- API might be down
- Rate limited (wait 1 hour, try again)
- Search parameters invalid

**Verify URL in browser:**

```
https://www.linkedin.com/jobs-guest/jobs/api/seeMoreJobPostings/search?keywords=java&location=remote&start=0
```

---

### Symptom: Getting duplicate jobs

**Cause:** Deduplication logic not working

**Check Code Node:** "Normalize & Deduplicate"

**Fix:** Ensure dedupe logic is correct:

```javascript
const key = `${normalized.title.toLowerCase()}_${normalized.company.toLowerCase()}`;
if (!jobMap.has(key)) {
  jobMap.set(key, normalized);
}
```

**Alternative Fix:** Use N8N's "Remove Duplicates" node

---

## 3. API Errors

### 401 Unauthorized

**Message:**

```
Error: 401 Unauthorized - Invalid API key
```

**Diagnosis:**

- API key is wrong or expired
- Credential not configured

**Fix:**

1. **Verify API key is correct:**

   ```powershell
   # Test Indeed API key
   curl "http://api.indeed.com/ads/apisearch?publisher=YOUR_KEY&q=test&format=json&v=2&limit=1"
   ```

2. **Re-enter credential in N8N:**
   - Credentials → Find credential → Edit
   - Paste new API key
   - Save
   - Retry workflow

3. **Check environment variable:**
   ```powershell
   docker exec n8n printenv | Select-String "INDEED"
   ```

---

### 403 Forbidden

**Message:**

```
Error: 403 Forbidden - Access denied
```

**Causes:**

1. **Violated Terms of Service:**
   - Exceeded rate limits
   - Banned IP address
   - **Fix:** Wait 24 hours, slow down requests

2. **Missing required headers:**

   ```javascript
   // Add to HTTP Request node
   headers: {
     'User-Agent': 'JobCopilot/1.0 (your@email.com)'
   }
   ```

3. **IP blocked:**
   - Some APIs block cloud IPs (AWS, Azure, GCP)
   - **Fix:** Use residential IP or VPN

---

### 429 Too Many Requests

**Message:**

```
Error: 429 Too Many Requests - Rate limit exceeded
```

**Diagnosis:**

- You're calling API too frequently
- Exceeded daily quota

**Fix:**

1. **Add delay between requests:**
   - Add "Wait" node after each API call
   - Set to 3 seconds

2. **Check daily quota:**
   - Indeed: 1000 calls/day
   - Adzuna: 1000 calls/month
   - **Track usage** in Google Sheets

3. **Implement retry logic:**
   ```javascript
   // In Code Node
   if (response.status === 429) {
     await new Promise((r) => setTimeout(r, 60000)); // Wait 1 min
     return $retry(); // Retry request
   }
   ```

---

### Timeout Errors

**Message:**

```
Error: ETIMEDOUT - Request timed out after 30000ms
```

**Causes:**

- API is slow or down
- Network issues
- N8N timeout too short

**Fix:**

1. **Increase timeout in HTTP Request node:**
   - Options → Timeout
   - Increase to 60000 (60 seconds)

2. **Check API status:**
   - Indeed: https://status.indeed.com
   - LinkedIn: (no status page, check Twitter)

3. **Add retry logic:**
   - HTTP Request node → Options → Retry on Fail
   - Set to 3 retries with 5-second delay

---

## 4. AI Evaluation Issues

### Symptom: AI giving all jobs low scores

**Diagnosis:**

- AI prompt might be too strict
- Profile doesn't match job types

**Check AI Scoring Prompt:**

- Open "AI Job Scorer" node
- Review system prompt

**Fix 1: Relax scoring criteria**

**Before (too strict):**

```
Score 90+ only if ALL skills match
```

**After (more realistic):**

```
Score 75+ if MOST core skills match
Score 90+ if ALL core skills + nice-to-haves match
```

**Fix 2: Update your profile in prompt**

Make sure AI knows your actual skills:

```
CANDIDATE PROFILE:
- Core Skills: [UPDATE THIS WITH YOUR ACTUAL SKILLS]
- Experience: [YOUR ACTUAL EXPERIENCE]
```

---

### Symptom: AI returning non-JSON

**Error:**

```
SyntaxError: Unexpected token 'I' in JSON at position 0
```

**Diagnosis:**

- AI returning plain text instead of JSON
- Happens with GPT-3.5 sometimes

**Fix 1: Update prompt to be more explicit:**

```
OUTPUT FORMAT: {"match_score": 85, ...}

YOU MUST OUTPUT ONLY VALID JSON. NO OTHER TEXT.
```

**Fix 2: Use better model:**

- Change from `gpt-3.5-turbo` to `gpt-4o`
- More reliable JSON output

**Fix 3: Add fallback in Parse AI Response node:**

```javascript
try {
  parsed = JSON.parse(aiResponse);
} catch (error) {
  // Fallback scoring
  parsed = {
    match_score: 60,
    reasoning: 'Manual review needed',
    matched_skills: [],
    missing_skills: [],
  };
}
```

---

### Symptom: AI generating bad cover letters

**Problem 1: Too generic**

**Fix:** Add more specific context to prompt:

```
CANDIDATE SPECIFIC PROJECTS:
- Project 1: Microservices platform handling 10K rps
- Project 2: OAuth2 auth for 50K users
- Project 3: Kafka pipeline processing 100K events/day

USE THESE SPECIFIC NUMBERS IN THE COVER LETTER.
```

**Problem 2: Wrong tone (too formal/informal)**

**Fix:** Add tone examples:

```
GOOD EXAMPLE:
"I'm excited about TechCorp's focus on scalable architecture.
My experience building Spring Boot services that handle 10K+
requests per second aligns well with your needs."

BAD EXAMPLE:
"I am writing to express my interest in the position at your
esteemed organization..."
```

---

### Symptom: OpenAI API errors

**Error 1: Insufficient credits**

```
Error: 429 - You exceeded your current quota
```

**Fix:**

- Go to https://platform.openai.com/account/billing
- Add credits ($20 minimum)

**Error 2: Model not available**

```
Error: Model 'gpt-4o' does not exist
```

**Fix:**

- Change to available model: `gpt-4o-mini` or `gpt-3.5-turbo`
- Check model availability: https://platform.openai.com/docs/models

**Error 3: Content policy violation**

```
Error: This request was rejected due to content policy
```

**Fix:**

- Check if job description contains flagged words
- Add content filter in Code Node:

```javascript
const flaggedWords = ['explicit', 'adult', 'xxx'];
const description = $json.description.toLowerCase();
const isFlagged = flaggedWords.some((word) => description.includes(word));

if (isFlagged) {
  return []; // Skip this job
}
```

---

## 5. Email/Notification Failures

### Symptom: Email not sending (Gmail)

**Error: Invalid credentials**

```
Error: Invalid login: 535-5.7.8 Username and Password not accepted
```

**Fix:**

1. Re-authenticate Gmail OAuth:
   - Credentials → Gmail OAuth2 → Edit
   - Click "Connect my account"
   - Re-authorize

2. Check Google Account settings:
   - Go to https://myaccount.google.com/security
   - Enable "Less secure app access" (if using password)
   - **Better:** Use OAuth2 (already configured)

**Error: Daily sending limit**

```
Error: 550 Daily user sending quota exceeded
```

**Diagnosis:**

- Gmail free: 500 emails/day
- You've exceeded limit

**Fix:**

- Wait 24 hours
- Reduce workflow frequency
- Use Slack/Telegram instead

---

### Symptom: Email goes to spam

**Diagnosis:**

- HTML too complex
- Flagged words in subject
- No SPF/DKIM (if self-hosted)

**Fix:**

1. **Simplify subject line:**
   - Bad: "🎯💰🚀 JOBS FOR YOU"
   - Good: "5 Job Matches - April 3"

2. **Reduce HTML complexity:**
   - Remove excessive styling
   - Use simple tables, not complex layouts

3. **Add plain text version:**
   ```javascript
   // In Format Email Digest node
   return [
     {
       json: {
         html: htmlContent,
         text: plainTextContent, // ADD THIS
         subject: subject,
       },
     },
   ];
   ```

---

### Symptom: Slack messages not posting

**Error: channel_not_found**

```
Error: channel_not_found
```

**Fix:**

- Add bot to channel:
  1. Go to Slack channel
  2. Type `/invite @Job Copilot Bot`
  3. Bot now has access

**Error: not_authed**

```
Error: not_authed - Invalid token
```

**Fix:**

- Re-create bot token:
  1. https://api.slack.com/apps
  2. Your app → OAuth & Permissions
  3. Reinstall to Workspace
  4. Copy new token to N8N credential

---

### Symptom: Telegram not working

**Error: Bad Request: chat not found**

```
Error: 400 Bad Request: chat not found
```

**Fix:**

1. Message your bot first (initiate conversation)
2. Get correct chat ID:
   ```powershell
   curl "https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates"
   ```
3. Look for `"chat":{"id":123456}`
4. Update `TELEGRAM_CHAT_ID` environment variable

---

## 6. Performance Problems

### Symptom: Workflow takes >30 minutes

**Diagnosis:**

- Too many jobs to process
- AI evaluation is slow

**Fix 1: Optimize API calls**

**Problem:** Fetching 500+ jobs, evaluating all
**Fix:** Limit results

```javascript
// In API nodes
limit: 25; // Instead of 50
```

**Fix 2: Pre-filter before AI**

Add "Basic Keyword Filter" Code Node before AI:

```javascript
// Skip jobs that obviously don't match
const title = $json.title.toLowerCase();
const description = $json.description.toLowerCase();

const requiredKeywords = ['java', 'spring', 'boot'];
const hasRequired = requiredKeywords.some(
  (kw) => title.includes(kw) || description.includes(kw),
);

if (!hasRequired) {
  return []; // Skip AI evaluation
}

return [$input.item];
```

**Fix 3: Use faster AI model**

- Change from `gpt-4o` to `gpt-4o-mini` (2x faster)
- Slightly less accurate but much faster

**Fix 4: Process in batches**

Add "Split in Batches" node:

- Batch size: 10
- Process 10 jobs at a time
- Prevents timeout

---

### Symptom: High memory usage

**Error:**

```
Error: JavaScript heap out of memory
```

**Diagnosis:**

- Processing too many jobs at once
- Large job descriptions

**Fix:**

1. **Increase N8N memory (Docker):**

   ```powershell
   docker run -e NODE_OPTIONS="--max-old-space-size=4096" n8nio/n8n
   ```

2. **Limit job description length:**

   ```javascript
   // Truncate long descriptions
   if ($json.description.length > 2000) {
     $json.description = $json.description.substring(0, 2000) + '...';
   }
   ```

3. **Clear data between steps:**
   ```javascript
   // Remove unnecessary fields
   delete $json.raw_html;
   delete $json.metadata;
   ```

---

## 7. Cost Issues

### Symptom: OpenAI bill is high

**Check usage:**
https://platform.openai.com/usage

**Diagnosis:**

**Problem 1: Using expensive model**

- `gpt-4o`: $5/1M tokens
- `gpt-4o-mini`: $0.15/1M tokens (97% cheaper!)

**Fix:** Use `gpt-4o-mini` for job scoring, `gpt-4o` only for cover letters

**Problem 2: Long prompts**

- Sending entire 5000-word job description
- System prompt too long

**Fix:** Truncate descriptions to 500 words

```javascript
const maxWords = 500;
const words = $json.description.split(' ');
if (words.length > maxWords) {
  $json.description = words.slice(0, maxWords).join(' ') + '...';
}
```

**Problem 3: Processing too many jobs**

- Evaluating 100+ jobs daily at $0.02 each = $60/month

**Fix:** Raise filter threshold

```javascript
// Only evaluate if keywords match
const basicScore = calculateBasicMatch($json);
if (basicScore < 50) {
  return []; // Skip AI
}
```

---

### Expected Costs Breakdown

**Realistic Daily Usage:**

```
Jobs discovered: 80
After basic filter: 40
After AI scoring: 10 (score > 75)
Cover letters: 10

OpenAI costs:
- Scoring: 40 jobs × 1500 tokens × $0.15/1M = $0.009
- Cover letters: 10 × 2000 tokens × $0.15/1M = $0.003
Total per day: ~$0.01
Monthly: ~$0.30
```

**If using GPT-4o (more expensive):**

```
Monthly cost: ~$18 (instead of $0.30)
```

**Set spending limit:**

- OpenAI dashboard → Billing → Set limit: $10/month
- Get alert when approaching limit

---

## 8. Data Quality Problems

### Symptom: Getting irrelevant jobs

**Problem 1: AI scoring incorrectly**

**Check:** Review jobs with score 80+ manually

- Are they actually relevant?
- If not, adjust AI prompt

**Fix:** Make scoring criteria more strict:

```
STRICT MATCHING:
- Deduct 20 points if primary language is not Java
- Deduct 15 points if no Spring Boot mentioned
- Deduct 10 points if seniority mismatched
```

**Problem 2: Wrong location**

**Check:** Are jobs in wrong country?

**Fix:** Add location filter in Code Node:

```javascript
const validLocations = ['remote', 'united states', 'usa', 'us'];
const location = $json.location.toLowerCase();

const isValid = validLocations.some((loc) => location.includes(loc));
if (!isValid) {
  return []; // Skip
}
```

---

### Symptom: Missing good jobs

**Problem:** Threshold too high

**Check:** Lower threshold to 70 temporarily, review results

**Fix:** Adjust threshold based on market:

```
Competitive  market (NYC, SF): 70+
Normal market: 75+
Niche skills: 80+
```

---

### Symptom: Duplicate jobs across sources

**Problem:** Same job on LinkedIn, Indeed, RemoteOK

**Check:** "Normalize & Deduplicate" node

**Fix:** Improve deduplication logic:

```javascript
// Normalize company names
const normalizeCompany = (name) => {
  return name
    .toLowerCase()
    .replace(/inc\.?|llc\.?|corp\.?/g, '')
    .trim();
};

// Normalize titles
const normalizeTitle = (title) => {
  return title
    .toLowerCase()
    .replace(/senior|sr\.?|junior|jr\.?/g, '')
    .trim();
};

const key = `${normalizeTitle($json.title)}_${normalizeCompany($json.company)}`;
```

---

## 9. Debugging Techniques

### Enable Debug Mode

**In N8N:**

1. Workflow Settings (gear icon)
2. Enable "Save execution progress"
3. Enable "Save execution data on error"

**In Docker:**

```powershell
docker run -e N8N_LOG_LEVEL=debug n8nio/n8n
```

---

### Test Individual Nodes

**Don't run entire workflow to debug:**

1. Click node you want to test
2. Click "Execute Node" (play icon)
3. See output immediately
4. Check "Input" and "Output" tabs

---

### Use "Sticky Notes" for logging

Add Code Nodes to log data:

```javascript
console.log('Jobs after dedupe:', $input.all().length);
return $input.all();
```

View logs:

```powershell
docker logs n8n --follow
```

---

### Test with Sample Data

**Create "Manual Trigger" version:**

1. Duplicate workflow
2. Replace "Schedule Trigger" with "Manual Trigger"
3. Add "Edit Fields" node with sample job:
   ```json
   {
     "title": "Senior Java Developer",
     "company": "Test Corp",
     "description": "Spring Boot, AWS...",
     "url": "https://example.com"
   }
   ```
4. Test AI evaluation with known data

---

## 10. Getting Help

### N8N Community

**Forum:** https://community.n8n.io

**How to ask:**

1. Describe the problem
2. Share workflow JSON (remove credentials!)
3. Include error message
4. Mention what you've tried

---

### Check Logs

**Docker:**

```powershell
docker logs n8n --tail 100 > n8n-logs.txt
```

**Self-hosted:**

```powershell
# Check N8N data directory
cd ~/.n8n
cat logs/n8n.log
```

---

### API Status Pages

- **Indeed:** https://status.indeed.com
- **OpenAI:** https://status.openai.com
- **Adzuna:** (no status page, check Twitter @Adzuna)

---

## Quick Diagnostic Checklist

**If workflow completely broken:**

- [ ] Is N8N running? (`docker ps`)
- [ ] Is workflow activated? (Green toggle)
- [ ] Are credentials configured? (Check each node)
- [ ] Are environment variables set? (`docker exec n8n printenv`)
- [ ] Can you access APIs manually? (Test with curl)
- [ ] Are there errors in execution history?
- [ ] Check N8N logs (`docker logs n8n`)

**If getting poor results:**

- [ ] Are search keywords too narrow?
- [ ] Is AI scoring too strict? (Lower threshold to 70)
- [ ] Are you getting any jobs at all? (Check each source)
- [ ] Review AI prompts (might need updating)
- [ ] Check your profile info (is it accurate?)

**If costs too high:**

- [ ] Using cheapest model? (`gpt-4o-mini`)
- [ ] Truncating job descriptions? (Max 500 words)
- [ ] Pre-filtering before AI? (Basic keywords)
- [ ] Set OpenAI spending limit?

---

**Still stuck? Create an issue with:**

1. Error message (full text)
2. Workflow JSON (credentials removed)
3. N8N version (`docker exec n8n n8n --version`)
4. What you've tried so far

Good luck! 🚀
