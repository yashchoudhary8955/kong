return {
  postgres = {
    up = [[
      CREATE TABLE IF NOT EXISTS "parameters" (
        key            TEXT PRIMARY KEY,
        value          TEXT NOT NULL,
        created_at     TIMESTAMP WITH TIME ZONE
      );
    ]],
  },
  cassandra = {
    up = [[
      CREATE TABLE IF NOT EXISTS parameters(
        key            text,
        value          text,
        created_at     timestamp,
        PRIMARY KEY    (key)
      );
    ]],
  }
}
