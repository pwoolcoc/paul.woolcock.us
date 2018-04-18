---
layout: post
title: Migrating your Rust project from GitHub to GitLab
description: Migrating your Rust project from GitHub to GitLab
---

So, you want to migrate from GitHub to GitLab. Maybe there is a feature you
just can't live without. Maybe you are concerned about the centralization of
open source code. Or, maybe you just want to use what is cool on Hacker News
this week. Whatever your reason, it turns out that it is pretty easy to move
your crate to GitLab!

(Note: when I refer to "GitLab" in this post, I am specifically
referring to the GitLab EE instance running at [https://gitlab.com](https://gitlab.com). There
might be differences if you are running your own GitLab instance)

## Create an Account and Import a Project

The first thing we need to do is create an account, by clicking "Sign In" on
[https://gitlab.com](https://gitlab.com) and selecting the Github icon. You could
just sign up manually and link up your github account later, but I found it easier
to save a step and just sign up with my github account.

Now, you should see an empty projects page, and in the top right you should see
a "+ New Project" button, that looks like this:

![new project button](/images/github-to-gitlab/new-projects-button.png)

Here you can either create a new project from scratch or import one from
a number of providers. Click the GitHub icon and you should see a list
of your GitHub projects (provided you gave GitLab access to your GitHub
account at some point). Find the project you want to migrate and click
the "Import" button.

[![list of projects from github](/images/github-to-gitlab/github-projects-list_thumb.png)](/images/github-to-gitlab/github-projects-list.png)

When the import finishes, navigate to the new project page, either by
clicking the link under the "To GitLab" column on the Import page, or by
clicking "Projects" in the sidebar and clicking on the project name
there.

[![new imported project](/images/github-to-gitlab/new-imported-project_thumb.png)](/images/github-to-gitlab/new-imported-project.png)

* Back to Projects page
* change git remotes on local copy of repo
* change `repository = ` line in Cargo.toml and show push to both
* pull rust docker image
  * sudo docker pull jimmycuadra/rust:latest
* install gitlab-ci-multi-runner
* follow instructions to `sudo gitlab-ci-multi-runner register`
* when asked about the actual worker, select the `docker` option
  and put `jimmycuadra/rust:latest` as the image
* add and push .gitlab-ci.yml
* Go to the `Runners` Page in the Project Settings and enable your `rust`
  runner (*** TAKE OUT TOKEN ***)
* Now go to builds, you should have a build going
* lets get docs set up - edit .gitlab-ci.yml
* Change Cargo.toml and various other places where the github links show up
* build badges: https://gitlab.com/:user/:repo/badges/:branch/build.svg
* also usually put note in README about canonical location of repo
