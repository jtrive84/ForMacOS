#!/usr/bin/bash
# ==============================================================================
# Connect to remotely running jupyter kernel instance using local              |
# jupyter installation. Requires key-based authentication to remote host.      |
# Instructions on how to set up key-based authentication from Windows to       |
# Linux are available here: https://gitlab.cna.com/snippets/32                 |
# ============================================================================== 
# USAGE:
# $ ./launchNotebook.sh --notebook --config=[CFGPATH] --local-port=[PORT] --remote-port=[PORT]
#
# ==============================================================================
CONFIG_DIR="G:/Repos/Utils/Config"


if [[ $# -eq 0 ]]; then
	CFG_NAME=locsrv.cfg
else 
	TEMP_ARG="$1"
	CFG_NAME="${TEMP_ARG%%.cfg}.cfg"
fi

	


	


#~ while [[ "$#" -gt 0 ]]; do
    #~ ##### Parse boolean command line parameters #####
    #~ case "$1" in
        #~ --debug)       DEBUG_IND="Y";;
		#~ --verbose)     DEBUG_IND="Y";;
        #~ --run)         RUN_IND="Y";;
        #~ --lab)         JUPYTER_LAB="Y";;
        #~ --notebook)    JUPYTER_NOTEBOOK="Y";;
    #~ esac

    #~ ### Check for local port argument ###
    #~ if [[ "$1" == --local-port=* ]]; then
        #~ TEMP_ARG="$1"
        #~ LOCAL_PORT="${TEMP_ARG##--local-port=}"
    #~ fi
    
    #~ # Parse configuration file - read variables into memory. 
    #~ if [[ "$1" == --config=* ]]; then
        #~ TEMP_ARG="$1"
        #~ CFG_NAME="${TEMP_ARG##--config=}"
    #~ else
        #~ CFG_NAME="locsrv.cfg"
    #~ fi
       
    #~ ### Check for remote port argument ###
    #~ if [[ "$1" == --remote-port=* ]]; then
        #~ TEMP_ARG="$1"
        #~ REMOTE_PORT="${TEMP_ARG##--remote-port=}"
    #~ fi
    #~ shift
#~ done

# Import configuration options ================================================]
CFG_PATH="${CONFIG_DIR%%/}/${CFG_NAME}"; source "${CFG_PATH}"

# SSH_SPEC="ssh -4 -F /dev/null -i ${SSH_IDENTITY_FILE} ${CID}@${REMOTEHOST}"



echo "Original argument  : ${TEMP_ARG}"
echo "CFG_NAME           : ${CFG_NAME}"
echo "CFG_PATH           : ${CFG_PATH}"
echo "CID                : ${CID}"
echo "REMOTEHOST         : ${REMOTEHOST}"
echo "LOCAL_PORT         : ${LOCAL_PORT}"
echo "REMOTE_PORT        : ${REMOTE_PORT}"
echo "REMOTE_LOGIN_PORT  : ${REMOTE_LOGIN_PORT}"
echo "SSH_IDENTITY_FILE  : ${SSH_IDENTITY_FILE}"
echo "REMOTE_TEMP_FILE   : ${REMOTE_TEMP_FILE}"
echo "REMOTE_NOTEBOOK_DIR: ${REMOTE_NOTEBOOK_DIR}"
echo "REMOTE_PYTHON      : ${REMOTE_PYTHON}"
echo "REMOTE_JUPYTER     : ${REMOTE_JUPYTER}"
echo "LOCAL_PYTHON       : ${LOCAL_PYTHON}"
echo "LOCAL_JUPYTER      : ${LOCAL_JUPYTER}"
echo "LOCAL_BROWSER      : ${LOCAL_BROWSER}"
echo "SSH_SPEC           : ${SSH_SPEC}"
echo "DEBUG_IND          : ${DEBUG_IND}"
echo "RUN_IND            : ${RUN_IND}"
echo "JUPYTER_LAB        : ${JUPYTER_LAB}"
echo "JUPYTER_NOTEBOOK   : ${JUPYTER_NOTEBOOK}"
echo "JUPYTER_QTCONSOLE  : ${JUPYTER_QTCONSOLE}"
echo "APP_SPEC           : ${APP_SPEC}"




# Assign LOCAL_PORT and REMOTE_PORT (if not specified) ========================]
if [[ ${#LOCAL_PORT} -eq 0 ]]; then
    tt=$(date)
    echo "[${tt}] Randomly assigning local port."
    VALID_LOCAL_PORT_IND=0
    while [[ ${VALID_LOCAL_PORT_IND} -eq 0 ]]; do
        CANDIDATE_PORT=$((RANDOM))
        if [ $CANDIDATE_PORT -ge 10000 -a $CANDIDATE_PORT -le 65535 ]; then
            LOCAL_PORT=${CANDIDATE_PORT}; VALID_LOCAL_PORT_IND=1
        fi
    done
fi
if [[ ${#REMOTE_PORT} -eq 0 ]]; then
    tt=$(date)
    echo "[${tt}] Randomly assigning remote port."
    VALID_REMOTE_PORT_IND=0
    while [[ ${VALID_REMOTE_PORT_IND} -eq 0 ]]; do
        CANDIDATE_PORT=$((RANDOM))
        if [ $CANDIDATE_PORT -ge 10000 -a $CANDIDATE_PORT -le 65535 ]; then
            REMOTE_PORT=${CANDIDATE_PORT}; VALID_REMOTE_PORT_IND=1
        fi
    done
fi

# Specify command to be run on remote server ==================================]
if [[ "${JUPYTER_LAB}" == "Y" ]]; then
    APP_SPEC="lab"
else
    APP_SPEC="notebook"
fi


REMOTE_INIT="pushd ${REMOTE_NOTEBOOK_DIR} > /dev/null; ${REMOTE_JUPYTER} ${APP_SPEC} --no-browser --port=${REMOTE_PORT} > notebookurl 2>&1 &"

echo "REMOTE_PORT: ${REMOTE_PORT}"
echo "LOCAL_PORT : ${LOCAL_PORT}"
echo "APP_SPEC   : ${APP_SPEC}"
echo "REMOTE_INIT: ${REMOTE_INIT}"



# Execute REMOTE_INIT on remotehost ===========================================]
tt=$(date)
echo "[${tt}] DEBUG_IND  : ${DEBUG_IND}"
echo "[${tt}] LOCAL_PORT : ${LOCAL_PORT}"
echo "[${tt}] REMOTE_PORT: ${REMOTE_PORT}"
echo "[${tt}] Initializing jupyter session on ${REMOTEHOST} @ ${REMOTE_PORT}."
ssh -4 -i ${SSH_IDENTITY_FILE} ${CID}@${REMOTEHOST} "${REMOTE_INIT}"


# Wait for notebook url file to be present before continuing execution ========]
FILE_EXISTS_IND="0"
while [[ ${FILE_EXISTS_IND} -eq 0 ]]; do
    CHECK_SPEC="pushd ${REMOTE_NOTEBOOK_DIR} > /dev/null; [ -f notebookurl ] && echo 1 || echo 0"
    FILE_EXISTS_IND="$(ssh -4 -i ${SSH_IDENTITY_FILE} jtriv@locsrv ${CHECK_SPEC})"
    sleep 1
done

# Ensure content has been written to file prior to resuming execution =========]
if [[ ${FILE_EXISTS_IND} -eq 1 ]]; then
    tt=$(date)
    echo "[${tt}] notebookurl exists on remotehost: Checking file content."
    LINES_SPEC="pushd ${REMOTE_NOTEBOOK_DIR} > /dev/null; cat notebookurl | wc -l"
    LINES_TOTAL="0"
    i="0"
    while [[ "${LINES_TOTAL}" -eq 0 ]]; do
        tt=$(date)
        echo "[${tt}] [$i] Standing by for session details..."
        sleep 1
        LINES_TOTAL="$(ssh -4 -i ${SSH_IDENTITY_FILE} jtriv@locsrv ${LINES_SPEC})"
        i=$[$i+1]
    done
fi

# =============================================================================]
# Parse file to extract token used to render jupyter notebook locally. 
# It is necessary to surround the actual regular expression pattern by single
# quotes in order to pass it to grep without error.
# =============================================================================]
TOKEN_REGEX="(?<=http://127.0.0.1:${REMOTE_PORT}/\?token=).*"
TOKEN_SPEC="pushd ${REMOTE_NOTEBOOK_DIR} > /dev/null; grep -oP -m 1 '${TOKEN_REGEX}' notebookurl"

if [[ "${DEBUG_IND}" == "Y" ]]; then
    tt=$(date)
    echo "TOKEN_REGEX              : ${TOKEN_REGEX}"
    echo "TOKEN_SPEC               : ${TOKEN_SPEC}"
fi

TOKEN="$(ssh -4 -i ${SSH_IDENTITY_FILE} jtriv@locsrv ${TOKEN_SPEC})"
LOCAL_JUPYTER_URL="http://127.0.0.1:${LOCAL_PORT}/?token=${TOKEN}"

if [[ "${DEBUG_IND}" == "Y" ]]; then
    tt=$(date)
    echo "[${tt}] TOKEN            : ${TOKEN}."
    echo "[${tt}] LOCAL_JUPYTER_URL: ${LOCAL_JUPYTER_URL}."
fi

# Setup jupyter session locally ===============================================]
tt=$(date)
echo "[${tt}] Initializing jupyter session on localhost."
ssh -4 -i "${SSH_IDENTITY_FILE}" -N -f -L 127.0.0.1:${LOCAL_PORT}:127.0.0.1:${REMOTE_PORT} "jtriv@locsrv"
wait


tt=$(date)
echo "[${tt}] Purging notebookurl from remotehost."
REMOVE_SPEC="rm -f ${REMOTE_TEMP_FILE}"
ssh -i ${SSH_IDENTITY_FILE} jtriv@locsrv "${REMOVE_SPEC}"

# Render LOCAL_JUPYTER_URL in LOCAL_BROWSER ===================================]
echo "${LOCAL_JUPYTER_URL}"
"${LOCAL_BROWSER}" "${LOCAL_JUPYTER_URL}"
#echo ""
#echo ""
#echo "${LOCAL_JUPYTER_URL}"
#echo ""
#echo ""
