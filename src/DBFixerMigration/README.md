# DB Fixer Migration - AWS DMS Task Analyzer & Retry Manager

Esta aplicación está diseñada para analizar instancias de replicación de AWS DMS, detectar tareas completadas y fallidas, ejecutar scripts post-migración automáticamente, y gestionar reintentos de tareas fallidas de manera inteligente.

## Características Principales

- ?? **Análisis Automático**: Analiza múltiples instancias de replicación DMS y sus tareas
- ? **Post-Scripts Automáticos**: Ejecuta scripts de constraints e índices para tareas exitosas
- ?? **Reportes Detallados**: Genera reportes CSV de tareas fallidas con información detallada
- ?? **Sistema de Reintentos**: Reintenta tareas fallidas distribuyéndolas inteligentemente entre instancias
- ?? **Múltiples Autenticaciones AWS**: Soporte para SharedCredentialsFile, AccessKey, e IAMRole
- ??? **Modo Interactivo/Automático**: Configurable para ejecución manual o desatendida

## Configuración

### Métodos de Autenticación AWS

#### 1. Shared Credentials File (Recomendado para desarrollo)
```json
{
  "Aws": {
    "AuthenticationMethod": "SharedCredentialsFile",
    "ProfileName": "your-profile-name",
    "Region": "us-east-2"
  }
}
```

#### 2. Access Key (Para CI/CD)
```json
{
  "Aws": {
    "AuthenticationMethod": "AccessKey",
    "AccessKey": "AKIAIOSFODNN7EXAMPLE",
    "SecretKey": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
    "Region": "us-east-2"
  }
}
```

#### 3. IAM Role (Para EC2 instances)
```json
{
  "Aws": {
    "AuthenticationMethod": "IAMRole",
    "Region": "us-east-2"
  }
}
```

### Configuración de Instancias de Replicación

```json
{
  "Aws": {
    "ReplicationInstanceArns": [
      "arn:aws:dms:us-east-2:123456789012:rep:instance-1",
      "arn:aws:dms:us-east-2:123456789012:rep:instance-2",
      "arn:aws:dms:us-east-2:123456789012:rep:instance-3"
    ]
  }
}
```

### Scripts SQL Post-Migración

Configura los scripts que se ejecutarán automáticamente:

```json
{
  "SqlScripts": {
    "ChangesetConstraintScript": "ChangesetConstraints.sql",
    "PlatformConstraintsScript": "PlatformConstraints.sql", 
    "RuntimeConstraintsScript": "RuntimeConstraints.sql"
  }
}
```

### Configuración de Reintentos

```json
{
  "RetryFixer": {
    "EnableInteractiveRetry": true,
    "MaxRetryAttempts": 3,
    "RetryDelayMinutes": 5,
    "TableWhitelist": [
      {
        "SchemaPattern": "dbo",
        "TablePattern": "*",
        "Description": "All tables in dbo schema"
      }
    ]
  }
}
```

## Uso

### Ejecución Básica

```bash
dotnet run
```

### Flujo de Ejecución

1. **Análisis de Instancias**: Analiza todas las instancias DMS configuradas
2. **Detección de Tareas**: Identifica tareas completadas y fallidas
3. **Ejecución de Post-Scripts**: Ejecuta automáticamente scripts para tareas exitosas
4. **Generación de Reportes**: Crea reportes CSV de tareas fallidas
5. **Proceso de Reintentos**: Opcionalmente reintenta tareas fallidas

### Ejemplo de Salida

```
================================================================================
DB FIXER MIGRATION - AWS DMS Task Analyzer & Retry Manager
================================================================================

Using AWS authentication method: SharedCredentialsFile
Successfully created credentials using shared credentials file with profile: tzdev
Connected to AWS DMS in region: us-east-2
Analyzing 2 replication instances...

STEP 1: Analyzing replication instances and their tasks...
Analyzing instance: arn:aws:dms:us-east-2:025381531841:rep:QVOO4IMB2NCLTEMMQUMTB6NWQI
Instance instance-1: 25 tasks (25/50 tasks, 50/100 endpoints)
Found 3 replication instances

STEP 2: Processing successful tasks...
Found 20 successful tasks for post-script execution
Executing post-scripts for 20 successful tasks...
? Post-script executed successfully for database-1-changeset
? Post-script executed successfully for database-2-platform

STEP 3: Analyzing failed tasks...
Failed tasks report saved to: failed_tasks_report_20241215_143022.csv

================================================================================
FAILED TASKS SUMMARY
================================================================================
Total failed tasks: 15 across 5 databases

Database: database-3-changeset
  Failed tables: 8
    General Error: 5 tables
    Validation Error: 3 tables

STEP 4: Retry failed tasks...
Do you want to retry these failed tasks? (y/N): y

Processing retry for 8 retryable tasks...
Retry task created successfully for database-3-changeset: arn:aws:dms:...

Process completed in 15:30
```

