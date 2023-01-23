# Running Mastodon with Nomad

This repository is designed to be read with [my blog post](https://www.carrot.blog/posts/2023/01/self-hosting-mastodon-aws-nomad/), and you should be familiar with the first-party [setup guide](https://docs.joinmastodon.org/admin/prerequisites/) too.

It includes [Nomad](https://www.nomadproject.io/) task definitions that I use to run my own [Mastodon](https://joinmastodon.org/) instance, as well as a couple of helpful scripts. They're tuned to run on a single `t4g.medium` server on AWS.

It's supposed to be for inspiration, rather than a step-by-step guide. You won't be able to run it out of the box using this repository, but I hope it's useful as a reference to get you started.

If you know of a better way to do something, or want to offer other improvements, please send me a message [on Mastodon @carrot@bunny.cloud](https://bunny.cloud/@carrot) before opening a PR.

For interest, it's actually a redacted copy of the `cluster` folder, from a repository I use to manage the infrastructure for [`bunny.cloud`](https://bunny.cloud). Not included are the terraform and ansible definitions for all the underlying infrastructure.

![Screenshot of Nomad running Mastodon](nomad_screenshot.png)

## Components

The Nomad task definitions include:
* A front proxy (nginx)
* Web server (Mastodon - Ruby on Rails)
* A message processor (Mastodon - Sidekiq)
* A streaming server (Mastodon - Node)
* A SQL migrations task (ran before every deploy)
* A periodic cleanup task (to remove old media)

### Scripts

* `install_dependencies.sh` installs local dependencies to run scripts
* `deploy_cluster.sh` uses the Nomad CLI to deploy all the tasks
* `./tootctl.sh` runs a given [`tootctl`](https://docs.joinmastodon.org/admin/tootctl/) command in a running sidekiq allocation
```
🥕 carrot 🗂 bunny-cloud-infra/infra/cluster 🐙 main $ ./tootctl.sh version
Discovering alloc of "mastodon-sidekiq" to run tootctl in...
Found alloc with ID: ef0fd901-d598-9fe6-b2c2-3c577c0aee2e
Executing: "tootctl version"
4.0.2
```

## License

Everything here is MIT licensed - use it, change it, and please credit me if you do something public with it.
