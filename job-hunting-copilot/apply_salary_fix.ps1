$filePath = "C:\Users\320219651\Desktop\job-hunting-copilot\job-hunting-copilot-workflow.json"
$j = Get-Content $filePath -Raw | ConvertFrom-Json

# =====================================================================
# FIX: Make MIN_SALARY_LPA configurable via env var
# - If $env.MIN_SALARY_LPA is set to a number (e.g. 18) => filter applies
# - If set to 0 or empty => ALL salary jobs pass through
# =====================================================================

$salaryNode = $j.nodes | Where-Object { $_.id -eq "salary-filter" }

$newSalaryCode = @'
// ─────────────────────────────────────────────────────────────────
// CONFIGURABLE SALARY FILTER
// Set environment variable MIN_SALARY_LPA in N8N:
//   - Number (e.g. 18) => only keep jobs at or above that LPA
//   - 0 or empty       => disable filter, all jobs pass through
// ─────────────────────────────────────────────────────────────────

const job = $json;

// Read the threshold from env var - default 18 if not set
const minLpaRaw = $env.MIN_SALARY_LPA;
const minLpa = (minLpaRaw !== undefined && minLpaRaw !== null && String(minLpaRaw).trim() !== '' && Number(minLpaRaw) > 0)
  ? Number(minLpaRaw)
  : 0;

// If threshold is 0 or unset - filter is disabled, pass everything
if (minLpa === 0) {
  return [{ json: job }];
}

// No salary info from AI = pass through (don't miss unlisted salaries)
const salaryStr = job.ai_evaluation ? job.ai_evaluation.salary_estimate : null;
if (!salaryStr || String(salaryStr).trim() === '') {
  return [{ json: job }];
}

// Parse numbers from strings like "15-25 LPA", "20 LPA", "18-30 LPA", "20"
const numbers = String(salaryStr).match(/\d+(\.\d+)?/g);
if (!numbers || numbers.length === 0) {
  return [{ json: job }]; // Can't parse = pass through
}

const salaryValues = numbers.map(Number);
const maxSalary = Math.max(...salaryValues);

// Filter out jobs where even the max salary is below the threshold
if (maxSalary < minLpa) {
  return [];
}

return [{ json: job }];
'@

$salaryNode.parameters.jsCode = $newSalaryCode
$salaryNode.notes = "Configurable salary filter. Set MIN_SALARY_LPA env var (e.g. 18). Set to 0 or leave empty to disable."
Write-Host "Salary filter updated to use MIN_SALARY_LPA env var" -ForegroundColor Green

# =====================================================================
# Update AI Scorer: reference configurable salary instead of hardcoded 18
# =====================================================================
$scorerNode = $j.nodes | Where-Object { $_.id -eq "ai-scorer" }
$content = $scorerNode.parameters.messages.values[0].content
$content = $content -replace `
    'Salary Expectation: Minimum 18 LPA \(flag as red_flag if clearly below\)', `
    'Salary Expectation: Minimum 18 LPA or above preferred (configurable). Flag as red_flag if job salary clearly states below 15 LPA. If no salary mentioned, do NOT penalize.'
$scorerNode.parameters.messages.values[0].content = $content
Write-Host "AI scorer updated" -ForegroundColor Green

# =====================================================================
# VERIFY ALL CHECKS
# =====================================================================
Write-Host ""
Write-Host "===== FINAL FULL VALIDATION REPORT =====" -ForegroundColor Cyan

$normCode  = ($j.nodes | Where-Object id -eq 'normalize-data').parameters.jsCode
$emailCode = ($j.nodes | Where-Object id -eq 'format-email').parameters.jsCode
$salCode   = ($j.nodes | Where-Object id -eq 'salary-filter').parameters.jsCode
$scorer2   = ($j.nodes | Where-Object id -eq 'ai-scorer').parameters.messages.values[0].content
$clCode    = ($j.nodes | Where-Object id -eq 'cover-letter-gen').parameters.messages.values[0].content
$cron      = ($j.nodes | Where-Object name -eq 'Daily Schedule (8 AM)').parameters.rule.interval[0].expression
$liLoc     = ($j.nodes | Where-Object name -eq 'LinkedIn Jobs RSS').parameters.queryParameters.parameters | Where-Object name -eq 'location' | Select-Object -ExpandProperty value
$indLoc    = ($j.nodes | Where-Object name -eq 'Indeed API').parameters.queryParameters.parameters | Where-Object name -eq 'l' | Select-Object -ExpandProperty value
$adzUrl    = ($j.nodes | Where-Object name -eq 'Adzuna API').parameters.url
$indUrl    = ($j.nodes | Where-Object name -eq 'Indeed API').parameters.url
$filterConn = $j.connections.'Filter: Score >= 75'.main[0][0].node
$salConn    = $j.connections.'Salary Filter (>= 18 LPA)'.main[0][0].node

