# Lab journal

## Phase 0
- Combined `apt install` (git, java, curl, unzip, jq, make) left Java missing. Re-running the Java install on its own fixed it. Cause unknown.
- kind did not install in the combined block. Downloading and installing it on its own worked.
- kubectl installed at v1.31.0 although stable was v1.37.2. Cause unknown. Fixed by downloading the current version explicitly and reinstalling.
- WSL2 gives Docker about 7.6 GiB by default (half of 16 GB). Fine for Phases 1 to 4, to be raised before Phase 5.
_Typed the folder name somarqube instead of sonarqube. Rename with mv. Check folder names with ls before moving on.
- Spring Initializr picked Spring Boot 4.1.2 (Java 17). Record this in the docs prerequisites page.
- Skipped the cat blocks that create the Java source files (ls showed only DemoAppApplication.java). Always verify with ls after creating files.
- git push returned HTTP 403 because the fine-grained token had Repository creation instead of Contents (Read and write). Search for 'contents' when adding permissions.
- First git push failed with 'Invalid username or token': GitHub rejects account passwords, a fine-grained token is required. Create it under Settings > Developer settings.
- Phase 1 break-it: changed an expected string in GreetingServiceTest. Build failed at the Unit Tests stage, not Build, because Build runs with -DskipTests. Failure message names test, file and line. Fixed with git revert.
- SonarQube on WSL2 needs: sudo sysctl -w vm.max_map_count=262144 . It resets when WSL restarts, so re-run it after a reboot or wsl --shutdown.
- Correction: on this WSL2 install vm.max_map_count was already 262144 by default, so no change was needed. Only re-check it if SonarQube fails with a max virtual memory areas error.
- SonarQube Community Build v26.10.0 (image sonarqube:community) started fine on WSL2. First login admin/admin, forced password change.
- Phase 2 break-it attempt 1: deleting tests did NOT fail the Sonar gate. The gate judges new code only and no production lines changed ('not enough lines to compute coverage'). To fail it, add new untested production code.
- Phase 2 break-it attempt 2: adding untested farewell() dropped overall coverage 86.7% to 50.0% but the default Sonar way gate still passed (new-code coverage). Switched to a custom gate on overall coverage.
- Sonar gate failure line in the Jenkins log: 'QUALITY GATE STATUS: FAILED - View details on http://sonarqube:9000/...'. That hostname only resolves inside Docker; use localhost:9000 in the browser.
- First Trivy scan downloaded two DBs: vulnerability DB (~40s) and Java DB (~2.5 min), both from mirror.gcr.io, no rate-limit problem. Clean baseline: 0 vulns in ubuntu 22.04 (143 pkgs) and 0 in app.jar. Java DB is cached for 3 days.
- Second Trivy scan reused the cached DBs (no download, finished in seconds). trivy_cache volume works.
- Phase 2 break-it: added log4j-core 2.14.1. Trivy flagged 3 findings in app.jar (CVE-2021-44228 CRITICAL, CVE-2021-45046 CRITICAL, CVE-2021-45105 HIGH) and the Trivy Scan stage failed. Fixed versions: 2.17.0 or later. Base ubuntu layer stayed at 0.
- Phase 2 done. Revert of the log4j commit gave a clean Trivy scan again (0 and 0). Stages 5, 6, 7 verified, including a failing quality gate and a failing vulnerability scan.
- After updating and restarting WSL, all containers were stopped. Recovery: start Docker Desktop, check sysctl vm.max_map_count, run docker compose up -d in cicd-lab-platform, wait for SonarQube status UP. Data survives in volumes.
- Stage 8 verified: registry catalog lists demo-app and tags/list shows the commit SHA tag. Registry is registry:2 on localhost:5001, replacing ECR.
- gitops repo: base Deployment, Service and dev overlay (Kustomize) pushed. Overlay tag starts as 'bootstrap' and Jenkins will overwrite it.
- Stage 9: Jenkins clones the gitops repo with credential github-pat, runs kustomize edit set image, and pushes a commit. After a build, run git pull in the local gitops folder before editing it.
- Stage 9 verified after creating the github-pat credential: Jenkins cloned the gitops repo, ran kustomize edit set image, committed 'demo-app: deploy <sha>' and pushed (abe90a4..0501f42). Image tag in the registry and newTag in the gitops overlay now match.
- Raised WSL memory to 12GB via C:\Users\<user>\.wslconfig ([wsl2] memory=12GB processors=6), then wsl --shutdown. free -h now shows 11Gi. Needed for kind + monitoring in Phases 4-5.
- kind cluster 'lab' created (kindest/node v1.37.0, 1 control-plane + 1 worker, host port 8090 -> NodePort 30080). Registry linked via containerd certs.d hosts.toml for localhost:5001 and docker network connect kind kind-registry.
- Pull test: a pod created from localhost:5001/demo-app:65b7f02 reached Running in 8s, so the kind nodes can pull from the local registry. (First attempt of the test never ran because the create command was missed in the paste.)
- All 7 Argo CD pods Running after ~5 min. UI via kubectl port-forward svc/argocd-server 8443:443 (self-signed cert warning is expected). Initial admin password is in secret argocd-initial-admin-secret.
- Argo CD UI reached, version v3.6.1, Applications page empty at first login.
- Stage 10 verified: Application demo-app Synced/Healthy, 2 pods Running in namespace demo, curl localhost:8090/actuator/info returns version 65b7f02 (the commit SHA Jenkins built).
