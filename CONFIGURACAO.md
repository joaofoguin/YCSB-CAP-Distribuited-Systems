# Configuração do ambiente YCSB + Cassandra

## 1. Objetivo

Este documento registra a configuração e os resultados finais do experimento realizado com o YCSB sobre um cluster Apache Cassandra 0.7.0 no Windows 11.

O experimento teve como objetivo observar, de forma prática, o comportamento de disponibilidade e dos diferentes requisitos de consistência do Cassandra em três situações:

1. operação normal do cluster;
2. indisponibilidade de um dos três nós;
3. recuperação do nó indisponível.

Foram utilizados os níveis de consistência:

- ONE
- QUORUM
- ALL

O YCSB foi utilizado como gerador de carga e ferramenta de benchmark.

> **Observação sobre CAP:** ONE, QUORUM e ALL são níveis de consistência configuráveis do Cassandra e não representam, individualmente, os três elementos do CAP. O experimento relaciona os resultados observados aos conceitos de consistência e disponibilidade durante a indisponibilidade de um nó. Ele não constitui, isoladamente, uma prova do teorema CAP nem deve ser usado para atribuir uma classificação absoluta ao Cassandra.

---

# 2. Ambiente

## Sistema operacional

Windows 11.

## Java utilizado pelo YCSB

Java 17:

```text
C:\Program Files\Java\jdk-17
```

Versão utilizada:

```text
17.0.12
```

## Java utilizado pelo Cassandra

O Cassandra 0.7.0 não é compatível com Java 17 devido ao uso de opções antigas da JVM, como:

```text
-XX:+UseParNewGC
```

Por isso, foi utilizado Java 7:

```text
C:\Program Files\Java\jdk1.7.0_80
```

Versão:

```text
1.7.0_80
```

### Regra de execução

- **Java 17:** compilação e execução do YCSB.
- **Java 7:** execução do Cassandra 0.7.0 e de suas ferramentas.

---

# 3. Maven

Foi utilizado o Maven 3.3.9:

```text
C:\Users\joaop\Tools\apache-maven-3.3.9
```

Variáveis utilizadas para compilação do YCSB:

```powershell
$env:JAVA_HOME="C:\Program Files\Java\jdk-17"
$env:MAVEN_HOME="$env:USERPROFILE\Tools\apache-maven-3.3.9"
$env:Path="$env:MAVEN_HOME\bin;$env:Path"
```

---

# 4. YCSB

Foi utilizado o YCSB 0.1.4.

Repositório de origem:

```text
https://github.com/rgcoelho01/YCSB
```

Diretório local utilizado durante a configuração:

```text
C:\Users\joaop\Documents\Code\Distribuited Systems\YCSB\YCSB
```

O projeto original utiliza configurações antigas de Java.

No arquivo `pom.xml`, foram alterados:

```xml
<source>1.6</source>
<target>1.6</target>
```

para:

```xml
<source>7</source>
<target>7</target>
```

Essa alteração foi necessária para permitir a compilação do projeto no ambiente atual e não altera a lógica do YCSB.

---

# 5. Compilação do YCSB

Com Java 17 configurado, foi utilizado:

```powershell
mvn -pl cassandra -am package -DskipTests
```

Entre os artefatos gerados estão:

```text
cassandra\target\cassandra-binding-0.1.4.jar
core\target\core-0.1.4.jar
```

Os testes foram executados diretamente pelos JARs compilados, sem depender do script `bin\ycsb`.

Comando-base:

```powershell
java -cp ".\core\target\core-0.1.4.jar;.\cassandra\target\cassandra-binding-0.1.4.jar" com.yahoo.ycsb.Client
```

---

# 6. Cassandra

Foi utilizado:

```text
Apache Cassandra 0.7.0
```

Diretório:

```text
C:\Users\joaop\Tools\apache-cassandra-0.7.0
```

A versão 0.7.0 foi utilizada por ser compatível com o binding Cassandra existente no YCSB 0.1.4.

---

# 7. Configuração inicial do Cassandra

Foi criada uma cópia do arquivo original:

```text
conf\cassandra.yaml.original
```

Os diretórios de armazenamento foram configurados para caminhos locais do Windows:

```yaml
data_file_directories:
    - C:/Users/joaop/Tools/apache-cassandra-0.7.0/data

commitlog_directory: C:/Users/joaop/Tools/apache-cassandra-0.7.0/commitlog

saved_caches_directory: C:/Users/joaop/Tools/apache-cassandra-0.7.0/saved_caches
```

Também foram criados os diretórios necessários para armazenamento.

---

