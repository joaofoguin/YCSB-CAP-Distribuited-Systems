# Configuração do ambiente YCSB + Cassandra

## 1. Objetivo

Este documento registra a configuração realizada para executar experimentos
do YCSB sobre um cluster Cassandra 0.7.0 no Windows 11.

O experimento tem como objetivo analisar o comportamento do sistema distribuído
sob diferentes níveis de consistência, em condições normais, durante falha de um nó
e após a recuperação do cluster.

Os níveis de consistência que serão utilizados são:

- ONE
- QUORUM
- ALL

O YCSB será utilizado como gerador de carga e ferramenta de benchmark.

---

# 2. Ambiente

## Sistema operacional

Windows 11

## Java utilizado pelo YCSB

Java 17:

```text
C:\Program Files\Java\jdk-17

Versão utilizada:

17.0.12
Java utilizado pelo Cassandra

O Cassandra 0.7.0 não é compatível com Java 17 devido às opções antigas da
JVM, como:

-XX:+UseParNewGC

Por isso, foi instalado o Java 7:

C:\Program Files\Java\jdk1.7.0_80

Versão:

1.7.0_80
Regra importante

Java 17 é utilizado para compilação e execução do YCSB.

Java 7 é utilizado para executar o Cassandra 0.7.0 e suas ferramentas.

3. Maven

Foi utilizado o Maven 3.3.9:

C:\Users\joaop\Tools\apache-maven-3.3.9

Variáveis utilizadas:

$env:JAVA_HOME="C:\Program Files\Java\jdk-17"
$env:MAVEN_HOME="$env:USERPROFILE\Tools\apache-maven-3.3.9"
$env:Path="$env:MAVEN_HOME\bin;$env:Path"
4. YCSB

Repositório utilizado:

https://github.com/rgcoelho01/YCSB

Versão encontrada no projeto:

YCSB 0.1.4

Diretório local:

C:\Users\joaop\Documents\Code\Distribuited Systems\YCSB\YCSB

O projeto original utiliza configurações antigas de Java.

No arquivo:

pom.xml

foram alterados:

<source>1.6</source>
<target>1.6</target>

para:

<source>7</source>
<target>7</target>

Essa alteração foi necessária para permitir a compilação do projeto com
Java 17 e não altera a lógica do YCSB.

5. Compilação do YCSB

Com Java 17 configurado:

$env:JAVA_HOME="C:\Program Files\Java\jdk-17"
$env:MAVEN_HOME="$env:USERPROFILE\Tools\apache-maven-3.3.9"
$env:Path="$env:MAVEN_HOME\bin;$env:Path"

O projeto foi compilado com:

mvn -pl cassandra -am package -DskipTests

Foram gerados, entre outros:

cassandra\target\cassandra-binding-0.1.4.jar
core\target\core-0.1.4.jar
6. Cassandra

Foi utilizado:

Apache Cassandra 0.7.0

Diretório:

C:\Users\joaop\Tools\apache-cassandra-0.7.0

A versão 0.7.0 foi escolhida porque é compatível com o binding Cassandra
existente no YCSB 0.1.4.

7. Configuração inicial do Cassandra

Foi criada uma cópia do arquivo original:

conf\cassandra.yaml.original

Os diretórios de armazenamento foram alterados para caminhos locais do
Windows.

A configuração inicial utilizou:

data_file_directories:
    - C:/Users/joaop/Tools/apache-cassandra-0.7.0/data

commitlog_directory: C:/Users/joaop/Tools/apache-cassandra-0.7.0/commitlog

saved_caches_directory: C:/Users/joaop/Tools/apache-cassandra-0.7.0/saved_caches

Foram criados os diretórios:

data
commitlog
saved_caches
8. Java 7 para o Cassandra

Antes de executar o Cassandra:

$env:JAVA_HOME="C:\Program Files\Java\jdk1.7.0_80"
$env:Path="$env:JAVA_HOME\bin;$env:Path"

A versão pode ser verificada com:

java -version

Resultado esperado:

java version "1.7.0_80"
9. Cluster com três nós

Foi criado um cluster com três nós na mesma máquina.

Foram utilizados diferentes endereços da interface de loopback:

Node 1 = 127.0.0.1
Node 2 = 127.0.0.2
Node 3 = 127.0.0.3

Cada nó utiliza as mesmas portas Cassandra porque os endereços IP são
diferentes.

Node 1
IP: 127.0.0.1
Storage: 7000
Thrift: 9160
JMX: 8080

Token:

162422213806482004240197338899574603198

Arquivo:

conf\cassandra-node1.yaml
Node 2
IP: 127.0.0.2
Storage: 7000
Thrift: 9160
JMX: 8081

Token:

-56713727820156410577229101238628035243

Arquivo:

conf\cassandra-node2.yaml

Diretório de configuração utilizado pelo processo:

conf-node2

Arquivo efetivo:

conf-node2\cassandra.yaml

Dados:

node2\data
node2\commitlog
node2\saved_caches
Node 3
IP: 127.0.0.3
Storage: 7000
Thrift: 9160
JMX: 8082

Token:

56713727820156410577229101238628035242

Arquivo:

conf\cassandra-node3.yaml

Diretório de configuração:

conf-node3

Arquivo efetivo:

conf-node3\cassandra.yaml

Dados:

node3\data
node3\commitlog
node3\saved_caches
10. Seeds

Os três nós utilizam o Node 1 como seed:

seeds: "127.0.0.1"
11. Scripts personalizados

O Cassandra 0.7.0 possui scripts antigos que dificultam executar várias
instâncias na mesma instalação.

O arquivo original:

bin\cassandra.bat

possui o JMX fixado em:

-Dcom.sun.management.jmxremote.port=8080

Por isso foram criados scripts específicos:

bin\cassandra-node2.bat
bin\cassandra-node3.bat

O Node 2 utiliza:

JMX = 8081

O Node 3 utiliza:

JMX = 8082

Além disso, os scripts definem o diretório de configuração correspondente.

Node 2:

set CASSANDRA_CONF=%CASSANDRA_HOME%\conf-node2

Node 3:

set CASSANDRA_CONF=%CASSANDRA_HOME%\conf-node3

O classpath também foi alterado para utilizar o diretório de configuração
correspondente:

set CLASSPATH=%CASSANDRA_CONF%

Essa alteração foi necessária porque o cassandra.bat original força:

set CLASSPATH=%CASSANDRA_HOME%\conf
## 12. Inicialização dos nós

### Node 1

Utilizando Java 7:

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

Os três processos devem permanecer executando.

---

## 13. Verificação das portas

Foi utilizada:

```powershell
Get-NetTCPConnection -State Listen |
Where-Object {$_.LocalPort -in 7000,9160,8080,8081,8082} |
Sort-Object LocalPort,LocalAddress |
Select-Object LocalAddress,LocalPort,OwningProcess
```

Resultado obtido:

```text
127.0.0.1   7000   Node 1
127.0.0.2   7000   Node 2
127.0.0.3   7000   Node 3

