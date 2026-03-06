# GRoWSS - GitHub Reusable Workflows for Simulation Systems :recycle:

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

This section intends to help users and developers quickly identify and resolve common issues which may be encountered while using the growss repository. If an issue which isn't listed here is found please notify us via discussions on the simulation systems [Q&A](https://github.com/MetOffice/simulation-systems/discussions/categories/q-a) channel.

### YAML file being called from growss is not found

1. Go into the settings of the repository that is calling a growss workflow.
2. Click on the actions tab on the left then click general.
3. Scroll down to the workflow permissions section.
4. Ensure the setting is set to Read and Write Permission to all the repository to access other repositories in the MetOffice organisation


