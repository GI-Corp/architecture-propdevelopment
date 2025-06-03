# Скрипт создания пользователей для кластера Kubernetes
#!/bin/bash

USERS=("secure-operator" "cluster-viewer" "cluster-manager")
DAYS_VALID=365
K8S_CA_CRT="/etc/kubernetes/pki/ca.crt"
K8S_CA_KEY="/etc/kubernetes/pki/ca.key"

create_user() {
    USER=$1
    echo "Создание пользователя: $USER"

    openssl genrsa -out ${USER}.key 2048
    openssl req -new -key ${USER}.key -out ${USER}.csr -subj "/CN=${USER}"

    openssl x509 -req -in ${USER}.csr -CA ${K8S_CA_CRT} -CAkey ${K8S_CA_KEY} -CAcreateserial -out ${USER}.crt -days ${DAYS_VALID}

    kubectl config set-credentials ${USER} \
        --client-certificate=${USER}.crt \
        --client-key=${USER}.key

    echo "Пользователь ${USER} успешно создан и добавлен в kubeconfig"
}

for USER in "${USERS[@]}"; do
    create_user "$USER"
done

echo "Все пользователи успешно созданы"
