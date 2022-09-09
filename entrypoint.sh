#!/usr/bin/env bash

set -e

# ------------------------
#  Args
# ------------------------
FILES=$1
VERSION=$2
STRICT=$3
OPENSHIFT=$4
IGNORE_MISSING_SCHEMAS=$5
IGNORED_FILENAME_PATTERNS=$6
IGNORED_LOGS_WORDS=$7
COMMENT=$8
GITHUB_TOKEN=$9
# ------------------------
# Vars
# ------------------------
SUCCESS=0
GIT_COMMENT=""

# ------------------------
#  Main
# ------------------------
cd ${GITHUB_WORKSPACE}/${WORKING_DIR}

set +e

# exec kubeval
CMD="kubeval --directories ${FILES} --output stdout --strict=${STRICT} --kubernetes-version=${VERSION} --openshift=${OPENSHIFT} --ignored-filename-patterns=\"${IGNORED_FILENAME_PATTERNS}\" --ignore-missing-schemas=${IGNORE_MISSING_SCHEMAS}"
OUTPUT=$(sh -c "${CMD}" 2>&1)
SUCCESS=$?

set -e

# let's log command
echo "executed: $CMD"
echo "return code: ${SUCCESS}"

if [ ${SUCCESS} -eq 0 ]; then
	echo "Validate success!"
	exit 0
fi

IFS=',' 
read -r -a ARRAY_OF_BLACKLISTED_SUBSTRING <<< "$IGNORED_LOGS_WORDS"

GREP_PARAM=""

for i in ${ARRAY_OF_BLACKLISTED_SUBSTRING[@]}
do
  GREP_PARAM="$GREP_PARAM | grep -v \"$(echo $i | xargs)\""
done

CMD="echo \"${OUTPUT}\" | grep -v \"^PASS\" ${GREP_PARAM}"
echo "running filter with : $CMD"

# We want to exit 0 later if grep command return empty result. 
# That's mean there is no important issues
set +e
FILTERED_ERROR=`eval ${CMD}`
set -e
if [ "${FILTERED_ERROR}" = "" ]; then
	echo "Validate success!"
	exit 0
fi

# Make validation details for the github comment (filter "PASS" line)
GIT_COMMENT="## ⚠ [kubeval] Validation Failed
<details><summary><code>detail</code></summary>

\`\`\`
${FILTERED_ERROR}
\`\`\`
</details>

"

# comment to github
if [ "${COMMENT}" = "true" ];then
	echo "Comment PR is activated"
	PAYLOAD=$(echo '{}' | jq --arg body "${GIT_COMMENT}" '.body = $body')
	COMMENTS_URL=$(cat ${GITHUB_EVENT_PATH} | jq -r .pull_request.comments_url)
	curl -sS -H "Authorization: token ${GITHUB_TOKEN}" --header "Content-Type: application/json" --data "${PAYLOAD}" "${COMMENTS_URL}" >/dev/null
fi

exit ${SUCCESS}

