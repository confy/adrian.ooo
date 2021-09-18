terraform {
  backend "remote" {
    organization = "confy"
    workspaces {
      name = "adrian-ooo"
    }
  }
}