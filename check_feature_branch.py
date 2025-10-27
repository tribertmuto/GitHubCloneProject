#!/usr/bin/env python3
"""
Feature Branch Creation Checker

This script checks if a feature branch can be created or switched to,
handling common Git branch issues and providing clear error messages.
"""

import subprocess
import sys
import os
from typing import Tuple, List, Optional


class FeatureBranchChecker:
    def __init__(self):
        self.repo_path = os.getcwd()
    
    def run_git_command(self, command: List[str]) -> Tuple[bool, str, str]:
        """Run a git command and return success status, stdout, and stderr."""
        try:
            result = subprocess.run(
                command,
                capture_output=True,
                text=True,
                cwd=self.repo_path,
                timeout=30
            )
            return result.returncode == 0, result.stdout.strip(), result.stderr.strip()
        except subprocess.TimeoutExpired:
            return False, "", "Command timed out"
        except Exception as e:
            return False, "", str(e)
    
    def is_git_repository(self) -> bool:
        """Check if current directory is a Git repository."""
        success, _, _ = self.run_git_command(["git", "rev-parse", "--git-dir"])
        return success
    
    def get_current_branch(self) -> Optional[str]:
        """Get the current branch name."""
        success, output, _ = self.run_git_command(["git", "branch", "--show-current"])
        return output if success else None
    
    def get_all_branches(self) -> List[str]:
        """Get all local and remote branches."""
        success, output, _ = self.run_git_command(["git", "branch", "-a"])
        if not success:
            return []
        
        branches = []
        for line in output.split('\n'):
            line = line.strip()
            if line and not line.startswith('*'):
                # Remove remote prefix and clean up branch names
                if line.startswith('remotes/'):
                    branch_name = line.replace('remotes/origin/', '').replace('remotes/', '')
                else:
                    branch_name = line
                branches.append(branch_name)
        return branches
    
    def has_uncommitted_changes(self) -> bool:
        """Check if there are uncommitted changes."""
        success, output, _ = self.run_git_command(["git", "status", "--porcelain"])
        return success and output.strip() != ""
    
    def can_switch_branch(self, branch_name: str) -> Tuple[bool, str]:
        """Check if we can switch to a specific branch."""
        if not self.is_git_repository():
            return False, "Not a Git repository"
        
        if self.has_uncommitted_changes():
            return False, "Cannot switch branch: uncommitted changes detected"
        
        branches = self.get_all_branches()
        if branch_name not in branches:
            return False, f"Branch '{branch_name}' does not exist"
        
        return True, "Can switch to branch"
    
    def can_create_branch(self, branch_name: str) -> Tuple[bool, str]:
        """Check if we can create a new branch."""
        if not self.is_git_repository():
            return False, "Not a Git repository"
        
        if self.has_uncommitted_changes():
            return False, "Cannot create branch: uncommitted changes detected"
        
        branches = self.get_all_branches()
        if branch_name in branches:
            return False, f"Branch '{branch_name}' already exists"
        
        return True, "Can create new branch"
    
    def check_feature_branch(self, branch_name: str) -> dict:
        """Comprehensive check for feature branch creation/switching."""
        result = {
            "branch_name": branch_name,
            "can_proceed": False,
            "action": "unknown",
            "error": None,
            "warnings": []
        }
        
        # Check if we're in a Git repository
        if not self.is_git_repository():
            result["error"] = "Not a Git repository"
            return result
        
        # Check for uncommitted changes
        if self.has_uncommitted_changes():
            result["error"] = "Cannot change branch: uncommitted changes detected"
            result["warnings"].append("Commit or stash your changes before switching branches")
            return result
        
        # Get current branch
        current_branch = self.get_current_branch()
        if current_branch == branch_name:
            result["can_proceed"] = True
            result["action"] = "already_on_branch"
            result["warnings"].append(f"Already on branch '{branch_name}'")
            return result
        
        # Check if branch exists
        branches = self.get_all_branches()
        if branch_name in branches:
            result["can_proceed"] = True
            result["action"] = "switch"
            result["warnings"].append(f"Branch '{branch_name}' exists, will switch to it")
        else:
            result["can_proceed"] = True
            result["action"] = "create"
            result["warnings"].append(f"Branch '{branch_name}' does not exist, will create it")
        
        return result
    
    def create_or_switch_branch(self, branch_name: str) -> Tuple[bool, str]:
        """Actually create or switch to the branch."""
        check_result = self.check_feature_branch(branch_name)
        
        if not check_result["can_proceed"]:
            return False, check_result["error"]
        
        if check_result["action"] == "already_on_branch":
            return True, f"Already on branch '{branch_name}'"
        
        if check_result["action"] == "switch":
            success, output, error = self.run_git_command(["git", "checkout", branch_name])
            if success:
                return True, f"Switched to branch '{branch_name}'"
            else:
                return False, f"Failed to switch to branch '{branch_name}': {error}"
        
        if check_result["action"] == "create":
            success, output, error = self.run_git_command(["git", "checkout", "-b", branch_name])
            if success:
                return True, f"Created and switched to branch '{branch_name}'"
            else:
                return False, f"Failed to create branch '{branch_name}': {error}"
        
        return False, "Unknown action"


def main():
    if len(sys.argv) != 2:
        print("Usage: python check_feature_branch.py <branch_name>")
        print("Example: python check_feature_branch.py feature/new-feature")
        sys.exit(1)
    
    branch_name = sys.argv[1]
    checker = FeatureBranchChecker()
    
    print(f"Checking feature branch: {branch_name}")
    print("-" * 50)
    
    # Perform the check
    result = checker.check_feature_branch(branch_name)
    
    # Display results
    print(f"Branch: {result['branch_name']}")
    print(f"Can proceed: {result['can_proceed']}")
    print(f"Action: {result['action']}")
    
    if result['error']:
        print(f"Error: {result['error']}")
        sys.exit(1)
    
    if result['warnings']:
        print("Warnings:")
        for warning in result['warnings']:
            print(f"  - {warning}")
    
    # Ask user if they want to proceed
    if result['can_proceed'] and result['action'] != 'already_on_branch':
        response = input("\nDo you want to proceed? (y/N): ").strip().lower()
        if response in ['y', 'yes']:
            success, message = checker.create_or_switch_branch(branch_name)
            if success:
                print(f"✅ {message}")
            else:
                print(f"❌ {message}")
                sys.exit(1)
        else:
            print("Operation cancelled.")
    elif result['action'] == 'already_on_branch':
        print("✅ Already on the target branch.")


if __name__ == "__main__":
    main()
