# Clones a Git repository with customizable service host and protocol.
# Usage: cloneGitRepo <repository_path> [service_host] [protocol]
function gcb() {
  local repository_path=${1:-}
  local service_host=${2:-github.com}
  local protocol=${3:-ssh}

  if [[ -z "$repository_path" ]]; then 
    echo "${RED}${CROSS_MARK}${RESET} Repository path is required."
    return 1
  fi

  if [[ "$protocol" != "ssh" && "$protocol" != "https" ]]; then 
    echo "${RED}${CROSS_MARK}${RESET} Invalid protocol, use ssh or https."
    return 1;
  fi

  local url
  if [[ "$protocol" == "ssh" ]]; then
    url="git@${service_host}:${repository_path}.git"
  else
    url="https://${service_host}/${repository_path}.git"
  fi

  local repository="${repository_path##*/}"

  git clone --bare "${url}" "${repository}"

  if [ $? -ne 0 ]; then
    echo "${RED}${CROSS_MARK}${RESET} Failed to clone repository."
    return 1
  fi

  cd "${repository}" || {echo "${RED}${CROSS_MARK}${RESET} Failed to enter ${repository}."; return 1;}

  # Check if the 'main' branch exists, fall back to 'master' if not
  local branch_name="main"
  if ! git show-ref --verify --quiet "refs/heads/${branch_name}"; then
    branch_name="master"

    if ! git show-ref --verify --quiet "refs/heads/${branch_name}"; then
      echo "${RED}${CROSS_MARK}${RESET} Neither 'main' nor 'master' branches found."
      return 1
    fi
  fi

  git worktree add "$branch_name" || { echo "${RED}${CROSS_MARK}${RESET} Failed to add worktree for main."; return 1; }
  git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"

  echo "${GREEN}${CHECK_MARK}${RESET} Cloned ${repository_path} to ${repository}"
}

function gwa() {
  local branch=${1}

  if [[ -z "${branch}" ]]; then
    echo "${RED}${CROSS_MARK}${RESET} Worktree name is required."
  fi

  git worktree add "${branch}" || { echo "${RED}${CROSS_MARK}${RESET} Failed to add worktree."; return 1; }


  cd "${branch}"
}