## Características Avanzadas

### Distribución Inteligente de Reintentos

La aplicación distribuye automáticamente las tareas de reintento entre instancias disponibles, considerando:

- Límite máximo de 50 tareas por instancia
- Límite máximo de 100 endpoints por instancia
- Balanceo de carga optimizado

### Whitelist de Tablas para Reintentos

```json
{
  "TableWhitelist": [
    {
      "SchemaPattern": "dbo", 
      "TablePattern": "Users*",
      "Description": "User-related tables"
    },
    {
      "SchemaPattern": "public",
      "TablePattern": "*_temp",
      "Description": "Temporary tables"
    }
  ]
}
```

### Logging Detallado

Genera logs tanto en formato CSV como TXT:

```csv
Timestamp,Operation,Status,Details
2024-12-15 14:30:22,POST_SCRIPTS,Completed,"Executed post-scripts for 20 successful tasks"
2024-12-15 14:32:15,RETRY,Started,"Starting retry for 8 tasks"
```

### Configuración por Tipos de Base de Datos

La aplicación identifica automáticamente el tipo de base de datos y ejecuta el script correspondiente:

- **Changeset databases** (`*-changeset*`): `ChangesetConstraints.sql`
- **Platform databases** (`*-platform*`): `PlatformConstraints.sql`
- **Runtime databases** (otros): `RuntimeConstraints.sql`
- **Changeset Propagation** (`*changesetPropagation*`): No ejecuta scripts

## Estructura de Archivos

```
src/DBFixerMigration/
??? Program.cs                    # Programa principal
??? Models/
?   ??? AppSettings.cs           # Modelos de configuración
?   ??? TaskModels.cs            # Modelos de tareas y reportes
?   ??? DatabaseMigration.cs     # Modelo de migración de DB
??? Services/
?   ??? ReplicationInstanceAnalyzer.cs  # Analizador de instancias
?   ??? PostScriptExecutor.cs          # Ejecutor de post-scripts
?   ??? FailedTaskReporter.cs          # Generador de reportes
?   ??? RetryTaskManager.cs            # Gestor de reintentos
??? Designer/                    # Scripts SQL (crear carpeta)
?   ??? ChangesetConstraints.sql
?   ??? PlatformConstraints.sql
?   ??? RuntimeConstraints.sql
??? appsettings.json
??? appsettings.Development.json
??? DBFixerMigration.csproj
```

## Limitaciones de AWS DMS

La aplicación respeta automáticamente las limitaciones de AWS DMS:

- **50 tareas máximo** por instancia de replicación
- **100 endpoints máximo** por instancia de replicación (50 source + 50 target)
- Las tareas se distribuyen inteligentemente entre instancias disponibles

## Manejo de Errores

- **Instancias no disponibles**: Continúa con otras instancias
- **Scripts faltantes**: Registra warning y continúa
- **Errores de conexión**: Reintenta automáticamente
- **Fallos de tareas**: Se registran para análisis posterior

## Seguridad

- Las credenciales se manejan de forma segura usando AWS SDK
- Los passwords se mantienen en configuración local
- Soporte para IAM roles en ambiente productivo

## Monitoreo y Logs

- Logs detallados en tiempo real
- Reportes CSV exportables
- Métricas de rendimiento por lotes
- Seguimiento de estado por instancia

## Troubleshooting

### Error: "No replication instances found"
- Verificar que los ARNs sean correctos
- Confirmar permisos de AWS
- Revisar la región configurada

### Error: "Post-script execution failed"
- Verificar que existan los archivos SQL en la carpeta Designer/
- Confirmar conectividad a PostgreSQL
- Revisar permisos de base de datos

### Error: "No available instance for retry"
- Todas las instancias están en capacidad máxima
- Considerar agregar más instancias o limpiar tareas obsoletas

## Permisos AWS Requeridos

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow", 
      "Action": [
        "dms:DescribeReplicationInstances",
        "dms:DescribeReplicationTasks",
        "dms:DescribeTableStatistics",
        "dms:CreateEndpoint",
        "dms:DeleteEndpoint",
        "dms:CreateReplicationTask",
        "dms:StartReplicationTask",
        "dms:StopReplicationTask"
      ],
      "Resource": "*"
    }
  ]
}
```

## Contribución

La aplicación está diseñada para ser extensible. Para agregar nuevos tipos de análisis o funcionalidades de retry, extender las interfaces en la carpeta Services/.

## Ejemplo de Configuración Completa

Ver `appsettings.json` para una configuración completa con todas las opciones disponibles.