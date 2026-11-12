#!/usr/bin/env bash
# run.sh: the Vizzini + mrman + garmr + okf-wiki UAT.
#
#   uat/run.sh [--stub] [--models "m1 m2"] [--fixtures "f1 f2"] [--no-forge] [--no-oss]
#
#   --stub       use Vizzini's stubllm instead of LiteLLM: no tokens, review
#                mode only, model-quality checks become metrics. Implies
#                --no-forge.
#   --models     override $MODELS from versions.env
#   --fixtures   override $FIXTURES (seeded fixtures under fixtures/)
#   --no-forge   skip the Azure DevOps + mrman leg
#   --no-oss     skip the real-world commits in fixtures/csharp-oss.txt
#
# Needs: uat/build.sh done; for live runs `litellm/litellm.sh up`; for the
# forge leg the ADO settings described in uat/ado.sh.
#
# Each run writes .cache/runs/<UTC stamp>/: one directory per fixture
# (repo/, repo.patch, repo.sarif, then one directory per model) and oss/.
# uat/score.py scores it into summary.md and scores.json there; the exit
# status is score.py's.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=versions.env
source "$root/versions.env"
bin="$root/.cache/bin"
src="$root/.cache/src"
policies="$src/vizzini/policies/garmr/vizzini"

stub=0 forge=1 oss=1
while [[ $# -gt 0 ]]; do
	case $1 in
	--stub) stub=1 forge=0 ;;
	--models) MODELS=$2; shift ;;
	--fixtures) FIXTURES=$2; shift ;;
	--no-forge) forge=0 ;;
	--no-oss) oss=0 ;;
	*) sed -n '2,21p' "$0" >&2; exit 2 ;;
	esac
	shift
done

say() { printf '\n== %s\n' "$*"; }
die() { printf 'run: %s\n' "$*" >&2; exit 1; }

for b in pr-review mrman garmr okfw; do [[ -x $bin/$b ]] || die "$bin/$b missing; run uat/build.sh"; done

export TIKTOKEN_CACHE_DIR="$root/.cache/tiktoken"
"$src/vizzini/scripts/tiktoken-cache.sh" "$TIKTOKEN_CACHE_DIR" >/dev/null

run="$root/.cache/runs/$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$run"
cp "$bin/build-manifest.json" "$run/"
echo "run: $run"

# timed BASE CMD...: stdout -> BASE.json, stderr -> BASE.err, exit status ->
# BASE.code, wall seconds -> BASE.time. Never fails: score.py judges.
timed() {
	local base=$1 t0 code
	shift
	t0=$(date +%s.%N)
	set +e
	"$@" >"$base.json" 2>"$base.err"
	code=$?
	set -e
	echo "$code" >"$base.code"
	python3 -I -c 'import sys,time;print(f"{time.time()-float(sys.argv[1]):.2f}")' "$t0" >"$base.time"
	printf '   %-10s exit %s in %ss\n' "$(basename "$base")" "$code" "$(<"$base.time")"
}

stub_pid=""
cleanup() { [[ -n $stub_pid ]] && kill "$stub_pid" 2>/dev/null || true; }
trap cleanup EXIT

say "model endpoint"
if ((stub)); then
	addr="127.0.0.1:${STUB_PORT:-18772}"
	(cd "$src/vizzini" && go build -o "$bin/stubllm" ./scripts/e2e/stubllm)
	"$bin/stubllm" -addr "$addr" -log "$run/stub-prompts.log" 2>"$run/stubllm.err" &
	stub_pid=$!
	for _ in $(seq 50); do curl -s -o /dev/null "http://$addr/" && break; sleep 0.1; done
	export VIZZINI_LITELLM_URL="http://$addr/v1"
	unset VIZZINI_API_KEY
	MODELS=stub
	echo "   stubllm at $VIZZINI_LITELLM_URL"
else
	"$root/litellm/litellm.sh" status >/dev/null || die "LiteLLM is not running: litellm/litellm.sh up"
	eval "$("$root/litellm/litellm.sh" env)"
	echo "   LiteLLM at $VIZZINI_LITELLM_URL; models: $MODELS"
fi

# Who and what is asking, on every request (Vizzini ISSUE-025).
export VIZZINI_AGENT=vizzini-lab VIZZINI_REQUESTER="${VIZZINI_REQUESTER:-${USER:-uat}}"

say "garmr: Vizzini policy pack"
"$bin/garmr" validate "$policies" >"$run/garmr-validate.log" 2>&1 || { cat "$run/garmr-validate.log"; die "garmr validate"; }
for t in review-gate review-advisory; do
	"$bin/garmr" test "$policies/review.cue" "$policies/${t}_test.cue" >"$run/garmr-test-$t.log" 2>&1 ||
		{ cat "$run/garmr-test-$t.log"; die "garmr test $t"; }
	echo "   garmr test $t: $(grep -o 'Results: .*' "$run/garmr-test-$t.log")"
