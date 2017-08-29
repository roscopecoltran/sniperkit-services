@test "postgres is the correct version" {
  run docker run smizy/postgres:${TAG} psql --version
  [ $status -eq 0 ]
  [ "${lines[0]}" = "psql (PostgreSQL) ${VERSION}" ]
}