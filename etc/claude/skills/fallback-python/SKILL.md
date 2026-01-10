# Fallback Python Skill

VCS-aware Python script executor with intelligent fallback.

## Description

This skill provides smart Python script execution by detecting VCS-controlled projects and using project-specific Python scripts when available.

## How It Works

1. **VCS Detection**: Searches for `.git` or `.svn` directories in the current or parent directories
2. **Script Discovery**: If a VCS root is found, looks for an executable file named `python` (with `+x` permission) at the same directory level
3. **Execution**:
   - If a project-specific script is found, executes it with provided arguments
   - Otherwise, falls back to the standard `fallback-python` command

## Use Cases

- Project-specific Python environment management
- Custom Python script execution per repository
- Seamless fallback to default `fallback-python` when no project script exists

## Examples

```bash
# In a git repository with executable file named 'python' at root
/fallback-python arg1 arg2  # Executes ./python arg1 arg2

# In a directory without VCS or executable 'python' file
/fallback-python arg1 arg2  # Falls back to: fallback-python arg1 arg2
```

## Technical Details

- Maximum search depth: 3 levels for VCS directories
- Supported VCS: Git (.git), Subversion (.svn)
- Script requirements: File must be named exactly `python` with executable permission
- Argument forwarding: All arguments are passed to the discovered script or fallback-python command
