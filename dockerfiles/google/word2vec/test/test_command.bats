
@test "word2vec returns no error code" {
  run docker run -i smizy/word2vec:${VERSION}-alpine word2vec

  echo "${output}"

  [ $status -eq 0 ]
}


