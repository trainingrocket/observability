workflow "Build and Deploy" {
  on = "push"
  resolves = [
      "Verify Manifests Deployment"
    ]
}

action "Branch Filter" {
  uses = "actions/bin/filter@master"
  args = [
      "branch master"
    ]
}

action "Deploy to EKS" {
  uses = "actions/aws/kubectl@master"
  needs = [
      "Branch Filter"
    ]
  runs = "sh -l -c"
  args = [
      "kubectl apply -f $GITHUB_WORKSPACE/mooplayground/prometheus-operator/prometheus-operator.yaml -n monitoring"
    ]
  secrets = [
      "KUBE_CONFIG_DATA",
    ]
}

action "Verify Manifests Deployment" {
  uses = "actions/aws/kubectl@master"
  needs = [
      "Deploy to EKS"
    ]
  args = [
      "kubectl get pods -n monitoring"
    ]
  secrets = [
      "KUBE_CONFIG_DATA",
    ]
}