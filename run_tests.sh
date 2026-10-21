#cucumber tag, then any extra cucumber-js arguments (e.g. --dry-run, --tags, --name)
tag=$1
shift

#run cucumber tests & always generate the report afterwards, preserving the test exit code
yarn run cucumber --profile "$tag" "$@"
exit_code=$?
yarn run postcucumber
exit $exit_code
