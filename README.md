<p>
  <a href="https://github.com/RazcoDev/broken-urls-in-code/actions"><img alt="actions status" src="https://github.com/RazcoDev/broken-urls-in-code/actions/workflows/test.yml/badge.svg?branch=main"></a>
</p>

# Broken URLs in Code Action

### Tired of broken URLs in your code ?
This action will check all URLs in your code and report broken ones. Simple as that. 


## Build

```bash
$ npm run build && npm run package
```

## Test

```bash
$ npm test
```

## Action Usage

```yaml
- name: Check broken URLs
  uses: RazcoDev/broken-urls-in-code@v1.0.1
  with:
    # The directory you want to check
    directory: '.'
    # The files glob to check the URLs inside
    files-glob: '**/*.js'
    # The URLs regex to check
    url-regex: 'http[s]?:\/\/(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+'
```


## Inputs

### `directory`

**Required** The directory you want to check. Default `.`.

### `files-glob`

**Required** The files glob to check the URLs inside. Default  `**/*`.

### `url-regex`

**Required** The URLs regex to check. Default `http[s]?:\/\/(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+`.

## Outputs

### `broken-urls`

The broken URLs found in the code.


# License

Apache-2.0 License

Authors: [Raz Cohen](https://github.com/RazcoDev)

