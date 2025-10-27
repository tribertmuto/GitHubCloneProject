# Feature Branch Creation Checker (PowerShell)
# This script checks if a feature branch can be created or switched to,
# handling common Git branch issues and providing clear error messages.

param(
    [Parameter(Mandatory=$true)]
    [string]$BranchName
)

# Function to print colored output
function Write-Error-Output {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-Success-Output {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning-Output {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Info-Output {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

# Function to check if we're in a git repository
function Test-IsGitRepository {
    try {
        $null = git rev-parse --git-dir 2>$null
        return $true
    }
    catch {
        return $false
    }
}

# Function to check for uncommitted changes
function Test-HasUncommittedChanges {
    try {
        $status = git status --porcelain
        return $status -ne ""
    }
    catch {
        return $false
    }
}

# Function to get current branch
function Get-CurrentBranch {
    try {
        return git branch --show-current 2>$null
    }
    catch {
        return ""
    }
}

# Function to check if branch exists
function Test-BranchExists {
    param([string]$BranchName)
    
    try {
        # Check local branches
        $localBranches = git branch --list $BranchName 2>$null
        if ($localBranches) { return $true }
        
        # Check remote branches
        $remoteBranches = git branch -r --list "origin/$BranchName" 2>$null
        if ($remoteBranches) { return $true }
        
        return $false
    }
    catch {
        return $false
    }
}

# Function to check feature branch
function Test-FeatureBranch {
    param([string]$BranchName)
    
    Write-Host "Checking feature branch: $BranchName"
    Write-Host "----------------------------------------"
    
    # Check if we're in a git repository
    if (-not (Test-IsGitRepository)) {
        Write-Error-Output "Not a Git repository"
        return $false
    }
    
    # Check for uncommitted changes
    if (Test-HasUncommittedChanges) {
        Write-Error-Output "Cannot change branch: uncommitted changes detected"
        Write-Warning-Output "Commit or stash your changes before switching branches"
        return $false
    }
    
    # Get current branch
    $currentBranch = Get-CurrentBranch
    
    # Check if already on target branch
    if ($currentBranch -eq $BranchName) {
        Write-Success-Output "Already on branch '$BranchName'"
        return $true
    }
    
    # Check if branch exists
    if (Test-BranchExists -BranchName $BranchName) {
        Write-Info-Output "Branch '$BranchName' exists, will switch to it"
    } else {
        Write-Info-Output "Branch '$BranchName' does not exist, will create it"
    }
    
    return $true
}

# Function to create or switch branch
function New-OrSwitch-Branch {
    param([string]$BranchName)
    
    # First check if we can proceed
    if (-not (Test-FeatureBranch -BranchName $BranchName)) {
        return $false
    }
    
    # Get current branch to determine action
    $currentBranch = Get-CurrentBranch
    
    if ($currentBranch -eq $BranchName) {
        Write-Success-Output "Already on branch '$BranchName'"
        return $true
    }
    
    # Check if branch exists
    if (Test-BranchExists -BranchName $BranchName) {
        Write-Info-Output "Switching to existing branch '$BranchName'..."
        try {
            git checkout $BranchName
            if ($LASTEXITCODE -eq 0) {
                Write-Success-Output "Switched to branch '$BranchName'"
                return $true
            } else {
                Write-Error-Output "Failed to switch to branch '$BranchName'"
                return $false
            }
        }
        catch {
            Write-Error-Output "Failed to switch to branch '$BranchName': $($_.Exception.Message)"
            return $false
        }
    } else {
        Write-Info-Output "Creating new branch '$BranchName'..."
        try {
            git checkout -b $BranchName
            if ($LASTEXITCODE -eq 0) {
                Write-Success-Output "Created and switched to branch '$BranchName'"
                return $true
            } else {
                Write-Error-Output "Failed to create branch '$BranchName'"
                return $false
            }
        }
        catch {
            Write-Error-Output "Failed to create branch '$BranchName': $($_.Exception.Message)"
            return $false
        }
    }
}

# Main execution
try {
    # Perform the check
    if (Test-FeatureBranch -BranchName $BranchName) {
        # Ask user if they want to proceed (only if not already on branch)
        $currentBranch = Get-CurrentBranch
        if ($currentBranch -ne $BranchName) {
            Write-Host ""
            $response = Read-Host "Do you want to proceed? (y/N)"
            if ($response -match "^[Yy]$") {
                New-OrSwitch-Branch -BranchName $BranchName
            } else {
                Write-Info-Output "Operation cancelled."
            }
        }
    } else {
        exit 1
    }
}
catch {
    Write-Error-Output "An error occurred: $($_.Exception.Message)"
    exit 1
}