127.0.0.1   9160   Node 1
127.0.0.2   9160   Node 2
127.0.0.3   9160   Node 3

8080         Node 1
8081         Node 2
8082         Node 3
```

---

## 14. Teste de conectividade

Foi utilizada a ferramenta:

```powershell
Test-NetConnection
```

Exemplo:

```powershell
Test-NetConnection 127.0.0.2 -Port 7000
```

e:

```powershell
Test-NetConnection 127.0.0.3 -Port 7000
```

Todos os nós apresentaram:

```text
TcpTestSucceeded : True
```

---

## 15. Confirmação do cluster

A confirmação efetiva do cluster foi realizada através do:

```powershell
.\bin\nodetool.bat -h 127.0.0.1 ring
```

Resultado:

```text
127.0.0.2   Up   Normal
127.0.0.3   Up   Normal
127.0.0.1   Up   Normal
```

Portanto, os três nós estão:

- Up
- Normal
- Participando do mesmo anel Cassandra.

---

## 16. Criação da keyspace

Inicialmente foi criada:

```text
Keyspace1
```

com:

```text
replication_factor=1
```

Entretanto, o YCSB utiliza por padrão a keyspace:

```text
usertable
```

Isso foi identificado através dos erros apresentados pelo YCSB.

Por isso, foi criada a keyspace utilizada efetivamente pelo benchmark:

```text
usertable
```

---

## 17. Column Family

Dentro da keyspace `usertable` foi criada:

```text
Standard1
```

com:

```text
comparator='UTF8Type'
```

Estrutura utilizada pelo YCSB:

```text
usertable
└── Standard1
```

---

## 18. Replicação

Após a criação do cluster de três nós, o fator de replicação da keyspace `usertable` foi alterado para:

```text
replication_factor=3
```

Comando utilizado no Cassandra CLI:

```text
update keyspace usertable with replication_factor=3;
```

A alteração foi aceita pelo Cassandra.

Após a alteração do fator de replicação, os dados foram carregados novamente pelo YCSB para que os experimentos principais fossem realizados com fator de replicação 3.

---

## 19. Binding Cassandra utilizado pelo YCSB

Foi utilizado:

```text
com.yahoo.ycsb.db.CassandraClient10
```

O `CassandraClient10` permite configurar os níveis de consistência através das propriedades:

```text
cassandra.readconsistencylevel
cassandra.writeconsistencylevel
cassandra.scanconsistencylevel
cassandra.deleteconsistencylevel
```

O host é informado através de:

```text
hosts
```

O YCSB seleciona aleatoriamente um dos hosts informados.

---

## 20. Níveis de consistência

Os testes planejados utilizarão:

- ONE
- QUORUM
- ALL

Esses valores representam níveis de consistência do Cassandra.

Eles não devem ser tratados como três modelos CAP diferentes.

O objetivo é observar experimentalmente como diferentes níveis de consistência afetam:

- throughput;
- latência;
- erros;
- disponibilidade;
- comportamento durante falhas/partições;
- recuperação.

---

## 21. Primeiro teste do YCSB

O YCSB foi executado diretamente através dos JARs compilados:

```powershell
java -cp ".\core\target\core-0.1.4.jar;.\cassandra\target\cassandra-binding-0.1.4.jar" com.yahoo.ycsb.Client
```

Workload utilizado:

```text
workloads\workloada
```

Configuração principal:

```text
recordcount=1000
operationcount=1000
readproportion=0.5
updateproportion=0.5
```

---

## 22. Teste inicial de carga

Comando:

```powershell
java -cp ".\core\target\core-0.1.4.jar;.\cassandra\target\cassandra-binding-0.1.4.jar" com.yahoo.ycsb.Client -db com.yahoo.ycsb.db.CassandraClient10 -P ".\workloads\workloada" -p hosts=127.0.0.1 -p cassandra.columnfamily=Standard1 -p cassandra.writeconsistencylevel=ONE -load *> ycsb-load.log
```

Resultado:

```text
Throughput: 2645.50 ops/sec
```

---

## 23. Baseline com um nó

Antes da configuração definitiva do cluster, foram realizados testes com apenas um nó.

### ONE

```text
Runtime: 322 ms
Throughput: 3105.59 ops/sec
Errors: 0
```

### QUORUM

```text
Runtime: 334 ms
Throughput: 2994.01 ops/sec
Errors: 0
```

### ALL

```text
Runtime: 268 ms
Throughput: 3731.34 ops/sec
Errors: 0
```

Esses valores são apenas uma linha de base inicial.

Não devem ser utilizados isoladamente para concluir que um determinado nível de consistência é sempre mais rápido.

Os testes do experimento principal serão realizados posteriormente com o cluster de três nós.

---

## 24. Resultados experimentais

Os experimentos principais foram realizados com:

- cluster Cassandra com 3 nós;
- fator de replicação (RF) igual a 3;
- workload A do YCSB;
- 1000 registros;
- 1000 operações;
- 50% de leitura e 50% de atualização;
- binding `com.yahoo.ycsb.db.CassandraClient10`;
- níveis de consistência `ONE`, `QUORUM` e `ALL`;
- cenários de operação normal, falha do Node 3 e recuperação do Node 3.

### 24.1 Operação normal

Com os três nós ativos, os três níveis de consistência concluíram a execução sem erros registrados:

| Consistência | Nós ativos | Runtime (ms) | Throughput (ops/s) | Erros | Resultado |
| --- | ---: | ---: | ---: | ---: | --- |
| ONE | 3/3 | 322 | 3105,59 | 0 | Concluído |
| QUORUM | 3/3 | 454 | 2202,64 | 0 | Concluído |
| ALL | 3/3 | 410 | 2439,02 | 0 | Concluído |

### 24.2 Falha do Node 3

O Node 3 (`127.0.0.3`) foi interrompido e o cluster permaneceu com dois dos três nós ativos.

| Consistência | Nós ativos | Runtime | Throughput (ops/s) | Erros | Resultado |
| --- | ---: | ---: | ---: | ---: | --- |
| ONE | 2/3 | 268 ms | 3731,34 | 0 | Concluído |
| QUORUM | 2/3 | 369 ms | 2710,03 | 0 | Concluído |
| ALL | 2/3 | > 5 min | — | — | Não concluiu no período observado; execução interrompida |

No teste com `ALL`, a execução permaneceu aguardando por mais de cinco minutos e foi interrompida manualmente. Como a execução não chegou ao final, não foi atribuído throughput zero a esse teste.

### 24.3 Recuperação

O Node 3 foi reiniciado e o comando `nodetool ring` confirmou novamente os três nós como `Up` e `Normal`. Em seguida, os testes foram executados novamente:

| Consistência | Nós ativos | Runtime (ms) | Throughput (ops/s) | Erros | Resultado |
| --- | ---: | ---: | ---: | ---: | --- |
| ONE | 3/3 | 381 | 2624,67 | 0 | Concluído |
| QUORUM | 3/3 | 382 | 2617,80 | 0 | Concluído |
| ALL | 3/3 | 484 | 2066,12 | 0 | Concluído |

### 24.4 Observações

Os resultados mostram que, durante a falha de um nó, `ONE` e `QUORUM` conseguiram concluir as operações com dois dos três nós ativos, enquanto `ALL` não concluiu dentro do período observado.

Após a recuperação do Node 3, os três níveis de consistência voltaram a concluir as execuções.

Esses resultados representam o comportamento observado nesta execução experimental. Eles não devem ser interpretados como uma prova isolada do teorema CAP nem como uma classificação fixa do Cassandra como CP ou AP. O objetivo é relacionar, de forma experimental, os requisitos de consistência e disponibilidade observados durante a falha e a recuperação.

As diferenças de throughput entre as execuções também não devem ser utilizadas, isoladamente, para estabelecer que um nível de consistência é sempre mais rápido que outro, pois os valores dependem das condições específicas de cada execução.

---

## 25. Estrutura final do experimento

| Cenário | Consistência | Nós ativos | Throughput (ops/s) | Latência/Runtime | Erros | Disponibilidade observada |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| Normal | ONE | 3/3 | 3105,59 | 322 ms | 0 | Concluído |
| Normal | QUORUM | 3/3 | 2202,64 | 454 ms | 0 | Concluído |
| Normal | ALL | 3/3 | 2439,02 | 410 ms | 0 | Concluído |
| Falha do Node 3 | ONE | 2/3 | 3731,34 | 268 ms | 0 | Concluído |
| Falha do Node 3 | QUORUM | 2/3 | 2710,03 | 369 ms | 0 | Concluído |
| Falha do Node 3 | ALL | 2/3 | — | > 5 min | — | Não concluiu no período observado |
| Recuperação | ONE | 3/3 | 2624,67 | 381 ms | 0 | Concluído |
| Recuperação | QUORUM | 3/3 | 2617,80 | 382 ms | 0 | Concluído |
| Recuperação | ALL | 3/3 | 2066,12 | 484 ms | 0 | Concluído |

### 25.1 Logs utilizados

Os resultados foram registrados nos arquivos de log gerados durante as execuções:

`ycsb-load-rf3.log`

`ycsb-one-rf3.log`

`ycsb-quorum-rf3.log`

`ycsb-all-rf3.log`

`ycsb-one-falha.log`

`ycsb-quorum-falha.log`

`ycsb-all-falha.log`

`ycsb-one-recuperacao.log`

`ycsb-quorum-recuperacao.log`

O log do teste `ALL` durante a falha não possui resultado final de throughput porque a execução foi interrompida após permanecer aguardando por mais de cinco minutos.

### 25.2 Situação da etapa experimental

A etapa experimental prevista neste documento foi concluída:

1. Cluster de três nós configurado.
2. Keyspace `usertable` configurada com RF=3.
3. Carga do YCSB executada.
4. Testes com `ONE`, `QUORUM` e `ALL` executados em condição normal.
5. Falha do Node 3 realizada.
6. Testes durante a falha executados.
7. Node 3 recuperado.
8. Testes após a recuperação executados.
9. Resultados registrados para análise em relação aos conceitos do teorema CAP.
