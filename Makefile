katana:
	katana --disable-fee --allowed-origins "*" --invoke-max-steps 4294967295

setup:
	@./scripts/setup.sh

deploy-slot:
	@./scripts/deploy_slot.sh $(PROFILE) $(ACTION)

init:
	@mkdir -p .git/hooks
	@touch .git/hooks/pre-push
	@echo '#!/bin/bash' > .git/hooks//pre-push
	@echo 'echo "Running pre-push hook..."' >> .git/hooks/pre-push
	@echo 'echo "Executing sozo test..."' >> .git/hooks/pre-push
	@echo '' >> .git/hooks/pre-push
	@echo '# Run sozo test' >> .git/hooks/pre-push
	@echo 'if ! sozo test; then' >> .git/hooks/pre-push
	@echo '    echo "❌ sozo test failed. Push aborted."' >> .git/hooks/pre-push
	@echo '    exit 1' >> .git/hooks/pre-push
	@echo 'fi' >> .git/hooks/pre-push
	@echo '' >> .git/hooks/pre-push
	@echo 'echo "✅ sozo test passed. Proceeding with push..."' >> .git/hooks/pre-push
	@echo 'exit 0' >> .git/hooks/pre-push
	@chmod +x .git/hooks/pre-push
	@echo "Git hooks initialized successfully!"

# Define tasks that are not real files
.PHONY: katana setup torii init

# Catch-all rule for undefined commands
%:
	@echo "Error: Command '$(MAKECMDGOALS)' is not defined."
	@exit 1
