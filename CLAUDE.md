# Python
- Always use `uv` for package management (never pip, pipenv, or poetry)
- Use `uv run` to execute scripts and tools
- Use `uv add` to add dependencies
- Use `uv sync` to install from lockfile
- Always add the following to `pyproject.toml` for Python projects:
  ```toml
  [tool.basedpyright]
  venvPath = "."
  venv = ".venv"
  ```
- Prefer pure functions over side effects. Functions should depend only on their inputs and communicate results only through their return values. Avoid mutating external state, global variables, or shared mutable objects.


# Git & Version Control
- Never commit, push, or create pull requests unless I explicitly ask you to do so.
