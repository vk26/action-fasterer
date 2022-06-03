# GitHub Action: Run fasterer with reviewdog 🐶

![](https://github.com/vk26/action-fasterer/workflows/CI/badge.svg)
![](https://img.shields.io/github/license/vk26/action-fasterer)
![](https://img.shields.io/github/v/release/vk26/action-fasterer)

This action runs [fasterer](https://github.com/DamirSvrtan/fasterer) with
[reviewdog](https://github.com/reviewdog/reviewdog) on pull requests to improve
code review experience. Fasterer will suggest some speed improvements your ruby-code.

## Examples

### With `github-pr-check`

By default, with `reporter: github-pr-check` an annotation is added to the line:

![Example comment made by the action, with github-pr-check](./examples/example-github-pr-check.png)

### With `github-pr-review`

With `reporter: github-pr-review` a comment is added to the Pull Request Conversation:

![Example comment made by the action, with github-pr-review](./examples/example-github-pr-review.png)

## Inputs

### `github_token`

**Required**. Must be in form of `github_token: ${{ secrets.github_token }}`'.

### `fasterer_version`

Optional. Set fasterer version. Possible values:
* empty or omit: install latest version
* `gemfile`: install version from Gemfile (`Gemfile.lock` should be presented, otherwise it will fallback to latest bundler version)
* version (e.g. `0.10.0`): install said version

### `tool_name`

Optional. Tool name to use for reviewdog reporter. Useful when running multiple
actions with different config.

### `level`

Optional. Report level for reviewdog [`info`, `warning`, `error`].
It's same as `-level` flag of reviewdog. By default - `error`.

### `reporter`

Optional. Reporter of reviewdog command [`github-pr-check`, `github-pr-review`].
The default is `github-pr-check`.

## Usage
.github/workflows/main.yml:
```yml
name: reviewdog
on: [pull_request]
jobs:
  fasterer:
    name: runner / fasterer
    runs-on: ubuntu-latest
    steps:
      - name: Check out code
        uses: actions/checkout@v1
      - name: fasterer
        uses: vk26/action-fasterer@v1
        with:
          github_token: ${{ secrets.github_token }}
          reporter: github-pr-review # Default is github-pr-check
```

## Sponsor

<p>
  <a href="https://evrone.com/?utm_source=action-fasterer">
    <img src="https://www.mgrachev.com/assets/static/evrone-sponsored-300.png" 
      alt="Sponsored by Evrone" width="210">
  </a>
</p>

## License

[MIT](https://choosealicense.com/licenses/mit)
