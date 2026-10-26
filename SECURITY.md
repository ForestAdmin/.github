# Security policy

Forest is used by companies in regulated industries, and we treat security reports as a priority. Thank you for helping keep Forest and its users safe.

## Reporting a vulnerability

**Please do not open a public issue, discussion or pull request for a security problem.**

Report it privately, by either of these channels:

- **GitHub private vulnerability reporting:** on the repository concerned, open the **Security** tab and click **Report a vulnerability**.
- **Email:** [security@forestadmin.com](mailto:security@forestadmin.com).

Please include:

- the repository and package affected, with the version;
- a description of the vulnerability and its impact;
- the steps to reproduce it, or a proof of concept;
- any fix or mitigation you can suggest.

## What happens next

Our technical team reviews every report. If the vulnerability is confirmed, we:

- work on a fix with the highest priority;
- keep you informed of progress;
- let you know when a patched version is published, and credit you in the advisory if you wish.

## Supported versions

| Package | Security fixes |
|---|---|
| v2 agents: [agent-nodejs](https://github.com/ForestAdmin/agent-nodejs), [agent-ruby](https://github.com/ForestAdmin/agent-ruby), [agent-python](https://github.com/ForestAdmin/agent-python) | Yes, on the latest major version |
| v1 agents: forest-express-sequelize, forest-express-mongoose, forest-rails, django-forestadmin | Yes, while in maintenance mode, on the latest major version |
| Archived repositories | No |

If you are on an older major version, upgrade first: the fix ships only in the latest one.
