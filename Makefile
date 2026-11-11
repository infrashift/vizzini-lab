.PHONY: help build litellm-up litellm-down litellm-smoke uat uat-vizzini uat-stub uat-bot uat-bot-stub uat-ci-github ado-check ado-down lint clean

help: ## List targets
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-14s %s\n", $$1, $$2}'

build: ## Clone the four tools at their pinned SHAs and build them into .cache/bin
	uat/build.sh

litellm-up: ## Start the LiteLLM proxy (needs the vizzini-anthropic-key podman secret)
	litellm/litellm.sh up

litellm-down: ## Stop the LiteLLM proxy
	litellm/litellm.sh down

litellm-smoke: ## One JSON-mode request per model
	litellm/litellm.sh smoke

uat: build ## Full UAT: live models, Azure DevOps + mrman leg, real-world commits
	uat/run.sh

uat-vizzini: build ## Live models without the forge leg (Vizzini + garmr + okfw, OSS commits)
	uat/run.sh --no-forge

uat-stub: build ## Token-free dry run of the harness against Vizzini's stubllm
	uat/run.sh --stub

uat-bot: build ## Unattended leg: vizzini-bot posts on an ADO PR under a garmr policy (deny, then allow)
	uat/bot.sh

uat-bot-stub: build ## The unattended leg against stubllm (no tokens; still posts on ADO)
	uat/bot.sh --stub

uat-ci-github: build ## Vizzini's GitHub Actions template, live on a throwaway PR here (stubllm as the model)
	uat/ci-github.sh

ado-check: ## Check the PAT and ADO repository
	uat/ado.sh check

ado-down: ## Abandon the UAT's PRs and delete its branches on ADO
	uat/ado.sh down

lint: ## shellcheck the scripts, compile-check score.py, validate the wiki
	shellcheck uat/*.sh litellm/*.sh
	python3 -I -c "import ast,sys; ast.parse(open(sys.argv[1]).read())" uat/score.py
	okfw validate --all
	okfw validate --okf

clean: ## Remove .cache (tool clones, binaries, runs, OSS mirrors)
	rm -rf .cache
