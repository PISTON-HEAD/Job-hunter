# ✅ Setup Checklist

**Use this checklist to track your progress through setup. Check off each item as you complete it.**

> 📖 **Before starting:** Read `INDIA-SETUP-EXPLAINED.md` first — it explains the whole workflow in simple terms.

---

## 📋 Phase 1: Prerequisites (Day 1)

### Install N8N

- [ ] **Option chosen:** ⬜ Docker ⬜ NPM ⬜ N8N Cloud
- [ ] N8N installed and running
- [ ] Can access N8N at http://localhost:5678 (or cloud URL)
- [ ] Created N8N account/login credentials

### Get API Keys

**OpenAI:**

- [ ] Created account at https://platform.openai.com
- [ ] Generated API key (starts with `sk-...`)
- [ ] Added $20 credit to account
- [ ] **API Key:** `sk-________________________________` (save securely!)

**Indeed:**

- [ ] Applied for Publisher Program at https://ads.indeed.com/jobroll/xmlfeed
- [ ] Received Publisher ID via email (1-2 days)
- [ ] **Publisher ID:** `________________` (save securely!)

**Adzuna:**

- [ ] Registered at https://developer.adzuna.com/
- [ ] Received App ID and App Key via email
- [ ] **App ID:** `________________`
- [ ] **App Key:** `________________________________`

### Notification Channel Setup (Choose at least one)

**Gmail:**

- [ ] Enabled Gmail API in Google Cloud Console
- [ ] Created OAuth2 credentials
- [ ] Have Client ID and Client Secret ready

**Slack (Alternative):**

- [ ] Created Slack app at https://api.slack.com/apps
- [ ] Added `chat:write` permission
- [ ] Installed to workspace
- [ ] Have Bot Token ready

**Telegram (Alternative):**

- [ ] Created bot via @BotFather
- [ ] Have Bot Token
- [ ] Have your Chat ID

---

## 📋 Phase 2: Configuration (Day 1)

### Import Workflow

- [ ] Downloaded `job-hunting-copilot-workflow.json`
- [ ] In N8N: Workflows → Import from File
- [ ] Workflow imported successfully
- [ ] Can see all nodes in canvas

### Configure Credentials

**OpenAI:**

- [ ] N8N: Credentials → Add Credential → OpenAI
- [ ] Pasted API key
- [ ] Named: "OpenAI - Job Copilot"
- [ ] Saved successfully

**Gmail (if using):**

- [ ] N8N: Credentials → Add Credential → Gmail OAuth2
- [ ] Entered Client ID and Client Secret
- [ ] Clicked "Connect my account"
- [ ] Authorized access
- [ ] Named: "Gmail - Personal"

**Slack (if using):**

- [ ] N8N: Credentials → Add Credential → Slack OAuth2
- [ ] Pasted Bot Token
- [ ] Named: "Slack - Job Alerts"

**Telegram (if using):**

- [ ] N8N: Credentials → Add Credential → Telegram
- [ ] Pasted Bot Token
- [ ] Named: "Telegram - Personal"

### Set Environment Variables

**Docker Method:**

- [ ] Stopped N8N container
- [ ] Updated docker run command with variables:
  - [ ] `INDEED_PUBLISHER_ID=your_id`
  - [ ] `ADZUNA_APP_ID=your_id`
  - [ ] `ADZUNA_APP_KEY=your_key`
  - [ ] `YOUR_NAME="Your Name"`
  - [ ] `YOUR_EMAIL=your@email.com`
  - [ ] `YOUR_GITHUB=github.com/username`
  - [ ] `MIN_SALARY_LPA=18` ← set to a number OR `0` to disable salary filter
- [ ] Restarted N8N
- [ ] Verified variables: `docker exec n8n printenv | Select-String "INDEED"`

> **`MIN_SALARY_LPA` quick reference:**
> | Value | Behaviour |
> |-------|-----------|
> | `18` | Only show jobs ≥ 18 LPA |
> | `25` | Only show jobs ≥ 25 LPA |
> | `0` | **Disable filter** — show all salary jobs |
> | _(not set)_ | Disabled (same as `0`) |

**NPM Method:**

- [ ] Created `.env` file in `~/.n8n/`
- [ ] Added all variables above (including `MIN_SALARY_LPA`)
- [ ] Restarted N8N

---

## 📋 Phase 3: Customization (Day 1-2)

### Update Your Profile

