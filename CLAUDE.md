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