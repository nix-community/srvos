Roles are special types of NixOS modules that are designed to take over a machine configuration.

We assume that only one role is assigned per machine.

By making this assumption, we are able to make deeper change to the machine configuration, without having to worry about potential conflicts with other roles.

### GitHub Actions runner (`nixosConfiguration.roles-github-actions-runner`)

Dedicates the machine to becoming a cluster of GitHub Actions runners. 

### Nix Remote builder (`nixosConfiguration.roles-nix-remote-builder`)

Dedicates the machine to acting as a remote builder for Nix. The main use-case we have is to add more build capacity to the GitHub Actions runners, in a star fashion.