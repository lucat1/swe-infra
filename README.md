# swe-infra

Setup GitLab, SonarQube, Mattermost, Taiga (and optionally Jenkins).

You need root access to a server with Debian via SSH.

Clone this repository and create a `hosts` file (you can find an example on `hosts.example`, not all variables can be set immediately) and execute the Ansible playbook: `ansible-playbook install.yaml`.

Setup your domain DNS for subdomains: `git`, `ci`, `qube`, `chat`, `taiga`.

## GitLab

Subdomain: `git`

Log in to the server with SSH.

Change the GitLab `root` user password:

```
cd /swe
docker-compose exec gitlab bash
gitlab-rake "gitlab:password:reset"
```

then follow the on-screen instructions.

Log in to GitLab.

Disable user registration or set the `Allowed domains for sign-ups`: [GitLab Docs](https://docs.gitlab.com/ee/user/admin_area/settings/sign_up_restrictions.html)

Disable Service Ping: [GitLab Docs](https://docs.gitlab.com/ee/user/admin_area/settings/usage_statistics.html#enable-or-disable-usage-statistics)

Obtain the registration token from `https://git.{{ domain }}/admin/runners` and on the remote machine execute:

```
docker run --rm -it -v /swe/runner_config.toml:/etc/gitlab-runner/config.toml -e CI_SERVER_URL=https://git.{{ domain }}/ -e REGISTRATION_TOKEN={{ gitlab_runner_token }} gitlab/gitlab-runner:latest register --non-interactive --locked=false --name=runner0 --executor=docker --docker-image=docker:dind --docker-volumes=/var/run/docker.sock:/var/run/docker.sock
```

## Jenkins

By default it's disabled, because GitLab Runner works better.
If you want to enable it, uncomment the Jenkins part in the Docker compose, Ansible playbook, homepage, backup and restore scripts.

Subdomain: `ci`

Get the initial admin password: `cat /jenkins/secrets/initialAdminPassword`

Connect to your Jenkins instance, click `Select plugins to install` and select the GitLab plugin.

Create a `root` account.

Setup the GitLab-Jenkins integration: [GitLab Docs](https://docs.gitlab.com/ee/integration/jenkins.html)

Manage Jenkins > Manage Plugins > Available > Install `gitlab-oauth` and [configure for SSO](https://github.com/jenkinsci/gitlab-oauth-plugin/blob/master/docs/README.md).

Manage Jenkins > Configure Global Security > Authorization > Matrix-based security and set reasonably permission.

Manage Jenkins > Manage Plugins > Available > Install `sonar`

## SonarQube

Subdomain: `qube`

Log in to your SonarQube instance: username `admin`, password `admin` (you will ask to change it on first login).

Set the Administration > Configuration > General Settings > General > Server base URL

Enable SonarQube SSO with GitLab, enable group synchronization and set the global settings: [SonarQube Docs](https://docs.sonarqube.org/latest/analysis/gitlab-integration/)

Administration > Security > Permission Templates, edit the default template, select all the permissions for `Creators`.

Administration > Security > Groups, create groups for all the GitLab ones, name the SonarQube groups with the path of the GitLab group (not include the GitLab domain).

When a user creates a project, (s)he should set it as Private in Project Settings > Permissions and give all the permissions to the correspond group.

## Mattermost

Subdomain: `chat`

On Mattermost create an admin account with a username different from `root`.

Go to System Console > Authentication > GitLab and follow the instructions.

System console > Email > Enable account creation with email: false

To share the root account from GitLab to Mattermost:

- Login on GitLab as root
- Login as admin on Mattermost (normally) then go to System console > Users > Set `root` user as System Admin
- Disable non-SSO login in Mattermost:
  - System console > Email > Enable sign-in with email: false
  - System console > Email > Enable sign-in with username: false

To enable push notifications: System Console > Environment > Push Notification Server > Enable Push Notifications: Use TPNS connection to send notifications to iOS and Android apps

To enable calls: System Console > Plugins > Calls > Enable on all channels: true

## Taiga

Subdomain: `taiga`

Create a new GitLab Application:

- Redirect URI: `https://taiga.{{ domain }}/login`
- Scopes: read_user

Change the `taiga_gitlab_client_id` and `taiga_gitlab_client_secret` variables in the `hosts` file and execute the Ansible playbook.