# 8. Cluster com três nós

Foi criado um cluster com três nós na mesma máquina.

Foram utilizados diferentes endereços da interface de loopback:

| Nó | Endereço |
| --- | --- |
| Node 1 | 127.0.0.1 |
| Node 2 | 127.0.0.2 |
| Node 3 | 127.0.0.3 |

Cada nó utiliza as mesmas portas Cassandra, pois os endereços IP são diferentes.

| Nó | Storage | Thrift | JMX |
| --- | ---: | ---: | ---: |
| Node 1 | 7000 | 9160 | 8080 |
| Node 2 | 7000 | 9160 | 8081 |
| Node 3 | 7000 | 9160 | 8082 |

Tokens utilizados:

### Node 1

```text
162422213806482004240197338899574603198
```

### Node 2

```text
-56713727820156410577229101238628035243
```

### Node 3

```text
56713727820156410577229101238628035242
```

---

# 9. Seeds

Os três nós utilizam o Node 1 como seed:

```yaml
seeds: "127.0.0.1"
```

---

# 10. Scripts personalizados

Para executar múltiplas instâncias do Cassandra 0.7.0 na mesma instalação, foram criados:

```text
bin\cassandra-node2.bat
bin\cassandra-node3.bat
```

O Node 2 utiliza JMX 8081 e o Node 3 utiliza JMX 8082.

Os scripts também definem o diretório de configuração correspondente:

```text
conf-node2
conf-node3
```

Os dados dos nós são mantidos separadamente em:

```text
node1\data
node1\commitlog
node1\saved_caches

node2\data
node2\commitlog
node2\saved_caches

node3\data
node3\commitlog
node3\saved_caches
```

---

# 11. Inicialização dos nós

### Node 1

```powershell
cd "C:\Users\joaop\Tools\apache-cassandra-0.7.0"

$env:JAVA_HOME="C:\Program Files\Java\jdk1.7.0_80"
$env:Path="$env:JAVA_HOME\bin;$env:Path"

.\bin\cassandra.bat -f -Dcassandra.config=file:///C:/Users/joaop/Tools/apache-cassandra-0.7.0/conf/cassandra-node1.yaml
```

### Node 2

```powershell
cd "C:\Users\joaop\Tools\apache-cassandra-0.7.0"

$env:JAVA_HOME="C:\Program Files\Java\jdk1.7.0_80"
$env:Path="$env:JAVA_HOME\bin;$env:Path"

.\bin\cassandra-node2.bat -f
```

### Node 3

```powershell
cd "C:\Users\joaop\Tools\apache-cassandra-0.7.0"

$env:JAVA_HOME="C:\Program Files\Java\jdk1.7.0_80"
$env:Path="$env:JAVA_HOME\bin;$env:Path"

.\bin\cassandra-node3.bat -f
```

---

# 12. Verificação do cluster

A conectividade das portas foi verificada com `Test-NetConnection`.

A confirmação da participação dos três nós no mesmo anel foi realizada com:

```powershell
.\bin\nodetool.bat -h 127.0.0.1 ring
```

Resultado observado:

```text
127.0.0.2   Up   Normal
127.0.0.3   Up   Normal
127.0.0.1   Up   Normal
```

Portanto, os três nós estavam:

- Up;
- Normal;
- participando do mesmo anel Cassandra.

---

# 13. Keyspace e Column Family

O YCSB utiliza por padrão a keyspace:

```text
usertable
```

Por isso, foi criada a keyspace utilizada efetivamente pelo benchmark.

Dentro dela foi criada a Column Family:

```text
Standard1
```

Estrutura:

```text
usertable
└── Standard1
```

---

# 14. Fator de replicação

O cluster foi configurado para trabalhar com:

```text
Replication Factor (RF) = 3
```

Comando utilizado:

```text
update keyspace usertable with replication_factor=3;
```

A configuração foi verificada com:

```text
describe keyspace usertable;
```

A keyspace apresentou fator de replicação 3.

Após a configuração do RF=3, os dados utilizados nos experimentos principais foram carregados novamente pelo YCSB.

> Alterar o fator de replicação não significa, por si só, que dados antigos sejam imediatamente redistribuídos. Por isso, a carga utilizada nos experimentos principais foi realizada após a configuração do RF=3.

---

# 15. Binding Cassandra utilizado pelo YCSB

Foi utilizado:

```text
com.yahoo.ycsb.db.CassandraClient10
```

O binding permite configurar os níveis de consistência através das propriedades:

```text
cassandra.readconsistencylevel
cassandra.writeconsistencylevel
cassandra.scanconsistencylevel
cassandra.deleteconsistencylevel
```

