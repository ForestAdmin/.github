# Forest

**The back office for operations teams in regulated companies.**

Forest gives fintech ops teams one place to review, decide and act on their data: customers, payments, cases, alerts. They work from the Forest interface or through AI agents connected over MCP, always within the roles, permissions and audit logs the company defines.

- **Your infrastructure, your data.** The Forest agent runs on your servers and queries your databases and providers directly. Forest does not store your business data.
- **Built by your developers, run by your ops.** Developers connect sources and code the business logic; ops teams shape their own views and processes on top.
- **Ready for AI agents.** The same data, actions and permissions are available to AI agents through the Forest MCP server, with every action logged.

[Website](https://forest.app) · [Documentation](https://docs.forest.app/get-started/quickstart) · [Support](https://forest.app/forms/support)

## Get started

Pick the agent for your stack:

| Stack | Repository | Package |
|---|---|---|
| Node.js (Express, Koa, Fastify, NestJS) | [agent-nodejs](https://github.com/ForestAdmin/agent-nodejs) | `@forestadmin/agent` |
| Ruby on Rails | [agent-ruby](https://github.com/ForestAdmin/agent-ruby) | `forest_admin_rails` |
| Python (Django, Flask) | [agent-python](https://github.com/ForestAdmin/agent-python) | `forestadmin-agent-django`, `forestadmin-agent-flask` |

Then follow the [quick start](https://docs.forest.app/get-started/quickstart).

## Also in this organization

| Repository | What it is |
|---|---|
| [toolbelt](https://github.com/ForestAdmin/toolbelt) | CLI to set up and manage your Forest project from the terminal |
| [ai-marketplace](https://github.com/ForestAdmin/ai-marketplace) | AI skills and plugins for Forest |
| [n8n-nodes-forest](https://github.com/ForestAdmin/n8n-nodes-forest) | n8n community node to use Forest in your n8n workflows |
| [demos](https://github.com/ForestAdmin/demos) | Example projects to see Forest running on realistic data |

**Using a v1 agent** (`forest-express-sequelize`, `forest-express-mongoose`, `forest_liana`, `django-forestadmin`)? These are in maintenance mode. See the [v1 to v2 migration guide](https://docs.forest.app/guides/migration/from-v1/overview).

## Security

To report a vulnerability, follow our [security policy](https://github.com/ForestAdmin/.github/blob/main/SECURITY.md). Please do not open a public issue.
