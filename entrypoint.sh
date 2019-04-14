#!/bin/bash

IFS="
"

function validate_parameters() {

  if ( [ ! -z $TAG_FILE ] && [ ! -f $TAG_FILE] ); then
    echo "ERROR: Tag file $TAG_FILE does not exist."
    usage
    exit
  fi

  if ( [ -z "$TAG" ] && [ -z $TAG_FILE ] ); then
    echo "ERROR: Tag name (-t or -x) must be passed."
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
  echo "    -t --tag         The name for the Git tag to create for the release."
  echo "    -x --tag-file    A file that contains the name of the Git tag to create for the release."
  echo "    -m --message     A text describing the content of this release."
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
COMMIT=

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
    -x|--tag-file)
      if [ "$2" ]; then
        TAG_FILE=$2
        shift
      else
        echo "ERROR: \"$1\" requires a non-empty option argument."
        exit
      fi
      ;;

    -m|--message)
      if [ "$2" ]; then
        MESSAGE=--message=$2
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

if [ ! -z "$GITHUB_SHA" ]; then
  COMMIT="-t ${GITHUB_SHA}"
fi

if [ -z "$MESSAGE" ]; then
  MESSAGE=--message="automatic release"
fi

if [ ! -z $TAG_FILE ]; then
  TAG=`cat $TAG_FILE`
fi

FILES_ATTACH=
for i in "${FILES[@]}"; do
  FILES_ATTACH="-a${i}
${FILES_ATTACH}"
done

hub release create $MESSAGE $DRAFT $PRERELEASE $FILES_ATTACH $COMMIT $TAG
