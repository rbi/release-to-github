#!/bin/bash

function validate_parameters() {
  if [ -z "$TAG" ]; then
    echo "ERROR: Tag name must be passed."
    usage
    exit
  fi

  if [ -z "$MESSAGE" ]; then
    echo "ERROR: A message must be passed."
    usage
    exit
  fi


  if [ -z "$GITHUB_SHA" ]; then
    echo "ERROR: The environment variable GITHUB_SHA musst be set."
    usage
    exit
  fi

  if [ -z "$GITHUB_TOKEN" ]; then
    echo "ERROR: The environment variable GITHUB_TOKEN musst be set."
    usage
    exit
  fi

  IFS="," read -a FILES <<< "${FILES_STRING}"
  for i in "${FILES[@]}"; do
    if [ ! -f "$i" ]; then
      echo "ERROR: file $i does not exist."
      usage
      exit
    fi
  done
}


function usage() {
  echo "Usage: $0 [options]"
  echo "    -t --tag         (required) The name for the Git tag to create for the release."
  echo "    -m --message     (required) A text describing the content of this release.."
  echo "    -p --prerelease  Mark this release as prerelease."
  echo "    -d --draft       Create a draft release instead of a normal one."
  echo "    -f --files       Files to attach to this release. Multiple files can be separated using a comma."
  echo "    -h --help        Show this help and exit."
  echo ""
  echo "Environment variables"
  echo "    GITHUB_SHA        The commit that will be tagged."
  echo "    GITHUB_TOKEN      Credentials to access the Github API."
}

TAG=
DRAFT=
PRERELEASE=
MESSAGE=

while :; do
  case $1 in
    -h|--help)
      usage
      exit
      ;;
    -p|--prerelease)
      PRERELEASE="-p"
      ;;
    -d|--draft)
      DRAFT="-d"
      ;;
    -t|--tag)
      if [ "$2" ]; then
        TAG=$2
        shift
      else
        echo "ERROR: \"$1\" requires a non-empty option argument."
        exit
      fi
      ;;
    -m|--message)
      if [ "$2" ]; then
        MESSAGE="--message=\"$2\""
        shift
      else
        echo "ERROR: \"$1\" requires a non-empty option argument."
        exit
      fi
      ;;
    -f|--files)
      if [ "$2" ]; then
        FILES_STRING=$2
        shift
      else
        echo "ERROR: \"$1\" requires a non-empty option argument."
        exit
      fi
      ;;

    --)
      shift
      break
      ;;
    -?*)
      echo "WARN: Unknown option (ignored): $1"
      ;;
    *)
       break
  esac
  shift
done

COMMIT="-t ${GITHUB_SHA}"

validate_parameters

# Github REST API for creating releases: https://developer.github.com/v3/repos/releases/#create-a-release
# Github CLI releases: https://hub.github.com/hub-release.1.html

FILES_ATTACH=

for i in "${FILES[@]}"; do
  FILES_ATTACH="-a \"${i}\" ${FILES_ATTACH}"
done

hub release create $MESSAGE $DRAFT $PRERELEASE $FILES_ATTACH $COMMIT $TAG
