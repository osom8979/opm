---
description: Generate and create a git commit using the commit-message-generator agent
argument-hint: [additional description]
---

# Git Commit

Use the commit-message-generator agent to analyze staged changes and create a professional commit.

**Important**: This command commits **only the changes that have been staged with `git add`**. Make sure you have staged all the files you want to commit before running this command.

Additional context: $ARGUMENTS

## Allowed Commands

The agent is allowed to use the following git commands:
- `bash git diff --cached` - View staged changes
- `bash git log --oneline -10` - View recent commit history

## Prohibited Commands

The agent **MUST NOT** use:
- `bash git add:*` - Adding files is not allowed

**CRITICAL**: After successfully executing the `git commit` command, immediately end your response with NO additional commentary, explanation, or status updates. Do not waste tokens on confirming what you did - the git commit output speaks for itself.
