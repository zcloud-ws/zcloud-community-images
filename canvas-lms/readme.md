# Canvas LMS Docker Image

Docker image baseada no projeto [Canvas LMS](https://github.com/instructure/canvas-lms) da Instructure.

## Características

- Baseada em Ubuntu 22.04 LTS
- Ruby 3.4+ e Node.js 20.x
- PostgreSQL 14+ (cliente)
- Redis 6.x+ para cache e jobs
- Configuração via variáveis de ambiente
- Volume único para persistência de dados
- Entrypoint customizado para configuração em runtime

## Estrutura de Diretórios

```
/opt/canvas/          # Diretório principal da aplicação
/opt/canvas/data/     # Volume de persistência
  ├── uploads/        # Arquivos enviados pelos usuários
  ├── tmp/            # Arquivos temporários
  └── log/            # Logs da aplicação
```

## Variáveis de Ambiente

### Banco de Dados (Obrigatório)

- `DB_ADAPTER`: Adapter do banco (padrão: `postgresql`)
- `DB_HOST`: Host do banco de dados (padrão: `localhost`)
- `DB_PORT`: Porta do banco de dados (padrão: `5432`)
- `DB_NAME`: Nome do banco de dados (padrão: `canvas_production`)
- `DB_QUEUE_NAME`: Nome do banco de dados de filas (padrão: `canvas_queue_production`)
- `DB_USER`: Usuário do banco de dados (padrão: `canvas`)
- `DB_PASSWORD`: Senha do banco de dados (**obrigatório**)

### Redis (Obrigatório)

- `REDIS_URL`: URL do Redis para jobs (padrão: `redis://localhost:6379/0`)
- `REDIS_CACHE_URL`: URL do Redis para cache (padrão: `redis://localhost:6379/1`)

### Segurança (Importante)

- `CANVAS_ENCRYPTION_KEY`: Chave de criptografia (gerada automaticamente se não fornecida)
- `CANVAS_SIGNING_SECRET`: Segredo de assinatura (gerado automaticamente se não fornecido)
- `CANVAS_LTI_ISS`: Issuer para LTI (padrão: `https://canvas.example.com`)

### Domínio

- `CANVAS_DOMAIN`: Domínio principal do Canvas (padrão: `localhost`)
- `CANVAS_SSL`: Usar SSL (padrão: `false`)
- `CANVAS_FILES_DOMAIN`: Domínio para arquivos (padrão: mesmo que `CANVAS_DOMAIN`)

### E-mail (SMTP)

- `SMTP_ADDRESS`: Servidor SMTP (padrão: `localhost`)
- `SMTP_PORT`: Porta SMTP (padrão: `25`)
- `SMTP_USERNAME`: Usuário SMTP (opcional)
- `SMTP_PASSWORD`: Senha SMTP (opcional)
- `SMTP_AUTH`: Tipo de autenticação (padrão: `plain`)
- `SMTP_STARTTLS`: Habilitar STARTTLS (padrão: `true`)
- `SMTP_DOMAIN`: Domínio do e-mail (padrão: `example.com`)
- `SMTP_FROM`: E-mail remetente (padrão: `canvas@example.com`)
- `SMTP_FROM_NAME`: Nome do remetente (padrão: `Canvas LMS`)

### Inicialização

- `RUN_MIGRATIONS`: Executar migrations ao iniciar (padrão: `false`)
- `COMPILE_ASSETS`: Compilar assets ao iniciar (padrão: `false`)

## Uso Básico

### 1. Build da Imagem

```bash
docker build -t canvas-lms:latest .
```

Para especificar uma versão do Canvas:

```bash
docker build --build-arg CANVAS_VERSION=stable -t canvas-lms:stable .
```

### 2. Preparar Banco de Dados

Certifique-se de ter PostgreSQL e Redis rodando:

```bash
docker run -d --name canvas-postgres \
  -e POSTGRES_USER=canvas \
  -e POSTGRES_PASSWORD=canvas_password \
  -e POSTGRES_DB=canvas_production \
  postgres:14

docker run -d --name canvas-redis redis:6-alpine
```

Criar banco de dados de filas:

```bash
docker exec canvas-postgres psql -U canvas -c "CREATE DATABASE canvas_queue_production;"
```

### 3. Executar Canvas

#### Primeira execução (com migrations e compilação de assets):

```bash
docker run -d --name canvas-lms \
  -p 3000:3000 \
  -v canvas-data:/opt/canvas/data \
  --link canvas-postgres:postgres \
  --link canvas-redis:redis \
  -e DB_HOST=postgres \
  -e DB_PASSWORD=canvas_password \
  -e REDIS_URL=redis://redis:6379/0 \
  -e REDIS_CACHE_URL=redis://redis:6379/1 \
  -e CANVAS_DOMAIN=localhost:3000 \
  -e RUN_MIGRATIONS=true \
  -e COMPILE_ASSETS=true \
  canvas-lms:latest
```

#### Execuções subsequentes:

```bash
docker run -d --name canvas-lms \
  -p 3000:3000 \
  -v canvas-data:/opt/canvas/data \
  --link canvas-postgres:postgres \
  --link canvas-redis:redis \
  -e DB_HOST=postgres \
  -e DB_PASSWORD=canvas_password \
  -e REDIS_URL=redis://redis:6379/0 \
  -e REDIS_CACHE_URL=redis://redis:6379/1 \
  -e CANVAS_DOMAIN=localhost:3000 \
  canvas-lms:latest
```

### 4. Executar Canvas Jobs (Background Jobs)

Canvas requer um processo separado para jobs em background:

```bash
docker run -d --name canvas-jobs \
  -v canvas-data:/opt/canvas/data \
  --link canvas-postgres:postgres \
  --link canvas-redis:redis \
  -e DB_HOST=postgres \
  -e DB_PASSWORD=canvas_password \
  -e REDIS_URL=redis://redis:6379/0 \
  canvas-lms:latest jobs:start
```

## Docker Compose

Exemplo de arquivo `docker-compose.yml`:

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:14
    environment:
      POSTGRES_USER: canvas
      POSTGRES_PASSWORD: canvas_password
      POSTGRES_DB: canvas_production
    volumes:
      - postgres-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U canvas"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:6-alpine
    volumes:
      - redis-data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  canvas:
    build: .
    ports:
      - "3000:3000"
    volumes:
      - canvas-data:/opt/canvas/data
    environment:
      DB_HOST: postgres
      DB_PASSWORD: canvas_password
      REDIS_URL: redis://redis:6379/0
      REDIS_CACHE_URL: redis://redis:6379/1
      CANVAS_DOMAIN: localhost:3000
      RUN_MIGRATIONS: "true"
      COMPILE_ASSETS: "true"
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy

  canvas-jobs:
    build: .
    command: jobs:start
    volumes:
      - canvas-data:/opt/canvas/data
    environment:
      DB_HOST: postgres
      DB_PASSWORD: canvas_password
      REDIS_URL: redis://redis:6379/0
    depends_on:
      - postgres
      - redis
      - canvas

volumes:
  postgres-data:
  redis-data:
  canvas-data:
```

Executar com Docker Compose:

```bash
docker-compose up -d
```

## Comandos Disponíveis

O entrypoint suporta vários comandos:

### Iniciar aplicação web:
```bash
docker run canvas-lms:latest app:start
```

### Iniciar jobs em background:
```bash
docker run canvas-lms:latest jobs:start
```

### Console Rails:
```bash
docker run -it canvas-lms:latest console
```

### Shell bash:
```bash
docker run -it canvas-lms:latest bash
```

## Acesso Inicial

Após iniciar o Canvas, acesse http://localhost:3000 e siga as instruções para criar a conta de administrador inicial.

## Requisitos Mínimos

- 8GB de RAM recomendado
- PostgreSQL 14+
- Redis 6.x+
- Espaço em disco adequado para uploads de usuários

## Notas de Segurança

- Sempre defina `CANVAS_ENCRYPTION_KEY` em produção
- Use senhas fortes para banco de dados
- Configure SSL/TLS em produção
- Faça backup regular do volume `/opt/canvas/data` e do banco de dados

## Troubleshooting

### Verificar logs:
```bash
docker logs canvas-lms
```

### Assets não carregam:
Execute com `COMPILE_ASSETS=true` na primeira execução.

### Migrations não executadas:
Execute com `RUN_MIGRATIONS=true` ou execute manualmente:
```bash
docker exec canvas-lms su -s /bin/bash canvas -c "cd /opt/canvas && bundle exec rake db:migrate"
```

## Licença

Canvas LMS é licenciado sob AGPL. Veja o repositório oficial para mais informações.

