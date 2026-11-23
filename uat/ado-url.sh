# shellcheck shell=bash
# shellcheck disable=SC2034 # the scripts that source this file read the variables
# ado-url.sh: parse ADO_REPO_URL for the UAT scripts (sourced, not run).
#
# Azure DevOps Services and Azure DevOps Server (2022.1 or later) differ only
# in the collection path (Vizzini ADR-0029):
#
#   https://dev.azure.com/ORG/PROJECT/_git/REPO
#   https://SERVER/tfs/DefaultCollection/PROJECT/_git/REPO
#
# ado_parse_url URL sets:
#   ADO_HOST        dev.azure.com, or the server's host[:port]
#   ORG             the collection path: ORG, or tfs/DefaultCollection
#   PROJECT, REPO   as in the URL (percent-encoding kept)
#   ADO_COLLECTION_URL  https://ADO_HOST/ORG: the base of every REST call
#   ADO_SERVER      1 on Azure DevOps Server, else 0
#   REPO_KEY        ADO_HOST/ORG/PROJECT/REPO: Vizzini's repository key
# It returns 1 when URL has another shape.

ado_parse_url() {
	local url=${1%/}
	[[ $url =~ ^https://([^/@]+@)?([^/]+)/(([^/]+/)*[^/]+)/([^/]+)/_git/([^/]+)$ ]] || return 1
	ADO_HOST="${BASH_REMATCH[2],,}"
	ORG="${BASH_REMATCH[3]}"
	PROJECT="${BASH_REMATCH[5]}"
	REPO="${BASH_REMATCH[6]}"
	[[ /$ORG/ != */_git/* ]] || return 1
	ADO_COLLECTION_URL="https://$ADO_HOST/$ORG"
	REPO_KEY="$ADO_HOST/$ORG/$PROJECT/$REPO"
	ADO_SERVER=1
	[[ $ADO_HOST == dev.azure.com ]] && ADO_SERVER=0
	return 0
}

# ado_url_shapes names the accepted shapes in error messages.
ado_url_shapes="https://dev.azure.com/ORG/PROJECT/_git/REPO or https://SERVER/[VDIR/]COLLECTION/PROJECT/_git/REPO"

# ado_require_mrman_host: on Azure DevOps Server, mrman needs the server in
# its config ([[forge.hosts]] with forge = "azuredevops" and a token), as any
# user does. The UAT does not write the user's mrman config; it stops with
# the entry to add.
ado_require_mrman_host() {
	((ADO_SERVER)) || return 0
	local conf="${XDG_CONFIG_HOME:-$HOME/.config}/mrman/config.toml" host=${ADO_HOST%%:*}
	grep -Eq "^[[:space:]]*host[[:space:]]*=[[:space:]]*\"$host\"" "$conf" 2>/dev/null && return 0
	# shellcheck disable=SC2016 # mrman expands $AZURE_DEVOPS_EXT_PAT when it runs
	printf '%s\n' "ado: mrman does not know $host. Add this to $conf:" "" \
		'[[forge.hosts]]' "host = \"$host\"" 'forge = "azuredevops"' 'token = "$AZURE_DEVOPS_EXT_PAT"' >&2
	if [[ $ADO_HOST == *:* ]]; then
		printf '%s\n' "api_base = \"$ADO_COLLECTION_URL\"" >&2
	fi
	return 1
}
