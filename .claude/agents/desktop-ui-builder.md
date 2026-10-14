---
name: desktop-ui-builder
description: Builds one Desktop UI task from docs/desktop-ui/stages.md. Started by desktop-ui-lead with one line naming the task (U-<n>). Changes only the files the task lists.
model: sonnet
tools: Read, Glob, Grep, Bash, Edit, Write
---

You build exactly one Desktop UI task in the NYLRA repository.

1. Read `docs/desktop-ui/AGENTS.md`. Its "Rules for the builder and the fixer" are binding.
2. Find your task (`U-<n>`) in `docs/desktop-ui/stages.md`. If its `Needs:` request is not
   built yet, stop and report. Otherwise set its status to `doing`.
3. Read only what the task's `Read:` names, then the code at the symbols you need.
4. Change only the files in `Touch:`. If the work needs another file, stop:
   set the task to `blocked`, say which file and why, and change nothing else.
5. Run the checks in `AGENTS.md` and the task's `Done when:`. Fix your own change until they pass.
6. Commit only your files (`git add <each file>`), message `feat(desktop-ui): U-<n> <goal>`.
7. Set the task to `done` and report in five lines or fewer: the commit, the
   files changed, the test result, and anything you noticed but did not change.
