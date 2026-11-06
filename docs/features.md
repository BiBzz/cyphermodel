# Features

!!! warning "Design phase"
    These are the goals CypherModel is built against. Each one lands with its documentation and tests.

## Designed for async Python

Web frameworks, task queues and data pipelines are async today, while most Python graph libraries still wrap a synchronous driver. A synchronous call inside an `async def` route blocks every other request of the process, so libraries end up telling you to write synchronous routes and let a thread pool absorb the waits.

CypherModel runs every query on the async Neo4j driver. A query is awaited like any other I/O, and a hundred concurrent requests need a hundred coroutines, not a hundred threads.

## Strongly typed, end to end

- Node and relationship models are typed classes.
- Query builders know which model they return: `select(Person)` yields `Person` objects, `select(Person, Movie)` yields `tuple[Person, Movie]`.
- Raw Cypher declares what it returns, and the result is checked and built as those models.
- The package ships its type information and is checked with a strict type checker in CI.

## Pydantic models

A node is a Pydantic model: validation, serialization, aliases, computed fields and JSON Schema all keep working. In a FastAPI application, the model that reads a request body is the one written to the graph and the one returned in the response.

## Relationships as models

Graphs are about relationships. A relationship model declares its source and target node models and its own properties, and is created, matched and deleted like a node.

## Cypher, one step away

CypherModel does not try to replace Cypher. The query builder covers the everyday matches, filters, traversals and pagination; anything else is written in Cypher, with parameters, and still returns typed models.

## Built for heavy writes

- Writes are grouped and sent with `UNWIND`, one query for many rows.
- Managed transactions retry transient conflicts, and every attempt can be counted.
- Writers that touch the same node can share a queue with a single writer, so that many concurrent tasks attaching edges to one node stop conflicting.

These patterns come from a production pipeline that links millions of scientific publications in Memgraph.

## Memgraph and Neo4j

Both databases speak Bolt and are reached through the same driver. CypherModel is tested against both, and names where they differ (constraints, indexes, procedures) instead of assuming one of them.
