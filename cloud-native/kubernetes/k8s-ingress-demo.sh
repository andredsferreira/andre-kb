# If using minikube you need to run "minikube tunnel" first

if [[ "${1:-}" == "--cleanup" ]]; then
  kubectl delete deployment alpaca bandicoot
  kubectl delete service alpaca bandicoot
  kubectl delete -f https://projectcontour.io/quickstart/contour.yaml
  kubectl delete -f manif-ingress-demo.yaml
  exit 0
fi

# Install the Contour Ingress controller
kubectl apply -f https://projectcontour.io/quickstart/contour.yaml

kubectl create deployment alpaca --image=nginx:latest
kubectl scale deployment alpaca --replicas=3
kubectl expose deployment alpaca --port=8080 --target-port=80

kubectl create deployment bandicoot --image=nginx:latest
kubectl scale deployment bandicoot --replicas=3
kubectl expose deployment bandicoot --port=8080 --target-port=80

kubectl apply -f manif-ingress-demo.yaml