**Open `YOUR-PROFILE.md` and fill in:**

**Basic Info:**

- [ ] Name
- [ ] Email
- [ ] Phone
- [ ] Location
- [ ] LinkedIn URL
- [ ] GitHub URL

**Professional Summary:**

- [ ] Current title
- [ ] Years of experience
- [ ] Elevator pitch (2-3 sentences)

**Technical Skills:**

- [ ] Core Java skills listed
- [ ] Spring Boot frameworks listed
- [ ] Databases listed
- [ ] AWS services listed
- [ ] Docker/DevOps tools listed
- [ ] All other relevant skills

**Certifications:**

- [ ] AWS Cloud Practitioner listed
- [ ] Any other certs added

**Education:**

- [ ] Degree
- [ ] Major
- [ ] University
- [ ] Graduation year

**Professional Experience:**

- [ ] Current/most recent job filled in
  - [ ] Title, company, dates
  - [ ] Key responsibilities (3-5 bullets)
  - [ ] Technologies used
  - [ ] Notable achievements
- [ ] Previous jobs added (if applicable)

**Notable Projects:**

- [ ] Project 1: Name, description, tech stack, achievements
- [ ] Project 2: Same as above
- [ ] Project 3: Same as above
- [ ] All projects have GitHub URLs

**Job Preferences:**

- [ ] Work arrangement (remote/hybrid/onsite)
- [ ] Location preferences
- [ ] Salary expectations ($$ minimum, target)
- [ ] Company size preferences
- [ ] Work authorization status

**Red Flags:**

- [ ] Listed job posting phrases to avoid
- [ ] Listed technologies you don't want to work with

### Update AI Prompts in Workflow

**AI Job Scorer Node:**

- [ ] Opened "AI Job Scorer" node
- [ ] Updated CANDIDATE PROFILE section with your info from profile file:
  - [ ] Education
  - [ ] Core skills
  - [ ] Cloud/DevOps
  - [ ] Experience level
  - [ ] GitHub URL
- [ ] Saved node

**Cover Letter Generator Node:**

- [ ] Opened "Generate Cover Letter" node
- [ ] Updated CANDIDATE INFO section:
  - [ ] Name
  - [ ] Current role
  - [ ] GitHub
  - [ ] Key projects/achievements
  - [ ] Certifications
- [ ] Saved node

### Update Search Keywords

**For each API node, verify search keywords (already set for India):**

- [ ] LinkedIn Jobs RSS: `keywords=Java Spring Boot`, `location=India` ✅ Already set
- [ ] Indeed API: `q=java spring boot`, `l=India` ✅ Already set
- [ ] Adzuna API: `what=java spring boot`, `where=India` ✅ Already set (India API)
- [ ] RemoteOK: filters in code node (remote jobs = India-friendly)
- [ ] WeWorkRemotely: RSS is general programming (remote = India-friendly)

**Optionally customize:**

- [ ] Added preferred city (e.g., Bangalore, Pune, Hyderabad, Mumbai)
- [ ] Adjusted experience level filter
- [ ] Set remote/hybrid/onsite preference

### Update Email Settings

**In "Send Email (Gmail)" node:**

- [ ] Changed `sendTo` to your actual email
- [ ] Verified subject line format is good
- [ ] Saved node

**In "Format Email Digest" node (optional customization):**

- [ ] Reviewed HTML template
- [ ] Adjusted styling if needed (colors, fonts)
- [ ] Saved node

---

## 📋 Phase 4: Testing (Day 2)

### Test Individual Components

**Test Job Source APIs:**

- [ ] Click "LinkedIn Jobs RSS" node → Execute Node
  - [ ] Returns 20-50 jobs
  - [ ] Job titles look relevant
- [ ] Click "Indeed API" node → Execute Node
  - [ ] Returns job array
  - [ ] No "Invalid Publisher ID" error
- [ ] Click "Adzuna API" node → Execute Node
  - [ ] Returns jobs
  - [ ] No "Invalid App ID" error
- [ ] Click "RemoteOK API" node → Execute Node
  - [ ] Returns jobs
- [ ] Click "WeWorkRemotely RSS" node → Execute Node
  - [ ] Returns jobs

**Test Merge & Dedupe:**

- [ ] Run all source nodes
- [ ] Click "Merge All Sources" → Execute Node
  - [ ] Combined all jobs
- [ ] Click "Normalize & Deduplicate" → Execute Node
  - [ ] Jobs standardized to same format
  - [ ] Duplicates removed