O host utilizado nos testes foi:

```text
127.0.0.1
```

---

# 16. Workload utilizado

Foi utilizado o Workload A do YCSB:

```text
workloads\workloada
```

Configuração:

```text
recordcount=1000
operationcount=1000
readproportion=0.5
updateproportion=0.5
scanproportion=0
insertproportion=0
requestdistribution=zipfian
```

Portanto:

- 1000 registros;
- 1000 operações;
- 50% de leituras;
- 50% de atualizações;
- distribuição Zipfian;
- sem operações de scan;
- sem inserções durante a carga do benchmark.

---

# 17. Níveis de consistência avaliados

Foram avaliados:

### ONE

A operação precisa ser confirmada por uma réplica.

### QUORUM

A operação precisa ser confirmada por uma maioria das réplicas.

Com RF=3:

```text
QUORUM = 2 réplicas
```

### ALL

A operação precisa ser confirmada por todas as réplicas.

Com RF=3:

```text
ALL = 3 réplicas
```

Esses níveis não representam três modelos CAP diferentes. Eles permitem observar diferentes requisitos de consistência e seus efeitos sobre a disponibilidade durante a indisponibilidade de um nó.

---

# 18. Automação do benchmark

Foi criado o script:

```text
benchmark.ps1
```

O script permite executar:

```powershell
.\benchmark.ps1 normal
```

ou:

```powershell
.\benchmark.ps1 falha
```

Para cada cenário, são executados automaticamente:

- ONE;
- QUORUM;
- ALL.

O script utiliza um limite de 30 segundos por execução. Caso o processo não termine dentro desse período, ele é encerrado e o resultado é registrado como:

```text
TIMEOUT / NÃO CONCLUIU
```

Isso evita que o benchmark fique indefinidamente bloqueado durante o teste de `ALL` com um nó indisponível.

---

# 19. Resultados finais do experimento

Os resultados abaixo correspondem à **execução automatizada final** do benchmark.

Configuração comum:

- Cassandra 0.7.0;
- 3 nós;
- RF=3;
- YCSB 0.1.4;
- Workload A;
- 1000 registros;
- 1000 operações;
- 50% leitura / 50% atualização;
- ONE, QUORUM e ALL;
- limite de 30 segundos no script automatizado.

## 19.1 Cenário normal

Os três nós estavam ativos:

```text
3/3 nós
```

| Consistência | Nós ativos | Runtime (ms) | Throughput (ops/s) | Resultado |
| --- | ---: | ---: | ---: | --- |
| ONE | 3/3 | 201 | 4975,12 | Concluído |
| QUORUM | 3/3 | 345 | 2898,55 | Concluído |
| ALL | 3/3 | 317 | 3154,57 | Concluído |

---

## 19.2 Cenário de falha

O Node 3 foi desligado.

```text
Node 1 = ativo
Node 2 = ativo
Node 3 = indisponível

2/3 nós ativos
```

| Consistência | Nós ativos | Runtime | Throughput (ops/s) | Resultado |
| --- | ---: | ---: | ---: | --- |
| ONE | 2/3 | 198 ms | 5050,51 | Concluído |
| QUORUM | 2/3 | 282 ms | 3546,10 | Concluído |
| ALL | 2/3 | > 30 s | — | Não concluiu / timeout |

O teste `ALL` não recebeu throughput zero. Como a execução não terminou dentro do limite definido pelo benchmark, o resultado foi registrado como **não concluído**.

---

## 19.3 Cenário de recuperação

O Node 3 foi reiniciado.

O `nodetool ring` voltou a apresentar os três nós como `Up` e `Normal`.

```text
3/3 nós ativos
```

| Consistência | Nós ativos | Runtime (ms) | Throughput (ops/s) | Resultado |
| --- | ---: | ---: | ---: | --- |
| ONE | 3/3 | 215 | 4651,16 | Concluído |
| QUORUM | 3/3 | 348 | 2873,56 | Concluído |
| ALL | 3/3 | 377 | 2652,52 | Concluído |

---

# 20. Tabela consolidada dos resultados finais

