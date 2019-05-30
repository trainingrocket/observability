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

action "Configure Kube Credentials" {
  needs = [
    "Branch Filter"
  ]
  uses = "actions/aws/cli@master"
  env = {
    AWS_DEFAULT_REGION = "us-west-2"
    CLUSTER_NAME = "mooplayground"
  }
  args = [
    "eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_DEFAULT_REGION"
  ]
  secrets = [
    "AWS_ACCESS_KEY_ID", 
    "AWS_SECRET_ACCESS_KEY"
  ]
}

action "Deploy to EKS" {
  uses = "./.github/actions/eks-kubectl"
  needs = [
      "Configure Kube Credentials"
  ]
  runs = "sh -l -c"
  args = [
      "kubectl config set-context --current --namespace=monitoring"
      "kubectl apply -f $GITHUB_WORKSPACE/mooplayground/prometheus-operator/"
  ]
  secrets = [
      "AWS_ACCESS_KEY_ID",
      "AWS_SECRET_ACCESS_KEY"
  ]
}

action "Verify Manifests Deployment" {
  uses = "./.github/actions/eks-kubectl"
  needs = [
      "Deploy to EKS"
  ]
  args = [
      "kubectl get pods -n monitoring"
  ]
  secrets = [
      "AWS_ACCESS_KEY_ID",
      "AWS_SECRET_ACCESS_KEY",
  ]
}