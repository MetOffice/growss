# :recycle: GRoWSS - GitHub Reusable Workflows for Simulation Systems

[![CI](https://github.com/MetOffice/growss/actions/workflows/validate.yaml/badge.svg?branch=main)](https://github.com/MetOffice/growss/actions/workflows/validate.yaml)

Placeholder for a collection of
[reusable workflows](https://docs.github.com/en/actions/learn-github-actions/reusing-workflows)
for the Met Office Simulation Systems Repositories.

## Notes for contributors

When contributing to this repository, your changes will be automatically
validated for YAML, Python, and Shell script correctness. We recommend manually
checking your files before opening a pull request. For example, you can run
`yamllint workflow-file.yaml` to verify YAML syntax.

## Troubleshooting

This section intends to help users and developers quickly identify and resolve
common issues which may be encountered while using the growss repository. If an
issue which isn't listed here is found please notify us via discussions on the
simulation systems
[Q&A](https://github.com/MetOffice/simulation-systems/discussions/categories/q-a)
channel.

### YAML file being called from growss is not found

1. Navigate to the **Settings** of the repository initiating the growss
   workflow.
2. Select **Actions** > **General** from the left-hand sidebar.
3. Scroll to the **Workflow permissions** section.
4. Select **Read and write permissions** to allow the workflow to access other
   repositories within the MetOffice organisation.
