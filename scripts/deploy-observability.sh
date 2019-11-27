#!/usr/bin/env bash

# Copyright 2018 The Learndot Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

CLUSTER=${CLUSTER:-mooplayground}

deployPrometheusOperator() {
    rdsCreds=$(aws secretsmanager get-secret-value --region=us-west-2 --secret-id "/operations/moo/monitoring/grafana/rdscreds" --query "SecretString" | jq "fromjson")
    username=$(echo $rdsCreds | jq ".username" | sed "s/\"//g")
    password=$(echo $rdsCreds | jq ".password" | sed "s/\"//g")
    cat ${CLUSTER}/prometheus-operator/*.yaml | sed "s/GRAFANA_DB_USERNAME/$username/g" | sed "s/GRAFANA_DB_PASSWORD/$password/g" | kubectl apply -f -
}


main() {
    aws eks update-kubeconfig --name ${CLUSTER} --region=us-west-2
    kubectl config set-context --current --namespace=monitoring
    kubectl apply -n kube-system -f ${CLUSTER}/metrics-server/*
    kubectl apply -n kube-system -f ${CLUSTER}/cluster-autoscaler/*
    deployPrometheusOperator
    kubectl apply -f  ${CLUSTER}/prometheus-adapter/*
    kubectl apply -f  ${CLUSTER}/helm-exporter/*
    kubectl apply -n monitoring -f ${CLUSTER}/thanos/
}

main