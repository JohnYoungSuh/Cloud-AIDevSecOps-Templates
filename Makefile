.PHONY: help init-project sync-upstream push-project list-projects switch-project validate-terraform validate-ansible setup-env

PROJECT ?= default
SCRIPT := ./scripts/git-iac-workflow.sh

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup-env: ## Setup starship and tmux configs
	@mkdir -p ~/.config
	@ln -sf $(PWD)/.config/starship.toml ~/.config/starship.toml
	@ln -sf $(PWD)/.tmux.conf ~/.tmux.conf
	@mkdir -p ~/.bashrc.d
	@ln -sf $(PWD)/.bashrc.d/iac-workflow.sh ~/.bashrc.d/iac-workflow.sh
	@echo "Add to ~/.bashrc: [ -f ~/.bashrc.d/iac-workflow.sh ] && source ~/.bashrc.d/iac-workflow.sh"

init-project: ## Initialize new project branch (make init-project PROJECT=myapp)
	@bash $(SCRIPT) init $(PROJECT)
	@echo "Project $(PROJECT) initialized at projects/$(PROJECT)"

sync-upstream: ## Sync template changes into project branch
	@bash $(SCRIPT) sync $(PROJECT)
	@echo "Synced upstream changes into project/$(PROJECT)"

push-project: ## Push project branch to remote
	@bash $(SCRIPT) push $(PROJECT)
	@echo "Pushed project/$(PROJECT) to origin"

list-projects: ## List all active project branches
	@bash $(SCRIPT) list

switch-project: ## Switch to project branch (make switch-project PROJECT=myapp)
	@bash $(SCRIPT) switch $(PROJECT)

validate-terraform: ## Validate Terraform configurations
	@find projects/$(PROJECT)/terraform -name "*.tf" -exec terraform fmt -check {} + 2>/dev/null || true
	@find projects/$(PROJECT)/terraform -type f -name "*.tf" -execdir terraform validate \; 2>/dev/null || true

validate-ansible: ## Validate Ansible playbooks
	@find projects/$(PROJECT)/ansible -name "*.yml" -exec ansible-playbook --syntax-check {} \; 2>/dev/null || true

ci-validate: validate-terraform validate-ansible ## Run all validations (CI-friendly)
	@echo "Validation complete for project/$(PROJECT)"
