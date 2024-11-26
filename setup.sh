#!/bin/bash

kind create cluster

helm repo add crossplane-stable https://charts.crossplane.io/stable

helm repo update

helm install crossplane --namespace crossplane-system --create-namespace crossplane-stable/crossplane --wait

kubectl apply -f apis/xsqls/

sleep 5

kubectl apply -f examples/sql/my-db.yaml