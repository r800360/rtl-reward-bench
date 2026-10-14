# RTL reward bench. Toolchain: scripts/install-tools.sh (Ubuntu 26.04) or the Dockerfile.
.PHONY: all bench report demo check clean
JOBS ?= 4

all: bench report      ## every grader on every design, then the report and figures

bench:
	python3 -m rrb.bench --jobs $(JOBS)

report:
	python3 -m rrb.report

# the reward environment on a correct and a buggy design
demo:
	python3 -m rrb.env acs_unit tasks/acs_unit/candidates/correct_priority.sv
	python3 -m rrb.env acs_unit tasks/acs_unit/candidates/bug_ties_to_path1.sv --staged

# fail if a rerun changed any committed result or figure (timings excepted)
check:
	python3 tools/check_results.py

clean:
	rm -rf build
