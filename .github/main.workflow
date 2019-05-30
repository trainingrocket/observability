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

action "Configure Cluster Credentials" {
  uses = "actions/aws/cli@master"
  needs = [
      "Branch Filter"
   ]
  args = [
      "eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_DEFAULT_REGION"
   ]
  env = {
    CLUSTER_NAME = "mooplayground"
    AWS_DEFAULT_REGION = "us-west-2"
   }
  secrets = [ 
      "AWS_ACCESS_KEY_ID", 
      "AWS_SECRET_ACCESS_KEY"
  ]
}

action "Deploy to EKS" {
  uses = "actions/aws/kubectl@master"
  needs = [
      "Configure Cluster Credentials"
    ]
  runs = "sh -l -c"
  args = [
      "kubectl apply -f $GITHUB_WORKSPACE/prometheus-operator/prometheus-operator.yaml -n monitoring"
    ]
  secrets = [
      "AWS_ACCESS_KEY_ID", 
      "AWS_SECRET_ACCESS_KEY"
    ]
}

action "Verify EKS Deployment" {
  uses = "actions/aws/kubectl@master"
  needs = [
      "Deploy to EKS"
    ]
  args = [
      "rollout status deployment/prometheus-operator"
    ]
  secrets = [
      "AWS_ACCESS_KEY_ID", 
      "AWS_SECRET_ACCESS_KEY"
    ]
}