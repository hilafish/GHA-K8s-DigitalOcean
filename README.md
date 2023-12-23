# Top read for this project

This project will not work by just cloning it.
You'll need to follow the prerequisites listed in this page in order to run the code (TF+GHA)

## Terraform run instructions

Prerequisites to run the terraform code:
1. generate digitalocean_token on DigitalOcean (API->tokens section) and set as an environment variable (`export TF_VAR_digitalocean_token=token_set_here`) on the station/server Terraform was run on. 
In production, it should be taken from a secret manager of some sort (AWS secrets manager in AWS, HAshicorp Vault, etc).


## Github-Actions instructions

Prerequisites to run the github actions workflows:
1. Add the digitalocean_token also as a github secret for the github workflow to use, via settings->secrets & variables sections. Call it DIGITALOCEAN_ACCESS_TOKEN
2. Add the "registry.digitalocean.com/go-registry" (digitalocean default registry name, if you haven't changed it) as a github secret as well, under the value "REGISTRY_NAME".
3. Add the "k8s-sp-test-cluster" (digitalocean default k8s cluster name, if you haven't changed it. if you did, it'll always be constructed as ${var.cluster_name}-${environment}-cluster, but you can always check the name on digitalocean UI) as a github secret as well, under the value "CLUSTER_NAME". 
4. Integrate the DigitalOcean Container Registry that was created by TF with the DigitalOcean k8s cluster by running this command `doctl kubernetes cluster registry add k8s-sp-test-cluster` (or via UI- Kubernetes->Settings Tab->DigitalOcean Container Registry Integration).
Ideally would be set in TF (via running the doctl command or via creating a secret as explained in DigitalOcean docs section).

Github-Actions overview:
1. it gets invoked on every push to main branch. it builds the docker image using the Dockerfile in the repo, pushes the image to the registry after login (hence why the DIGITALOCEAN_ACCESS_TOKEN is needed) and then replaces the image on the deployment manifest in the manifest.yml. 
* the github actions curently deploys the entire manifest which includes the deployment, service, pdb and hpa (to accomodate the requirements given in the assignment). on regular production environment, it would not deploy all, but only deployment.yml based on image tag change (even though upon no changes, the rest of the manifest is not changed, but not sure we want to give visibility via the ci to the rest of the k8s cluster resources), and the rest of the k8s resources would either be managed via a separate github actions workflow or via terraform in a separate flow - depends on the use case, requirements and level of flexibility we want to achieve.
2. you can access the app via browsing the loadbalancer external ip with port 80.

Update - Github-Actions additions for the Service SSL support -
1. creating the secret with the self signed key via kubectl command and not via addition of secret to the manifest.yml due to issues of converting it to base64 that way. didn't want to waste more time on that so I did it the easy way.
2. added checks to see if ingress-nginx-controller already deployed, because I noticed that it applies its manifests every CI run (a.k.a status is configured and not untouched) even though manifest hasn't changed, so in favor of shortening CI runtime + couple apply to manifest changes, I've added those tests.
This is not a production baked solution, as it doesn't handle/consider use case of the same resources modified via a separate file, then the CI will apply it (k8s doesn't care if it's the same file name or not, it checks per manifest definition, and if the same resource was changed via two different files, it will attempt to apply both if both exist in the CI steps, for example if the CI tests applies all manifests under a certain folder).
In production the CI should not apply all k8s resources, only deployment changes, and if we do decide to deploy k8s resources via CI, it will be via a separate CI job, not the same one we'd give our developers to run for deploying their code.


## bonus - hosting the app on HTTPS

Background-
1. self-signed certificate was used for simplicity. In a production environment, we would use a valid SSL certificate from a certificate authority. self-signed cert should include SAN. command use to create the self signed cert-
`openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout private_key.pem -out certificate.pem -subj "/CN=subdomain.domainname.com/O=subdomain.domainname.com" -addext "subjectAltName = DNS:subdomain.domainname.com"`
2. ingress-controller-manifest.yml was added to the repo and to the github workflow.
3. external-dns deployment was added to manifest.yml, in order to register dns record to the dns hosted zone, which will be used in the ingress rules hosts section.

Prerequisites to run the github actions workflows with the bonus steps added:
1. create new github secret with the content of the self signed certificate.pem file, save it under SELF_SIGNED_CERT.
2. create new github secret with the content of the self signed private_key.pem file, save it under SELF_SIGNED_CERT_KEY.