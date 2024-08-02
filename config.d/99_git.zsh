# ANSI color codes
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RESET="\033[0m"

# Symbols
CROSS_MARK="❌"
CHECK_MARK="✅"
WORKING="🛠️"
ROCKET="🚀"

CROSS="${RED}${CROSS_MARK}${RESET}"
CHECK="${GREEN}${CHECK_MARK}${RESET}"

# Clones a Git repository with customizable service host and protocol.
# Usage: cloneGitRepo <repository_path> [service_host] [protocol]
function gcb() {
  local repository_path=${1:-}
  local service_host=${2:-github.com}
  local protocol=${3:-ssh}

  if [[ -z "$repository_path" ]]; then 
    echo "${CROSS} Repository path is required."
    echo ""
    echo "usage: gcb repository_path service_host protocol"

    return 1
  fi

  if [[ "$protocol" != "ssh" && "$protocol" != "https" ]]; then 
    echo "${CROSS} Invalid protocol, use ssh or https."
    echo ""
    echo "usage: gcb repository_path service_host protocol"

    return 1;
  fi

  local url
  if [[ "$protocol" == "ssh" ]]; then
    url="git@${service_host}:${repository_path}.git"
  else
    url="https://${service_host}/${repository_path}.git"
  fi

  local repository="${repository_path##*/}"

  git clone --quiet --bare "${url}" "${repository}"


  echo "${CHECK} Cloned ${YELLOW}${repository_path}${RESET} to ${YELLOW}${repository}${RESET}."

  if [ $? -ne 0 ]; then
    echo "${CROSS} Failed to clone ${YELLOW}${repository}${RESET}."
    return 1
  fi

  cd "${repository}" || {echo "${CROSS} Failed to enter ${YELLOW}${repository}${RESET}."; return 1;}

  # Check if the 'main' branch exists, fall back to 'master' if not
  local branch_name="main"

  if ! git show-ref --verify --quiet "refs/heads/${branch_name}"; then
    branch_name="master"

    if ! git show-ref --verify --quiet "refs/heads/${branch_name}"; then
      echo "${CROSS} Neither 'main' nor 'master' branches found."
      return 1
    fi
  fi

  git worktree add -q "${branch_name}" || { echo "${CROSS} Failed to add worktree for main."; return 1; }

  cd "${branch_name}"

  git config advice.setUpstreamFailure false
  git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"

  echo "${CHECK} ${YELLOW}${branch_name}${RESET} ready to track ${YELLOW}origin/${branch_name}${RESET}."

  git fetch -q origin &> /dev/null
  git branch -q --set-upstream-to=origin/"${branch_name}" "${branch_name}"

  echo "${ROCKET} ${YELLOW}${repository}${RESET} ready to use."
}

function gwa() {
  local branch=${1}

  if [[ -z "${branch}" ]]; then
    echo "${CROSS} Worktree name is required."
  fi

  git worktree add -q "${branch}" || { echo "${CROSS} Failed to add worktree."; return 1; }

  echo "${CHECK} ${YELLOW}${branch}${RESET} ready to use."

  cd "${branch}"
}
