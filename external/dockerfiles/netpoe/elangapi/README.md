# Can computers create their own opinions?

ELang is a library of world languages arranged by 

- Language codes. e.g. es_MX
- Parts of speech structured alphabetically

In the future, ELang should be able to parse content and: 

- Fix grammar mistakes
- Fix typos
- Get the context of what's written
- Answer questions like: who, when, where, what, how much, __why__
- Get similarities between different blocks of content
- Be able to generate human-like conclusions from the parsed content such as: _Ben is trying to fix his code and he is requesting Elaine's help_ (in all languages)
- Be able to generate human-like opinions from the parsed content such as: _I don't think you should go to that trip, it's too dangerous considering the current situation in that country_ (in all languages)

## Roadmap

It would be great to have a robust API where the endpoints work something like this:

```
GET //elang.something/{language_code}/verbs?l=a,f,t

GET //elang.something/{language_code}/verbs?conjugate=dance

GET //elang.something/{language_code}/verbs?toPast=code

GET //elang.something/{language_code}/nouns?similarTo=keyboard

GET //elang.something/{language_code}/content?get=verbs

GET //elang.something/{language_code}/content?get=sentences

GET //elang.something/{language_code}/content?who=1&when=1
```

## Resources

### es_MX

- [Partes del diccionario](https://www.unprofesor.com/lengua-espanola/el-diccionario-y-sus-partes-264.html)
- [Graphaware neo4j PHP Client](https://github.com/graphaware/neo4j-php-client)
- [5000 most common spanish words paginated](https://www.memrise.com/course/203799/5000-most-frequent-spanish-words/1/)
- [Wordreference definitions used like `/definicion/{word}`](http://www.wordreference.com/definicion/entender)
- [Abreviaturas y signos usados](http://www.rae.es/sites/default/files/Abreviaturas_y_signos_empleados.pdf)
- [Abreviaturas de las categorías gramaticales](http://www.culturaderioja.org/index.php/notas-para-el-uso-del-diccionario/abreviaturas-de-las-categorias-gramaticales)