| Cenário | Consistência | Nós ativos | Runtime | Throughput (ops/s) | Resultado |
| --- | --- | ---: | ---: | ---: | --- |
| Normal | ONE | 3/3 | 201 ms | 4975,12 | Concluído |
| Normal | QUORUM | 3/3 | 345 ms | 2898,55 | Concluído |
| Normal | ALL | 3/3 | 317 ms | 3154,57 | Concluído |
| Falha Node 3 | ONE | 2/3 | 198 ms | 5050,51 | Concluído |
| Falha Node 3 | QUORUM | 2/3 | 282 ms | 3546,10 | Concluído |
| Falha Node 3 | ALL | 2/3 | > 30 s | — | Não concluiu |
| Recuperação | ONE | 3/3 | 215 ms | 4651,16 | Concluído |
| Recuperação | QUORUM | 3/3 | 348 ms | 2873,56 | Concluído |
| Recuperação | ALL | 3/3 | 377 ms | 2652,52 | Concluído |

---

# 21. Interpretação dos resultados

Com os três nós ativos, os níveis `ONE`, `QUORUM` e `ALL` conseguiram concluir as 1000 operações.

Quando um dos três nós foi desligado:

- `ONE` continuou concluindo as operações;
- `QUORUM` continuou concluindo as operações;
- `ALL` não conseguiu concluir dentro do limite de 30 segundos.

Esse comportamento é compatível com os requisitos de confirmação de cada nível quando o fator de replicação é 3:

```text
RF = 3

ONE     → precisa de 1 réplica
QUORUM  → precisa de 2 réplicas
ALL     → precisa das 3 réplicas
```

Com dois nós disponíveis:

```text
ONE     → atende
QUORUM  → atende
ALL     → não atende
```

Após a recuperação do Node 3, os três níveis voltaram a concluir as execuções.

Os resultados demonstram experimentalmente a relação entre **requisitos de consistência e disponibilidade** em um sistema distribuído com replicação.

Eles não devem ser interpretados como uma prova isolada do teorema CAP. Também não é adequado utilizar os valores de throughput de uma única execução para afirmar que um nível de consistência é sempre mais rápido que outro.

---

# 22. Relação com o CAP

O experimento foi desenvolvido para observar empiricamente aspectos relacionados aos elementos do CAP, principalmente o comportamento de **consistência e disponibilidade diante da indisponibilidade de um nó**.

A relação observada pode ser resumida como:

```text
                    Cassandra
                       │
          ┌────────────┴────────────┐
          │                         │
   Consistência                 Disponibilidade
          │                         │
   ONE / QUORUM / ALL       Nó indisponível
          │                         │
          └────────────┬────────────┘
                       │
             comportamento observado
```

O Cassandra permite ajustar o nível de consistência por operação. Assim, o experimento não deve ser descrito simplesmente como uma escolha entre "C", "A" ou "P" feita através dos comandos ONE, QUORUM e ALL.

O que foi observado foi que, com RF=3 e um nó indisponível, níveis que exigem somente uma parte das réplicas conseguiram continuar executando, enquanto `ALL`, que exige todas as réplicas, deixou de concluir as operações.

---

# 23. Conclusão experimental

O experimento confirmou, no ambiente configurado, que:

1. o cluster de três nós funcionou com RF=3;
2. os três níveis de consistência foram executados em condição normal;
3. com um nó indisponível, `ONE` e `QUORUM` continuaram disponíveis para as operações testadas;
4. com um nó indisponível, `ALL` não concluiu dentro do limite de 30 segundos;
5. após a recuperação do nó, `ONE`, `QUORUM` e `ALL` voltaram a concluir;
6. o nível de consistência escolhido altera o número de réplicas necessárias para confirmar uma operação;
7. o comportamento observado permite relacionar experimentalmente consistência e disponibilidade em um sistema distribuído.

---

# 24. Estrutura dos arquivos relevantes

Os principais arquivos adicionados ou utilizados no experimento são:

```text
CONFIGURACAO.md
benchmark.ps1
pom.xml
workloads/
└── workloada
```

Os artefatos de compilação, dados do Cassandra e logs locais não devem ser versionados.

O `.gitignore` está configurado para ignorar:

- arquivos `target/`;
- JARs e classes gerados;
- logs;
- dados do Cassandra;
- diretórios de instalação;
- resultados locais de benchmark;
- arquivos temporários.

---

# 25. Estado final

A etapa experimental foi concluída:

- [x] YCSB configurado;
- [x] Cassandra 0.7.0 configurado;
- [x] cluster com 3 nós criado;
- [x] RF=3 configurado;
- [x] Workload A configurado;
- [x] benchmark automatizado criado;
- [x] cenário normal executado;
- [x] falha de um nó executada;
- [x] cenário de falha executado;
- [x] nó recuperado;
- [x] cenário de recuperação executado;
- [x] resultados finais registrados;
- [x] relação dos resultados com consistência e disponibilidade documentada.

O repositório contém o código e a documentação necessários para reproduzir a configuração e compreender o experimento realizado.
