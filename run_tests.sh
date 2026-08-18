#cucumber tag
tag=$1

#run cucumber tests & always generate the report afterwards, preserving the test exit code
yarn run cucumber --profile $tag
exit_code=$?
yarn run postcucumber
exit $exit_code