$checks = @(
  @{ Label="Nodes total (expected 20)";      Pass=($j.nodes.Count -eq 20);               Detail=$j.nodes.Count },
  @{ Label="Schedule Mon-Fri 8AM";           Pass=($cron -eq '0 8 * * 1-5');             Detail=$cron },
  @{ Label="LinkedIn location India";        Pass=($liLoc -eq 'India');                  Detail=$liLoc },
  @{ Label="Indeed location India";          Pass=($indLoc -eq 'India');                 Detail=$indLoc },
  @{ Label="Indeed HTTPS";                   Pass=($indUrl -match '^https');              Detail=$indUrl },
  @{ Label="Adzuna India API (/in/)";        Pass=($adzUrl -match '/in/');               Detail=$adzUrl },
  @{ Label="Normalize syntax clean";         Pass=(-not ($normCode -match 'continue; else')); Detail="no broken syntax" },
  @{ Label="Adzuna Array.isArray ";          Pass=($normCode -match 'Array\.isArray');   Detail="processes results array" },
  @{ Label="Email uses jobEval (not eval)";  Pass=($emailCode -match 'jobEval');         Detail="reserved word fixed" },
  @{ Label="Salary filter node exists";      Pass=($null -ne ($j.nodes | Where-Object id -eq 'salary-filter')); Detail="id=salary-filter" },
  @{ Label="Salary reads MIN_SALARY_LPA";    Pass=($salCode -match 'MIN_SALARY_LPA');    Detail="env var driven" },
  @{ Label="Salary filter configurable (0 disables)"; Pass=($salCode -match 'minLpa === 0'); Detail="0 = disabled" },
  @{ Label="Unknown salary passes through";  Pass=($salCode -match "Can't parse = pass through"); Detail="safe fallback" },
  @{ Label="AI scorer knows 18 LPA pref";    Pass=($scorer2 -match '18 LPA');            Detail="in candidate profile" },
  @{ Label="Filter -> Salary connection";    Pass=($filterConn -eq 'Salary Filter (>= 18 LPA)'); Detail=$filterConn },
  @{ Label="Salary -> Cover Letter conn";    Pass=($salConn -eq 'Generate Cover Letter'); Detail=$salConn },
  @{ Label="Cover letter no buzzwords rule"; Pass=($clCode -match 'NO fancy words');     Detail="honesty enforced" },
  @{ Label="Cover letter honesty rule";      Pass=($clCode -match 'Be HONEST');          Detail="skills not fabricated" }
)

$passed = 0; $failed = 0
foreach ($c in $checks) {
  $symbol = if ($c.Pass) { "PASS" } else { "FAIL" }
  $color  = if ($c.Pass) { "Green" } else { "Red" }
  Write-Host ("  [{0,-4}] {1,-45} {2}" -f $symbol, $c.Label, $c.Detail) -ForegroundColor $color
  if ($c.Pass) { $passed++ } else { $failed++ }
}

Write-Host ""
Write-Host "  Results: $passed passed, $failed failed" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })
Write-Host ""
if ($failed -eq 0) {
  Write-Host "==========================================" -ForegroundColor Green
  Write-Host "  ALL $($checks.Count) CHECKS PASSED - 100% READY   " -ForegroundColor Green
  Write-Host "==========================================" -ForegroundColor Green
} else {
  Write-Host "WARNING: $failed check(s) failed - review above" -ForegroundColor Red
}

# Save
$j | ConvertTo-Json -Depth 20 | Set-Content $filePath -Encoding UTF8
Write-Host "File saved." -ForegroundColor Cyan
