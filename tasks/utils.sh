check_param() {
  local name=$1
  local value=$(eval echo '$'$name)
  if [ "$value" == 'replace-me' ]; then
    echo "environment variable $name must be set"
    exit 1
  fi
}

print_git_state() {
  local git_project=$1
  pushd $git_project
  echo "--> last commit for ${git_project}..."
  TERM=xterm-256color git log -1
  echo "---"
  echo "--> local changes for ${git_project} (e.g., from 'fly execute')..."
  TERM=xterm-256color git status -vv
  echo "---"
  popd
}

enable_github_work() {
  mkdir -p $HOME/.ssh
  chmod 700 $HOME/.ssh
  touch $HOME/.ssh/config
  if ! grep -q github.com  $HOME/.ssh/config; then
    echo "Host github.com" >> $HOME/.ssh/config
    echo "  StrictHostKeyChecking no" >> $HOME/.ssh/config
  fi
}

generate_latest_commit_msg() {
  echo 'Latest commits:'$'\n\n'
  for repo in env-aws cloudops-ci cloudops-tools; do
    pushd $repo 2>&1 >/dev/null
    repo_reference=$(git remote -v | grep fetch |  cut -d':' -f2 | cut -d' ' -f1|sed "s/.git//g")
    git log --pretty=format:"%ad $repo_reference@%h %s" --date=short HEAD^..HEAD
    echo
    popd 2>&1 >/dev/null
  done
}

git config --global user.email "cloudops@pivotal.io"
git config --global user.name "Cloudops CI"
enable_github_work
