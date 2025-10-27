# Feature Branch Creation Checker

This project provides comprehensive tools to check and handle feature branch creation, addressing the common error "Can't change branch or doesn't exist".

## Overview

The feature branch checker includes three implementations:
- **Python script** (`check_feature_branch.py`) - Cross-platform Python implementation
- **PowerShell script** (`check_feature_branch.ps1`) - Windows PowerShell implementation  
- **Bash script** (`check_feature_branch.sh`) - Unix/Linux/macOS implementation

## Features

✅ **Branch Existence Validation** - Checks if a branch exists locally or remotely  
✅ **Uncommitted Changes Detection** - Prevents branch switching with uncommitted changes  
✅ **Smart Branch Creation** - Creates new branches or switches to existing ones  
✅ **Error Handling** - Clear error messages for common Git issues  
✅ **Interactive Confirmation** - Asks for user confirmation before making changes  
✅ **Cross-Platform Support** - Works on Windows, macOS, and Linux  

## Common Issues Addressed

- **"Can't change branch or doesn't exist"** - Validates branch existence and switching capabilities
- **Uncommitted changes** - Detects and warns about uncommitted changes
- **Branch conflicts** - Handles local and remote branch differences
- **Repository validation** - Ensures you're in a valid Git repository

## Usage

### PowerShell (Windows)
```powershell
# Check and create/switch to a feature branch
.\check_feature_branch.ps1 -BranchName "feature/new-feature"

# Example with a specific branch name
.\check_feature_branch.ps1 -BranchName "feature/user-authentication"
```

### Python (Cross-platform)
```bash
# Check and create/switch to a feature branch
python check_feature_branch.py feature/new-feature

# Example with a specific branch name
python check_feature_branch.py feature/user-authentication
```

### Bash (Unix/Linux/macOS)
```bash
# Make the script executable first
chmod +x check_feature_branch.sh

# Check and create/switch to a feature branch
./check_feature_branch.sh feature/new-feature

# Example with a specific branch name
./check_feature_branch.sh feature/user-authentication
```

## What the Scripts Do

1. **Validate Git Repository** - Ensures you're in a valid Git repository
2. **Check Uncommitted Changes** - Prevents branch switching with uncommitted changes
3. **Determine Action** - Decides whether to create a new branch or switch to existing one
4. **Interactive Confirmation** - Asks for user confirmation before proceeding
5. **Execute Action** - Creates or switches to the specified branch
6. **Provide Feedback** - Clear success/error messages with colored output

## Example Scenarios

### Scenario 1: Creating a New Branch
```bash
$ ./check_feature_branch.sh feature/new-feature
Checking feature branch: feature/new-feature
----------------------------------------
[INFO] Branch 'feature/new-feature' does not exist, will create it

Do you want to proceed? (y/N): y
[INFO] Creating new branch 'feature/new-feature'...
[SUCCESS] Created and switched to branch 'feature/new-feature'
```

### Scenario 2: Switching to Existing Branch
```bash
$ ./check_feature_branch.sh main
Checking feature branch: main
----------------------------------------
[INFO] Branch 'main' exists, will switch to it

Do you want to proceed? (y/N): y
[INFO] Switching to existing branch 'main'...
[SUCCESS] Switched to branch 'main'
```

### Scenario 3: Already on Target Branch
```bash
$ ./check_feature_branch.sh main
Checking feature branch: main
----------------------------------------
[SUCCESS] Already on branch 'main'
```

### Scenario 4: Uncommitted Changes Detected
```bash
$ ./check_feature_branch.sh feature/new-feature
Checking feature branch: feature/new-feature
----------------------------------------
[ERROR] Cannot change branch: uncommitted changes detected
[WARNING] Commit or stash your changes before switching branches
```

## Error Handling

The scripts handle various error conditions:

- **Not a Git repository** - Ensures you're in a valid Git repository
- **Uncommitted changes** - Prevents branch switching with uncommitted changes
- **Branch creation failure** - Handles Git command failures gracefully
- **Branch switching failure** - Provides clear error messages for switch failures
- **Invalid branch names** - Validates branch name format

## Requirements

### Python Script
- Python 3.6 or higher
- Git installed and available in PATH

### PowerShell Script
- Windows PowerShell 5.1 or PowerShell Core 6+
- Git installed and available in PATH

### Bash Script
- Bash shell
- Git installed and available in PATH

## Installation

1. Clone or download the scripts to your project directory
2. Make sure Git is installed and available in your PATH
3. For bash script: `chmod +x check_feature_branch.sh`
4. Run the appropriate script for your platform

## Best Practices

1. **Always commit or stash changes** before switching branches
2. **Use descriptive branch names** following your team's naming convention
3. **Review the script output** before confirming actions
4. **Keep scripts updated** with your Git workflow changes

## Troubleshooting

### Common Issues

1. **"Not a Git repository"** - Make sure you're in a Git repository directory
2. **"Uncommitted changes detected"** - Commit or stash your changes first
3. **"Failed to create branch"** - Check if the branch name is valid and doesn't conflict
4. **Permission denied** - Make sure the script has execute permissions (Unix/Linux)

### Getting Help

If you encounter issues:
1. Check that Git is installed and available in your PATH
2. Verify you're in a valid Git repository
3. Ensure you have the necessary permissions
4. Review the error messages for specific guidance

## Contributing

Feel free to submit issues, feature requests, or pull requests to improve these scripts.

## License

This project is open source and available under the MIT License.
