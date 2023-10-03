#!/bin/bash

COPYING=0
CLEANING=0

function cleanup() {
	if [[ $CLEANING -eq 0 && ! "$NOCLEANUP" ]]; then
		CLEANING=1
		[[ "$VERBOSE" ]] && echo "Deleting ${RUNDIR}."
		cd ${CWD}
		rm -fr ${RUNDIR}
	fi
	exit ${EV}
}

function copyback() {
	if [[ $COPYING -eq 0 ]]; then
		COPYING=1
		[[ "$VERBOSE" ]] && echo "Copying back new files from ${RUNDIR} to ${CWD}."
		rsync -SHPauq --delete ${RUNDIR}/ ${CWD} || ( echo "Trouble copying files back." && exit 1 )
		[[ "$VERBOSE" ]] && echo "Done copying files."
	fi
	cleanup
}

if [[ "${1}" == "" || "${1}" == "-h" || "${1}" == "--help" ]]; then
	echo -e "Runs a command in another directory."
	echo -e "The script recursively copies the current directory,"
	echo -e "runs a command, and updates the changed files.\n"
	echo -e "Usage:\n\t$0 <command>"
	echo "Environment variables:"
	echo -e "\tNOCLEANUP : do not remove running directory."
	echo -e "\tRUNDIR : Run in this directory; default is a random directory in \${TMPDIR}."
	echo -e "\tVERBOSE : Shows the steps."
	exit 1
fi


CMD=$@

RUNDIR=${RUNDIR:-$TMPDIR/$RANDOM}
CWD=$PWD

if [ "${CWD}" != "`pwd`" ]; then
	echo "Could not determine current directory."
	echo "${CWD} vs. `pwd`"
	exit 1
fi

mkdir -p ${RUNDIR} || ( echo "Could not create the ${RUNDIR} temporary directory." && exit 1 )
trap cleanup SIGINT SIGTERM SIGKILL SIGUSR2
[[ "$VERBOSE" ]] && echo "Copying files from ${CWD} to ${RUNDIR}."
rsync -SHPaq --delete ./ ${RUNDIR} || ( rm -fr ${RUNDIR} && exit 1 )

EV=0

# BSUB does SIGINT, SIGTERM, SIGKILL 10 s. apart
trap copyback SIGINT SIGTERM

cd ${RUNDIR} || ( echo "Could not change directory to ${RUNDIR}." && exit 1 )

[[ "$VERBOSE" ]] && echo "Running ${CMD} in ${RUNDIR} ${PWD}."
eval $CMD

EV=$?

copyback