**Test AI Evaluation:**

- [ ] Create test job data (or use real job from above)
- [ ] Click "AI Job Scorer" → Execute Node
  - [ ] Returns JSON with match_score
  - [ ] Reasoning makes sense
  - [ ] No OpenAI API errors
- [ ] Verify score seems accurate (70-90 for relevant job)

**Test Filter:**

- [ ] Ensure previous AI score was captured
- [ ] Click "Filter: Score >= 75" → Execute Node
  - [ ] Job continues if score high enough
  - [ ] Job stops if score too low

**Test Cover Letter:**

- [ ] With a high-scoring job
- [ ] Click "Generate Cover Letter" → Execute Node
  - [ ] Returns 3-paragraph cover letter
  - [ ] Mentions specific company/role
  - [ ] Includes your GitHub link
  - [ ] Professional tone
  - [ ] No generic phrases

**Test Notification:**

- [ ] Run entire workflow (or use execute-from-here)
- [ ] Click "Send Email (Gmail)" → Execute Node
  - [ ] Email sends successfully
  - [ ] Check your inbox
  - [ ] HTML renders correctly
  - [ ] All job cards visible
  - [ ] Cover letters expandable
  - [ ] "Apply Now" links work

---

## 📋 Phase 5: Full Workflow Test (Day 2)

### Manual Execution

