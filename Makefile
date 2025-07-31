SHELL := bash
.SHELLFLAGS := -euo pipefail -c
.ONESHELL:
.DELETE_ON_ERROR:
.DEFAULT_GOAL := all

include vpn/ipsec/Makefile
include nodes/routers/Makefile

FORCE:
