# Makefile for ctmgr - Container Test Manager
# A tool for managing systemd-enabled containers for testing

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
CYAN := \033[0;36m
NC := \033[0m # No Color

# Installation paths
PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
DOCDIR = $(PREFIX)/share/doc/ctmgr

# Project files
SCRIPTS = ctmgr ctmgr-distros
DOCS = README.md DISTROS.md
DOCKERFILES = dockerfiles/Dockerfile.debian dockerfiles/Makefile

# Default target
.DEFAULT_GOAL := help

##@ General

.PHONY: help
help: ## Display this help message
	@echo "$(CYAN)╔════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(CYAN)║$(NC)  $(GREEN)ctmgr$(NC) - Container Test Manager                         $(CYAN)║$(NC)"
	@echo "$(CYAN)╚════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "$(BLUE)Usage:$(NC)\n  make $(CYAN)<target>$(NC)\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  $(CYAN)%-20s$(NC) %s\n", $$1, $$2 } /^##@/ { printf "\n$(YELLOW)%s$(NC)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo ""

##@ Installation

.PHONY: install
install: check-deps install-scripts install-docs ## Install ctmgr and ctmgr-distros to system
	@echo "$(GREEN)✓$(NC) Installation complete!"
	@echo "$(BLUE)→$(NC) Scripts installed to: $(CYAN)$(BINDIR)$(NC)"
	@echo "$(BLUE)→$(NC) Documentation installed to: $(CYAN)$(DOCDIR)$(NC)"

.PHONY: install-scripts
install-scripts: ## Install executables only
	@echo "$(BLUE)→$(NC) Installing scripts to $(CYAN)$(BINDIR)$(NC)..."
	@install -d $(BINDIR)
	@install -m 755 ctmgr $(BINDIR)/ctmgr
	@install -m 755 ctmgr-distros $(BINDIR)/ctmgr-distros
	@echo "$(GREEN)✓$(NC) Scripts installed"

.PHONY: install-docs
install-docs: ## Install documentation only
	@echo "$(BLUE)→$(NC) Installing documentation to $(CYAN)$(DOCDIR)$(NC)..."
	@install -d $(DOCDIR)
	@install -m 644 README.md $(DOCDIR)/README.md
	@install -m 644 DISTROS.md $(DOCDIR)/DISTROS.md
	@echo "$(GREEN)✓$(NC) Documentation installed"

.PHONY: uninstall
uninstall: ## Remove ctmgr from system
	@echo "$(YELLOW)→$(NC) Uninstalling ctmgr..."
	@rm -f $(BINDIR)/ctmgr
	@rm -f $(BINDIR)/ctmgr-distros
	@rm -rf $(DOCDIR)
	@echo "$(GREEN)✓$(NC) Uninstallation complete"

##@ Development

.PHONY: check
check: check-deps check-syntax ## Run all checks
	@echo "$(GREEN)✓$(NC) All checks passed"

.PHONY: check-deps
check-deps: ## Check if required dependencies are installed
	@echo "$(BLUE)→$(NC) Checking dependencies..."
	@command -v docker >/dev/null 2>&1 || { echo "$(RED)✗$(NC) docker is required but not installed"; exit 1; }
	@command -v curl >/dev/null 2>&1 || { echo "$(RED)✗$(NC) curl is required but not installed"; exit 1; }
	@command -v jq >/dev/null 2>&1 || { echo "$(RED)✗$(NC) jq is required but not installed"; exit 1; }
	@echo "$(GREEN)✓$(NC) All dependencies satisfied"

.PHONY: check-syntax
check-syntax: ## Validate bash syntax
	@echo "$(BLUE)→$(NC) Checking script syntax..."
	@bash -n ctmgr || { echo "$(RED)✗$(NC) Syntax error in ctmgr"; exit 1; }
	@bash -n ctmgr-distros || { echo "$(RED)✗$(NC) Syntax error in ctmgr-distros"; exit 1; }
	@echo "$(GREEN)✓$(NC) Syntax validation passed"

.PHONY: test
test: check ## Run tests (placeholder for future tests)
	@echo "$(BLUE)→$(NC) Running tests..."
	@echo "$(YELLOW)!$(NC) No tests defined yet"

##@ Docker Images

.PHONY: build-debian
build-debian: ## Build Debian systemd container image
	@echo "$(BLUE)→$(NC) Building Debian systemd image..."
	@./ctmgr pool build --pool debian --dockerfile dockerfiles/Dockerfile.debian
	@echo "$(GREEN)✓$(NC) Debian image built"

.PHONY: build-all
build-all: ## Build all available container images
	@echo "$(BLUE)→$(NC) Building all container images..."
	@$(MAKE) build-debian
	@echo "$(GREEN)✓$(NC) All images built"

.PHONY: list-pools
list-pools: ## List all configured pools
	@./ctmgr pool list

##@ Maintenance

.PHONY: clean
clean: ## Remove temporary files and caches
	@echo "$(BLUE)→$(NC) Cleaning temporary files..."
	@rm -rf ~/.ctmgr_cache/*
	@echo "$(GREEN)✓$(NC) Cache cleaned"

.PHONY: clean-all
clean-all: clean ## Remove all ctmgr state and caches
	@echo "$(YELLOW)→$(NC) Removing all ctmgr state files..."
	@rm -f ~/.ctmgr_state
	@rm -f ~/.ctmgr_pools
	@rm -rf ~/.ctmgr_cache
	@echo "$(GREEN)✓$(NC) All state cleaned"

.PHONY: distclean
distclean: clean-all ## Complete cleanup including Docker images
	@echo "$(YELLOW)→$(NC) Removing Docker images..."
	@docker images | grep -E 'debian-systemd|ubuntu-systemd|centos-systemd|fedora-systemd' | awk '{print $$3}' | xargs -r docker rmi -f
	@echo "$(GREEN)✓$(NC) Complete cleanup done"

##@ Information

.PHONY: version
version: ## Show version information
	@echo "$(CYAN)ctmgr$(NC) - Container Test Manager"
	@echo "Version: $(GREEN)1.0.0$(NC)"
	@echo "Author: Mårten Cassel"

.PHONY: status
status: ## Show current ctmgr status
	@echo "$(CYAN)╔════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(CYAN)║$(NC)  $(GREEN)ctmgr Status$(NC)                                            $(CYAN)║$(NC)"
	@echo "$(CYAN)╚════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(YELLOW)Managed Containers:$(NC)"
	@./ctmgr list || echo "  $(YELLOW)!$(NC) No containers managed"
	@echo ""
	@echo "$(YELLOW)Available Pools:$(NC)"
	@./ctmgr pool list || echo "  $(YELLOW)!$(NC) No pools built yet"
	@echo ""
	@echo "$(YELLOW)Cache Status:$(NC)"
	@if [ -d ~/.ctmgr_cache ] && [ -n "$$(ls -A ~/.ctmgr_cache 2>/dev/null)" ]; then \
		echo "  $(GREEN)✓$(NC) Cache directory: ~/.ctmgr_cache"; \
		du -sh ~/.ctmgr_cache 2>/dev/null | awk '{print "  $(BLUE)→$(NC) Size: "$$1}'; \
	else \
		echo "  $(YELLOW)!$(NC) Cache is empty"; \
	fi

##@ Examples

.PHONY: example
example: ## Show usage examples
	@echo "$(CYAN)╔════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(CYAN)║$(NC)  $(GREEN)ctmgr Examples$(NC)                                         $(CYAN)║$(NC)"
	@echo "$(CYAN)╚════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(YELLOW)Build a pool:$(NC)"
	@echo "  $$ $(CYAN)ctmgr pool build --pool debian --user devops --password changeme$(NC)"
	@echo ""
	@echo "$(YELLOW)Allocate containers:$(NC)"
	@echo "  $$ $(CYAN)ctmgr alloc --pool debian --name test-vm$(NC)"
	@echo "  $$ $(CYAN)ctmgr alloc --pool debian --count 5$(NC)"
	@echo ""
	@echo "$(YELLOW)List containers:$(NC)"
	@echo "  $$ $(CYAN)ctmgr list$(NC)"
	@echo ""
	@echo "$(YELLOW)Generate docker-compose:$(NC)"
	@echo "  $$ $(CYAN)ctmgr render-compose --pool debian --count 3 > docker-compose.yml$(NC)"
	@echo ""
	@echo "$(YELLOW)Discover distro versions:$(NC)"
	@echo "  $$ $(CYAN)ctmgr-distros list --distro debian$(NC)"
	@echo "  $$ $(CYAN)ctmgr-distros search bookworm$(NC)"
	@echo ""

.PHONY: info
info: version status ## Show version and status

##@ Advanced

.PHONY: dev-install
dev-install: ## Install in development mode (symlinks)
	@echo "$(BLUE)→$(NC) Creating development symlinks..."
	@install -d $(BINDIR)
	@ln -sf $(PWD)/ctmgr $(BINDIR)/ctmgr
	@ln -sf $(PWD)/ctmgr-distros $(BINDIR)/ctmgr-distros
	@echo "$(GREEN)✓$(NC) Development symlinks created"
	@echo "$(YELLOW)!$(NC) Edit files in $(PWD) to modify installed versions"

.PHONY: shellcheck
shellcheck: ## Run shellcheck on all scripts (requires shellcheck)
	@if command -v shellcheck >/dev/null 2>&1; then \
		echo "$(BLUE)→$(NC) Running shellcheck..."; \
		shellcheck ctmgr ctmgr-distros || true; \
	else \
		echo "$(YELLOW)!$(NC) shellcheck not installed, skipping"; \
	fi
