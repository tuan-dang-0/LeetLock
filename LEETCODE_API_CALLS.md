# LeetCode API Call Documentation

This document lists all LeetCode API calls made by the LeetLock app, when they occur, and what data they fetch.

## API Calls Summary

### 1. **Username Verification** (`verifyUsername`)
- **Location:** `LeetCodeService.swift`
- **GraphQL Query:** `getUserProfile`
- **When Called:**
  - During onboarding (OnboardingPage1.swift)
  - When changing username in Settings (SettingsView.swift)
- **Rate Limited:** Yes (1 second)
- **Data Fetched:** Verifies if a LeetCode username exists
- **Returns:** Boolean (true if username exists)

---

### 2. **Recent Submissions** (`fetchRecentSubmissions`)
- **Location:** `LeetCodeService.swift`
- **GraphQL Query:** `getRecentSubmissions`
- **When Called:**
  - Internally by `fetchDailyProgress()` and `getSubmissionHeatmap()`
  - Not called directly by views
- **Rate Limited:** Yes (1 second)
- **Data Fetched:** 
  - Problem title and slug
  - Submission timestamp
  - Status (Accepted, Wrong Answer, etc.)
  - Programming language
- **Limit:** 100 submissions (for daily progress) or 1000 (for heatmap)
- **Returns:** Array of Submission objects

---

### 3. **Daily Progress** (`fetchDailyProgress`)
- **Location:** `LeetCodeService.swift`
- **Called Internally By:** `ProgressService.updateDailyProgress()`
- **When Called:**
  - MainView.swift - on pull-to-refresh (swipe down on main page)
  - SettingsView.swift - after username change
- **Rate Limited:** Yes (1 second, via `fetchRecentSubmissions`)
- **Data Fetched:**
  - **Unique problems** solved today (filters by Accepted status and today's date)
  - Uses `Set(titleSlug)` to ensure only unique problems are counted
  - No duplicate submissions counted
- **Returns:** DailyProgressResult with:
  - `problemCount` - number of unique problems
  - `uniqueProblemSlugs` - array of problem identifiers
  - `verified` - always true

---

### 4. **Submission Heatmap** (`getSubmissionHeatmap`)
- **Location:** `LeetCodeService.swift`
- **When Called:**
  - HeatmapView.swift - on first appearance (task modifier)
  - HeatmapView.swift - on pull-to-refresh (refreshable modifier)
- **Rate Limited:** Yes (1 second, via `fetchRecentSubmissions`)
- **Data Fetched:**
  - Submission counts per day for the last 90+ days
  - Only counts Accepted submissions
  - Groups by date (start of day)
- **Limit:** Fetches last 1000 submissions
- **Returns:** Dictionary `[Date: Int]` mapping dates to submission counts

---

### 5. **Daily Question** (`getDailyQuestion`)
- **Location:** `LeetCodeService.swift`
- **GraphQL Query:** `questionOfToday`
- **When Called:**
  - NextProblemCarousel.swift - on view appear (fetches current day's problem)
- **Rate Limited:** Yes (1 second)
- **Data Fetched:**
  - Daily challenge problem title
  - Difficulty level
  - Date
  - Problem link
- **Returns:** DailyQuestion object

---

## API Call Triggers

### On App Launch
1. None automatically (only on user action)

### On Main Page Appear
1. None (removed auto-refresh to reduce API calls)

### On Pull-to-Refresh (Main Page)
1. `fetchDailyProgress()` → calls `fetchRecentSubmissions(limit: 100)`

### On Pull-to-Refresh (Heatmap)
1. `getSubmissionHeatmap()` → calls `fetchRecentSubmissions(limit: 1000)`

### On Settings Username Change
1. `verifyUsername()` - validates new username
2. `fetchDailyProgress()` - refreshes progress with new username

### On Next Problem Carousel Load
1. `getDailyQuestion()` - fetches today's daily challenge

---

## Rate Limiting

All API calls are rate-limited with a **1-second minimum interval** between requests via the `RateLimiter` actor. This prevents:
- API throttling by LeetCode
- 504 Gateway Timeout errors
- Request cancellations

---

## Unique Problem Counting

The app ensures **no duplicate submissions** are counted:

```swift
// In fetchDailyProgress()
let todaySubmissions = submissions.filter { submission in
    // Only Accepted submissions from today
    submission.statusDisplay == "Accepted" && submissionDay == today
}

// Use Set to get unique problems by titleSlug
let uniqueProblems = Set(todaySubmissions.map { $0.titleSlug })
```

**Example:**
- You solve "Two Sum" 5 times today → Counts as **1 problem**
- You solve "Two Sum", "Valid Parentheses", "Merge Two Lists" → Counts as **3 problems**

---

## Total API Calls Per Session

**Minimal Usage (typical day):**
1. Pull-to-refresh main page: 1 call
2. Daily problem load: 1 call
3. **Total: 2 calls**

**Heavy Usage (exploring app):**
1. Pull-to-refresh main page: 1 call
2. Pull-to-refresh heatmap: 1 call
3. Daily problem load: 1 call
4. Change username: 2 calls (verify + refresh)
5. **Total: 5 calls**

All calls respect the 1-second rate limit, so maximum request rate is **60 calls/minute** (though typical usage is much lower).
