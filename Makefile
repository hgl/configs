SHELL := bash
.SHELLFLAGS := -euo pipefail -c
.ONESHELL:
.DELETE_ON_ERROR:
.DEFAULT_GOAL := all

include vpn/ipsec/ipsec.mk
include nodes/routers/routers.mk

FORCE:
