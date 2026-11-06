<style>
.md-content .md-typeset h1 { display: none; }
</style>

# CypherModel

<p align="center">
  <a href="https://cyphermodel.businessagile.eu"><img src="img/logo.svg" alt="CypherModel" width="420"></a>
</p>
<p align="center">
    <em>CypherModel, graph databases in Python, fully async and strongly typed.</em>
</p>
<p align="center">
<a href="https://gitlab.com/businessagile/libraries/cyphermodel/-/blob/development/LICENSE" target="_blank"><img src="img/badges/license.svg" alt="License: MIT"></a>
<img src="img/badges/status.svg" alt="Status: design phase">
<img src="img/badges/python.svg" alt="Python 3.11+">
</p>

---

**Documentation**: <a href="https://cyphermodel.businessagile.eu" target="_blank">https://cyphermodel.businessagile.eu</a>

**Source Code**: <a href="https://gitlab.com/businessagile/libraries/cyphermodel" target="_blank">https://gitlab.com/businessagile/libraries/cyphermodel</a>

---

!!! warning "Design phase"
    CypherModel is being designed in the open. The code on this page shows the **target API**, which is not released yet. Follow the repository to see it land, or open an issue to shape it.

CypherModel is a library for working with **graph databases** that speak **Cypher** (Memgraph, Neo4j) from Python code, with Python objects. It is designed to be **async from end to end**, **strongly typed**, and to keep Cypher one step away rather than hiding it.

**CypherModel** is based on Python type annotations, and powered by <a href="https://docs.pydantic.dev" target="_blank">Pydantic</a> and the async <a href="https://neo4j.com/docs/api/python-driver/current/" target="_blank">Neo4j Python driver</a>, which both Neo4j and Memgraph recommend.

The key features are:

* **Async first**: every call that reaches the database is awaited. No thread pool in disguise, no event loop blocked by a synchronous driver.
* **Strongly typed**: nodes, relationships and query results are typed models. Your editor completes properties, and your type checker catches a wrong label before the database does.
* **Pydantic models**: a node is a Pydantic model. The same class validates input, serializes output in your API, and maps to the graph.
* **Relationships are first class**: a relationship is a model with its own properties, its source and its target, not an attribute hidden in a node.
* **Cypher stays close**: a typed query builder covers the common cases, and raw Cypher with typed results covers the rest.
* **Built for load**: writes are batched with `UNWIND`, and concurrent writers that share a node can be serialized instead of fighting over it.

## Graph databases in FastAPI

**CypherModel** is designed to fit **FastAPI** applications: the same models validate requests, document the OpenAPI schema and talk to the graph, and every route stays `async def`.

It follows the path opened by <a href="https://sqlmodel.tiangolo.com" target="_blank">SQLModel</a> for SQL databases: a thin layer on top of Pydantic and a solid driver, carefully designed to be compatible with both.

## Requirements

A recent and currently supported <a href="https://www.python.org/downloads/" target="_blank">version of Python</a>.

As **CypherModel** is based on **Pydantic** and the **Neo4j driver**, it requires them. They are installed with it.

A graph database reachable over Bolt: **Memgraph** or **Neo4j**.

## Installation

Once the first version is released:

```console
$ pip install cyphermodel
---> 100%
Successfully installed cyphermodel neo4j pydantic
```

## Example

For an introduction to graph databases and Cypher, see the <a href="https://memgraph.com/docs/querying" target="_blank">Memgraph</a> and <a href="https://neo4j.com/docs/cypher-manual/current/" target="_blank">Neo4j</a> guides.

Here is a quick example of the target API. ✨

### A small graph

Let's say we have people, movies, and who acted in what:

```cypher
(:Person {name: "Keanu Reeves", born: 1964})-[:ACTED_IN {roles: ["Neo"]}]->(:Movie {title: "The Matrix", released: 1999})
```

### Create the models

Then you could create **CypherModel** models like this:

```python
from cyphermodel import Field, Node, Relationship


class Person(Node):
    name: str = Field(primary_key=True)
    born: int | None = None


class Movie(Node):
    title: str = Field(primary_key=True)
    released: int


class ActedIn(Relationship[Person, Movie]):
    roles: list[str] = []
```

The class `Person` is a **node model**, its label is `Person`. Each attribute is a property, and `name` identifies a person.

The class `ActedIn` is a **relationship model** from a `Person` to a `Movie`, its type is `ACTED_IN`. Its properties belong to the relationship itself.

### Write to the graph

```python hl_lines="1  6  10-16"
from cyphermodel import Graph

keanu = Person(name="Keanu Reeves", born=1964)
matrix = Movie(title="The Matrix", released=1999)

graph = Graph("bolt://localhost:7687")


async def main() -> None:
    async with graph.session() as session:
        session.add_all([
            keanu,
            matrix,
            ActedIn(source=keanu, target=matrix, roles=["Neo"]),
        ])
        await session.commit()
```

The session gathers what you add and writes it in one transaction, with `MERGE` on the primary keys, batched with `UNWIND`.

### Read from the graph

```python hl_lines="1  6-8"
from cyphermodel import select


async def actors_of_the_90s() -> list[Person]:
    async with graph.session() as session:
        statement = select(Person).where(Person.acted_in(Movie.released < 2000))
        people = await session.exec(statement)
        return people.all()
```

`people.all()` is a `list[Person]`, and your editor knows it. How traversals are spelled (`Person.acted_in(...)` here) is one of the open design questions.

### Raw Cypher, still typed

When a query is better written in Cypher, write it in Cypher and keep the types:

```python
async def co_actors(name: str) -> list[Person]:
    async with graph.session() as session:
        result = await session.cypher(
            """
            MATCH (:Person {name: $name})-[:ACTED_IN]->(:Movie)<-[:ACTED_IN]-(other:Person)
            RETURN DISTINCT other
            """,
            {"name": name},
            returns=Person,
        )
        return result.all()
```

### Editor support everywhere

Models are plain Pydantic models with type annotations, so autocompletion, inline errors and type checking work in models, in queries and on results, before anything reaches the database.

## Pydantic and the Neo4j driver

**CypherModel** is a thin layer on two well maintained projects. A `Node` is a Pydantic model, so everything Pydantic does still works: validation, serialization, JSON Schema. Queries run on the async Neo4j driver, in managed read or write transactions, retried by the driver on transient errors.

## License

This project is licensed under the terms of the [MIT license](https://gitlab.com/businessagile/libraries/cyphermodel/-/blob/development/LICENSE).
