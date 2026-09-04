param(
    [string]$GitHubUser = "deeepakb016",
    [string]$RepoName = $(Split-Path -Leaf (Get-Location)),
    [string]$BranchName = "feature/ci-setup",
    [string]$CommitMessage = "CI: add Makefile, workflow, and test infra"
)

function RunCmd($cmd) {
    Write-Host "> $cmd"
    $proc = Start-Process -FilePath powershell -ArgumentList "-NoProfile -Command $cmd" -NoNewWindow -Wait -PassThru
    return $proc.ExitCode
}

# Ensure git is available
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "git not found in PATH. Install Git and re-run this script." -ForegroundColor Red
    exit 1
}

# Initialize repo if needed
if (-not (Test-Path ".git")) {
    Write-Host "Not a git repo — initializing"
    git init
}

# Ensure main branch exists
if (-not (git show-ref --verify --quiet refs/heads/main)) {
    try { git checkout -b main } catch { }
}

# Create or switch to branch
git checkout -B $BranchName

# Stage and commit
git add -A
$commit = git commit -m "$CommitMessage" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Commit may have failed or nothing to commit. Message: $commit"
} else {
    Write-Host "Committed changes"
}

# Add fork remote if missing
$remoteName = "fork"
$existing = git remote | Select-String -Pattern "^$remoteName$"
if (-not $existing) {
    $forkUrl = "https://github.com/$GitHubUser/$RepoName.git"
    Write-Host "Adding remote '$remoteName' -> $forkUrl"
    git remote add $remoteName $forkUrl
} else {
    Write-Host "Remote '$remoteName' already exists"
}

# Push branch
Write-Host "Pushing branch '$BranchName' to remote '$remoteName'"
git push --set-upstream $remoteName $BranchName
if ($LASTEXITCODE -ne 0) {
    Write-Host "Push failed. Try running the script again after resolving remote/auth issues." -ForegroundColor Red
    exit 2
}

# Create PR using gh if available
if (Get-Command gh -ErrorAction SilentlyContinue) {
    Write-Host "Creating PR with gh..."
    gh pr create --base main --head "${GitHubUser}:$BranchName" --title "$CommitMessage" --body "Automated PR: add CI workflow and Makefile" --fill
    if ($LASTEXITCODE -ne 0) { Write-Host "gh pr create failed or cancelled" -ForegroundColor Yellow }
} else {
    Write-Host "gh (GitHub CLI) not found. Install it or create a PR in the web UI: https://github.com/$GitHubUser/$RepoName/compare" -ForegroundColor Yellow
}

Write-Host "Done. If CI runs, use 'gh run list' to find the run and 'gh run download <run-id> --dir reports' to fetch artifacts."