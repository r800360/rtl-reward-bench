#!/bin/bash
# install-tools.sh - the toolchain behind every result in this repository, pinned to the versions the committed
# results were produced with. Used by the Dockerfile and by GitHub Actions; run as root on Ubuntu 26.04.
#   Icarus Verilog 12.0, Verilator 5.032, Yosys 0.52 (+ ABC, yosys-smtbmc), Z3 4.13.3, SymbiYosys 0.52 (from git),
#   Python 3, make, g++ (Verilator compiles its models to C++)
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
  iverilog=12.0-3 \
  verilator=5.032-1 \
  yosys=0.52-2 yosys-abc=0.52-2 \
  z3=4.13.3-1build1 \
  python3 make g++ git ca-certificates
# SymbiYosys is not packaged for Ubuntu 26.04: install the release that matches Yosys 0.52
if ! command -v sby > /dev/null; then
  git clone -q --depth 1 --branch v0.52 https://github.com/YosysHQ/sby.git /tmp/sby
  make -C /tmp/sby install PREFIX=/usr/local > /dev/null
  rm -rf /tmp/sby
fi
echo "== toolchain"
iverilog -V 2>&1 | sed -n 1p
verilator --version
yosys -V
z3 --version
sby --help > /dev/null && echo "SymbiYosys v0.52"
python3 --version
