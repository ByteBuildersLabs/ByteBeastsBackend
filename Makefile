katana:
	katana --disable-fee --allowed-origins "*" --invoke-max-steps 4294967295

setup:
	@./scripts/setup.sh

deploy-slot:
	@./scripts/deploy_slot.sh $(PROFILE) $(ACTION)

# Define tasks that are not real files
.PHONY: katana setup torii

# Catch-all rule for undefined commands
%:
	@echo "Error: Command '$(MAKECMDGOALS)' is not defined."
	@exit 1