done

if ((forge)); then
	say "Azure DevOps"
	"$root/uat/ado.sh" check
	# shellcheck source=uat/forge.sh
	source "$root/uat/forge.sh"
	# The requester is the human behind the PAT (Vizzini ISSUE-025).
	VIZZINI_REQUESTER="$("$root/uat/ado.sh" whoami)"
	export VIZZINI_REQUESTER
	echo "   requester: ${VIZZINI_REQUESTER:0:3}… (redacted; it is in the reports and spend logs)"
fi

# Per fixture, per model: every Vizzini mode on the fixture (from its root,
# so relative paths match the SARIF and the knowledge base), garmr on the
# review, then the forge leg.
for fixture in $FIXTURES; do
	[[ $fixture != oss ]] || die "a fixture cannot be named oss"
	fx="$root/fixtures/$fixture"
	f="$run/$fixture"
	mkdir -p "$f"
	say "fixture $fixture"
	"$root/uat/fixture.sh" "$fixture" "$f/repo"
	(cd "$f/repo" && git ls-files >"$f/tree.txt")
	(cd "$f/repo" && "$bin/okfw" validate --all && "$bin/okfw" validate --okf) >"$f/okfw.log" 2>&1 ||
		{ cat "$f/okfw.log"; die "okfw validate failed on the $fixture wiki"; }
	sed 's/^/   okfw: /' "$f/okfw.log" | grep -v '^ *okfw: *$'
	if ((forge)); then "$root/uat/ado.sh" base "$f/repo" "$fixture"; fi

	# Attribution (Vizzini ISSUE-025): every request names this fixture's
	# "pull request", the head commit and who ran it; each pr-review call
	# gets its own run id.
	VIZZINI_ITERATION="$(git -C "$f/repo" rev-parse HEAD)"
	export VIZZINI_PR="uat:vizzini-lab/$fixture" VIZZINI_ITERATION
	for model in $MODELS; do
		export VIZZINI_MODEL=$model
		d="$f/$model"
		mkdir -p "$d"
		say "Vizzini + garmr: $fixture / $model"
		if ((forge)); then forge_open "$model" "$d" "$fixture" "$f"; fi
		(
			cd "$f/repo"
			timed "$d/review" "$bin/pr-review" --mode review --patch-file "$f/repo.patch" \
				--lint-json "$f/repo.sarif" --knowledge .okfw --repo . --format json
			if ((!stub)); then
				timed "$d/describe" "$bin/pr-review" --mode describe --patch-file "$f/repo.patch" --format json
				timed "$d/improve" "$bin/pr-review" --mode improve --patch-file "$f/repo.patch" --format json
				timed "$d/plan" "$bin/pr-review" --mode plan --issue "$fx/issue.json" --tree "$f/tree.txt" \
					--okf-index .okfw/index.md --format json
			fi
		)
		timed "$d/garmr" "$bin/garmr" eval --policy-dir "$policies" --input "$d/review.json" -n vizzini -o json
		if ((forge)); then forge_leg "$model" "$d" "$fixture" "$f"; fi
	done
done

if ((oss)); then
	say "real-world commits"
	grep -v '^\s*\(#\|$\)' "$root/fixtures/csharp-oss.txt" | while read -r label url sha; do
		name="$(basename "$url" .git)"
		mirror="$root/.cache/oss/$name.git"
		[[ -d $mirror ]] || git clone -q --bare --filter=blob:none "$url" "$mirror"
		git -C "$mirror" cat-file -e "$sha^{commit}" 2>/dev/null || git -C "$mirror" fetch -q origin "$sha"
		for model in $MODELS; do
			d="$run/oss/$model/$label"
			mkdir -p "$d"
			git -C "$mirror" show --format= --no-color "$sha" >"$d/change.patch"
			echo "   $model / $label ($(grep -c '^diff --git' "$d/change.patch") files)"
			export VIZZINI_MODEL=$model VIZZINI_PR="oss:$label" VIZZINI_ITERATION=$sha
			timed "$d/review" "$bin/pr-review" --mode review --patch-file "$d/change.patch" --format json
			((stub)) || timed "$d/describe" "$bin/pr-review" --mode describe --patch-file "$d/change.patch" --format json
			timed "$d/garmr" "$bin/garmr" eval --policy-dir "$policies" --input "$d/review.json" -n vizzini -o json
		done
	done
fi

if ((!stub)); then
	say "cost attribution"
	"$root/uat/costs.sh" "$run" || echo "   cost attribution failed (rerun: uat/costs.sh $run)"
fi

say "score"
args=("$run")
((stub)) && args+=(--stub)
((forge)) && args+=("--require" "mrman,ado")
python3 -I "$root/uat/score.py" "${args[@]}"
