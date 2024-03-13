# GitHub Actions Runner

GitHub Action Runners are processes that execute the automated jobs you specify in your GitHub Actions workflows. These runners can be hosted on GitHub-hosted infrastructure or your infrastructure. Self-hosted runners run for your project only and are available at no additional cost.

This article looks at how to install a GitHub runner in your own NixOS infrastructure, making sure the environment is scalable and secure.

We have built a [NixOS module](https://nixos.wiki/wiki/NixOS_modules) that installs one or more [self-hosted github action runner](https://docs.github.com/en/actions/hosting-your-own-runners/about-self-hosted-runners), along with a [cachix](https://www.cachix.org/) watch store service with the most secure defaults.

> __NOTE__: if you intend to run NixOS VM tests you must ensure your hosting provider supports [nested virtualization](https://docs.fedoraproject.org/en-US/quick-docs/using-nested-virtualization-in-kvm/) 
> or use bare-metal hosts, otherwise your tests will take a long time to execute. 

## Authentication

In order to use a self-hosted GitHub action runner, you will need to register the runner with your GitHub account or organization. There are three different ways a self hosted runner can register itself on GitHub:

* Using a Registration token
* Using a Personal Authentication token
* Using a [Github app](https://docs.github.com/en/apps/creating-github-apps/creating-github-apps/about-apps)

In this document, I will describe the most secure option: how to connect using a new GitHub App in your organization.

To ensure that you have complete control over the permissions that the app requires, you should create your own GitHub Application.

First, go to the setting page of your organization: `https://github.com/organizations/<YOUR ORGANIZATION>/settings/apps`

* Click on `New GitHub App`.
* In "GitHub App name" type `<YOUR ORGANISATION> App for GitHub runners`.
* In "Homepage" fill in your project URL. It is required but won't be used hereafter.
* Unselect `Expire user authorization tokens`.
* Unselect `Active` in the "Webhook" section.
* In the "Organization permissions" select `Read and write` next to the "Self-hosted runner" permission
* Click on `Create GitHub App`

Once the app is created, the app's settings page will be presented. Scroll to the *Private keys* section and click the button labeled *Generate a private key*. You should save securely the generated PEM encoded private key. You will need that private key when you configure the CI. You should also save the generated GitHub App Id.

Once created, you should also limit the usage of this github app to your CI hosts public IPs (ipv4 and ipv6).

The application can be now be installed in your organization:

* Go to `https://github.com/organizations/<YOUR ORGANIZATION>/settings/apps`
* Click on the Edit button for your newly created GitHub app
* Click on Install App and choose to install it on your organization

You can now use the NixOS role to install and configure the GitHub self hosted runner in your NixOS CI host.

If someone else is configuring the runner for you, you will need to provide him the the generated PEM encoded private key and the GitHub App Id.

You can find more information in the [Official GitHub App creation documentation](https://docs.github.com/en/apps/creating-github-apps/creating-github-apps/creating-a-github-app).

## Using the NixOS module

The module has been created as a role. Roles are used to define the specific purpose of a node, making it easy to manage and scale your infrastructure.

The following options must be configured

`url` the full URI to your organization or your repository. This URI has to match with the location where you installed the GitHub App.

`count` the number of runners you want to start on the host.

`githubApp.id` the Id of the GitHub App that was created.

`githubApp.login` the name of your organization / user where the GitHub App was registered.

`githubApp.privateKeyFile` the path to the file containing the GitHub App generated PEM encoded private key. This file should be present on the host and deployed as a secret (using [sops-nix](https://github.com/Mic92/sops-nix) or [agenix](https://github.com/ryantm/agenix)).

`cachix.cacheName` the name of your cachix organization.

`cachix.tokenFile` the path to the file containing your cachix token. This file should also be present on the host and deployed as a secret (using [sops-nix](https://github.com/Mic92/sops-nix) or [agenix](https://github.com/ryantm/agenix)).

Example of a module to configure 12 Github runners:

```
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

## Scaling

There are multiple ways to scale your GitHub runners, such as increasing the number of hosts or increasing the number of services on a single host.
All services are completely isolated from each other, so there is no real distinction between one or the other approach. Your decision should be based on the compute/memory power your project needs.

You now have a fully functional self-hosted runner running on your NixOS infrastructure. If you need any further assistance in managing or improving your CI workflows with Nix, don't hesitate to [contact us](https://numtide.com).
Our team of experts is here to help you optimize your CI/CD pipelines and streamline your development process.
