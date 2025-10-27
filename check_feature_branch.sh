#!/bin/bash

# Feature Branch Creation Checker
# This script checks if a feature branch can be created or switched to,
# handling common Git branch issues and providing clear error messages.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Function to check if we're in a git repository
is_git_repo() {
    git rev-parse --git-dir > /dev/null 2>&1
}

# Function to check for uncommitted changes
has_uncommitted_changes() {
    ! git diff-index --quiet HEAD --
}

# Function to get current branch
get_current_branch() {
    git branch --show-current 2>/dev/null || echo ""
}

# Function to check if branch exists
branch_exists() {
    local branch_name="$1"
    git show-ref --verify --quiet "refs/heads/$branch_name" 2>/dev/null || \
    git show-ref --verify --quiet "refs/remotes/origin/$branch_name" 2>/dev/null
}

# Function to check feature branch
check_feature_branch() {
    local branch_name="$1"
    local can_proceed=false
    local action="unknown"
    local error=""
    local warnings=()
    
    echo "Checking feature branch: $branch_name"
    echo "----------------------------------------"
    
    # Check if we're in a git repository
    if ! is_git_repo; then
        error="Not a Git repository"
        print_error "$error"
        return 1
    fi
    
    # Check for uncommitted changes
    if has_uncommitted_changes; then
        error="Cannot change branch: uncommitted changes detected"
        warnings+=("Commit or stash your changes before switching branches")
        print_error "$error"
        print_warning "Commit or stash your changes before switching branches"
        return 1
    fi
    
    # Get current branch
    local current_branch=$(get_current_branch)
    
    # Check if already on target branch
    if [ "$current_branch" = "$branch_name" ]; then
        can_proceed=true
        action="already_on_branch"
        warnings+=("Already on branch '$branch_name'")
        print_success "Already on branch '$branch_name'"
        return 0
    fi
    
    # Check if branch exists
    if branch_exists "$branch_name"; then
        can_proceed=true
        action="switch"
        warnings+=("Branch '$branch_name' exists, will switch to it")
        print_info "Branch '$branch_name' exists, will switch to it"
    else
        can_proceed=true
        action="create"
        warnings+=("Branch '$branch_name' does not exist, will create it")
        print_info "Branch '$branch_name' does not exist, will create it"
    fi
    
    # Display warnings
    if [ ${#warnings[@]} -gt 0 ]; then
        echo ""
        print_info "Warnings:"
        for warning in "${warnings[@]}"; do
            echo "  - $warning"
        done
    fi
    
    return 0
}

# Function to create or switch branch
create_or_switch_branch() {
    local branch_name="$1"
    
    # First check if we can proceed
    if ! check_feature_branch "$branch_name"; then
        return 1
    fi
    
    # Get current branch to determine action
    local current_branch=$(get_current_branch)
    
    if [ "$current_branch" = "$branch_name" ]; then
        print_success "Already on branch '$branch_name'"
        return 0
    fi
    
    # Check if branch exists
    if branch_exists "$branch_name"; then
        print_info "Switching to existing branch '$branch_name'..."
        if git checkout "$branch_name"; then
            print_success "Switched to branch '$branch_name'"
        else
            print_error "Failed to switch to branch '$branch_name'"
            return 1
        fi
    else
        print_info "Creating new branch '$branch_name'..."
        if git checkout -b "$branch_name"; then
            print_success "Created and switched to branch '$branch_name'"
        else
            print_error "Failed to create branch '$branch_name'"
            return 1
        fi
    fi
}

# Main function
main() {
    if [ $# -ne 1 ]; then
        echo "Usage: $0 <branch_name>"
        echo "Example: $0 feature/new-feature"
        exit 1
    fi
    
    local branch_name="$1"
    
    # Perform the check
    if check_feature_branch "$branch_name"; then
        # Ask user if they want to proceed (only if not already on branch)
        local current_branch=$(get_current_branch)
        if [ "$current_branch" != "$branch_name" ]; then
            echo ""
            read -p "Do you want to proceed? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                create_or_switch_branch "$branch_name"
            else
                print_info "Operation cancelled."
            fi
        fi
    else
        exit 1
    fi
}

# Run main function with all arguments
main "$@"
