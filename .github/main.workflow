workflow "Build and Deploy" {
  on = "push"
  resolves = [
      "Verify EKS Deployment"
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
      "apply -f $GITHUB_WORKSPACE/mooplayground/prometheus-operator/prometheus-operator.yaml -n monitoring"
    ]
  secrets = [
      "KUBE_CONFIG_DATA",
    ]
}

action "Verify EKS Deployment" {
  uses = "actions/aws/kubectl@master"
  needs = [
      "Deploy to EKS"
    ]
  args = [
      "rollout status deployment/prometheus-operator -n monitoring"
    ]
  secrets = [
      "KUBE_CONFIG_DATA",
    ]
}