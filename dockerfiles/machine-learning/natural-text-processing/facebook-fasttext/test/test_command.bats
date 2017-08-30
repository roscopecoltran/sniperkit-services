

@test "fasttext returns no error code" {
  run docker run -i smizy/fasttext:${VERSION}-alpine fasttext supervised -input /fastText/LICENSE -output /tmp/test

  echo "${output}"

  [ $status -eq 0 ]
}

