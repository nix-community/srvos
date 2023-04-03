#!/usr/bin/env bash
# original code in https://github.com/myoung34/docker-github-actions-runner
#
# MIT License
#
# Copyright (c) 2020 Marcus Young
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set -eu
_GITHUB_HOST=${GITHUB_HOST:="github.com"}

# If URL is not github.com then use the enterprise api endpoint
if [[ ${GITHUB_HOST} == "github.com" ]]; then
  URI="https://api.${_GITHUB_HOST}"
else
  URI="https://${_GITHUB_HOST}/api/v3"
fi

API_VERSION=v3
API_HEADER="Accept: application/vnd.github.${API_VERSION}+json"
AUTH_HEADER="Authorization: token ${ACCESS_TOKEN}"
CONTENT_LENGTH_HEADER="Content-Length: 0"

case ${RUNNER_SCOPE} in
org*)
  _FULL_URL="${URI}/orgs/${ORG_NAME}/actions/runners/registration-token"
  ;;

ent*)
  _FULL_URL="${URI}/enterprises/${ENTERPRISE_NAME}/actions/runners/registration-token"
  ;;

*)
  _PROTO="https://"
  # shellcheck disable=SC2116
  _URL="$(echo "${REPO_URL/${_PROTO}/}")"
  _PATH="$(echo "${_URL}" | grep / | cut -d/ -f2-)"
  _ACCOUNT="$(echo "${_PATH}" | cut -d/ -f1)"
  _REPO="$(echo "${_PATH}" | cut -d/ -f2)"
  _FULL_URL="${URI}/repos/${_ACCOUNT}/${_REPO}/actions/runners/registration-token"
  ;;
esac

RUNNER_TOKEN="$(curl -XPOST -fsSL \
  -H "${CONTENT_LENGTH_HEADER}" \
  -H "${AUTH_HEADER}" \
  -H "${API_HEADER}" \
  "${_FULL_URL}" |
  jq -r '.token')"

echo "{\"token\": \"${RUNNER_TOKEN}\", \"full_url\": \"${_FULL_URL}\"}"
