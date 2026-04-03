# 🚀 Job Hunting Co-Pilot (India-Focused)

**An intelligent N8N workflow that automates 90% of your job hunting work while staying compliant with platform terms of service.**

**🇮🇳 Configured for India job market** - searches Indian companies, startups, and MNC India offices.

---

## 🎯 What This Does (In Simple Terms)

Every morning at 8 AM, this workflow:

1. **Searches 5 job sites** → Finds Java/Spring Boot jobs in India
2. **AI filters bad matches** → Keeps only jobs that fit your skills (75+ match score)
3. **Writes simple cover letters** → Natural-sounding, not AI-like
4. **Emails you the results** → 10-15 high-quality job listings with:
   - Direct links to apply
   - Why each job matches your skills
   - Ready-to-use cover letter for each

**IMPORTANT:** This does NOT apply to jobs for you. It sends you an email with job links and cover letters. YOU still manually apply by clicking the links.

---

## ✅ What It Does

- ✅ **Discovers jobs** from LinkedIn India, Indeed India, Naukri (via Adzuna India), RemoteOK, WeWorkRemotely
- ✅ **AI-evaluates** each job against your specific skills (Java, Spring Boot, JPA, Docker, AWS)
- ✅ **Generates simple, natural** cover letters (not AI-sounding)
- ✅ **Sends daily email digest** with 10-15 high-match jobs ready for YOU to manually apply
- ❌ **Does NOT auto-submit** applications (you click links and apply yourself)

---

## ⚡ Quick Start

### Prerequisites

- [ ] **N8N installed** (Docker, NPM, or Cloud)
- [ ] **OpenAI API key** ($20 credit recommended)
- [ ] **Indeed Publisher ID** (free, 1-2 day approval)
- [ ] **Adzuna API credentials** (free, instant)
- [ ] **Gmail/Slack/Telegram** configured for notifications

### 5-Minute Setup

1. **Install N8N (Docker):**

   ```powershell
   docker pull n8nio/n8n
   docker run -it --rm --name n8n -p 5678:5678 -v n8n_data:/home/node/.n8n n8nio/n8n
   ```

   Open: http://localhost:5678

2. **Get API Keys:**
   - OpenAI: https://platform.openai.com/api-keys
   - Indeed: https://ads.indeed.com/jobroll/xmlfeed
   - Adzuna: https://developer.adzuna.com/

3. **Import Workflow:**
   - In N8N: Workflows → Import from File
   - Select: `job-hunting-copilot-workflow.json`

4. **Configure Credentials:**
   - OpenAI API
   - Gmail OAuth2 (or Slack/Telegram)
   - Set environment variables (INDEED_PUBLISHER_ID, ADZUNA_APP_ID, ADZUNA_APP_KEY)

5. **Fill Your Profile:**
   - Edit `YOUR-PROFILE.md` with your skills
   - Update AI prompts in workflow with your profile

6. **Test & Activate:**
   - Click "Execute Workflow" to test
   - Review results
   - Activate schedule trigger (daily at 8 AM)

**Done!** You'll receive daily job digests.

---

## 📚 Documentation

| File                                             | Description                                                           |
| ------------------------------------------------ | --------------------------------------------------------------------- |
| **[ROADMAP.md](ROADMAP.md)**                     | 📖 **START HERE** - Complete step-by-step guide explaining EVERYTHING |
| **[SETUP-GUIDE.md](SETUP-GUIDE.md)**             | 🛠️ Detailed installation and configuration instructions               |
| **[YOUR-PROFILE.md](YOUR-PROFILE.md)**           | 👤 Template for your professional profile (AI uses this)              |
| **[API-SOURCES.md](API-SOURCES.md)**             | 📡 How to access job board APIs and RSS feeds                         |
| **[COMPLIANCE-ETHICS.md](COMPLIANCE-ETHICS.md)** | ⚖️ Legal/ethical guidelines (MUST READ to avoid bans)                 |
| **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)**     | 🔧 Common issues and solutions                                        |
| `job-hunting-copilot-workflow.json`              | 🔄 N8N workflow file (import this)                                    |

---

## 🏗️ Architecture

```
Daily Trigger (8 AM)
    ↓
[Phase 1] Job Discovery (Parallel)
├── LinkedIn RSS
├── Indeed API
├── Adzuna API
├── RemoteOK API
└── WeWorkRemotely RSS
    ↓
[Phase 2] Normalize & Deduplicate
    ↓
[Phase 3] AI Evaluation (For Each Job)
├── Score against your profile (0-100)
└── Only continue if score >= 75
    ↓
[Phase 4] Generate Cover Letters
    ↓
[Phase 5] Send Digest
├── Gmail (HTML email)
├── Slack (channel post)
└── Telegram (message)
```

