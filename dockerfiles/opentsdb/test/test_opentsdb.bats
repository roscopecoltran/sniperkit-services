@test "tsdb returns the correct version" {
  run docker run --net vnet --volumes-from tsdb-1 smizy/opentsdb:${VERSION}-alpine tsdb version

  echo "${output}"

  [ $status -eq 0 ]
  [[ "${lines[0]}" =~ ^net.opentsdb.tools" ${VERSION}" ]]
}