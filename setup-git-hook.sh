#!/bin/bash

cat <<\EOF > .git/hooks/pre-commit
#!/bin/bash
BRANCH="$(git symbolic-ref HEAD 2>/dev/null)"
BRANCH=${BRANCH##refs/heads/}
echo "$BRANCH"
if [[ "$BRANCH" == "master" || "$BRANCH" == "develop" ]]; then
  echo "You are on branch $BRANCH. Are you sure you want to commit to this branch?"
  echo "If so, commit with -n to bypass this pre-commit hook."
  exit 1
fi
exit 0
EOF
chmod a+x .git/hooks/pre-commit