---

## 🎓 How It Works

### 1. Job Discovery (How We Find Jobs)

**LinkedIn (Safe Method):**

- Uses public RSS feed (no login required)
- URL: `https://www.linkedin.com/jobs-guest/jobs/api/seeMoreJobPostings/search`
- Safe from bans (no automation of clicking)

**Indeed:**

- Official Publisher API (free, 1000 calls/day)
- Requires Publisher ID (apply at ads.indeed.com)

**Adzuna:**

- Official API (free, 1000 calls/month)
- Covers US, UK, AU, DE, FR, etc.

**RemoteOK:**

- Public API (no auth needed)
- 100% remote tech jobs

**WeWorkRemotely:**

- RSS feed (no auth needed)
- Curated remote jobs

### 2. AI Evaluation (How We Score Jobs)

**Uses OpenAI GPT-4o to:**

- Read job description
- Compare against YOUR specific skills:
  - Java, Spring Boot, JPA, Security
  - Docker, AWS, Kafka
  - Your experience level
- Output structured JSON:
  ```json
  {
    "match_score": 85,
    "reasoning": "Perfect match: Spring Boot, AWS, Docker",
    "matched_skills": ["Java", "Spring Boot", "AWS"],
    "missing_skills": ["Kubernetes"],
    "recommendation": "apply"
  }
  ```

**Scoring Thresholds:**

- **90-100:** Perfect match - apply immediately
- **75-89:** Strong match - likely good fit
- **60-74:** Moderate match - review carefully
- **<60:** Poor match - skip

### 3. Cover Letter Generation

**AI writes customized 3-paragraph cover letters:**

- **Paragraph 1:** Why excited about THIS company
- **Paragraph 2:** Your relevant experience (with numbers)
- **Paragraph 3:** Call to action + GitHub link

**Example:**

> I'm excited to apply for the Senior Java Developer position at TechCorp. Your focus on
> building scalable microservices architecture with Spring Boot aligns perfectly with my
> experience designing distributed systems that handle 10K+ requests per second.
>
> In my current role, I've architected and deployed 12+ Spring Boot microservices on AWS
> ECS, implementing OAuth2.0 security patterns and Apache Kafka event streaming...

### 4. Daily Digest

**Beautiful HTML email with:**

- All high-match jobs (score >= 75)
- Match score and reasoning for each
- Matched/missing skills
- Generated cover letter (click to expand)
- Direct "Apply Now" buttons

**Also available via:**

- Slack channel post
- Telegram message
- Google Sheets log (optional)

---

## 💰 Cost Analysis

### Monthly Costs

| Service           | Cost        | Usage                                     |
| ----------------- | ----------- | ----------------------------------------- |
| **OpenAI API**    | ~$1-3/month | Using gpt-4o-mini (60 jobs/day evaluated) |
| **Indeed API**    | Free        | Up to 1000 calls/day                      |
| **Adzuna API**    | Free        | Up to 1000 calls/month                    |
| **All RSS feeds** | Free        | Unlimited                                 |
| **Notifications** | Free        | Gmail/Slack/Telegram                      |
| **N8N Cloud**     | $0-20/month | Self-hosted is free                       |

**Total: $1-25/month** (depending on OpenAI usage and N8N hosting)

### ROI Calculation

**Time Saved:**

- Traditional job hunting: 2-3 hours/day
- With this workflow: 15-30 minutes/day
- **Time saved: ~40 hours/month**

**Value at $50/hour: $2,000/month**  
**ROI: 6,600%** 🚀

---

## 🎯 Expected Results

### Daily Stats (Conservative Estimate)

- **Jobs Discovered:** 50-100
- **After Deduplication:** 40-80
- **Match Score > 75:** 5-15
- **Sent to You:** 5-15 high-quality opportunities

### Quality Improvements

- ✅ **No more missing jobs** - Automated daily coverage
- ✅ **Consistent quality** - Every application is tailored
- ✅ **Better targeting** - Only see jobs you're qualified for
- ✅ **Reduced fatigue** - Review 5-15 vs 50+ manual searches

---

## ⚠️ Important Warnings

### What NOT to Do

1. ❌ **NEVER** use automated clicking/form-filling on LinkedIn
2. ❌ **NEVER** exceed API rate limits (can get banned)
3. ❌ **NEVER** use Selenium/Puppeteer on LinkedIn
4. ❌ **NEVER** apply to jobs you're not qualified for
5. ❌ **NEVER** skip manual review before applying

