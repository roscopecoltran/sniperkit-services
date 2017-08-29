@test "mosquitto is the correct version" {
  run docker run smizy/mosquitto:${TAG} sh -c 'mosquitto -h | head -n 1 | grep -oE "\d+\.\d+\.\d+" '
  echo "${output}" 

  [ $status -eq 0 ]
  [ "${lines[0]}" = "${VERSION}" ]
}