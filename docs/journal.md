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
