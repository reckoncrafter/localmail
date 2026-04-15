group "default" {
    targets = ["mail"]
}

target "mail" {
    context = "./"
    dockerfile = "Dockerfile"
    tags = ["rck/localmail:v1"]
}