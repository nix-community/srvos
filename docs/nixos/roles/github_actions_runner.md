# GitHub Action Runner

This role installs:

- One or more self hosted github action runner
- One [cachix](https://www.cachix.org) watch store service

## Authentication

There are different ways a self hosted runner can register itself by GitHub.

- Using a Registration token
- Using a Personal Authentication token
- Using a GitHub App

We will document hereafter how to connect using a new GitHub Application in your organization.

First, create the GitHub Application in `https://github.com/organizations/<YOUR ORGANIZATION>/settings/apps`

- Click on `New GitHub App`.
- In "GitHub App name" type `<YOUR ORGANISATION> App for GitHub runners`.
- In "Homepage" fill in your project URL. It is required but won't be used hereafter.
- Unselect `Expire user authorization tokens`.
- Unselect `Active` in the "Webhook" section.
- In the "Organization permissions" select `Read and write` next to the "Self-hosted runner" permission
- Click on `Create GitHub App`

You should save securely the generated pem encoded private key. We will use that private key to configure the CI to use it.
You should also save the generated GitHub App Id.

Once created, you should also limit the usage of this github app to the CI hosts IPs (ipv4 and ipv6).

Application can be now be installed in your organization:

- Go to `https://github.com/organizations/<YOUR ORGANIZATION>/settings/apps`
- Click on the Edit button for our newly created GitHub app
- Click on Install App and choose to install it on your organization

Example:

```bash
roles.github-actions-runner = {
  url = "https://github.com/<YOUR ORGANIZATION>";
  count = 12;
  name = "github-runner";
  githubApp = {
    id = "<YOUR GENERATED APP ID>";
    login = "<YOUR ORGANIZATION>";
    privateKeyFile = config.age.secrets.github-app-runner-private-key.path;
  };
  cachix.cacheName = "<YOUR CACHIX ORGANIZATION>";
  cachix.tokenFile = config.age.secrets.cachixToken.path;
};
```

[Official GitHub App creation documentation](https://docs.github.com/en/apps/creating-github-apps/creating-github-apps/creating-a-github-app)
