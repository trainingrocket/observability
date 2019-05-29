workflow "Deploy Observability to Kubernetes" {
  on = "push"
  resolves = [ 
      "Branch Filter",
      "Configure Cluster Credentials",
      "Deploy Manifests To Cluster"
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

action "Deploy Manifests To Cluster" {
  uses = "./.github/actions/eks-kubectl"
  needs = [
      "Configure Cluster Credentials"
   ]
  runs = "sh -l -c"
  args = [ 
      "SHORT_REF=$(echo $GITHUB_SHA | head -c7) && cat $GITHUB_WORKSPACE/mooplayground/prometheus-operator/ | sed 's/TAG/'\"$SHORT_REF\"'/' | kubectl apply -f - "
  ]
  env = { }
  secrets = [
      "AWS_ACCESS_KEY_ID", 
      "AWS_SECRET_ACCESS_KEY"
   ]
}