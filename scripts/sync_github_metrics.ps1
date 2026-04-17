$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$dataPath = Join-Path $root "data/universities.json"
$readmePath = Join-Path $root "README.md"
$beginMarker = "<!-- BEGIN:repo-table -->"
$endMarker = "<!-- END:repo-table -->"
$minStars = 10
$minLastCommitAt = [DateTime]"2024-01-01T00:00:00Z"

function Get-GitHubJson {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $json = gh api $Path --header "Accept: application/vnd.github+json" --header "X-GitHub-Api-Version: 2022-11-28"
    if (-not $json) {
        throw "Empty response from gh api for $Path"
    }
    $json | ConvertFrom-Json
}

$syncedAt = [DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
$data = Get-Content $dataPath -Raw | ConvertFrom-Json -Depth 100

foreach ($school in $data) {
    $retainedTemplates = @()
    foreach ($template in $school.templates) {
        $repoInfo = Get-GitHubJson -Path "/repos/$($template.repo)"
        $commitInfo = Get-GitHubJson -Path "/repos/$($template.repo)/commits?per_page=1"
        $lastCommitAtUtc = ([DateTime]$commitInfo[0].commit.committer.date).ToUniversalTime()
        $lastCommitAt = $lastCommitAtUtc.ToString("yyyy-MM-ddTHH:mm:ssZ")
        $stars = [int]$repoInfo.stargazers_count

        $template | Add-Member -NotePropertyName github_metrics -NotePropertyValue ([pscustomobject]@{
            stars = $stars
            last_commit_at = $lastCommitAt
            last_synced_at = $syncedAt
        }) -Force

        if ($stars -ge $minStars -and $lastCommitAtUtc -ge $minLastCommitAt) {
            $retainedTemplates += $template
        }
    }

    $school.templates = @($retainedTemplates)
    if ($school.templates.Count -gt 0) {
        $school.status = "covered"
        $school.notes = "自动同步后仍满足收录门槛：stars >= $minStars，且最近一次提交时间在 2024-01-01 及之后。"
    }
    else {
        $school.status = "unverified"
        $school.notes = "当前没有 GitHub 仓库满足收录门槛：stars >= $minStars，且最近一次提交时间在 2024-01-01 及之后。"
    }
}

$data | ConvertTo-Json -Depth 100 | Set-Content $dataPath -Encoding utf8NoBOM

$rows = foreach ($school in $data) {
    foreach ($template in $school.templates) {
        [pscustomobject]@{
            school_name_zh = $school.school_name_zh
            repo = $template.repo
            url = $template.url
            stars = [int]$template.github_metrics.stars
            last_commit_date = ([string]$template.github_metrics.last_commit_at).Substring(0, 10)
        }
    }
}

$sortedRows = $rows | Sort-Object @{ Expression = "stars"; Descending = $true }, school_name_zh, repo
$coveredCount = ($data | Where-Object { $_.status -eq "covered" }).Count
$unverifiedCount = ($data | Where-Object { $_.status -eq "unverified" }).Count
$unverifiedSchools = $data | Where-Object { $_.status -eq "unverified" } | ForEach-Object { "- $($_.school_name_zh)" }

$tableLines = @(
    "| 学校 | 仓库 | Stars | 最近提交 |",
    "| --- | --- | ---: | --- |"
)

foreach ($row in $sortedRows) {
    $repoLabel = $row.repo
    $tableLines += "| {0} | [`{1}`]({2}) | {3} | {4} |" -f $row.school_name_zh, $repoLabel, $row.url, $row.stars, $row.last_commit_date
}

$tableMarkdown = ($tableLines -join "`n")
$readme = Get-Content $readmePath -Raw
$pattern = "(?s)$([regex]::Escape($beginMarker)).*?$([regex]::Escape($endMarker))"
$replacement = "$beginMarker`n$tableMarkdown`n$endMarker"
$coveredLine = "- 已收录至少一个仓库的学校数：``{0}``" -f $coveredCount
$unverifiedLine = "- 首轮检索后仍未确认的学校数：``{0}``" -f $unverifiedCount
$unverifiedBlock = "## 当前未确认学校`n`n{0}`n`n## 已确认仓库" -f ($unverifiedSchools -join "`n")
$updatedReadme = [regex]::Replace($readme, $pattern, $replacement)
$updatedReadme = [regex]::Replace($updatedReadme, '- 已收录至少一个仓库的学校数：`[0-9]+`', $coveredLine)
$updatedReadme = [regex]::Replace($updatedReadme, '- 首轮检索后仍未确认的学校数：`[0-9]+`', $unverifiedLine)
$updatedReadme = [regex]::Replace($updatedReadme, '- 跟踪学校数：`[0-9]+`', "- 跟踪学校数：``$($data.Count)``")
$updatedReadme = [regex]::Replace(
    $updatedReadme,
    "(?s)## 当前未确认学校\s+.*?\s+## 已确认仓库",
    $unverifiedBlock
)
$updatedReadme | Set-Content $readmePath -Encoding utf8NoBOM
