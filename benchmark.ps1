param(
    [string]$Cenario = "normal"
)

$classpath = ".\core\target\core-0.1.4.jar;.\cassandra\target\cassandra-binding-0.1.4.jar"

if ($Cenario -eq "falha") {
    $nosAtivos = "2/3"
    $titulo = "CENÁRIO DE FALHA"
}
else {
    $nosAtivos = "3/3"
    $titulo = "CENÁRIO NORMAL"
}

Write-Host ""
Write-Host "========================================"
Write-Host "       BENCHMARK YCSB + CASSANDRA"
Write-Host "========================================"
Write-Host $titulo
Write-Host "Nós ativos: $nosAtivos"
Write-Host "RF: 3"
Write-Host ""

$consistencias = @("ONE", "QUORUM", "ALL")

foreach ($consistencia in $consistencias) {

    Write-Host "Consistência: $consistencia"
    Write-Host "Executando YCSB..."
    Write-Host ""

    $process = Start-Process `
        -FilePath "java" `
        -ArgumentList @(
            "-cp", $classpath,
            "com.yahoo.ycsb.Client",
            "-db", "com.yahoo.ycsb.db.CassandraClient10",
            "-P", ".\workloads\workloada",
            "-p", "hosts=127.0.0.1",
            "-p", "cassandra.columnfamily=Standard1",
            "-p", "cassandra.readconsistencylevel=$consistencia",
            "-p", "cassandra.writeconsistencylevel=$consistencia",
            "-p", "recordcount=1000",
            "-p", "operationcount=1000",
            "-t"
        ) `
        -NoNewWindow `
        -PassThru `
        -RedirectStandardOutput ".\benchmark-temp-output.log" `
        -RedirectStandardError ".\benchmark-temp-error.log"

    $tempoLimite = 30
    $tempo = 0

    while (-not $process.HasExited -and $tempo -lt $tempoLimite) {
        Start-Sleep -Seconds 1
        $tempo++
    }

    if (-not $process.HasExited) {

        Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue

        Write-Host "----------------------------------------"
        Write-Host "Runtime:    > $tempoLimite segundos"
        Write-Host "Throughput: ---"
        Write-Host "Resultado:  TIMEOUT / NÃO CONCLUIU"
        Write-Host "----------------------------------------"
    }
    else {

        $output = Get-Content ".\benchmark-temp-output.log"

        $runtimeLinha = $output | Select-String "\[OVERALL\], RunTime\(ms\)"
        $throughputLinha = $output | Select-String "\[OVERALL\], Throughput\(ops/sec\)"

        if ($runtimeLinha -and $throughputLinha) {

            $runtime = $runtimeLinha.ToString().Split(",")[-1].Trim()
            $throughput = $throughputLinha.ToString().Split(",")[-1].Trim()

            Write-Host "----------------------------------------"
            Write-Host "Runtime:    $runtime ms"
            Write-Host "Throughput: $throughput ops/sec"
            Write-Host "Resultado:  SUCESSO"
            Write-Host "----------------------------------------"
        }
        else {

            Write-Host "----------------------------------------"
            Write-Host "Resultado:  NÃO CONCLUIU"
            Write-Host "----------------------------------------"
        }
    }

    Write-Host ""
}