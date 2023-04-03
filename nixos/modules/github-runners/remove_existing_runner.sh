#!/usr/bin/env bash
set -ueo pipefail

_GITHUB_HOST=${GITHUB_HOST:="github.com"}

# If URL is not github.com then use the enterprise api endpoint
if [[ ${GITHUB_HOST} == "github.com" ]]; then
  URI="https://api.${_GITHUB_HOST}"
else
  URI="https://${_GITHUB_HOST}/api/v3"
fi

API_HEADER="Accept: application/vnd.github+json"
AUTH_HEADER="Authorization: token ${ACCESS_TOKEN}"
CONTENT_LENGTH_HEADER="Content-Length: 0"

function get_runner_id() {
  # Get the runner id based on its name
  case ${RUNNER_SCOPE} in
  org*)
    _FULL_URL="${URI}/orgs/${ORG_NAME}/actions/runners"
    ;;

  ent*)
    _FULL_URL="${URI}/enterprises/${ENTERPRISE_NAME}/actions/runners"
    ;;

  *)
    _PROTO="https://"
    # shellcheck disable=SC2116
    _URL="$(echo "${REPO_URL/${_PROTO}/}")"
    _PATH="$(echo "${_URL}" | grep / | cut -d/ -f2-)"
    _ACCOUNT="$(echo "${_PATH}" | cut -d/ -f1)"
    _REPO="$(echo "${_PATH}" | cut -d/ -f2)"
    _FULL_URL="${URI}/repos/${_ACCOUNT}/${_REPO}/actions/runners"
    ;;
  esac

  RUNNERS="$(curl -XGET -fsSL \
    -H "${CONTENT_LENGTH_HEADER}" \
    -H "${AUTH_HEADER}" \
    -H "${API_HEADER}" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "${_FULL_URL}")"
  ID=$(echo "$RUNNERS" | jq -r '.runners[] | select( (.name == env.RUNNER_NAME) and (.status == "offline") ) | .id')
  echo "$ID"
}

RUNNER_ID=$(get_runner_id)
if [[ $RUNNER_ID == "" ]]; then
  echo "Runner ${RUNNER_NAME} doesn't exist. Nothing to unregister"
  exit 0
fi
echo "${RUNNER_NAME} is still registered and offline. Forcing removal..."

case ${RUNNER_SCOPE} in
org*)
  _FULL_URL="${URI}/orgs/${ORG_NAME}/actions/runners/${RUNNER_ID}"
  ;;

ent*)
  _FULL_URL="${URI}/enterprises/${ENTERPRISE_NAME}/actions/runners/${RUNNER_ID}"
  ;;

*)
  _PROTO="https://"
  # shellcheck disable=SC2116
  _URL="$(echo "${REPO_URL/${_PROTO}/}")"
  _PATH="$(echo "${_URL}" | grep / | cut -d/ -f2-)"
  _ACCOUNT="$(echo "${_PATH}" | cut -d/ -f1)"
  _REPO="$(echo "${_PATH}" | cut -d/ -f2)"
  _FULL_URL="${URI}/repos/${_ACCOUNT}/${_REPO}/actions/runners/${RUNNER_ID}"
  ;;
esac

curl -XDELETE -fsSL \
  -H "${CONTENT_LENGTH_HEADER}" \
  -H "${AUTH_HEADER}" \
  -H "${API_HEADER}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "${_FULL_URL}"
