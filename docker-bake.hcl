variable "IMAGE_PREFIX" {
	default = "thelovekesh"
}

group "default" {
	targets = ["phpfpm"]
}

group "phpfpm" {
	targets = ["phpfpm-matrix"]
}

target "_common" {
	platforms =[
		"linux/amd64",
		"linux/arm64"
	]
}

target "phpfpm-matrix" {
	inherits = ["_common"]

	context = "./phpfpm"
	dockerfile = "Dockerfile"

	matrix = {
		PHP_VERSION =["8.2", "8.3", "8.4", "8.5"]
	}

	name = "phpfpm-${replace(PHP_VERSION, ".", "")}"

	args = {
		PHP_VERSION = PHP_VERSION
	}

	tags = [
		"${IMAGE_PREFIX}/php:${PHP_VERSION}-fpm"
	]
}
