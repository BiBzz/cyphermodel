# Design and roadmap

CypherModel is designed in the open. This page states what it aims at, what it leaves out, and in which order it will be built. Discussion happens in the [GitHub issues](https://gitlab.com/businessagile/libraries/cyphermodel/-/issues).

## Principles

1. **Async only.** No synchronous twin of the API: one way to do each thing.
2. **Types first.** If the type checker cannot follow it, it is not the API.
3. **Pydantic is the model.** No parallel descriptor system to learn.
4. **Cypher is not hidden.** The builder covers common cases; raw Cypher is a first class citizen.
5. **Measure before optimizing.** Performance work, including native extensions, follows a measurement.

## Non goals

- Replacing Cypher with a complete Python query language.
- Schema migrations as a framework. Constraints and indexes are declared on models and applied explicitly.
- Supporting every graph database. Bolt databases first; others only through a clear engine interface.

## Roadmap

| Step | Content |
|---|---|
| 0.1 | Connection and session, raw Cypher with typed results, node and relationship models, `MERGE` by primary key, batched writes |
| 0.2 | `select()` with filters, ordering and pagination, single hop traversals |
| 0.3 | Constraints and indexes from models, Memgraph and Neo4j test matrix |
| 0.4 | Shared write queues for hot nodes, write metrics |
| 0.5 | FastAPI recipes, documentation tutorial |
| later | Embedded engines (LadybugDB), measured native acceleration |

## Prior art

CypherModel stands on what others built: [SQLModel](https://sqlmodel.tiangolo.com) for the shape of the API, [Neontology](https://github.com/ontolocy/neontology) for Pydantic first graph models and relationship classes, [neomodel](https://github.com/neo4j-contrib/neomodel) for a complete async OGM on Neo4j, and the [Neo4j Python driver](https://neo4j.com/docs/api/python-driver/current/) underneath.
