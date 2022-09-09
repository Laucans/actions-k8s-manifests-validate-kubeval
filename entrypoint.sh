#!/bin/sh

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
COMMENT=$7
GITHUB_TOKEN=$8
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

# Make validation details for the github comment (filter "PASS" line)
GIT_COMMENT="## ⚠ [kubeval] Validation Failed
<details><summary><code>detail</code></summary>

\`\`\`
$(echo "${OUTPUT}" | grep -v ^PASS | grep -v "Set to ignore missing schemas")
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

