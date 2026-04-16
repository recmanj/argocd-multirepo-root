default_env := "test"

install-argocd:
    kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
    helm install argocd argo-cd --repo https://argoproj.github.io/argo-helm --version 9.4.16 -n argocd

bootstrap env=default_env:
    helm install bootstrap ./bootstrap --set env={{ env }} -n argocd

argocd-password:
    @kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

render-bootstrap env=default_env:
    helm template bootstrap ./bootstrap --set env={{ env }} -n argocd

render-argocd:
    @find argocd -name '*.yaml' -exec echo '---' \; -exec cat {} \;

render env=default_env: (render-bootstrap env) render-argocd
