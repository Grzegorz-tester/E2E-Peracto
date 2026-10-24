#cucumber tag, then any extra cucumber-js arguments (e.g. --dry-run, --tags, --name)
tag=$1
shift

#cucumber 13 needs Node 22+ (see .nvmrc) - fail clearly rather than with a cryptic import error
node_major=$(node -p 'process.versions.node.split(".")[0]')
if [ "$node_major" -lt 22 ]; then
  echo "Node $(node -v) is too old: this suite needs Node 22+. Run 'nvm use' first." >&2
  exit 1
fi

#run cucumber tests & always generate the report afterwards, preserving the test exit code
yarn run cucumber --profile "$tag" "$@"
exit_code=$?
yarn run postcucumber
exit $exit_code
