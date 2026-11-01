#### Update kube config

Update the kubeconfig so you can interact with your cluster via **kubectl** (the
kubeconfig file is present under $HOME/.kube/config).

```bash
aws eks update-kubeconfig --region region-code --name my-cluster
```

