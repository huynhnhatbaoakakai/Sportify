param(
    [string]$PostgresBin = 'C:\Program Files\PostgreSQL\18\bin'
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$temporaryRoot = Join-Path ([IO.Path]::GetTempPath()) ('sportify-pg-' + [guid]::NewGuid().ToString('N'))
$clusterPath = Join-Path $temporaryRoot 'data'
$started = $false
$testExit = 1

function Invoke-PostgresTool([string]$Tool, [string[]]$ToolArguments) {
    & (Join-Path $PostgresBin ($Tool + '.exe')) @ToolArguments
    if ($LASTEXITCODE -ne 0) { throw "$Tool failed with exit code $LASTEXITCODE" }
}

foreach ($tool in @('initdb', 'pg_ctl', 'createdb', 'psql')) {
    if (-not (Test-Path -LiteralPath (Join-Path $PostgresBin ($tool + '.exe')))) {
        throw "Missing $tool.exe; specify -PostgresBin with your PostgreSQL bin directory."
    }
}

$listener = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, 0)
$listener.Start()
$port = $listener.LocalEndpoint.Port
$listener.Stop()

New-Item -ItemType Directory -Path $temporaryRoot | Out-Null
Push-Location $projectRoot
try {
    Invoke-PostgresTool 'initdb' @('-D', $clusterPath, '-U', 'sportify_review_test', '-A', 'trust', '-E', 'UTF8')
    Invoke-PostgresTool 'pg_ctl' @('-D', $clusterPath, '-l', (Join-Path $temporaryRoot 'postgres.log'), '-o', "-p $port -h 127.0.0.1", '-w', 'start')
    $started = $true
    Invoke-PostgresTool 'createdb' @('-w', '-h', '127.0.0.1', '-p', "$port", '-U', 'sportify_review_test', 'sportify_review_test')
    $connection = @('-X', '-w', '-h', '127.0.0.1', '-p', "$port", '-U', 'sportify_review_test', '-d', 'sportify_review_test', '-v', 'ON_ERROR_STOP=1')
    # Apply twice to verify that installing/upgrading the schema is repeatable.
    Invoke-PostgresTool 'psql' ($connection + @('-f', 'database/init_all_postgresql.sql', '-f', 'database/04_booking_automation_postgresql.sql', '-f', 'database/05_user_profile_postgresql.sql', '-f', 'database/06_inventory_newsfeed_postgresql.sql', '-f', 'database/init_all_postgresql.sql', '-f', 'database/04_booking_automation_postgresql.sql', '-f', 'database/05_user_profile_postgresql.sql', '-f', 'database/06_inventory_newsfeed_postgresql.sql', '-f', 'src/test/resources/postgresql-fixtures.sql'))
    & mvn -B -ntp "-Dsportify.reviewTestUrl=jdbc:postgresql://127.0.0.1:$port/sportify_review_test" clean package
    $testExit = $LASTEXITCODE
} finally {
    if ($started) {
        & (Join-Path $PostgresBin 'pg_ctl.exe') -D $clusterPath -m fast -w stop
        if ($LASTEXITCODE -ne 0) { throw "Cannot stop test PostgreSQL. Inspect $temporaryRoot" }
    }
    Pop-Location
    $resolvedTemporaryRoot = (Resolve-Path -LiteralPath $temporaryRoot).Path
    $expectedParent = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\') + '\'
    if (-not $resolvedTemporaryRoot.StartsWith($expectedParent, [StringComparison]::OrdinalIgnoreCase) -or
        (Split-Path -Leaf $resolvedTemporaryRoot) -notmatch '^sportify-pg-[a-f0-9]{32}$') {
        throw 'Refusing to remove an unexpected test directory.'
    }
    Remove-Item -LiteralPath $resolvedTemporaryRoot -Recurse -Force
}

exit $testExit
