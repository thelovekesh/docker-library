# Docker Library

Collection of Docker images, built with [Docker Bake](https://docs.docker.com/build/bake/) and published to Docker Hub for `linux/amd64` and `linux/arm64`.

## Images

### `thelovekesh/php:<version>-fpm`

PHP-FPM (Debian Trixie) tailored for WordPress development. Built for PHP `8.2`, `8.3`, `8.4`, and `8.5`.

Bundled extensions: `apcu`, `bcmath`, `bz2`, `calendar`, `exif`, `gd`, `gettext`, `gmp`, `igbinary`, `imagick`, `intl`, `mbstring`, `memcached`, `mysqli`, `opcache`, `pcntl`, `pdo`, `pdo_mysql`, `redis` (with igbinary + zstd), `shmop`, `soap`, `sockets`, `sysvsem`, `sysvshm`, `xdebug`, `zip`.

Bundled tooling: `composer`, `wp-cli`, `mailpit`, plus the helper scripts `xdebug`, `wp-logs`, and `setup-wordpress` on `PATH`.

## Build locally

```sh
# Build everything for the current platform
docker buildx bake

# Build a single PHP variant
docker buildx bake phpfpm-83

# Override the image namespace
IMAGE_PREFIX=youruser docker buildx bake phpfpm
```

## Release

Images are published via the [`release`](.github/workflows/ci.yml) workflow (manual `workflow_dispatch`). Pass the bake target to build (e.g. `phpfpm`, `phpfpm-84`).

## License

MIT
