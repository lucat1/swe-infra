# swe-infra

Setup GitLab, Jenkins, SonarQube, Mattermost and Taiga.

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

## Jenkins

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

Set the Administration > General > Server base URL

Enable SonarQube SSO with GitLab and set the global settings: [SonarQube Docs](https://docs.sonarqube.org/latest/analysis/gitlab-integration/)

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

## Taiga

Subdomain: `taiga`

Create a new GitLab Application:

- Redirect URI: `https://taiga.<domain>/login`
- Scopes: read_user

Change the variables in the `hosts` file and execute the Ansible playbook.
