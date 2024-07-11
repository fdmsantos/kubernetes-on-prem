GITHUB_TOKEN=<gh-token>
flux bootstrap github \
  --token-auth \
  --owner=fdmsantos \
  --repository=kubernetes-on-prem \
  --branch=main \
  --path=clusters/my-cluster \
  --personal \
  --private=false