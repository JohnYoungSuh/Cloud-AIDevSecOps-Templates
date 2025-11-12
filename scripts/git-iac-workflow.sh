#!/usr/bin/env bash
set -euo pipefail

# Initialize project branch from template
init_project() {
  local project_name="${1:?Project name required}"
  local branch="project/${project_name}"

  git fetch origin main --depth=1
  git checkout -b "${branch}" origin/main 2>/dev/null || git checkout "${branch}"
  mkdir -p "projects/${project_name}"/{terraform,ansible,kubernetes}
  touch "projects/${project_name}/.gitkeep"
  git add "projects/${project_name}"
  git commit -m "chore: initialize ${project_name} project structure" --allow-empty
}

# Sync upstream template changes
sync_upstream() {
  local project_name="${1:?Project name required}"
  local branch="project/${project_name}"

  git fetch origin main --depth=1
  git merge origin/main --no-edit --strategy-option=theirs
}

# Push project changes
push_project() {
  local project_name="${1:?Project name required}"
  local branch="project/${project_name}"

  git push -u origin "${branch}"
}

# List active projects
list_projects() {
  git branch -r | grep -E 'origin/project/' | sed 's|origin/project/||' || echo "No projects found"
}

# Switch to project
switch_project() {
  local project_name="${1:?Project name required}"
  git checkout "project/${project_name}"
}

# Main dispatcher
case "${1:-}" in
  init) init_project "${2:-}" ;;
  sync) sync_upstream "${2:-}" ;;
  push) push_project "${2:-}" ;;
  list) list_projects ;;
  switch) switch_project "${2:-}" ;;
  *) echo "Usage: $0 {init|sync|push|list|switch} <project-name>"; exit 1 ;;
esac
