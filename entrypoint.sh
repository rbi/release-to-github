#!/bin/bash

function validate_parameters() {
  if [ -z "$TAG" ]; then
    echo "ERROR: Tag name must be passed."
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
  for i in "${FILES[@]}"
  do
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
  echo "    -n --name        A name for this release."
  echo "    -b --body        A text describing the content of this release.."
  echo "    -p --prerelease  Mark this release as prerelease."
  echo "    -d --draft       Create a draft release instead of a normal one."
  echo "    -f --files       Files to attach to this release. Multiple files can be separated using a comma."
  echo "    -h --help        Show this help and exit."
  echo ""
  echo "Environment variables"
  echo "    GITHUB_SHA       The commit that will be tagged."
  echo "    GITHUB_TOKEN     Credentials to access the Github API."
}

while :; do
  case $1 in
    -h|--help)
      usage
      exit
      ;;
    -p|--prerelease)
      PRERELEASE=true
      ;;
    -d|--draft)
      DRAFT=true
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
    -n|--name)
      if [ "$2" ]; then
        NAME=$2
        shift
      else
        echo "ERROR: \"$1\" requires a non-empty option argument."
        exit
      fi
      ;;
    -b|--body)
      if [ "$2" ]; then
        BODY=$2
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

validate_parameters

# Github REST API for creating releases: https://developer.github.com/v3/repos/releases/#create-a-release
# Github CLI API: https://hub.github.com/hub-api.1.html
#hub ...