- [ ] Workflow is still INACTIVE (don't schedule yet)
- [ ] Click "Execute Workflow" button (top right)
- [ ] Wait for completion (may take 5-15 minutes)
- [ ] Check execution results:
  - [ ] No errors in any node
  - [ ] Jobs were discovered
  - [ ] Jobs were evaluated
  - [ ] High-match jobs generated cover letters
  - [ ] Notification was sent

### Review Output

- [ ] Check your email/Slack/Telegram
- [ ] Received job digest
- [ ] Check quality of matches:
  - [ ] Jobs are actually relevant (Java/Spring Boot)
  - [ ] Correct location (remote/your location)
  - [ ] Match scores seem accurate
  - [ ] Cover letters are specific (not generic)

### Adjust Thresholds if Needed

**If too many jobs (>20):**

- [ ] Increased match score threshold to 80
- [ ] Added stricter keyword filters
- [ ] Re-test

**If too few jobs (<3):**

- [ ] Decreased match score threshold to 70
- [ ] Broadened search keywords
- [ ] Added more job sources
- [ ] Re-test

**If AI scores seem off:**

- [ ] Reviewed AI prompt
- [ ] Made skills list more accurate
- [ ] Added examples to prompt
- [ ] Re-test

---

## 📋 Phase 6: Deployment (Day 3)

### Final Configuration

- [ ] Match score threshold finalized (75 recommended)
- [ ] Search keywords optimized
- [ ] Your profile info is accurate
- [ ] AI prompts tested and working
- [ ] Notification channel working

### Schedule Setup

- [ ] Opened "Daily Schedule (8 AM)" trigger node
- [ ] Schedule is pre-configured as cron: `0 8 * * 1-5` (Mon-Fri at 8 AM)
- [ ] Verify the cron expression shows in the "Expression" field
- [ ] **Set Timezone to: IST (Asia/Kolkata)** in the node settings
- [ ] Saved node
- [ ] _(Optional: change `1-5` to `_` in cron if you want weekends too)\*

### Activate Workflow

- [ ] **IMPORTANT:** Double-checked all credentials are set
- [ ] Clicked workflow toggle at top (Inactive → Active)
- [ ] Status shows "Active" with green indicator
- [ ] Next execution time shows correctly

### Monitor First Scheduled Run

**Next morning (or at scheduled time):**

- [ ] Check if workflow executed (Executions tab)
- [ ] Review execution details
- [ ] Confirm notification received
- [ ] Verify job quality

---

## 📋 Phase 7: Ongoing Maintenance

### Weekly Tasks

- [ ] **Week 1:** Review match quality
  - [ ] Are scores accurate?
  - [ ] Getting good jobs?
  - [ ] Adjust threshold if needed
- [ ] **Week 2:** Check API usage
  - [ ] Any rate limit errors?
  - [ ] OpenAI costs reasonable?
  - [ ] All sources still working?
- [ ] **Week 3:** Track application results
  - [ ] How many interviews from applications?
  - [ ] Which sources yield best results?
  - [ ] Disable low-quality sources
- [ ] **Week 4:** Optimize workflow
  - [ ] Refine AI prompts based on results
  - [ ] Update your profile with new skills
  - [ ] Adjust search keywords

### Monthly Tasks

- [ ] **Month 1:**
  - [ ] Review total jobs discovered
  - [ ] Calculate application → interview rate
  - [ ] Update YOUR-PROFILE.md with any new skills/projects
  - [ ] Audit OpenAI costs (should be <$5/month with gpt-4o-mini; ~₹400/month)

- [ ] **Month 2:**
  - [ ] Analyze which job sources are most effective
  - [ ] Consider adding more sources or removing low-quality ones
  - [ ] Review and improve cover letter templates
  - [ ] Check for N8N updates: `docker pull n8nio/n8n`

- [ ] **Month 3:**
  - [ ] Rotate API keys (security best practice)
  - [ ] Review and update job preferences
  - [ ] Consider advanced features (database tracking, Google Sheets)

---

## 📋 Success Metrics Tracking

### Track These Numbers:

**Week 1:**

- Jobs discovered per day: \_\_\_
- Jobs after AI filter: \_\_\_
- Applications submitted: \_\_\_
- Time spent reviewing: \_\_\_ minutes/day

**Week 2:**

- Interview requests received: \_\_\_
- Application → Interview rate: \_\_\_\_%
- Most effective job source: \***\*\_\_\_\*\***

**Week 4:**

- Total applications submitted: \_\_\_
- Total interviews: \_\_\_
- Offers received: \_\_\_
- Time saved vs manual search: \_\_\_ hours

### Target Metrics:

- ✅ 5-15 high-quality matches per day
- ✅ <30 minutes review time per day
- ✅ >5% application → interview rate
- ✅ <$5/month OpenAI costs

---

## 🚨 Troubleshooting Checkpoints

**If workflow fails:**

- [ ] Checked execution logs (Executions tab)
- [ ] Reviewed error message
- [ ] Consulted TROUBLESHOOTING.md
- [ ] Checked N8N logs: `docker logs n8n --tail 50`
- [ ] Verified all credentials still valid
- [ ] Tested problem node individually

**If no jobs found:**

- [ ] Tested each API source individually
- [ ] Verified API keys are correct
- [ ] Checked search keywords aren't too narrow
- [ ] Reviewed job sources in browser manually

**If AI scores seem wrong:**

- [ ] Manually reviewed a few job descriptions
- [ ] Verified your profile info in AI prompt is accurate
- [ ] Tested with known good/bad job descriptions
- [ ] Considered adjusting scoring criteria in prompt

**If costs are high:**

- [ ] Checked OpenAI usage dashboard
- [ ] Verified using `gpt-4o-mini` not `gpt-4o`
- [ ] Confirmed job descriptions are truncated
- [ ] Reviewed number of jobs being evaluated daily

---

## 🎉 Completion

### Final Checklist:

- [ ] ✅ Workflow running daily without errors
- [ ] ✅ Receiving quality job matches
- [ ] ✅ Cover letters are specific and useful
- [ ] ✅ Application → interview rate is healthy (>5%)
- [ ] ✅ Time saved is significant (90%+)
- [ ] ✅ Costs are reasonable (<$10/month)
- [ ] ✅ Tracking applications and results

### Optional Enhancements to Consider:

- [ ] Add Google Sheets tracking
- [ ] Set up PostgreSQL database for historical data
- [ ] Create analytics dashboard
- [ ] Implement company research automation
- [ ] Add salary filtering
- [ ] Set up interview tracking
- [ ] Create application follow-up automation

---

## 📝 Notes & Issues

**Document any problems or customizations here:**

```
Date: ___________
Issue:
Solution:

Date: ___________
Customization:
Result:
```

---

## 🆘 Need Help?

- [ ] Reviewed TROUBLESHOOTING.md
- [ ] Checked N8N Community forums
- [ ] Consulted API documentation
- [ ] Reviewed workflow execution logs
- [ ] Still stuck? Document your issue:
  - Error message:
  - What you've tried:
  - N8N version:
  - Node that's failing:

---

**Congratulations!** If you've checked off everything above, your Job Hunting Co-Pilot is fully operational! 🚀

**Next Steps:**

1. Let it run for a week
2. Track your metrics
3. Optimize based on results
4. Apply to jobs with confidence!

**Good luck with your job hunt!** 🎯💼
