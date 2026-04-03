# 📡 Job API Sources - Complete Reference

**Detailed documentation on accessing job board APIs and RSS feeds**

---

## Table of Contents

1. [LinkedIn Jobs (RSS Method)](#1-linkedin-jobs-rss-method)
2. [Indeed Publisher API](#2-indeed-publisher-api)
3. [Adzuna API](#3-adzuna-api)
4. [RemoteOK API](#4-remoteok-api)
5. [Remotive API](#5-remotive-api)
6. [GitHub Jobs Alternatives](#6-github-jobs-alternatives)
7. [Stack Overflow Jobs](#7-stack-overflow-jobs)
8. [WeWorkRemotely RSS](#8-weworkremotely-rss)
9. [AngelList/Wellfound](#9-angeli stwellfound)
10. [Custom Company Career Pages](#10-custom-company-career-pages)

---

## 1. LinkedIn Jobs (RSS Method)

### ⚠️ Important: WHY NOT SCRAPING?

**DO NOT USE:**

- ❌ Selenium/Puppeteer automated browser
- ❌ LinkedIn's private APIs
- ❌ Login-required scraping
- ❌ Any method requiring authentication

**These WILL get your account permanently banned.**

### ✅ SAFE METHOD: Public RSS Feeds

LinkedIn exposes job search results as RSS-like feeds **without requiring login**.

---

### How to Get Your Custom Feed URL

**Step 1: Manual Search on LinkedIn**

1. Go to: https://www.linkedin.com/jobs/
2. In search box, enter: `Java Spring Boot`
3. Set filters:
   - **Location:** Your location or "Remote"
   - **Experience Level:** Entry, Mid-Senior, Director
   - **Date Posted:** Past 24 hours
   - **Job Type:** Full-time
   - **On-site/Remote:** Remote, Hybrid

**Step 2: Copy the URL**

After setting filters, your URL will look like:

```
https://www.linkedin.com/jobs/search/?keywords=Java%20Spring%20Boot&location=United%20States&f_TPR=r86400&f_E=3,4&f_JT=F
```

**Parameters Explained:**

- `keywords=Java%20Spring%20Boot` - Search query (URL encoded)
- `location=United%20States` - Location filter
- `f_TPR=r86400` - Time posted filter (r86400 = past 24 hours)
  - `r604800` = past week
  - `r2592000` = past month
- `f_E=3,4` - Experience level
  - `2` = Entry level
  - `3` = Associate
  - `4` = Mid-Senior
  - `5` = Director
  - `6` = Executive
- `f_JT=F` - Job type
  - `F` = Full-time
  - `P` = Part-time
  - `C` = Contract
- `f_WT=2` - Remote filter
  - `1` = On-site
  - `2` = Remote
  - `3` = Hybrid

**Step 3: Convert to API URL**

Replace the URL with the API endpoint:

```
https://www.linkedin.com/jobs-guest/jobs/api/seeMoreJobPostings/search?keywords=Java%20Spring%20Boot&location=United%20States&f_TPR=r86400&f_E=3,4&start=0
```

**Pagination:**

- `start=0` - First page (jobs 0-25)
- `start=25` - Second page (jobs 25-50)
- `start=50` - Third page (jobs 50-75)

---

### N8N Implementation

**Node Type:** HTTP Request

```javascript
{
  "method": "GET",
  "url": "https://www.linkedin.com/jobs-guest/jobs/api/seeMoreJobPostings/search",
  "queryParameters": {
    "keywords": "Java Spring Boot",
    "location": "United States",
    "f_TPR": "r86400",
    "f_E": "3,4",
    "f_WT": "2",
    "start": "0"
  },
  "options": {
    "response": {
      "response": {
        "fullResponse": false,
        "contentType": "html"
      }
    }
  }
}
```

**Response Format:** HTML (not JSON)

**Parsing Strategy:**
Use N8N's HTML Extract node or Code node with cheerio:

```javascript
// N8N Code Node
const cheerio = require('cheerio');
const $ = cheerio.load($input.item.json.data);

const jobs = [];

$('li').each((i, elem) => {
  const $elem = $(elem);

  const job = {
    job_id:
      $elem
        .find('div[data-entity-urn]')
        .attr('data-entity-urn')
        ?.split(':')
        .pop() || '',
    title: $elem.find('.base-search-card__title').text().trim(),
    company: $elem.find('.base-search-card__subtitle').text().trim(),
    location: $elem.find('.job-search-card__location').text().trim(),
    url: $elem.find('.base-card__full-link').attr('href') || '',
    snippet: $elem.find('.base-search-card__snippet').text().trim(),
    posted_date: $elem.find('time').attr('datetime') || '',
    source: 'linkedin',
  };

  if (job.title && job.company) {
    jobs.push({ json: job });
  }
});

return jobs;
```

---

### Rate Limiting

**LinkedIn's Limits:**

- ~1 request per 2-3 seconds is safe
- Max ~500 requests per day from same IP
- Use delays between requests

**N8N Rate Limit Node:**

- Add "Wait" node: 3 seconds between requests
- Or use "Split In Batches" with delay

---

### Getting Full Job Description

The RSS feed only gives snippets. For full description:

**Method 1: Direct Job URL Fetch**

```javascript
// After getting job list with URLs
const jobUrl = $json.url;
const fullDescription = await fetch(jobUrl)
  .then((res) => res.text())
  .then((html) => {
    const $ = cheerio.load(html);
    return $('.show-more-less-html__markup').text().trim();
  });
```

**Method 2: Use "Browse AI" (No-Code Scraper)**

- Service: https://browse.ai
- Free tier: 50 scrapes/month
- No coding needed

---

## 2. Indeed Publisher API

### Registration

**URL:** https://ads.indeed.com/jobroll/xmlfeed

**Application Process:**

1. Fill out publisher application form
2. Provide website URL (you can use your GitHub profile)
3. State purpose: "Job aggregation for personal use"
4. Approval time: 1-2 business days
5. Receive Publisher ID via email

**Cost:** Free (rate-limited to 1000 calls/day)

---

### API Documentation

**Base URL:**

```
http://api.indeed.com/ads/apisearch
```

**Required Parameters:**

- `publisher` - Your publisher ID
- `v` - API version (use `2`)
- `format` - Response format (`json` or `xml`)

**Search Parameters:**

```javascript
{
  publisher: "YOUR_PUBLISHER_ID", // Required
  v: "2",                          // Required
  format: "json",                  // Required

  // Search filters
  q: "java spring boot",           // Keywords
  l: "remote",                     // Location (or city name)
  sort: "date",                    // Sort by date posted
  radius: "25",                    // Miles from location (0-50)
  st: "jobsite",                   // Site type
  jt: "fulltime",                  // Job type: fulltime, parttime, contract, internship, temporary
  start: "0",                      // Pagination (0, 10, 20...)
  limit: "25",                     // Results per page (max 25)
  fromage: "1",                    // Days ago (1=last 24 hours, 7=last week)
  highlight: "0",                  // Highlight keywords (0=no, 1=yes)
  filter: "1",                     // Duplicate filtering (1=yes)
  latlong: "1",                    // Include coordinates (1=yes)
  co: "us",                        // Country code (us, uk, ca, etc.)

  // Salary filter (optional)
  salary: "80000",                 // Minimum salary

  // Company filter (optional)
  company: "google",               // Specific company
}
```

---

### Full Example URL

```
http://api.indeed.com/ads/apisearch?publisher=1234567890123456&q=java+spring+boot&l=remote&sort=date&radius=25&st=jobsite&jt=fulltime&start=0&limit=25&fromage=1&filter=1&latlong=1&co=us&format=json&v=2
```

---

### Response Format

```json
{
  "version": 2,
  "query": "java spring boot",
  "location": "remote",
  "totalResults": 1543,
  "start": 0,
  "end": 24,
  "pageNumber": 0,

  "results": [
    {
      "jobtitle": "Senior Java Developer",
      "company": "Tech Corp",
      "city": "New York",
      "state": "NY",
      "country": "US",
      "formattedLocation": "New York, NY",
      "source": "Tech Corp Careers",
      "date": "Mon, 01 Apr 2026 00:00:00 GMT",
      "snippet": "We are looking for experienced Java Spring Boot developer...",
      "url": "https://www.indeed.com/viewjob?jk=abc123",
      "onmousedown": "indeed_clk(this,'1234');",
      "latitude": 40.7128,
      "longitude": -74.006,
      "jobkey": "abc123",
      "sponsored": false,
      "expired": false,
      "formattedLocationFull": "New York, NY 10001",
      "formattedRelativeTime": "30+ days ago"
    }
  ]
}
```

---

### N8N Implementation

```javascript
// HTTP Request Node Configuration
{
  "method": "GET",
  "url": "http://api.indeed.com/ads/apisearch",
  "qs": {
    "publisher": "={{$env.INDEED_PUBLISHER_ID}}",
    "q": "java spring boot",
    "l": "remote",
    "sort": "date",
    "jt": "fulltime",
    "fromage": "1",
    "limit": "25",
    "format": "json",
    "v": "2"
  }
}

// Then use "Item Lists" node to split results array
```

---

### Rate Limits

**Free Tier:**

- 1000 API calls per day
- No per-second limit specified
- Be respectful: 1 call per 2 seconds is safe

**Monitoring Usage:**

- Indeed doesn't provide a usage dashboard
- Track manually in your N8N database
- Set up alerts if approaching limit

---

### Getting Full Job Description

Indeed API doesn't provide full descriptions. Options:

**Option 1: Accept snippet (recommended)**

- Snippet is usually 150-200 words
- Often enough for AI evaluation

**Option 2: Fetch full job page**

- Use `url` field from API response
- HTTP Request to that URL
- Parse HTML (similar to LinkedIn method)
- **Warning:** This counts separately from API calls

---

## 3. Adzuna API

### Registration

**URL:** https://developer.adzuna.com/

**Process:**

1. Click "Register for API Access"
2. Fill form (free account)
3. Instant approval
4. Receive App ID and App Key via email

**Coverage:** US, UK, AU, DE, FR, NL, AT, CH, BE, IN, SG, PL, ZA, CA

**Cost:** Free tier: 1000 calls/month

---

### API Documentation

**Base URL:**

```
https://api.adzuna.com/v1/api/jobs/{country}/search/{page}
```

**Path Parameters:**

- `{country}` - Country code: `us`, `gb`, `au`, `de`, etc.
- `{page}` - Page number (starts at 1)

**Query Parameters:**

```javascript
{
  app_id: "YOUR_APP_ID",           // Required
  app_key: "YOUR_APP_KEY",         // Required
  results_per_page: "50",          // Max 50
  what: "java spring boot",        // Keywords
  where: "remote",                 // Location
  sort_by: "date",                 // date, relevance, salary
  max_days_old: "1",               // Filter by age (days)
  salary_min: "80000",             // Minimum salary
  salary_max: "150000",            // Maximum salary
  full_time: "1",                  // 1=yes, 0=no
  part_time: "0",                  // 1=yes, 0=no
  contract: "0",                   // 1=yes, 0=no
  permanent: "1",                  // 1=yes, 0=no
  category: "it-jobs",             // Job category
}
```

---

### Complete Example URL

```
https://api.adzuna.com/v1/api/jobs/us/search/1?app_id=12345678&app_key=abcdef1234567890abcdef1234567890&results_per_page=50&what=java%20spring%20boot&where=remote&sort_by=date&max_days_old=1&full_time=1
```

---

### Response Format

```json
{
  "count": 1234,
  "mean": 95000.5,
  "results": [
    {
      "id": "3456789012",
      "created": "2026-04-01T10:30:00Z",
      "title": "Senior Java Spring Boot Engineer",
      "location": {
        "display_name": "Remote, USA",
        "area": ["USA"]
      },
      "description": "Full job description text here... We are seeking an experienced...",
      "company": {
        "display_name": "Tech Corp Inc"
      },
      "category": {
        "label": "IT Jobs",
        "tag": "it-jobs"
      },
      "salary_min": 90000,
      "salary_max": 120000,
      "salary_is_predicted": "0",
      "redirect_url": "https://www.adzuna.com/land/ad/3456789012?se=...",
      "contract_time": "full_time",
      "contract_type": "permanent"
    }
  ]
}
```

---

### N8N Implementation

```javascript
// HTTP Request Node
{
  "method": "GET",
  "url": "https://api.adzuna.com/v1/api/jobs/us/search/1",
  "qs": {
    "app_id": "={{$env.ADZUNA_APP_ID}}",
    "app_key": "={{$env.ADZUNA_APP_KEY}}",
    "results_per_page": "50",
    "what": "java spring boot",
    "where": "remote",
    "sort_by": "date",
    "max_days_old": "1"
  }
}
```

---

### Pagination

```javascript
// Loop through pages
for (let page = 1; page <= 5; page++) {
  const url = `https://api.adzuna.com/v1/api/jobs/us/search/${page}?...`;
  // Fetch page
  await wait(2000); // 2 second delay between pages
}
```

---

### Rate Limits

**Free Tier:**

- 1000 calls per month (~33/day)
- No per-second limit
- Be conservative: 1 call per 3 seconds

**Pro Tier ($50/month):**

- 10,000 calls per month
- Higher rate limits

---

## 4. RemoteOK API

**Best for:** 100% remote tech jobs

**URL:** https://remoteok.com/api

**Cost:** Free, no API key required

**Rate Limit:** ~1 request per 2 seconds

---

### Endpoint

```
https://remoteok.com/api
```

**Filtering:**

- Returns all jobs (no query parameters)
- Filter client-side by tag/keywords

**Example:**

```
https://remoteok.com/api?tag=java
```

---

### Response Format

```json
[
  {
    "id": "123456",
    "url": "https://remoteok.com/remote-jobs/123456",
    "position": "Senior Java Engineer",
    "company": "Tech Startup",
    "company_logo": "https://remoteok.com/assets/logo/abc.png",
    "tags": ["java", "spring", "aws", "docker"],
    "location": "Worldwide",
    "description": "Full job description HTML...",
    "date": "2026-04-01T10:00:00.000Z",
    "salary_min": "90000",
    "salary_max": "140000",
    "apply_url": "https://jobs.lever.co/company/..."
  }
]
```

---

### N8N Implementation

```javascript
// HTTP Request Node
{
  "method": "GET",
  "url": "https://remoteok.com/api",
  "options": {
    "headers": {
      "User-Agent": "JobCopilotBot/1.0 (your@email.com)"
    }
  }
}

// Code Node: Filter for Java jobs
const javaJobs = $input.all().filter(item => {
  const job = item.json;
  const tags = (job.tags || []).map(t => t.toLowerCase());
  const position = (job.position || '').toLowerCase();

  return tags.includes('java') ||
         tags.includes('spring') ||
         position.includes('java') ||
         position.includes('spring boot');
});

return javaJobs;
```

---

## 5. Remotive API

**Best for:** High-quality remote jobs (curated)

**URL:** https://remotive.com/api/remote-jobs

**Cost:** Free, no API key required

---

### Endpoint

```
GET https://remotive.com/api/remote-jobs?category=software-dev&search=java
```

**Parameters:**

- `category` - Job category (software-dev, devops, etc.)
- `search` - Keywords
- `limit` - Results per page

---

### Response Format

```json
{
  "0-legal-notice": "...",
  "job-count": 234,
  "jobs": [
    {
      "id": 123456,
      "url": "https://remotive.com/remote-jobs/software-dev/...",
      "title": "Senior Backend Engineer (Java)",
      "company_name": "StartupXYZ",
      "company_ logo": "...",
      "category": "Software Development",
      "job_type": "full-time",
      "publication_date": "2026-04-01",
      "candidate_required_location": "Worldwide",
      "salary": "$100k - $140k",
      "description": "Full description...",
      "tags": ["java", "spring-boot", "aws"]
    }
  ]
}
```

---

## 6. GitHub Jobs Alternatives

GitHub Jobs shut down in 2021. Alternatives:

### Himalayas Jobs API

**URL:** https://himalayas.app/jobs/api

Free, focuses on remote tech jobs.

### Arbeitnow API

**URL:** https://arbeitnow.com/api/job-board-api

Free, EU-focused but has international remote jobs.

---

## 7. Stack Overflow Jobs

**Note:** Stack Overflow Jobs marketplace closed in 2022.

**Alternative:** Use Stack Overflow Talent RSS (requires company account)

---

## 8. WeWorkRemotely RSS

**URL:** https://weworkremotely.com/

**RSS Feeds:**

```
# Programming jobs
https://weworkremotely.com/categories/remote-programming-jobs.rss

# Full-stack jobs
https://weworkremotely.com/categories/remote-full-stack-programming-jobs.rss

# Backend jobs
https://weworkremotely.com/categories/remote-back-end-programming-jobs.rss

# DevOps
https://weworkremotely.com/categories/remote-devops-sysadmin-jobs.rss
```

---

### N8N Implementation

```javascript
// RSS Feed Read Node
{
  "url": "https://weworkremotely.com/categories/remote-programming-jobs.rss"
}
```

**Response:** Standard RSS format, easy to parse with N8N

---

## 9. AngelList/Wellfound

**URL:** https://wellfound.com/

**API:** Recently removed public API access

**Alternative Method:** RSS feed by search

```
https://wellfound.com/role/l-software-engineer/skills/java.rss
```

---

## 10. Custom Company Career Pages

Target specific companies you'd love to work for:

### Method: RSS Feeds for Company Blogs

Many companies announce jobs on blogs with RSS:

```
# Examples
https://blog.stripe.com/feed
https://engineering.fb.com/feed/
https://blog.google/rss/
```

### Method: Use Common ATS Systems

**Greenhouse:**

```
https://boards-api.greenhouse.io/v1/boards/COMPANY/jobs
```

**Lever:**

```
https://api.lever.co/v0/postings/COMPANY?mode=json
```

**Workable:**

```
https://COMPANY.workable.com/api/v1/jobs
```

---

## Rate Limiting Best Practices

### N8N Rate Limit Configuration

**Add "Wait" nodes between API calls:**

```javascript
// Wait 2 seconds
{
  "amount": 2,
  "unit": "seconds"
}
```

**Or use "Split in Batches":**

- Batch size: 10
- Wait between batches: 30 seconds

---

## Cost Summary

| Source       | Cost | Rate Limit  | Jobs/Day |
| ------------ | ---- | ----------- | -------- |
| LinkedIn RSS | Free | ~500/day    | 100-200  |
| Indeed API   | Free | 1000/day    | 1000     |
| Adzuna API   | Free | 1000/month  | 30-50    |
| RemoteOK     | Free | Unlimited\* | 50-100   |
| Remotive     | Free | Unlimited   | 20-50    |
| WWR RSS      | Free | Unlimited   | 30-60    |

\*Be respectful with unlimited APIs - 1 call per 2-3 seconds

---

## Testing APIs

### Quick Test Script (PowerShell)

```powershell
# Test Indeed API
curl "http://api.indeed.com/ads/apisearch?publisher=YOUR_ID&q=java&l=remote&format=json&v=2&limit=1"

# Test Adzuna API
curl "https://api.adzuna.com/v1/api/jobs/us/search/1?app_id=YOUR_ID&app_key=YOUR_KEY&what=java&results_per_page=1"

# Test RemoteOK API
curl "https://remoteok.com/api"
```

---

**Next Steps:**

1. Register for APIs (Indeed, Adzuna)
2. Test each API in browser/Postman
3. Configure in N8N workflow
4. Set up rate limiting
5. Monitor daily for issues

---

All APIs tested as of April 2026. Check official documentation for updates.
