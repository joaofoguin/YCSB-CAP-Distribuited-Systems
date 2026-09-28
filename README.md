# YCSB + Cassandra — Experimento sobre CAP

Experimento acadêmico da disciplina de Sistemas Distribuídos utilizando o **Yahoo! Cloud System Benchmark (YCSB)** e um cluster **Apache Cassandra 0.7.0** para observar, de forma prática, o comportamento de consistência e disponibilidade diante da indisponibilidade de um nó.

## Objetivo

Avaliar o comportamento do Cassandra em três cenários:

1. **Normal:** os três nós estão disponíveis;
2. **Falha:** um dos três nós é desligado;
3. **Recuperação:** o nó indisponível é iniciado novamente.

Em cada cenário são avaliados os níveis de consistência:

- **ONE**
- **QUORUM**
- **ALL**

O experimento permite relacionar os resultados aos conceitos de **Consistency, Availability e Partition Tolerance (CAP)**, principalmente observando a relação entre o requisito de consistência e a disponibilidade quando um nó fica indisponível.

> **Importante:** ONE, QUORUM e ALL são níveis de consistência configuráveis do Cassandra e não representam, individualmente, os três elementos do CAP. Os resultados deste experimento demonstram um comportamento observado no ambiente configurado; não constituem, isoladamente, uma prova do teorema CAP.

---

## Tecnologias utilizadas

| Tecnologia | Versão |
|---|---|
| YCSB | 0.1.4 |
| Apache Cassandra | 0.7.0 |
| Java — YCSB/Maven | 17.0.12 |
| Java — Cassandra | 1.7.0_80 |
| Maven | 3.3.9 |
| Sistema operacional | Windows 11 |
| Nós Cassandra | 3 |
| Replication Factor | 3 |

O Cassandra 0.7.0 utiliza componentes antigos da JVM e, por isso, foi executado com **Java 7**. O YCSB foi compilado e executado com **Java 17**.

---

## Estrutura do experimento

### Cluster

O cluster foi executado em uma única máquina utilizando endereços diferentes da interface de loopback:

| Nó | Endereço | Storage | Thrift | JMX |
|---|---|---:|---:|---:|
| Node 1 | 127.0.0.1 | 7000 | 9160 | 8080 |
| Node 2 | 127.0.0.2 | 7000 | 9160 | 8081 |
| Node 3 | 127.0.0.3 | 7000 | 9160 | 8082 |

O fator de replicação utilizado nos testes foi:

```text
RF = 3
```

Assim, cada operação possui até três réplicas.

### Workload

Foi utilizado o **Workload A** do YCSB:

```text
recordcount=1000
operationcount=1000
readproportion=0.5
updateproportion=0.5
scanproportion=0
insertproportion=0
requestdistribution=zipfian
```

Ou seja:

- 1000 registros;
- 1000 operações;
- 50% de leituras;
- 50% de atualizações;
- distribuição Zipfian.

---

## Níveis de consistência

### ONE

Precisa de resposta de uma réplica.

### QUORUM

Precisa de resposta da maioria das réplicas.

Com RF=3:

```text
QUORUM = 2 réplicas
```

### ALL

Precisa de resposta de todas as réplicas.

Com RF=3:

```text
ALL = 3 réplicas
```

Essa diferença foi utilizada para observar o comportamento do sistema quando um dos três nós fica indisponível.

---

## Automação

O repositório contém o script:

```text
benchmark.ps1
```

Execução do cenário normal:

```powershell
.\benchmark.ps1 normal
```

Execução do cenário de falha:

```powershell
.\benchmark.ps1 falha
```

O script executa automaticamente os testes **ONE, QUORUM e ALL**.

Cada execução possui um limite de **30 segundos**. Caso o YCSB não termine nesse período, o processo é encerrado e o resultado é registrado como **TIMEOUT / NÃO CONCLUIU**.

---

# Resultados finais

Os valores abaixo correspondem à **execução automatizada final** realizada no ambiente configurado.

### Cenário normal — 3/3 nós

