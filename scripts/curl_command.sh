#!/bin/bash

USER="" #Set Username in Account Credentials
KEY="" #Set API Key(Password) in Account Credentials
AUTH_ENDPOINT="" #Set Authentication Endpoint in Account Credentials
CONTAINER_NAME="" #Set YOUR container name




function error_exit() {
    echo "Exit with errors."
    exit 1
}

function check_key() {
    STATUS=$(curl -s -X GET -i -H "X-Auth-User: ${USER}" -H "X-Auth-Key: ${KEY}" ${AUTH_ENDPOINT} | grep HTTP/1.1 | awk '{print $2}')

    if [ ${STATUS} -eq 200 ]; then
        # echo "Authentication suceeded"
        return 0
    else
        echo "Authentication failed. Please check if your USER / KEY / AUTH_ENDPOINT / CONTAINER_NAME is set appropriately"
        return 1
    fi
}

function get_token() {
    XAUTHTOKEN=$(curl -s -X GET -i -H "X-Auth-User: ${USER}" -H "X-Auth-Key: ${KEY}" ${AUTH_ENDPOINT} | grep X-Auth-Token: | sed 's/\r//')
    API_ENDPOINT=$(curl -s -X GET -i -H "X-Auth-User: ${USER}" -H "X-Auth-Key: ${KEY}" ${AUTH_ENDPOINT} | grep -Eo "\"public\"\:\ \"http.*\"" | awk -F \" '{print $4}')

    if [ -z "${XAUTHTOKEN}" ]; then
        echo "XAUTHTOKEN is empty"
        return 1
    fi

    if [ -z "${API_ENDPOINT}" ]; then
        echo "API_ENDPOINT is empty"
        return 1
    fi

}

function get_container_contents() {
    #echo "${CONTAINER_NAME}のファイル一覧を取得するには、以下のコマンドを実行してください"
    echo "To get file list in the ${CONTAINER_NAME}, please execute command below."
    echo ""
    echo "curl -s -X GET -i -H \"${XAUTHTOKEN}\" ${API_ENDPOINT}/${CONTAINER_NAME}"
    echo -e "\n"
}

function put_container_contents() {
    #echo "upload.imgを${CONTAINER_NAME}にアップロードする為には、以下のコマンド(二行)を実行してください"
    echo "To upload file 'upload.img' to ${CONTAINER_NAME}, please create 'upload.img' using dd"
    echo ""
    echo "dd if=/dev/zero of=upload.img bs=1M count=5"
    echo ""
    echo "and upload file using curl"
    echo "curl -s -X PUT -T upload.img -v -H \"${XAUTHTOKEN}\" ${API_ENDPOINT}/${CONTAINER_NAME}/upload.img"
}





##########    main    ##########

check_key || error_exit
get_token || error_exit
get_container_contents
put_container_contents



