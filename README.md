## Function for generator UUID V7 in PostgreSQL

### Overview

The uuid_generate_v7 function is a tool for generating v7-like UUIDs in PostgreSQL. It merges the current UNIX timestamp in milliseconds with 10 random bytes to create unique identifiers, complying with the UUID RFC 4122 specification.

### Benefits
A v7 UUID has a distinct advantage over v4 because the timestamp prefix allows them to be partially sequential. This allows better indexing performance in comparison to completely random UUIDs (v4). This is particularly beneficial for databases that frequently insert and search records.

### Test
```sql
SELECT uuid_generate_v7(now())
```
Parameter `now()` taken as timestamp from your current time zone.

otherwise you can declare the `now()` parameter from the initial function when generate the uuid

```sql
CREATE OR REPLACE FUNCTION generate_uuid_v7(now())
```