### What TO Do

1. ✅ Always manually review before applying
2. ✅ Customize cover letters further if needed
3. ✅ Track which applications convert to interviews
4. ✅ Keep your profile updated
5. ✅ Respect rate limits and TOS

**Read [COMPLIANCE-ETHICS.md](COMPLIANCE-ETHICS.md) before deploying!**

---

## 🚀 Advanced Features (Optional)

### Add Database Tracking

Track all jobs in PostgreSQL:

- Application status tracking
- Interview funnel metrics
- Source effectiveness analysis
- Historical data

### Google Sheets Integration

Log all jobs to spreadsheet:

- Columns: Date | Title | Company | Score | Status | URL
- Easy filtering and sorting
- Share with career coach/mentor

### Salary Analysis

Add salary extraction and filtering:

- Only show jobs within salary range
- Track salary trends over time
- Negotiate better with data

### Company Research Agent

Automatically research companies:

- Glassdoor ratings
- Recent news
- Funding information
- Tech stack used

---

## 📊 Success Metrics

### Week 1-2: Baseline

- Total jobs discovered per day
- Average match score distribution
- Source effectiveness

### Week 3-4: Optimization

- Adjust match score threshold
- Refine AI prompts
- Add/remove sources

### Month 2+: Advanced

- Track application → interview conversion rate
- Identify best performing sources
- Optimize for your specific market

**Target Metrics:**

- Application → Interview: >5%
- Time spent reviewing: <30 min/day
- High-quality applications: 5-10/day

---

## 🤝 Contributing

Found a bug? Have an improvement?

1. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. Review [issues](https://github.com/your-repo/issues)
3. Create detailed issue with:
   - Error message
   - Steps to reproduce
   - N8N version
   - Workflow JSON (remove credentials)

---

## 📞 Support

- **N8N Community:** https://community.n8n.io
- **Documentation:** See files above
- **Troubleshooting:** [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

## 📜 License

This workflow is provided as-is for personal use.

**Legal Disclaimer:**

- You are responsible for complying with all API terms of service
- This tool should augment, not replace, your job hunting efforts
- Always manually review applications before submitting
- The authors are not liable for account bans or other consequences

---

## 🎉 Getting Started

**New to this?**

1. Read [ROADMAP.md](ROADMAP.md) - Complete guide (read this first!)
2. Follow [SETUP-GUIDE.md](SETUP-GUIDE.md) - Step-by-step setup
3. Customize [YOUR-PROFILE.md](YOUR-PROFILE.md) - Your skills
4. Review [COMPLIANCE-ETHICS.md](COMPLIANCE-ETHICS.md) - Stay safe
5. Import workflow and test!

**Experienced with N8N?**

1. Import `job-hunting-copilot-workflow.json`
2. Configure credentials (OpenAI, Gmail, APIs)
3. Update AI prompts with your profile
4. Test and activate

---

## 📈 Roadmap

**v1.0 (Current):**

- ✅ Multi-source job discovery
- ✅ AI evaluation
- ✅ Cover letter generation
- ✅ Email/Slack/Telegram notifications

**v1.1 (Planned):**

- [ ] Google Sheets tracking
- [ ] Duplicate detection across workflow runs
- [ ] Salary extraction and filtering
- [ ] Interview preparation mode

**v2.0 (Future):**

- [ ] Company research automation
- [ ] Network graph (who do you know at company?)
- [ ] Application follow-up scheduler
- [ ] Interview tracking and prep

---

## 🙏 Acknowledgments

Built with:

- **N8N** - Workflow automation platform
- **OpenAI GPT-4** - AI evaluation and content generation
- **Job Board APIs** - Indeed, Adzuna, RemoteOK, etc.

Inspired by the need to work smarter, not harder, in the job hunt.

---

## 📝 Quick Links

- [Complete Roadmap](ROADMAP.md) ← **Start here if new**
- [Setup Guide](SETUP-GUIDE.md)
- [Your Profile Template](YOUR-PROFILE.md)
- [API Documentation](API-SOURCES.md)
- [Compliance & Ethics](COMPLIANCE-ETHICS.md)
- [Troubleshooting](TROUBLESHOOTING.md)

---

**Ready to revolutionize your job hunt?** Start with [ROADMAP.md](ROADMAP.md)!

**Questions?** Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) or [open an issue](#).

**Good luck!** 🚀💼