| Consistência | Runtime | Throughput | Resultado |
|---|---:|---:|---|
| ONE | 201 ms | 4975,12 ops/s | Concluído |
| QUORUM | 345 ms | 2898,55 ops/s | Concluído |
| ALL | 317 ms | 3154,57 ops/s | Concluído |

### Cenário de falha — 2/3 nós

O **Node 3 foi desligado**.

| Consistência | Runtime | Throughput | Resultado |
|---|---:|---:|---|
| ONE | 198 ms | 5050,51 ops/s | Concluído |
| QUORUM | 282 ms | 3546,10 ops/s | Concluído |
| ALL | > 30 s | — | Não concluiu / timeout |

O resultado de ALL não representa throughput zero. A execução simplesmente não terminou dentro do limite definido pelo benchmark.

### Cenário de recuperação — 3/3 nós

O **Node 3 foi iniciado novamente** e voltou a aparecer como `Up` e `Normal` no anel Cassandra.

| Consistência | Runtime | Throughput | Resultado |
|---|---:|---:|---|
| ONE | 215 ms | 4651,16 ops/s | Concluído |
| QUORUM | 348 ms | 2873,56 ops/s | Concluído |
| ALL | 377 ms | 2652,52 ops/s | Concluído |

---

## Resultado observado em relação ao CAP

O principal comportamento observado durante a falha foi:

```text
RF = 3

Node 1 ✓
Node 2 ✓
Node 3 ✗

ONE     → 1 réplica necessária → continua
QUORUM  → 2 réplicas necessárias → continua
ALL     → 3 réplicas necessárias → não conclui
```

![Throughput por nível de consistência](/assets/Throughput%20por%20nível%20de%20consistência.png)

Portanto, com um dos três nós indisponível, **ONE e QUORUM continuaram executando as operações testadas**, enquanto **ALL não conseguiu concluir dentro de 30 segundos**.

Após a recuperação do Node 3, os três níveis voltaram a concluir as operações.

Esse comportamento demonstra experimentalmente a relação entre os requisitos de consistência configurados e a disponibilidade do sistema em um ambiente replicado.

Não é adequado utilizar os valores de throughput de uma única execução para estabelecer uma ordem permanente de desempenho entre ONE, QUORUM e ALL.

---

## Compilação do YCSB

O projeto utiliza o YCSB 0.1.4. Para permitir a compilação no ambiente atual, o `pom.xml` foi adaptado de Java 6 para Java 7 no nível de compatibilidade do compilador.

Com Java 17 configurado:

```powershell
mvn -pl cassandra -am package -DskipTests
```

Os principais artefatos gerados são:

```text
core\target\core-0.1.4.jar
cassandra\target\cassandra-binding-0.1.4.jar
```

O benchmark é executado diretamente pelos JARs compilados.

---

## Documentação completa

A configuração detalhada do ambiente, comandos utilizados, configuração dos três nós, keyspace, fator de replicação, workload, automação e resultados completos está em:

**[CONFIGURACAO.md](CONFIGURACAO.md)**

---

## Arquivos principais

```text
YCSB/
├── README.md
├── CONFIGURACAO.md
├── benchmark.ps1
├── pom.xml
├── workloads/
│   └── workloada
├── core/
└── cassandra/
```

Arquivos de compilação, dados do Cassandra, logs e resultados temporários não fazem parte do versionamento.

---

## Estado do projeto

- [x] YCSB 0.1.4 configurado
- [x] Cassandra 0.7.0 configurado
- [x] Cluster com 3 nós criado
- [x] Replication Factor 3 configurado
- [x] Workload A configurado
- [x] ONE, QUORUM e ALL testados
- [x] Cenário normal executado
- [x] Falha de um nó executada
- [x] Cenário de recuperação executado
- [x] Benchmark automatizado com timeout
- [x] Resultados finais documentados
- [x] Relação experimental com CAP documentada

---

## Observação

Este projeto possui finalidade acadêmica e experimental. Os resultados apresentados correspondem ao ambiente específico utilizado nos testes e podem variar em outras máquinas, versões, configurações ou execuções.
